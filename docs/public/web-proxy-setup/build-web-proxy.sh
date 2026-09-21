set -e

if [ -t 1 ]; then
    C_RESET='\033[0m'
    C_BOLD='\033[1m'
    C_STEP='\033[1;36m'
    C_OK='\033[1;32m'
    C_WARN='\033[1;33m'
    C_ERR='\033[1;31m'
    C_ASK='\033[1;35m'
    C_DIM='\033[2m'
else
    C_RESET=''; C_BOLD=''; C_STEP=''; C_OK=''; C_WARN=''; C_ERR=''; C_ASK=''; C_DIM=''
fi

step()    { printf "\n${C_STEP}== %s ==${C_RESET}\n" "$1"; }
ok()      { printf "${C_OK}✔ %s${C_RESET}\n" "$1"; }
warn()    { printf "${C_WARN}⚠ %s${C_RESET}\n" "$1"; }
err()     { printf "${C_ERR}✘ %s${C_RESET}\n" "$1" >&2; }
info()    { printf "${C_DIM}%s${C_RESET}\n" "$1"; }
ask()     { printf "${C_ASK}%s${C_RESET}" "$1"; }

MAIN_PY_URL="https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/web-proxy-setup/main.py"

WORKDIR="$HOME/web-proxy-build"
PROJECT_DIR="$WORKDIR/project"
mkdir -p "$WORKDIR" "$PROJECT_DIR" "$PROJECT_DIR/my-site"
cd "$WORKDIR"

step "Step 1/8: checking packages"

NEEDED_BINS="go:golang git:git openssl:openssl-tool cloudflared:cloudflared ssh:openssh termux-setup-storage:termux-api"
MISSING_PKGS=""
for pair in $NEEDED_BINS; do
    bin="${pair%%:*}"
    pkg="${pair##*:}"
    if ! command -v "$bin" >/dev/null 2>&1; then
        MISSING_PKGS="$MISSING_PKGS $pkg"
    fi
done

if [ -z "$MISSING_PKGS" ]; then
    ok "all required packages already installed, skipping pkg update/install"
else
    info "missing:$MISSING_PKGS -- updating package lists and installing"
    pkg update -y
    pkg install -y $MISSING_PKGS
    ok "packages installed"
fi

step "Step 2/8: building tproxy-server"
if [ -f "tproxy-server-linux" ]; then
    ok "already built, skipping (delete tproxy-server-linux to rebuild)"
else
    [ -d "tproxy-server" ] || git clone https://github.com/telegramdesktop/tproxy-server.git
    (cd tproxy-server && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -buildvcs=false \
        -o ../tproxy-server-linux ./cmd/tproxy-server)
    ok "tproxy-server built"
fi

step "Step 3/8: building mtg v1"
if [ -f "mtg-v1-linux" ]; then
    ok "already built, skipping (delete mtg-v1-linux to rebuild)"
else
    [ -d "mtg-v1" ] || git clone https://github.com/9seconds/mtg.git mtg-v1
    (cd mtg-v1 && git checkout v1.0.12 && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -buildvcs=false \
        -o ../mtg-v1-linux .)
    ok "mtg v1 built"
fi

step "Step 4/8: project settings"
info "these get written straight into your config files -- leave any"
info "answer blank to keep a placeholder and fill it in by hand later."
echo

ask "Your domain (e.g. your-domain.example.com): "
read -r INPUT_DOMAIN
DOMAIN="${INPUT_DOMAIN:-your-domain.example.com}"

echo
ask "Tunnel mode -- [1] Quick Tunnel (no domain needed) or [2] Named Tunnel (stable, needs your domain)? [1/2, default 1]: "
read -r INPUT_TUNNEL_MODE
if [ "$INPUT_TUNNEL_MODE" = "2" ]; then
    TUNNEL_MODE="named"
    QUICK_TUNNEL_VALUE="0"
    echo
    ask "  Cloudflare tunnel UUID (from 'cloudflared tunnel create'): "
    read -r INPUT_TUNNEL_UUID
    TUNNEL_UUID="${INPUT_TUNNEL_UUID:-YOUR-TUNNEL-UUID}"
else
    TUNNEL_MODE="quick"
    QUICK_TUNNEL_VALUE="1"
    TUNNEL_UUID=""
fi

echo
ask "MTG secret -- paste your own 32-hex value, or leave blank to generate one now: "
read -r INPUT_SECRET
if [ -n "$INPUT_SECRET" ]; then
    SECRET="$INPUT_SECRET"
