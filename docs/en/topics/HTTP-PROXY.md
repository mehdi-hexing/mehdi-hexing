---
layout: doc
outline: deep
title: "Free Proxy Archive"
description: "Documentation for the HTTP-PROXY repo — a GitHub Actions workflow that collects, tests, and categorizes free public proxies by country/IP risk every 6 hours, with ready-made subscription links"
date: 2026-9-27
editLink: true
head:
  - - meta
    - name: keywords
      content: HTTP, SOCKS5, HTTP Proxies, Action github, Workflow, Cron job, Python, Free Proxy, Free for iran
---

# HTTP-PROXY

## What Is This Project?

A fully automated repository (no server required, just GitHub Actions) that every 6 hours:

- Fetches raw proxy lists from 8+ public sources (proxyscrape, TheSpeedX, monosans, ShiftyTR, iplocate, proxifly, etc.)
- Actually tests each proxy for connectivity
- Retrieves the country and fraud score for each live proxy
- Saves the results by protocol and country, in both txt and CSV formats, and commits them to the same repository
- Also generates ready-made subscription config formats (for MahsaNG, V2rayNG, Exclave) with QR codes

## 📱 Scan and Use Right Now

Each of these QR codes is always in sync with the latest scan (every 6 hours) — they load directly from the repo itself, so they're always up to date:

<div align="center">

| MahsaNG <br>HTTP | V2rayNG <br>HTTP | Exclave <br>HTTP |
| ---|---|---|
| <img src="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/mahsang_http_qr.png" width="220" alt="MahsaNG HTTP QR Code"> | <img src="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/v2rayng_http_qr.png" width="220" alt="V2rayNG HTTP QR Code"> | <img src="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_http_qr.png" width="220" alt="Exclave HTTP QR Code"> |
| Exclave <br>HTTPS | Exclave <br>SOCKS4 | V2rayNG <br>SOCKS5 | Exclave <br>SOCKS5 |
| ---|---|---|---|
| <img src="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_https_qr.png" width="220" alt="Exclave HTTPS QR Code"> | <img src="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_socks4_qr.png" width="220" alt="Exclave SOCKS4 QR Code"> | <img src="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/v2rayng_socks5_qr.png" width="220" alt="V2rayNG SOCKS5 QR Code"> | <img src="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_socks5_qr.png" width="220" alt="Exclave SOCKS5 QR Code"> |

</div>

Whichever client you use, scan the corresponding QR code with the scanner inside the app — the subscription link will be added automatically. If you prefer to copy the link manually, the full table with raw links is in the "Subscription Links" section below.

This project is connected to the [Cloudflare-Scamalytics][1] project for fraud scores, in the following way:

If the Pages version doesn't respond, it switches to the Workers version; if both fail to respond, default metadata (`Unknown`/`N/A`) is recorded for that proxy — the proxy is not removed from the list entirely, only the country/risk columns remain empty.

## How It Works (Automated, Every 6 Hours)

A GitHub Actions workflow (`Scan_Proxies.yml`) runs automatically on a schedule and initiates the scan:

- Fetches the raw list for each protocol from the sources above and merges it with the previous local pool (`Raw_Sources/raw_<protocol>.txt`) (a maximum of 300,000 entries is retained)
- Tests each proxy with up to 50 concurrent threads:
  - For `http`/`https`: a request to `clients3.google.com/generate_204` followed by a separate cross-check to `api.ipify.org` — if the cross-check fails, the proxy is set aside as a single-use relay (potential false-positive)
  - For `socks4`/`socks5`: a request to `gstatic.com/generate_204` (requires the `requests[socks]`/PySocks library)
- Live proxies are sorted by (country, fraud score) and saved in the following formats:
  - `proxies/protocol/<protocol>/all.txt` and `all.csv` (global list)
  - `proxies/countries/<protocol>/<CC>.txt` and `<CC>.csv` (by country code; unknown countries go into `UNKNOWN`)
