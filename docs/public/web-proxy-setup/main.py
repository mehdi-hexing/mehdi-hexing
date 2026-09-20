"""
Startup wrapper for running cloudflared + tproxy-server on a host that only
lets you run a Python (or Node.js) process, such as a Pterodactyl-style
free game-hosting panel (e.g. Katabump).
It expects the following files to already be uploaded next to this script:
    cloudflared            - cloudflared binary (linux/amd64), chmod +x
    tproxy-server-linux    - compiled tproxy-server binary (linux/amd64)
    config.json            - tproxy-server process config
    profiles.json          - tproxy-server secret/profile config
    my-site/                - decoy static site, served on 127.0.0.1:3000
Named tunnel mode (default) additionally needs:
    cf-config.yml          - cloudflared tunnel config (ingress rules)
    <TUNNEL-UUID>.json     - cloudflared tunnel credentials file
                             (referenced from cf-config.yml)
Quick tunnel mode (set QUICK_TUNNEL=1 in the environment / startup command)
does not need cf-config.yml or a credentials file. It gets a random
*.trycloudflare.com hostname from cloudflared on every restart, and this
script automatically updates config.json's "public_hostname" to match.
In both tunnel modes, this script writes the current proxy link to
status.html next to itself and prints it to the console (once when the
hostname is known, and again once every process is up).
Usage (as the panel's "Startup Command"):
    python3 main.py
    QUICK_TUNNEL=1 python3 main.py
"""
import json
import os
import queue
import re
import subprocess
import sys
import threading
import time

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

CLOUDFLARED_BIN = os.path.join(BASE_DIR, "cloudflared")
TPROXY_BIN = os.path.join(BASE_DIR, "tproxy-server-linux")
MTG_BIN = os.path.join(BASE_DIR, "mtg-v1-linux")
CF_CONFIG = os.path.join(BASE_DIR, "cf-config.yml")
TPROXY_CONFIG = os.path.join(BASE_DIR, "config.json")
PROFILES_FILE = os.path.join(BASE_DIR, "profiles.json")
TOKEN_KEY_FILE = os.path.join(BASE_DIR, "token.key")
STATUS_FILE = os.path.join(BASE_DIR, "status.html")
SITE_DIR = os.path.join(BASE_DIR, "my-site")
SITE_PORT = 3000  # must match "public_upstream" in config.json
# Set QUICK_TUNNEL=1 in the panel's startup command / environment to use a
# throwaway *.trycloudflare.com tunnel instead of the named tunnel in
# cf-config.yml. The hostname changes every restart, so this mode
# auto-detects it and rewrites config.json + status.html each time.
QUICK_TUNNEL = os.environ.get("QUICK_TUNNEL", "0") == "1"
QUICK_TUNNEL_URL_RE = re.compile(r"https://([a-zA-Z0-9.-]+\.trycloudflare\.com)")

# mtg v1 tries to auto-detect the host's public IPv4 address on startup
# (it needs this to talk to Telegram's own middle proxies, not just to
# print links). On a NATed / containerized host - like a Pterodactyl-style
# panel such as Katabump, which gives no real public interface to bind to -
# that auto-detection has nothing to find and mtg aborts with
# "fatal error: cannot resolve any public address". Setting this env var to
# the container's actual outbound public IPv4 (e.g. the IP shown in the
# panel's network/allocation tab, or the result of `curl -4 ifconfig.me`
# run from a shell on the same host) works around it by passing mtg's
# `-4/--public-ipv4` flag explicitly instead of relying on auto-detection.
MTG_PUBLIC_IPV4 = os.environ.get("MTG_PUBLIC_IPV4", "").strip()