else
    SECRET="$(openssl rand -hex 16)"
    info "generated: $SECRET"
fi

echo
while [ -z "$INPUT_MTG_IPV4" ]; do
    ask "MTG_PUBLIC_IPV4 -- your Katabump/Orihost container's IP:PORT (required): "
    read -r INPUT_MTG_IPV4
    if [ -z "$INPUT_MTG_IPV4" ]; then
        warn "this is required -- without it mtg usually can't be reached from Telegram."
    fi
done
MTG_IPV4="$INPUT_MTG_IPV4"

ok "settings collected"

step "Step 5/8: writing project files"

cat > "$PROJECT_DIR/config.json" << EOF
{
  "public_hostname": "$DOMAIN",
  "base_path": "",
  "listen": "127.0.0.1:8080",
  "admin_listen": "127.0.0.1:8081",
  "public_upstream": "http://127.0.0.1:3000",
  "token_key_file": "./token.key",
  "static_routes": "exact",
  "profiles_file": "./profiles.json",
  "enable_pprof": false,
  "limits": {
    "max_header_bytes": 16384,
    "max_body_bytes": 2097152,
    "max_frame_payload": 1048576,
    "carrier_batch_bytes": 2097152,
    "max_streams_per_session": 128,
    "max_closed_stream_ids": 4096,
    "max_pending_per_session": 33554432,
    "max_pending_global": 536870912,
    "max_pending_items_per_session": 16384,
    "max_pending_items_global": 262144,
    "max_sessions_per_ip": 0,
    "max_sessions_global": 128,
    "max_streams_global": 4096,
    "max_backend_dials_in_flight": 256,
    "new_sessions_per_minute": 600,
    "new_sessions_burst": 128,
    "new_streams_per_minute": 6000,
    "new_streams_burst": 512,
    "max_bootstraps_per_ip": 0,
    "max_bootstraps_global": 512,
    "new_bootstraps_per_minute": 1200,
    "new_bootstraps_burst": 256,
    "max_profiles": 32
  },
  "timeouts": {
    "backend_dial": "5s",
    "long_poll": "25s",
    "reconnect_grace": "2m",
    "bootstrap_lifetime": "2m",
    "read_header": "10s",
    "idle": "75s",
    "shutdown": "15s"
  }
}
EOF

cat > "$PROJECT_DIR/profiles.json" << EOF
{
  "profiles": [
    {
      "name": "primary",
      "secret": "$SECRET",
      "backend": "127.0.0.1:2398",
      "carrier_mode": "https"
    }
  ]
}
EOF

if [ "$TUNNEL_MODE" = "named" ]; then
    cat > "$PROJECT_DIR/cf-config.yml" << EOF
tunnel: tproxy
credentials-file: ./$TUNNEL_UUID.json

ingress:
  - hostname: $DOMAIN
    service: http://localhost:8080
    originRequest:
      httpHostHeader: $DOMAIN
  - service: http_status:404
EOF
    ok "config.json, profiles.json, cf-config.yml written"
else
    rm -f "$PROJECT_DIR/cf-config.yml"
    ok "config.json, profiles.json written (cf-config.yml skipped, not needed for Quick Tunnel)"
fi