- Subscription files (`proxies/subscriptions/`) and their QR codes are generated, and the table in `README.md` is automatically updated between the `SUBSCRIPTION_TABLE_START/END` comments
- Changes are committed and pushed with the `github-actions[bot]` user

## CSV File Columns

| Column | Description |
| ---|---|
| Proxy | ip:port address |
| Protocol | HTTP/HTTPS/SOCKS4/SOCKS5 |
| Country / Country Code / Flag | From Cloudflare-Scamalytics metadata |
| Fraud Score / Risk | Fraud score and risk level |
| VPN | Whether this IP is recognized as a VPN |
| ISP | Internet Service Provider |
| Latency (ms) | Response time at the moment of testing |

## Psiphon Compatibility

Verified proxies can also be used with Psiphon:

1. Open Psiphon
2. Options → More Options
3. Check the Upstream Proxy option
4. Enter one of the live proxies and ports from the list

## Live Lists

### Global List (by protocol)

```
proxies/protocol/{http,https,socks4,socks5}/all.txt
proxies/protocol/{http,https,socks4,socks5}/all.csv
```

### By Country

```
proxies/countries/{http,https,socks4,socks5}/{CC}.txt
proxies/countries/{http,https,socks4,socks5}/{CC}.csv
```

## Subscription Links (for direct import into clients)

The QR codes for these links are at the top of this page; here are just the raw links for manual copying:

| Client | Protocol | Copy Link |
|----|----|--------|
| MahsaNG | HTTP | <CopyLink url="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/mahsang_http.txt" /> |
| V2rayNG | HTTP | <CopyLink url="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/v2rayng_http.txt" /> |
| Exclave | HTTP | <CopyLink url="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_http.txt" /> |
| Exclave | HTTPS | <CopyLink url="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_https.txt" /> |
| Exclave | SOCKS4 | <CopyLink url="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_socks4.txt" /> |
| V2rayNG | SOCKS5 | <CopyLink url="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/v2rayng_socks5.txt" /> |
| Exclave | SOCKS5 | <CopyLink url="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_socks5.txt" /> |

## Running Locally (Optional)

```bash
pip install -r requirements.txt   # requests[socks] and qrcode[pil]
python Scanner.py
```

- If `requests[socks]` is not installed, socks4/socks5 proxies will be skipped with the reason `missing_pysocks_dependency` (the script won't crash)
- If `qrcode` is not installed, only QR code generation is disabled; the rest of the scan continues normally

## Important Notes

- This project has no live service/API — it's just an automated archive of static files updated every 6 hours.
- Per the script's own warning: free public proxies may stop working within minutes of being verified; always use the latest scan and prioritize lower Latency in the CSV.
- Regarding the point above: you can actually use the Balancer configs in V2rayNG clients (named Policy Group) and in Exclave (under the Balancer name). After you enter your subscription link and the configs are loaded, you can URL Test those same configs to sort by lowest ping and use them in Psiphon. My personal recommendation is to use the Exclave Balancer.

## Troubleshooting

- **A proxy that's in the CSV isn't working:** This is normal; free proxies have a short lifespan. Wait for the next scan (at most 6 hours from now).
- **Country/Fraud Score columns are empty or show `Unknown`:** This means both the Pages and Workers versions of the Cloudflare-Scamalytics service failed to respond at the time of the scan; the proxy itself is still valid, only its metadata is missing.
- **The workflow isn't making new commits:** If no proxies have changed (`git diff --quiet`), no empty commit is intentionally made; this is not an error.

## Related Links

::: info **Links**  

- Project repository:  
  https://github.com/mehdi-hexing/HTTP-PROXY

- Fraud score source:  
  https://github.com/mehdi-hexing/Cloudflare-Scamalytics

:::

[1]: https://github.com/mehdi-hexing/Cloudflare-Scamalytics
