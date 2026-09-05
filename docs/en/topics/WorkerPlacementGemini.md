---
title: Accessing Gemini / Google AI Studio with a Dedicated Worker (Cloudflare Placement)
description: A step-by-step guide to setting up a separate Worker with Placement on Google Cloud Platform to access US-restricted services like Google AI Studio, without affecting the main Worker (which has variable destinations)
---

# Accessing Gemini / Google AI Studio with a Dedicated Worker

## Where this started

Cloudflare's default Worker behavior (**Default** mode in Placement settings) always picks the Cloudflare data center closest to **the end user** to minimize latency. For a user connecting from Iran, that means execution near Azerbaijan, Turkey, Germany, Sweden, or Finland — not the US.

Here's the problem: some services (like **Google AI Studio / Gemini**) only respond to requests coming from a specific geographic region (mainly the US). When the Worker always runs near Europe, these services won't load.

The solution: create a **separate** Worker whose Placement is manually locked to a Google Cloud Platform region (e.g., the US), so that Cloudflare's code execution itself happens from a data center closer to that region.

## What exactly is Placement on Cloudflare Workers?

According to Cloudflare's official documentation, there are three modes:

| Mode | Best suited for |
|---|---|
| **Default (off)** | The Worker runs at the data center closest to **the end user**; lowest latency for the user's own connection |
| **Smart** | Cloudflare automatically determines, based on traffic, which fixed backend the Worker connects to most, and runs it near that backend |
| **Region** | You explicitly specify a region from AWS, GCP, or Azure (e.g., `gcp:us-east4`); Cloudflare runs the Worker at its data center closest to that region |

Smart and Region are designed for cases where the Worker connects to a **fixed** (single-homed) backend/database/API, and you want to shorten the round trip between the Worker and that backend.

## Why the main Worker (VLESS/tunnel with variable destinations) should not enable this

The main code and config (VLESS over Serverless) has no fixed backend — this week it's Telegram (Dubai/Netherlands servers), next week Instagram (Germany/Austria/US), or an embassy website (Poland/Australia). The destination changes constantly, and there's no fixed database or API in the code either.

For this kind of use case:
- **Smart** and **Region** are of no use — because there's no fixed backend to get closer to
- Worse, they might move the Worker to a data center farther from the end user, **making latency worse**
- The only factor that actually matters here is the distance between the user and the Worker (the speed of the handshake and initial round trip), not the distance between the Worker and a "backend"

**So the main Worker should stay on Default.**

## Recommended Worker code

For this use case, the following code and repository are recommended as the suggested Worker:

- Repo: `https://github.com/NiREvil/zizifn`
- Setup tutorial: `https://diana-cl.github.io/Diana-Cl/topics/zizifn`

## The solution: a second, separate Worker just for US/GCP destinations

Instead of changing the main Worker's settings, create a completely separate Worker whose Placement is set to Region on GCP, and use it only for destinations you know are hosted in the US or only respond to US traffic (like Google AI Studio). Give it a name like `only-GS` (Only Google Studio) so it doesn't get mixed up with the main Worker — since for anything other than these specific destinations, this second Worker is useless.

## Step-by-step instructions (based on the Cloudflare dashboard)

1. Log into the Cloudflare dashboard → **Workers & Pages** → select the Worker (or create a new one) → the Settings tab → the **Runtime** section

2. Click the **Placement** field and change it from the default (Default) to **Region**

3. A **Provider** field appears — make sure to set it to **Google Cloud Platform (GCP)** (this field is required, not optional)

4. The **Location/Region** field comes next — this one is **optional**; you can select one or more regions (e.g., Australia and US East) or leave it blank and let Cloudflare pick the best option itself

![Runtime settings page in the Cloudflare dashboard with Placement set to Region and Provider set to GCP](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/worker-placement-gemini/pic.jpg)

5. Click **Save and Deploy** (the Deploy button at the bottom of the page, which shows an "Unsaved changes" message instead of its usual text after you change the settings)

6. **Update** your subscription once

7. Create a new config whose domain points exactly to this Worker (not the default Worker), and connect with it

8. Now try Google AI Studio / Gemini — it should normally come up

## Why this actually works (further explanation)

According to Cloudflare's official documentation, in Region mode, **the Worker code execution itself** happens at the Cloudflare data center with the lowest latency to the selected cloud region (here, GCP) — meaning that data center is genuinely geographically closer to that region (e.g., the US). When this Worker makes an outbound request to Gemini/Google AI Studio, the outbound IP comes from that US Cloudflare data center, not the European/near-Iran data center that would be selected in Default mode. Since these services typically decide whether to respond based on the geographic location of the incoming IP, this change is exactly what's needed.

An important note: Cloudflare itself officially markets this feature for "reducing latency to a specific backend," not for "changing the geographic location of a request." In other words, this is a side effect of a performance feature, not an official, guaranteed capability for bypassing geographic restrictions. Cloudflare may change this feature's internal behavior in the future.

## Summary and final recommendation

- **Main Worker (tunnel/browsing with variable destinations):** keep Placement on **Default**
- **Second, separate Worker (only for US/GCP destinations like Gemini):** Placement on **Region → Google Cloud Platform**, location optional, named something like `only-GS` to make clear it's only for this purpose
- For this second Worker's code, use the recommended repo `https://github.com/NiREvil/zizifn`
- Keep this second Worker as a separate, additional config, not a replacement for your everyday config