cat > "$PROJECT_DIR/my-site/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Daily Bulletin</title>
<style>
  :root {
    --ink: #1a1a1a;
    --muted: #6b6b6b;
    --line: #e5e5e5;
    --accent: #b3261e;
  }
  * { box-sizing: border-box; }
  body {
    margin: 0;
    font-family: Georgia, "Times New Roman", serif;
    color: var(--ink);
    background: #fff;
  }
  header {
    border-bottom: 3px solid var(--ink);
    padding: 18px 24px 14px;
    text-align: center;
  }
  .masthead {
    font-family: "Helvetica Neue", Arial, sans-serif;
    font-size: 2.1rem;
    font-weight: 800;
    letter-spacing: -0.5px;
    text-transform: uppercase;
  }
  .dateline {
    font-family: "Helvetica Neue", Arial, sans-serif;
    font-size: 0.75rem;
    color: var(--muted);
    text-transform: uppercase;
    letter-spacing: 1px;
    margin-top: 4px;
  }
  nav {
    display: flex;
    justify-content: center;
    gap: 22px;
    padding: 10px 0;
    border-bottom: 1px solid var(--line);
    font-family: "Helvetica Neue", Arial, sans-serif;
    font-size: 0.8rem;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }
  nav a { color: var(--ink); text-decoration: none; }
  nav a:hover { color: var(--accent); }
  main {
    max-width: 920px;
    margin: 0 auto;
    padding: 28px 24px 60px;
  }
  .lead {
    border-bottom: 1px solid var(--line);
    padding-bottom: 26px;
    margin-bottom: 26px;
  }
  .lead h1 {
    font-size: 1.9rem;
    line-height: 1.15;
    margin: 0 0 10px;
  }
  .lead .kicker {
    font-family: "Helvetica Neue", Arial, sans-serif;
    color: var(--accent);
    font-size: 0.75rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1px;
    margin-bottom: 6px;
  }
  .lead p {
    font-size: 1.05rem;
    line-height: 1.65;
    color: #333;
  }
  .byline {
    font-family: "Helvetica Neue", Arial, sans-serif;
    font-size: 0.78rem;
    color: var(--muted);
    margin-top: 10px;
  }
  .grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 28px;
  }
  .card h2 {
    font-size: 1.1rem;
    line-height: 1.3;
    margin: 0 0 8px;
  }
  .card .kicker {
    font-family: "Helvetica Neue", Arial, sans-serif;
    color: var(--muted);
    font-size: 0.7rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.6px;
    margin-bottom: 6px;
  }
  .card p {
    font-size: 0.92rem;
    line-height: 1.55;
    color: #444;
  }
  footer {
    border-top: 1px solid var(--line);
    margin-top: 40px;
    padding: 18px 24px;
    text-align: center;
    font-family: "Helvetica Neue", Arial, sans-serif;
    font-size: 0.72rem;
    color: var(--muted);
  }
  @media (max-width: 700px) {
    .grid { grid-template-columns: 1fr; }
  }
</style>
</head>
<body>
<header>
  <div class="masthead">Daily Bulletin</div>
  <div class="dateline" id="dateline"></div>
</header>
<nav>
  <a href="#">Home</a>
  <a href="#">World</a>
  <a href="#">Business</a>
  <a href="#">Technology</a>
  <a href="#">Culture</a>
  <a href="#">Opinion</a>
</nav>
<main>
  <article class="lead">
    <div class="kicker">Top Story</div>
    <h1>Local council approves new transit funding plan for coming fiscal year</h1>
    <p>
      City officials voted late Thursday to move forward with a revised transit
      budget, allocating additional resources toward route expansion and
      infrastructure maintenance. Supporters say the plan addresses long-standing
      service gaps in outlying districts, while critics have raised questions
      about the timeline for implementation.
    </p>
    <div class="byline">Staff Report · Updated this week</div>
  </article>

  <div class="grid">
    <div class="card">
      <div class="kicker">Business</div>
      <h2>Small manufacturers report steady demand heading into next quarter</h2>
      <p>Industry surveys point to modest but consistent order growth across
      several regional supply chains, even as input costs remain a concern
      for smaller operators.</p>
    </div>
    <div class="card">
      <div class="kicker">Technology</div>
      <h2>Researchers outline efficiency gains in updated networking standard</h2>
      <p>A working group published benchmark results this week showing
      meaningful improvements in throughput under common real-world
      conditions.</p>
    </div>
    <div class="card">
      <div class="kicker">Culture</div>
      <h2>Community archive project digitizes decades of local photographs</h2>
      <p>Volunteers have catalogued thousands of images from the past
      half-century, with plans to make the collection publicly searchable
      later this year.</p>
    </div>
    <div class="card">
      <div class="kicker">World</div>
      <h2>Trade delegation concludes multi-day talks on shipping standards</h2>
      <p>Negotiators described the session as productive, with a follow-up
      meeting expected before the end of the year.</p>
    </div>
    <div class="card">
      <div class="kicker">Opinion</div>
      <h2>Why smaller civic institutions deserve more sustained attention</h2>
      <p>A columnist argues that local governance often shapes daily life
      more directly than national politics, yet receives a fraction of the
      coverage.</p>
    </div>
    <div class="card">
      <div class="kicker">Technology</div>
      <h2>Guide: keeping software dependencies up to date without breaking builds</h2>
      <p>A practical rundown of strategies teams use to stay current while
      minimizing disruption to ongoing development work.</p>
    </div>
  </div>
