---
layout: doc
outline: deep
title: "Setting Up a Telegram Proxy with Katabump"
description: "A step-by-step guide to creating a server and running a Telegram MTProto proxy using Katabump"
date: 2026-10-6
editLink: true
head:
  - - meta
    - name: keywords
      content: MTProto, SOCKS5, HTTP Proxies, Action github, Python, Free Proxy, Telegram Proxies, MT-Proto protocol
---

# Setting Up a Telegram MTProto Proxy with Katabump

## What Is This Method?

This method allows you to set up a dedicated <Badge type="danger" text="MTProto" /> proxy for Telegram using <Badge type="danger" text="Katabump" /> (a free Node.js/Python hosting service). This version has a small modification compared to the original project: every time the server starts, a new random secret is generated, and in addition to the link displayed in the Console, a simple web page is also served on the same port, showing the proxy link with a copy button.

::: tip **Important Note**

Katabump's free plan requires manual renewal (Renew) every 4 days. If you forget the due date, the server and proxy will shut down completely, and you'll need to start it again.

:::

## Prerequisites and Required Links

You'll need the following links for this tutorial:

- [Katabump Panel Link][1]
- [Original Project Link (for reference)][2]

No obfuscation or compilation is needed; the entire project runs with plain Python and is ready to upload as-is.

**📦 Attached File (zip)** 

- [Ready-to-upload zip file][3]

<br/>

::: info **Note**

<Badge type="danger" text="Extract" /> the file above; its contents (`mtprotoproxy.py`, `config.py`, and the `pyaes` folder) will be used directly in the file upload step.

:::

<br/>

## Step 1: Sign Up

To get started, you need to create an account on Katabump. You can sign up with Gmail. The First Name and Last Name fields must each contain more than one character. For the password, you can either enter one yourself or use the browser's suggested password.

**📷 Image 1 of 15:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic.jpg" alt="Sign Up - Account creation form">
</p><br/>

**📷 Image 2 of 15:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic1-fa.jpg" alt="Sign Up - Completing information and logging in">
</p><br/>

## Step 2: Accessing the Dashboard and Creating a New Server

After logging into the Katabump dashboard, click the Create Server option.

<br/>

**📷 Image 3 of 15:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic2.jpg" alt="Dashboard - Create new server button">
</p><br/>

**📷 Image 4 of 15:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic3-fa.jpg" alt="Selecting the free server plan">
</p><br/>

**📷 Image 5 of 15:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic4-fa.jpg" alt="Entering the management panel of the created server">
</p><br/>

## Step 3:** Selecting the Python Environment

In the Startup tab of the server panel, set the environment type to Python (not Node.js), since the proxy runs on Python.

**📷 Image 6 of 15:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic5.jpg" alt="Selecting Python environment in the Startup tab">
</p><br/>

## Step 4: Finding the Server's Public Port

Each server on Katabump has a dedicated public port, which is displayed in the server's Settings section. This port is typically a five-digit number (e.g., something like `25565` or `31842`).

**📷 Image 7 of 15:**
<p align="center">
  <img src="/katabump-mtproto-setup/pic6.jpg" alt="login in server">
</p><br/>

## Step 5: Setting the Port in config.py

Replace the port number you found in the previous step inside the `config.py` file. Note that the number `25565` below is just an example and must be replaced with your actual port:

```python
PORT = 25565  # replace with your own public port
```

::: danger **Attention**

This is the only value that needs to be set manually; everything else (secret and links) is generated automatically.

:::

<br/>

**📷 Image 8 of 15:** <Badge type="danger" text="Example of a five-digit public port in the panel" />

<p align="center">
  <img src="/katabump-mtproto-setup/pic7.jpg" alt="Example of a five-digit public">
</p><br/>

## Step 6: Uploading the Files

Extract the zip file provided in the Prerequisites section. All files and the `pyaes` folder must be uploaded directly (without nested folders) to the server root at `/home/container/` — via the Web File Manager or SFTP.

The final structure should look like this:

```
/home/container/
├── mtprotoproxy.py
├── config.py
└── pyaes/
    ├── __init__.py
    ├── aes.py
    ├── blockfeeder.py
    └── util.py
```

<br/>

**📷 Image 9 of 15:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic8.jpg" alt="Uploading files via File Manager">
</p><br/>

**📷 Image 10 of 15:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic9.jpg" alt="Files and pyaes folder after upload">
</p><br/>

## Step 7: Configuring Startup (Entrypoint)

In the Startup tab of the panel, find the PY FILE field (or Main File / Entry Point) and enter exactly this value:

```
mtprotoproxy.py
```

Then click Save.

<br/>

**📷 Image 11 of 15:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic10.jpg" alt="Setting the executable file in Startup">
</p><br/>

## Step 8: Starting the Server and Getting the Link from the Console

Start the server from the panel.

<br/>

**📷 Image 12 of 15:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic11.jpg" alt="Starting the server from the Console tab">
</p><br/>

In the Console tab, a line similar to the following will appear, which is the ready-to-use proxy link (the IP, PORT, and SECRET values will be replaced with your server's actual information):

```
tg://proxy?server=IP&port=PORT&secret=SECRET
```

Copy this link and open it in Telegram.

<br/>

**📷 Image 13 of 15:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic12.jpg" alt="Console output with the proxy link">
</p><br/>

## Step 9: Dedicated Proxy Web Page

Instead of manually copying from the Console, you can open the server address in your browser. Replace `SERVER_IP` and `PORT` with your actual server IP and port:

```
http://SERVER_IP:PORT/
```

<br/>

**📷 Image 14 of 15:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic13.jpg" alt="Opening the server address in a browser">
</p><br/>

A simple page will open displaying the proxy link in a selectable box, along with a Copy button for quick copying and an Open in Telegram link to open it directly in the app. This page is served on the same main proxy port and does not require a separate port.

<br/>

**📷 Image 15 of 15:****

<p align="center">
  <img src="/katabump-mtproto-setup/pic14.jpg" alt="Dedicated proxy web page with copy button">
</p><br/>

## Final Notes

::: danger **Don't Forget**   
You must log in to the Katabump panel and Renew your server every 4 days; otherwise, the server and proxy will stop working.

<br/>

Every time you restart or Renew the server, the secret is automatically changed; the previous link will stop working, and you'll need to get the new link from the Console or the web page.

The free plan has limited resources (308 MB RAM, 25% of one CPU core); this is sufficient for personal use or a small group of users.

<br/>

If you see an error message like "ModuleNotFoundError" or "No such file" in the Console, it means either the `mtprotoproxy.py` file is not in its correct location or the `pyaes` folder hasn't been uploaded alongside it.   
:::

## Support and Help

::: info **Further Assistance**   
If you encounter any questions or issues during setup or while using this project, you can reach out through the following channels:  
- Direct contact: [My personal Telegram account][4]
- General Q&A: [Telegram support group][5]   
:::

[1]: https://control.katabump.com
[2]: https://github.com/alexbers/mtprotoproxy
[3]: https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/mtprotoproxy-katabump[NeedToExtract].zip
[4]: https://t.me/mehdiasmart
[5]: https://t.me/NiREvil_GP
