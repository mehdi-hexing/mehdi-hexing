---
title: ECH-Workers — DoH Worker with Automatic Fastest-Route Selection
description: Documentation for the ECH-Workers repository — a Cloudflare Worker that returns DNS-over-HTTPS records (for things like ECH) across several resolvers and intermediary proxies, with automatic benchmarking and KV caching
---

# ECH-Workers

## What is this project?

A **Cloudflare Worker** that returns DNS-over-HTTPS (DoH) records — including ones used for ECH config lookups — across several **resolvers** (Cloudflare, Google, Quad9, NextDNS, OpenDNS) and several **intermediary proxies**.

## How it works

1. A list of (resolver × proxy) combinations is built.
2. All of these combinations are benchmarked with one test request (`cloudflare.com`, type `A`), and the result (healthy/unhealthy + latency) is cached in KV for **10 minutes**.
3. For every real request, one of the 5 fastest routes is picked **at random** (so load spreads across several routes instead of one fixed path).
4. If the chosen route doesn't respond, it's retried up to **4 times** with a different route from that same top 5.
5. A successful response is cached in KV, per domain/type, for **3 hours**, so later requests come straight from the cache.

## Endpoints

### `GET /`

Just returns a usage message with the endpoint format.

### `GET /resolve/{domain}/{type?}`

Returns the domain's DoH record. `{type}` is optional and defaults to `HTTPS`.

```bash
curl https://your-worker.your-subdomain.workers.dev/resolve/example.com
curl https://your-worker.your-subdomain.workers.dev/resolve/example.com/A
```

### `GET /resolve/{domain}/{type?}/download`

The same response, but with a `Content-Disposition: attachment` header so the browser downloads it as a file (filename: `{domain}_{type}.json`).

### Response headers

| Header | Description |
| --- | --- |
| `x-cache` | `HIT` or `MISS` |
| `x-resolver-used` | which resolver answered (MISS only; `cache` on HIT) |
| `x-proxy-used` | which intermediary proxy was used (MISS only) |
| `x-resolver-ms` | that resolver's response time in milliseconds |

The raw JSON response is also processed before being returned: `HTTPS`-type records (type 65) and `OPT` records (type 41) are broken out into readable fields (`priority`, `target`, `params` for HTTPS; `edns` for OPT), instead of staying one raw string.

## Default resolvers and proxies

```
Resolvers:
cloudflare, google, quad9, nextdns, opendns

Intermediary proxies:
direct (no intermediary), allorigins, corsproxy
```

These are public, free services with no uptime guarantee; if you need to change them, you have to edit them directly in `src/index.js` (the `DEFAULT_RESOLVERS` and `DEFAULT_PROXIES` constants) and redeploy.

## Prerequisites

- A **Cloudflare** account (with Workers KV enabled)
- A **GitHub** account (for automatic deployment via Actions)
- A dedicated Cloudflare **API Token** (steps to create one below)

## One-time setup

1. Create a Cloudflare API token with these permissions:
- **Workers Scripts: Edit**
- **Workers KV Storage: Edit**
- **Account: Read**

Steps: go to [dash.cloudflare.com/profile/api-tokens](https://dash.cloudflare.com/profile/api-tokens), then click **Create Token** and choose the **"Edit Cloudflare Workers"** template (this template automatically adds KV Storage:Edit and Workers Scripts:Edit; it also adds Zone→Workers Routes:Edit, which isn't needed for this project and you can remove it)
Add one more permission manually:
**Account → Account Settings → Read** →
under "Account Resources", select just your specific account, not "All accounts"
**Continue to summary** → **Create Token**
and copy the API token along with the Account ID right there (it's shown only once)
We need these for the GitHub Action, so make sure you've forked the repo first.

2. Add these two secrets in your forked repo's GitHub settings (Settings → Secrets and variables → Actions):

| Secret | Value |
| --- | --- |
| `CF_API_TOKEN` | the token you created above |
| `CF_ACCOUNT_ID` | your Cloudflare account ID |

## Deployment guide

### Automatic

Every push to `main` that touches `src/**` or `wrangler.toml` deploys automatically.

### Manual (with a custom name for the Worker)

1. Go to the **Actions** tab on the repo.
2. Select the **"Deploy Worker"** workflow.
3. Click **Run workflow**.
4. Optional: enter a custom name in the `worker_name` field (leave it empty to use the name already in `wrangler.toml`).
5. Click **Run workflow** again to start it.

## KV namespace handling

The deploy workflow itself ensures two KV namespaces exist: one for DNS response caching (bound as `DNS_CACHE`) and one for runtime config (bound as `CONFIG_KV`).

- Namespace titles follow the pattern `{worker_name}-{binding}-{random_suffix}`
- Before creating a new namespace, the workflow checks whether one already exists with that same prefix; if so, that one is reused.
- This means re-running the deploy with the same Worker name doesn't create duplicate namespaces.

## Log safety

As soon as the API Token, Account ID, and each KV namespace ID are known, the workflow masks them using GitHub Actions' `::add-mask::` mechanism. API responses are only parsed with `jq` and never printed directly to the log; shell command tracing (`set -x`) is also disabled in the step that builds authenticated requests.

## Troubleshooting

- **502 error (`no healthy route available`):** no resolver+proxy combination responded in the last benchmark; wait a few minutes (the benchmark cache refreshes every 10 minutes) or check the proxy/resolver list in the code
- **502 error (`all attempts failed`):** the benchmark had found healthy routes, but all 4 real attempts failed (the `reason` field shows the reason for the last attempt); this usually means the public intermediary proxies are temporarily down
- **Response is very slow:** if `x-cache: MISS` and the benchmark just refreshed, this is normal — the next request comes back from cache (`HIT`) much faster

## Related links

- This project's repo: `https://github.com/mehdi-hexing/ECH-Workers`