def lock_down_permissions() -> None:
    """tproxy-server refuses to start if profiles.json (or an existing
    token.key) is readable/writable by group or others. Panels like
    Katabump often upload files with permissive default perms (644/666)
    and give no shell access to fix this manually, so we fix it here in
    Python instead, which only needs filesystem access we already have."""
    for path in (PROFILES_FILE, TOKEN_KEY_FILE):
        if os.path.isfile(path):
            os.chmod(path, 0o600)
            print(f"[main] set permissions 600 on {path}")


def ensure_token_key() -> None:
    """token_key_file must exist as a persistent 32-byte signing key before
    the relay starts; tproxy-server does not create it itself on a cold
    start. Generate it once and never overwrite it on later runs, since it
    must stay unchanged across restarts."""
    if os.path.isfile(TOKEN_KEY_FILE):
        return
    print(f"[main] {TOKEN_KEY_FILE} missing, generating a new 32-byte key...")
    key_bytes = os.urandom(32)
    fd = os.open(TOKEN_KEY_FILE, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    try:
        os.write(fd, key_bytes)
    finally:
        os.close(fd)
    print(f"[main] created {TOKEN_KEY_FILE} with permissions 600")


def ensure_executable(path: str) -> None:
    if not os.path.isfile(path):
        print(f"[main] ERROR: expected file not found: {path}", file=sys.stderr)
        sys.exit(1)
    os.chmod(path, 0o755)


def stream_output(proc: subprocess.Popen, name: str) -> None:
    assert proc.stdout is not None
    for raw_line in proc.stdout:
        line = raw_line.decode(errors="replace").rstrip()
        print(f"[{name}] {line}")


def stream_and_capture_url(proc: subprocess.Popen, name: str, url_queue: "queue.Queue[str]") -> None:
    """Like stream_output, but also watches for the *.trycloudflare.com URL
    cloudflared prints once in quick-tunnel mode and pushes it to a queue
    the first time it appears."""
    assert proc.stdout is not None
    found = False
    for raw_line in proc.stdout:
        line = raw_line.decode(errors="replace").rstrip()
        print(f"[{name}] {line}")
        if not found:
            m = QUICK_TUNNEL_URL_RE.search(line)
            if m:
                found = True
                url_queue.put(m.group(1))


def read_first_secret() -> str:
    with open(PROFILES_FILE) as f:
        data = json.load(f)
    return data["profiles"][0]["secret"]


def update_public_hostname(hostname: str) -> None:
    """Quick tunnels get a brand new hostname every restart. tproxy-server
    checks incoming requests against config.json's public_hostname, so it
    must be kept in sync or the relay will reject otherwise-valid traffic."""
    with open(TPROXY_CONFIG) as f:
        cfg = json.load(f)
    cfg["public_hostname"] = hostname
    with open(TPROXY_CONFIG, "w") as f:
        json.dump(cfg, f, indent=2)
    print(f"[main] updated config.json public_hostname -> {hostname}")


def write_status_page(hostname: str) -> None:
    secret = read_first_secret()
    link = f"https://t.me/webproxy?server={hostname}&secret={secret}"
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S UTC", time.gmtime())
    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Proxy status</title>
<style>
  body {{
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    max-width: 560px;
    margin: 90px auto;
    padding: 0 24px;
    color: #1a1a1a;
    line-height: 1.6;
  }}
  h1 {{ font-size: 1.3rem; font-weight: 600; margin-bottom: 4px; }}
  .meta {{ color: #767676; font-size: 0.85rem; margin-bottom: 28px; }}
  .link-box {{
    background: #f5f5f7;
    border: 1px solid #e2e2e5;
    border-radius: 10px;
    padding: 16px 18px;
    word-break: break-all;
    font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
    font-size: 0.88rem;
  }}
  a {{ color: #2b7de9; text-decoration: none; }}
  a:hover {{ text-decoration: underline; }}
  .btn {{
    display: inline-block;
    margin-top: 18px;
    padding: 10px 18px;
    background: #2b7de9;
    color: #fff;
    border-radius: 8px;
    font-size: 0.9rem;
  }}
</style>
</head>
<body>
  <h1>Current proxy link</h1>
  <div class="meta">Last updated: {timestamp}</div>
  <div class="link-box"><a href="{link}">{link}</a></div>
  <a class="btn" href="{link}">Open in Telegram</a>
</body>
</html>
"""
    with open(STATUS_FILE, "w") as f:
        f.write(html)
    print(f"[main] status page written to {STATUS_FILE}")
    print(f"[main] PROXY LINK: {link}")


def run_local_diagnostic() -> None:
    """Runs a few seconds after tproxy-server starts. Sends a bridge-style
    request straight to tproxy's local public listener (127.0.0.1:8080),
    bypassing Cloudflare entirely. Comparing this result to what real
    Telegram traffic gets (served the decoy site, per the logs) tells us
    whether the problem is inside our own setup or specifically caused by
    routing through Cloudflare's edge (which always terminates TLS itself,
    per the project's "no CDN in front" warning)."""
    time.sleep(4)
    try:
        with open(TPROXY_CONFIG) as f:
            hostname = json.load(f).get("public_hostname", "")
        import http.client

        conn = http.client.HTTPConnection("127.0.0.1", 8080, timeout=8)
        conn.request(
            "GET",
            "/?bridge=diagnostic-test-token",
            headers={"Host": hostname},
        )
        resp = conn.getresponse()
        body = resp.read(300)
        print(f"[diag] local bridge probe -> status={resp.status} host={hostname}")
        print(f"[diag] response headers: {dict(resp.getheaders())}")
        print(f"[diag] body preview: {body[:200]!r}")
        conn.close()
    except Exception as e:
        print(f"[diag] local bridge probe failed: {e!r}")


def main() -> None:
    ensure_executable(CLOUDFLARED_BIN)
    ensure_executable(TPROXY_BIN)
    ensure_executable(MTG_BIN)
    ensure_token_key()
    lock_down_permissions()

    if not QUICK_TUNNEL and not os.path.isfile(CF_CONFIG):
        print(f"[main] ERROR: missing {CF_CONFIG}", file=sys.stderr)
        sys.exit(1)
    if not os.path.isfile(TPROXY_CONFIG):
        print(f"[main] ERROR: missing {TPROXY_CONFIG}", file=sys.stderr)
        sys.exit(1)
    if not os.path.isdir(SITE_DIR):
        print(f"[main] ERROR: missing site directory: {SITE_DIR}", file=sys.stderr)
        sys.exit(1)

    print(f"[main] starting decoy site server on 127.0.0.1:{SITE_PORT}...")
    site_server_code = (
        "import http.server as hs\n"
        "class H(hs.SimpleHTTPRequestHandler):\n"
        "    def do_GET(self):\n"
        "        print(f'[site-debug] Host header received: {self.headers.get(\"Host\")!r}', flush=True)\n"
        "        super().do_GET()\n"
        "hs.test(HandlerClass=H, port=" + str(SITE_PORT) + ", bind='127.0.0.1')\n"
    )
    site_proc = subprocess.Popen(
        [sys.executable, "-c", site_server_code],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        cwd=SITE_DIR,
    )

    if QUICK_TUNNEL:
        print("[main] starting cloudflared in QUICK TUNNEL mode...")
        cloudflared_proc = subprocess.Popen(
            [CLOUDFLARED_BIN, "tunnel", "--url", "http://localhost:8080"],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            cwd=BASE_DIR,
        )
        url_queue: "queue.Queue[str]" = queue.Queue()
        threading.Thread(
            target=stream_and_capture_url,
            args=(cloudflared_proc, "cloudflared", url_queue),
            daemon=True,
        ).start()

        print("[main] waiting for cloudflared to publish a quick tunnel URL...")
        try:
            hostname = url_queue.get(timeout=30)
        except queue.Empty:
            print("[main] ERROR: no trycloudflare.com URL seen within 30s", file=sys.stderr)
            cloudflared_proc.terminate()
            site_proc.terminate()
            sys.exit(1)

        print(f"[main] quick tunnel hostname: {hostname}")
        update_public_hostname(hostname)
    else:
        print("[main] starting cloudflared tunnel (named tunnel)...")
        cloudflared_proc = subprocess.Popen(
            [CLOUDFLARED_BIN, "tunnel", "--config", CF_CONFIG, "run"],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            cwd=BASE_DIR,
        )
        threading.Thread(
            target=stream_output, args=(cloudflared_proc, "cloudflared"), daemon=True
        ).start()

        with open(TPROXY_CONFIG) as f:
            hostname = json.load(f).get("public_hostname", "")

    # Written and printed here regardless of tunnel mode -- previously this
    # only ran for Quick Tunnel, so Named Tunnel setups never got a link.
    write_status_page(hostname)

    # Give cloudflared and the site server a moment to come up before the
    # relay starts accepting local traffic and proxying to them.
    time.sleep(2)

    print("[main] starting mtg v1 (MTProxy backend) on 127.0.0.1:2398...")
    mtg_secret = read_first_secret()
    mtg_args = [MTG_BIN, "run", "-b", "127.0.0.1:2398"]
    if MTG_PUBLIC_IPV4:
        print(f"[main] using explicit mtg public IPv4: {MTG_PUBLIC_IPV4}")
        mtg_args += ["-4", MTG_PUBLIC_IPV4]
    else:
        print(
            "[main] WARNING: MTG_PUBLIC_IPV4 is not set. mtg will try to "
            "auto-detect its public IP, which fails on most containerized "
            "panels (e.g. 'fatal error: cannot resolve any public "
            "address'). Set MTG_PUBLIC_IPV4=<your container's public "
            "outbound IPv4> in the panel's startup environment if mtg "
            "exits immediately below.",
            file=sys.stderr,
        )
    mtg_args.append(mtg_secret)
    mtg_proc = subprocess.Popen(
        mtg_args,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        cwd=BASE_DIR,
    )
    threading.Thread(
        target=stream_output, args=(mtg_proc, "mtg"), daemon=True
    ).start()

    # Give mtg a moment to bind its listener before tproxy-server starts
    # dialing 127.0.0.1:2398 as its backend.
    time.sleep(2)

    print("[main] starting tproxy-server relay...")
    tproxy_proc = subprocess.Popen(
        [TPROXY_BIN, "--config", TPROXY_CONFIG],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        cwd=BASE_DIR,
    )

    threading.Thread(
        target=stream_output, args=(site_proc, "site"), daemon=True
    ).start()
    threading.Thread(
        target=stream_output, args=(tproxy_proc, "tproxy"), daemon=True
    ).start()
    threading.Thread(target=run_local_diagnostic, daemon=True).start()

    procs = {
        "site": site_proc,
        "cloudflared": cloudflared_proc,
        "mtg": mtg_proc,
        "tproxy": tproxy_proc,
    }

    proxy_link = f"https://t.me/webproxy?server={hostname}&secret={mtg_secret}"
    print("=" * 64)
    print(f"[main] all processes started. PROXY LINK: {proxy_link}")
    print("=" * 64)

    try:
        # Exit when any process dies, and take the others down with it so
        # the panel can restart the whole thing cleanly.
        while True:
            dead = {name: p.poll() for name, p in procs.items() if p.poll() is not None}
            if dead:
                for name, code in dead.items():
                    print(f"[main] {name} exited with code {code}")
                break
            time.sleep(1)
    except KeyboardInterrupt:
        print("[main] received interrupt, shutting down...")
    finally:
        for name, proc in procs.items():
            if proc.poll() is None:
                print(f"[main] terminating {name}...")
                proc.terminate()
                try:
                    proc.wait(timeout=10)
                except subprocess.TimeoutExpired:
                    proc.kill()


if __name__ == "__main__":
    main()
