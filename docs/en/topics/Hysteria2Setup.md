---
layout: doc
outline: deep
title: "Setting Up a Server and Hysteria Config with Katabump"
description: "A step-by-step guide to setting up a server and Hysteria config using Katabump — from registration to uploading files and getting the subscription link"
date: 2026-9-13
editLink: true
head:
  - - meta
    - name: keywords
      content: Hysteria2, Katabump, VPS, Server Setup, Config, Subscription Link
---

# Setting Up a Server and Hysteria Config with Katabump

## What is this method?

A new method where you can set up a server and config using **Katabump**.

## Prerequisites and required links

For this tutorial, you'll need these links:

- Katabump panel: `https://dashboard.katabump.com`
- Code obfuscator (JS Obfuscator): `https://js-obfuscator.github.io/`
- Config repository: `https://github.com/qlxi/Xray-Sing-node`

Obfuscating the code before use is **mandatory**; but don't worry, since it's already obfuscated using the obfuscator mentioned above.

📦 **Attached file (zip):**

[Config zip file][1]

Extract the file above; its contents will be used in the file-upload step — you can either upload the files directly, or copy each file's content and paste it into the corresponding location.

::: danger Important Note About Quality and Server Renewal
This Hysteria config gives good throughput and a stable connection on Irancell. The important thing to note is that you have to **renew** the server every **4 days**.
:::

## Important Technical Notes Before You Start

- **Minimum server resources:** this config downloads and runs several binaries (sing-box, and — if enabled — Xray-core and Cloudflared). The core services (Hysteria2 + VLESS-WS) will come up fine even on very limited plans (a few hundred MB of disk/RAM), but if you keep **Argo (the Cloudflare tunnel)** enabled, you need roughly an extra 200–300MB of free disk space; otherwise you'll see a "not enough disk space" error in the logs and only Argo will stay disabled — every other service keeps working normally.
- **Configuration is done by editing the file itself:** the Katabump panel (on some plans) doesn't support setting Environment Variables. So if you need to change anything (e.g. the data directory, disabling Argo to save resources, or the SNI), you'll need to edit that setting's default value directly inside the JS file before uploading it.
- **Data directory:** if your host's temp folder (`/tmp`) is backed by RAM instead of real disk, it's better to point the data directory to a subfolder next to the project itself (e.g. `xray-sing` next to the main file) so disk usage isn't mistaken for RAM usage.

## Step 1: Registration

To get started, you need to create an account on Katabump:

- You can sign up with Gmail
- In the **First Name** and **Last Name** fields, each must be more than one character (for example, entering something like `Jon K` won't be accepted, since the last name is only one character)
- For the password, you can either enter one yourself or use the strong password suggested by Chrome

📷 **Images for this step:**

Image 1 of 2:

<p align="center">
<img src="/public/hysteria2-setup/pic.jpg" alt="Registration step - Image 1">
</p><br/>

Image 2 of 2:

<p align="center">
<img src="/public/hysteria2-setup/pic1-en.jpg" alt="Registration step - Image 2">
</p><br/>

## Step 2: Creating and logging into the server management panel

In this step, the server is created and you log into its management panel.

📷 **Images for this step:**

Image 1 of 5:

<p align="center">
<img src="/public/hysteria2-setup/pic2.jpg" alt="Server creation and panel login step - Image 1">
</p><br/>

Image 2 of 5:

<p align="center">
<img src="/public/hysteria2-setup/pic3-en.jpg" alt="Server creation and panel login step - Image 2">
</p><br/>

Image 3 of 5:

<p align="center">
<img src="/public/hysteria2-setup/pic4-en.jpg" alt="Server creation and panel login step - Image 3">
</p><br/>

Image 4 of 5:

<p align="center">
<img src="/public/hysteria2-setup/pic5.jpg" alt="Server creation and panel login step - Image 4">
</p><br/>

Image 5 of 5:

<p align="center">
<img src="/public/hysteria2-setup/pic6.jpg" alt="Server creation and panel login step - Image 5">
</p><br/>

## Step 3: Uploading files

Extract the zip file provided in the Prerequisites section; its contents are used in this step. In the images below, the location and method for uploading the JS and JSON files are marked in green.

::: tip Before you upload
If you want to change any default settings (e.g. disabling Argo on low-resource plans, or the data directory), now — before uploading — is the time to do it. As mentioned in "Important Technical Notes Before You Start," these changes must be made directly in the JS file, since there's no way to set Environment Variables through the panel.
:::

📷 **Images for this step:**

Image 1 of 3:

<p align="center">
<img src="/public/hysteria2-setup/pic7.jpg" alt="File upload step - Image 1">
</p><br/>

Image 2 of 3:

<p align="center">
<img src="/public/hysteria2-setup/pic8.jpg" alt="File upload step - Image 2">
</p><br/>

Image 3 of 3:

<p align="center">
<img src="/public/hysteria2-setup/pic9.jpg" alt="File upload step - Image 3">
</p><br/>

## Step 4: Final step — getting the panel address and subscription

At this stage, as shown in the images below, the panel address and subscription link are displayed in the logs, and no extra work is needed — you can now access the panel and subscriptions.

📷 **Images for this step:**

Image 1 of 3:

<p align="center">
<img src="/public/hysteria2-setup/pic10.jpg" alt="Final step - Image 1">
</p><br/>

Image 2 of 3:

<p align="center">
<img src="/public/hysteria2-setup/pic11.jpg" alt="Final step - Image 2">
</p><br/>

Image 3 of 3:

<p align="center">
<img src="/public/hysteria2-setup/pic12.jpg" alt="Final step - Image 3">
</p><br/>

## Common Issues

**The log says "Argo link not ready" or shows a disk-space error for Argo — what do I do?**

This means there wasn't enough free disk space (roughly 60MB or more) to download cloudflared. Every other service (Hysteria2, VLESS-WS, etc.) keeps working fine — only Argo (the Cloudflare tunnel) is unavailable for that run. If you don't actually need Argo, it's best to disable it directly in the JS file as described in "Important Technical Notes Before You Start," which frees up both disk space and RAM for the other services.

[1]: https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/hysteria2-setup/KataBumpJSCode[NeedToExtract].zip
