---
title: Setting Up a Telegram MTProto Proxy with Katabump
description: A step-by-step guide to creating a server and running a Telegram MTProto proxy on Katabump — from signup to getting the proxy link and a dedicated web page
---

# Setting Up a Telegram MTProto Proxy with Katabump

## What is this method?

A way to run your own **MTProto** Telegram proxy using **Katabump** (a free Node.js/Python hosting service). This version has one small change compared to the original project: every time the server starts, a **new random secret** is generated automatically, and besides the link printed in the Console, a **simple web page** is also served on the same port, showing the proxy link with a one-click copy button.

> ⚠️ **Important reminder:** Katabump's free plan requires a manual **Renew** every **4 days**. If you miss the deadline, the server and the proxy shut down completely and you'll need to start them again.

## Prerequisites and required links

For this guide you'll need:

- Katabump panel: `https://control.katabump.com`
- Original project (for reference): `https://github.com/alexbers/mtprotoproxy`

No obfuscation or compilation is needed; the whole project runs on plain Python and is ready to upload as-is.

📦 **Attached file (zip):**

[Ready-to-upload zip file](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/mtprotoproxy-katabump[NeedToExtract].zip)

Extract the file above; its contents (`mtprotoproxy.py`, `config.py`, and the `pyaes` folder) are used directly in the file-upload step.

## Step 1: Sign up

Start by creating an account on Katabump. You can sign up with Gmail. Both the **First Name** and **Last Name** fields need more than one character each. For the password, you can either type your own or use the one suggested by your browser.

📷 Image 1 of 15:

![Sign up - account creation form](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic.jpg)

📷 Image 2 of 15:

![Sign up - completing details and logging in](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic1.jpg)

## Step 2: Log into the dashboard and create a new server

After logging into the Katabump dashboard, click **Create Server**.

📷 Image 3 of 15:

![Dashboard - Create Server button](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic2.jpg)

📷 Image 4 of 15:

![Selecting the free server plan](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic3.jpg)

📷 Image 5 of 15:

![Entering the newly created server's management panel](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic4.jpg)

## Step 3: Select the Python environment

In the server panel's **Startup** tab, set the environment type to **Python** (not Node.js), since the proxy runs on Python.

📷 Image 6 of 15:

![Selecting the Python environment in the Startup tab](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic5.jpg)

## Step 4: Find your server's public port

Every Katabump server has a **dedicated public port**, shown in the server's **Settings** section. This port is usually a **five-digit** number (something like `25565` or `31842`).

📷 Image 7 of 15 — example of a five-digit public port in the panel:

![Example of a five-digit public server port](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic6.jpg)

## Step 5: Set the port in config.py

Replace the port number from the previous step inside `config.py`. Note that `25565` below is just an example — replace it with your own real port:

```python
PORT = 25565  # replace with your own public port
```

⚠️ This is the only value you need to set manually; everything else (the secret and the links) is generated automatically.

📷 Image 8 of 15:

![Editing PORT in config.py](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic7.jpg)

## Step 6: Upload the files

Extract the zip file mentioned in the prerequisites section. All the files and the `pyaes` folder must be uploaded directly (with no extra nested folder) into the server root, `/home/container/` — via the **Web File Manager** or **SFTP**.

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

📷 Image 9 of 15:

![Uploading files via the File Manager](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic8.jpg)

📷 Image 10 of 15:

![Files and the pyaes folder after upload](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic9.jpg)

## Step 7: Set the Startup entrypoint

In the panel's **Startup** tab, find the **PY FILE** field (also labeled Main File / Entry Point on some panel versions) and enter exactly this value:

```
mtprotoproxy.py
```

Then click **Save**.

📷 Image 11 of 15:

![Setting the entrypoint file in Startup](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic10.jpg)

## Step 8: Start the server and get the link from the Console

Start the server from the panel.

📷 Image 12 of 15:

![Starting the server from the Console tab](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic11.jpg)

In the Console tab, a line like this will appear — this is your ready-to-use proxy link (the IP, PORT, and SECRET values are replaced with your actual server's data):

```
tg: tg://proxy?server=IP&port=PORT&secret=SECRET
```

Copy this link and open it in Telegram.

📷 Image 13 of 15:

![Console output with the proxy link](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic12.jpg)

## Step 9: The dedicated proxy web page

Instead of manually copying the link from the Console, you can open the server's address in a browser. Replace `SERVER_IP` and `PORT` with your server's real IP and port:

```
http://SERVER_IP:PORT/
```

📷 Image 14 of 15:

![Opening the server address in a browser](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic13.jpg)

A simple page opens, showing the proxy link in a selectable box, along with a **Copy** button for a quick copy and an **Open in Telegram** link that opens the app directly. This page is served on the same port as the proxy itself, so no extra port is needed.

📷 Image 15 of 15:

![Dedicated proxy web page with copy button](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic14.jpg)

## Final notes

> ⚠️ **Don't forget:** Log into the Katabump panel and **Renew** your server every **4 days**, otherwise the server and the proxy will stop working.

- Every time you **restart** or **Renew** the server, the secret is regenerated automatically; the old link stops working, and you'll need to grab the new one from the Console or the web page.
- The free plan has limited resources (308MB RAM, 25% of one CPU core), which is enough for personal or small-group use.
- If you see an error like `ModuleNotFoundError` or `No such file` in the Console, it means either `mtprotoproxy.py` isn't in the right place, or the `pyaes` folder wasn't uploaded alongside it.