</main>
<footer>
  &copy; <span id="year"></span> Daily Bulletin. All rights reserved.
</footer>
<script>
  document.getElementById("year").textContent = new Date().getFullYear();
  document.getElementById("dateline").textContent = new Date().toLocaleDateString(
    "en-US", { weekday: "long", year: "numeric", month: "long", day: "numeric" }
  );
</script>
</body>
</html>
EOF

warn "main.py is NOT written by this script (it changes often during troubleshooting)."
info "  it's fetched fresh in the next step from MAIN_PY_URL."

step "Step 6/8: downloading main.py"
if curl -fsSL -o "$PROJECT_DIR/main.py" "$MAIN_PY_URL"; then
    ok "downloaded main.py from: $MAIN_PY_URL"

    QT_LINE='QUICK_TUNNEL = os.environ.get("QUICK_TUNNEL", "0") == "1"'
    if grep -qF "$QT_LINE" "$PROJECT_DIR/main.py"; then
        if [ "$TUNNEL_MODE" = "quick" ]; then
            QT_HARDCODED='QUICK_TUNNEL = True  # hardcoded by build script: quick tunnel selected'
        else
            QT_HARDCODED='QUICK_TUNNEL = False  # hardcoded by build script: named tunnel selected'
        fi
        awk -v old="$QT_LINE" -v new="$QT_HARDCODED" \
            '{ if ($0 == old) print new; else print }' \
            "$PROJECT_DIR/main.py" > "$PROJECT_DIR/main.py.tmp" \
            && mv "$PROJECT_DIR/main.py.tmp" "$PROJECT_DIR/main.py"
        ok "QUICK_TUNNEL hardcoded to $([ "$TUNNEL_MODE" = "quick" ] && echo True || echo False) in main.py"
    else
        warn "could not find the expected QUICK_TUNNEL line in main.py -- it may"
        warn "have changed upstream. main.py was left as downloaded: you'll need"
        warn "to set QUICK_TUNNEL=$QUICK_TUNNEL_VALUE as a panel env var / in the start command instead."
    fi
else
    err "could not download main.py from $MAIN_PY_URL"
    warn "edit MAIN_PY_URL at the top of this script, or copy main.py into"
    warn "$PROJECT_DIR manually before uploading."
fi

step "Step 7/8: copying binaries into the project folder"
cp tproxy-server-linux "$PROJECT_DIR/"
cp mtg-v1-linux "$PROJECT_DIR/"
ok "binaries copied"

step "Step 8/8: upload"
echo
ask "Do you have SFTP/SSH access to Katabump and want to upload now? [y/N] "
read -r HAS_SFTP

