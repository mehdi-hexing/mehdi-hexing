---
title: HTTP-PROXY — Automated Free Proxy Archive (HTTP/HTTPS/SOCKS4/SOCKS5)
description: Documentation for the HTTP-PROXY repository — a GitHub Actions workflow that collects, tests, and categorizes free public proxies by country/fraud score every 6 hours, along with ready-made subscription configs
---

# HTTP-PROXY

## What is this project?

A repo that, **fully automatically** (no server at all, just GitHub Actions), every 6 hours:

1. Fetches raw proxy lists from **8+ public sources** (proxyscrape, TheSpeedX, monosans, ShiftyTR, iplocate, proxifly, etc.)
1. Actually tests each proxy's connectivity
1. Gets the country and **fraud score** for every proxy that's alive
1. Saves the results split by protocol and country, both as txt and CSV, and commits them into the same repo
1. Also generates several ready-made subscription config formats (for MahsaNG, V2rayNG, Exclave) along with QR codes

## Scan it and use it right now 📱

Each of these QR codes always stays in sync with the latest scan (every 6 hours) — they load directly from the repo itself, so they're always up to date:

<div align="center">

| **MahsaNG**<br>HTTP | **V2rayNG**<br>HTTP | **Exclave**<br>HTTP |
| :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/mahsang_http_qr.png" width="220" alt="MahsaNG HTTP QR code"/> | <img src="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/v2rayng_http_qr.png" width="220" alt="V2rayNG HTTP QR code"/> | <img src="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_http_qr.png" width="220" alt="Exclave HTTP QR code"/> |

| **Exclave**<br>HTTPS | **Exclave**<br>SOCKS4 | **V2rayNG**<br>SOCKS5 | **Exclave**<br>SOCKS5 |
| :---: | :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_https_qr.png" width="220" alt="Exclave HTTPS QR code"/> | <img src="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_socks4_qr.png" width="220" alt="Exclave SOCKS4 QR code"/> | <img src="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/v2rayng_socks5_qr.png" width="220" alt="V2rayNG SOCKS5 QR code"/> | <img src="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_socks5_qr.png" width="220" alt="Exclave SOCKS5 QR code"/> |

</div>

Whichever client you use, scan its matching QR code with the in-app scanner — the subscription link gets added automatically. If you'd rather copy the link manually, the full table with raw links is further down, in the "Subscription links" section.

This project connects to the [Cloudflare-Scamalytics](https://github.com/mehdi-hexing/Cloudflare-Scamalytics) project for its fraud score, like this:
if the Pages version doesn't respond, it switches to the Workers version; if neither responds, default metadata (`Unknown`/`N/A`) gets recorded for that proxy — the proxy itself isn't dropped from the list, just its country/risk columns stay empty.

## How it works (automatic, every 6 hours)

A GitHub Actions workflow (`Scan_Proxies.yml`) runs automatically on a schedule and kicks off the scan:

1. Fetches the raw list for each protocol from the sources above and merges it with the previous local pool (`Raw_Sources/raw_<protocol>.txt`) (at most 300,000 entries are kept)
1. Tests every proxy with up to **50 concurrent threads**:

- For `http`/`https`: one request to `clients3.google.com/generate_204`, then a separate **cross-check** against `api.ipify.org` — if the cross-check fails, the proxy is discarded as a likely single-purpose relay (possible false positive)
- For `socks4`/`socks5`: one request to `gstatic.com/generate_204` (requires the `requests[socks]`/PySocks library)

1. Live proxies are sorted by (country, fraud score) and saved in the following formats:

- `proxies/protocol/<protocol>/all.txt` and `all.csv` (global list)
- `proxies/countries/<protocol>/<CC>.txt` and `<CC>.csv` (split by country code; unknown countries go in `UNKNOWN`)

1. Subscription files (`proxies/subscriptions/`) and their QR codes are generated, and the table inside `README.md` between the two `SUBSCRIPTION_TABLE_START/END` comments is automatically updated.
1. Changes are committed and pushed under the `github-actions[bot]` user.

## CSV file columns

| Column | Description |
| --- | --- |
| Proxy | `ip:port` address |
| Protocol | HTTP/HTTPS/SOCKS4/SOCKS5 |
| Country / Country Code / Flag | From Cloudflare-Scamalytics metadata |
| Fraud Score / Risk | Fraud score and risk level |
| VPN | Whether this IP is known as a VPN |
| ISP | Internet service provider |
| Latency (ms) | Response time at the moment of testing |

## Psiphon compatibility

Verified proxies can also be used in Psiphon:

1. Open Psiphon
2. **Options → More Options**
3. Check **Upstream Proxy**
4. Enter one of the live proxies and ports from the list

## Live lists

### Global list (per protocol)

```
proxies/protocol/{http,https,socks4,socks5}/all.txt
proxies/protocol/{http,https,socks4,socks5}/all.csv
```

### List by country

```
proxies/countries/{http,https,socks4,socks5}/{CC}.txt
proxies/countries/{http,https,socks4,socks5}/{CC}.csv
```

### Subscription links (for direct import in a client)

The QR codes for these links are at the top of this page; here are just the raw links for manual copying:

| Client | Protocol | Raw link (copyable) |
| --- | --- | --- |
| **MahsaNG** | HTTP | `https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/mahsang_http.txt` |
| **V2rayNG** | HTTP | `https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/v2rayng_http.txt` |
| **Exclave** | HTTP | `https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_http.txt` |
| **Exclave** | HTTPS | `https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_https.txt` |
| **Exclave** | SOCKS4 | `https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_socks4.txt` |
| **V2rayNG** | SOCKS5 | `https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/v2rayng_socks5.txt` |
| **Exclave** | SOCKS5 | `https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_socks5.txt` |

## Running it locally (optional)

```bash
pip install -r requirements.txt   # requests[socks] and qrcode[pil]
python Scanner.py
```

- If `requests[socks]` isn't installed, socks4/socks5 proxies are rejected with the reason `missing_pysocks_dependency` (not a crash of the whole script)
- If `qrcode` isn't installed, only QR code generation is disabled; the rest of the scan continues

## Important notes

- **This project has no live service/API** — it's just an automated archive of static files that refreshes every 6 hours.
- Per the script's own warning: free public proxies can die within minutes of being verified; always use the freshest scan, and in the CSV prefer lower values in the **Latency** column.
- On the note above: you can actually use Balancer configs — called "Policy Group" in V2rayNG clients, and just "Balancer" in Exclave — once you've entered your subscription link and the configs have loaded, to have those same configs sorted by lowest URL-Test ping, and use them in Psiphon that way. My own recommendation is to use Exclave's Balancer.

## Troubleshooting

- **A proxy that's in the CSV doesn't work:** normal; free proxies have a short lifespan. Wait for the next scan (at most 6 hours away)
- **Country/Fraud Score columns are empty or `Unknown`:** means both the Pages and Workers versions of the Cloudflare-Scamalytics service didn't respond at scan time; the proxy itself is still valid, just its metadata is missing
- **The workflow doesn't commit anything new:** if no proxy has changed (`git diff --quiet`), an empty commit is deliberately not made; this isn't an error

## Related links

- This project's repo: `https://github.com/mehdi-hexing/HTTP-PROXY`
- Fraud score source: `https://github.com/mehdi-hexing/Cloudflare-Scamalytics`