if [[ "$HAS_SFTP" =~ ^[Yy]$ ]]; then
    ask "  SFTP address (paste it as shown on the panel, e.g. sftp://user.katabump.fr:2022 or sftp://user@de-01.orihost.com:2022): "
    read -r RAW_ADDR
    RAW_ADDR="${RAW_ADDR#sftp://}"
    if [[ "$RAW_ADDR" == *"@"* ]]; then
        PARSED_USER="${RAW_ADDR%%@*}"
        RAW_ADDR="${RAW_ADDR#*@}"
    else
        PARSED_USER=""
    fi
    KATABUMP_HOST="${RAW_ADDR%%:*}"
    if [[ "$RAW_ADDR" == *":"* ]]; then
        KATABUMP_PORT="${RAW_ADDR##*:}"
    else
        KATABUMP_PORT="2022"
    fi

    if [ -n "$PARSED_USER" ]; then
        KATABUMP_USER="$PARSED_USER"
        info "  username from address: $KATABUMP_USER"
    else
        ask "  Username (e.g. dj7e9f6afve6ac3o5831c8j8): "; read -r KATABUMP_USER
    fi

    ask "  Remote directory [/]: "; read -r KATABUMP_REMOTE_DIR
    KATABUMP_REMOTE_DIR="${KATABUMP_REMOTE_DIR:-/}"

    if [ -z "$KATABUMP_HOST" ] || [ -z "$KATABUMP_USER" ]; then
        warn "host or username left empty, skipping upload."
    else
        # Wings' SFTP server only supports the SFTP subsystem, not exec, so scp
        # can never work here ("exec request failed on channel 0"); we drive
        # sftp directly instead. No "-b batchfile" (forces BatchMode=yes, which
        # blocks the password prompt); no "put -r" (its setstat call fails on
        # Wings and aborts mid-directory); no "cd" (a silent failure would
        # misdirect every later relative path) -- every path below is absolute.
        SFTP_BATCH_FILE="$WORKDIR/sftp-batch.txt"
        REMOTE_BASE="${KATABUMP_REMOTE_DIR%/}"
        {
            echo "-mkdir $KATABUMP_REMOTE_DIR"
            echo "lcd $PROJECT_DIR"
            find "$PROJECT_DIR" -mindepth 1 -type d | sed "s#^$PROJECT_DIR/##" | sort \
                | while IFS= read -r d; do echo "-mkdir $REMOTE_BASE/$d"; done
            find "$PROJECT_DIR" -mindepth 1 -type f | sed "s#^$PROJECT_DIR/##" | sort \
                | while IFS= read -r f; do echo "put $f $REMOTE_BASE/$f"; done
        } > "$SFTP_BATCH_FILE"

        SFTP_LOG="$WORKDIR/sftp-upload.log"
        info "uploading $PROJECT_DIR to $KATABUMP_USER@$KATABUMP_HOST:$KATABUMP_REMOTE_DIR (port $KATABUMP_PORT) ..."
        info "you'll be asked for your panel password next."
        sftp -P "$KATABUMP_PORT" "$KATABUMP_USER@$KATABUMP_HOST" \
            < "$SFTP_BATCH_FILE" 2>&1 | tee "$SFTP_LOG"
        SFTP_EXIT="${PIPESTATUS[0]}"

        if [ "$SFTP_EXIT" -eq 0 ] && ! grep -qiE \
            "permission denied|no such file|not a directory|failure|connection (refused|closed)" \
            "$SFTP_LOG"; then
            ok "upload finished."
        else
            err "upload failed -- check host/port/username/password, review the"
            warn "log above, and try again, or upload the Downloads copy by hand"
            warn "(see below)."
        fi
    fi
else
    info "skipping auto-upload."
fi

step "Saving a copy to your phone's Downloads folder"

if [ ! -d "$HOME/storage/downloads" ]; then
    warn "storage access isn't set up yet. Running termux-setup-storage --"
    warn "please tap Allow on the permission prompt, then re-run this script."
    termux-setup-storage
    exit 0
fi

SUMMARY_FILE="$PROJECT_DIR/SETTINGS-SUMMARY.txt"
{
    printf "%-22s %-38s %s\n" "SETTING" "VALUE" "WRITTEN TO"
    printf "%-22s %-38s %s\n" "----------------------" "--------------------------------------" "------------------------------"
    printf "%-22s %-38s %s\n" "Domain" "$DOMAIN" "config.json"
    printf "%-22s %-38s %s\n" "Tunnel mode" "$TUNNEL_MODE" "-"
    if [ "$TUNNEL_MODE" = "named" ]; then
        printf "%-22s %-38s %s\n" "Tunnel UUID" "$TUNNEL_UUID" "cf-config.yml"
        printf "%-22s %-38s %s\n" "Hostname (tunnel)" "$DOMAIN" "cf-config.yml"
    fi
    printf "%-22s %-38s %s\n" "MTG secret" "$SECRET" "profiles.json"
    printf "%-22s %-38s %s\n" "MTG_PUBLIC_IPV4" "$MTG_IPV4" "panel env var"
    printf "%-22s %-38s %s\n" "QUICK_TUNNEL" "$QUICK_TUNNEL_VALUE" "hardcoded in main.py"
} > "$SUMMARY_FILE"

DEST="$HOME/storage/downloads/web-proxy-project"
rm -rf "$DEST"
cp -r "$PROJECT_DIR" "$DEST"

echo
printf "${C_OK}${C_BOLD}================================================================${C_RESET}\n"
printf "${C_OK}${C_BOLD}Done.${C_RESET} Your project folder is saved in your phone's Downloads app\n"
echo "at:"
printf "  ${C_BOLD}Download/web-proxy-project/${C_RESET}\n"
echo
step "Double-check these before you upload/run"
cat "$SUMMARY_FILE"
info "(also saved as SETTINGS-SUMMARY.txt inside the project folder)"
echo
echo "Set this as an environment variable in the Katabump panel, then start with:"
printf "  ${C_BOLD}python /home/container/main.py${C_RESET}\n"
printf "${C_OK}${C_BOLD}================================================================${C_RESET}\n"
