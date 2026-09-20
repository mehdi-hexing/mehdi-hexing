---
layout: doc
outline: deep
lang: "fa-IR"
dir: "rtl"
title: "راه‌اندازی پراکسی WEB تلگرام با tproxy-server، mtg و Katabump"
description: "راهنمای گام‌به‌گام و ساده‌ی راه‌اندازی پروتکل جدید WEB Proxy تلگرام، روی هاست رایگان Katabump"
date: 2026-09-20
category: "ابزارها و سرور"
icon: "⚙️"
editLink: true
head:
  - - meta
    - name: keywords
      content: Telegram, WEB Proxy, tproxy-server, Cloudflare Tunnel, mtg, MTProxy, Katabump, Termux, Python
---

# راه‌اندازی پراکسی WEB تلگرام با tproxy-server و Katabump

## این روش چیه؟

تلگرام دسکتاپ از نسخه‌ی <Badge type="tip" text="7.1" /> به بعد یک نوع پروکسی جدید به اسم **WEB** اضافه کرده که ترافیک را شبیه بازدید از یک سایت عادی می‌کند و همین باعث می‌شود شناساییش سخت‌تر باشد.

این راهنما نشان می‌دهد چطور این نوع پروکسی را کاملاً **رایگان** روی یک هاست رایگان مثل <Badge type="danger" text="Katabump" /> راه‌اندازی کنیم.

## سایت‌های مورد نیاز

پیش از شروع، به اکانت روی این سایت‌ها نیاز دارید:

**۱. Katabump**
لینک: [control.katabump.com][1]
یک هاست رایگان که پلن Python/Node.js می‌دهد. سروری که پروژه رویش اجرا می‌شود.

**۲. Orihost** *(جایگزین Katabump، اختیاری)*
لینک: [orihost.com][8]
یک هاست رایگان مشابه Katabump با همین نوع پلن. اگر Katabump در دسترس نبود، می‌توانید از این استفاده کنید.

**۳. Cloudflare**
لینک: [dash.cloudflare.com][2]
برای ساخت تانل و عبور از محدودیت پورت هاست استفاده می‌شود.

**۴. Termux**
لینک: [termux.dev][3]
یک اپلیکیشن ترمینال برای اندروید. باینری‌های لازم را با آن روی گوشی می‌سازیم.

**۵. یک رجیستر دامین** *(اگر می‌خواهید دامین شخصی بخرید)*
لینک: [namecheap.com][9]
برای خرید یک دامین ارزان و بدون سابقه — دلیل اهمیتش در بخش [نکات دامین](#نکات-فیلترینگ-و-انتخاب-دامین) توضیح داده شده.

**۶. DigitalPlat FreeDomain** *(جایگزین رایگان برای دامین شخصی)*
لینک: [dash.domain.digitalplat.org][7]
یک سرویس رایگان ثبت ساب‌دامین، برای وقتی که خرید دامین فعلاً مقدور نیست.

**۷. مخزن tproxy-server**
لینک: [github.com/telegramdesktop/tproxy-server][5]
پروژه‌ی رسمی تیم تلگرام که این نوع پروکسی را پیاده‌سازی می‌کند.

**۸. مخزن mtg**
لینک: [github.com/9seconds/mtg][6]
نرم‌افزاری که ترافیک واقعی تلگرام را می‌فهمد و رد و بدل می‌کند.

## پیش‌نیازها

- یک اکانت Katabump (یا مشابهش) با پلن Python/Node.js
- یک اکانت رایگان Cloudflare (فقط برای دامین اختصاصی لازم است، نه برای Quick Tunnel)
- Termux روی گوشی اندروید
- یک دامین (ترجیحاً خریداری‌شده — دلیلش را در بخش [نکات دامین](#نکات-فیلترینگ-و-انتخاب-دامین) بخوانید)

## معماری کلی

```
Internet
   │
   ▼
Cloudflare
   │
   ▼
main.py (on your host)
   ├── decoy site      <- looks like a normal website
   ├── tproxy-server   <- HTTPS disguise layer
   └── mtg             <- real Telegram backend
```

هر درخواستی که به دامین شما می‌رسد، اول وارد `tproxy-server` می‌شود. اگر همراهش کد معتبر تلگرام نباشد، بدون هیچ نشانه‌ای سایت قلابی نشانش داده می‌شود؛ اگر معتبر باشد، به `mtg` (که ترافیک واقعی تلگرام را می‌فهمد) وصل می‌شود.

## روش پیشنهادی: اجرای خودکار با اسکریپت

::: tip توصیه‌ی ما
به‌جای انجام دستی همه‌ی مراحل (نصب پکیج‌ها، کامپایل `tproxy-server` و `mtg`، ساخت فایل‌های کانفیگ)، یک اسکریپت آماده هست که همه‌ی این کار‌ها را برایتان انجام می‌دهد. برای اکثر کاربرها این ساده‌ترین و سریع‌ترین راه است.
:::

کافی است این یک دستور را در ترموکس بزنید:

```bash
curl -fsSL -o build-web-proxy.sh https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/web-proxy-setup/build-web-proxy.sh && bash build-web-proxy.sh
```

این اسکریپت:

- پکیج‌های لازم را نصب می‌کند (فقط اگر از قبل نصب نباشند)
- `tproxy-server` و `mtg v1` را کامپایل می‌کند
- دامین، نوع تانل، سکرت و `MTG_PUBLIC_IPV4` را از شما می‌پرسد و خودش مستقیم توی `config.json`، `profiles.json` و `cf-config.yml` می‌نویسد — دیگر لازم نیست بعداً دستی این فایل‌ها را ویرایش کنید
- `main.py` را دانلود و باینری‌ها را کنار بقیه‌ی فایل‌ها کپی می‌کند
- در پایان یک جدول از همه‌ی مقادیری که وارد کردید/برایتان ساخته شد چاپ می‌کند تا قبل از آپلود دوباره چکشان کنید (همین جدول توی `SETTINGS-SUMMARY.txt` داخل پوشه‌ی پروژه هم ذخیره می‌شود)
- یک پوشه‌ی کامل و آماده‌ی آپلود در Downloads گوشی شما (`Download/web-proxy-project/`) قرار می‌دهد
- اجرای دوباره‌اش بی‌خطر است — مراحلی که قبلاً کامل شده‌اند را دوباره انجام نمی‌دهد

### آپلود خودکار با SFTP (اختیاری)

در پایان اجرای اسکریپت، این سؤال از شما پرسیده می‌شود:

```
Do you have SFTP/SSH access to Katabump and want to upload now? [y/N]
```

اگر `y` را بزنید، از شما می‌خواهد همان آدرس SFTP را که پنل نشانتان می‌دهد پیست کنید (مثل `sftp://user.katabump.fr:2022`) — اسکریپت خودش هاست و پورت را از آن جدا می‌کند، و اگر یوزرنیم هم داخل آدرس بود (مثل فرمت Orihost) دیگر جداگانه یوزرنیم نمی‌پرسد. پسورد هم همان پسورد پنل شماست که خود دستور آپلود موقع اتصال از شما می‌پرسد.

**پیدا کردن اطلاعات SFTP:**

- **Katabump:** از منوی سه‌خط (☰) بالا سمت چپ پنل، بروید به بخش **Settings** — آدرس و یوزرنیم SFTP همان‌جاست.

- **Orihost:** در پایین صفحه، بخش **Files** را باز کنید و گزینه‌ی **SFTP Connection Details** را بزنید.

  **📷 تصویر ۱ از ۲:**

<p align="center">
  <img src="/web-proxy-setup/pic-fa.jpg" alt="اطلاعات SFTP در Katabump" >
</p><br><br/>

**📷 تصویر ۲ از ۲:**

<p align="center">
  <img src="/web-proxy-setup/pic1-fa.jpg" alt="اطلاعات SFTP در orihost" >
</p><br><br/>

اگر `n` بزنید یا فقط Enter بزنید، این بخش رد می‌شود و فقط پوشه‌ی آماده در Downloads گوشی‌تان می‌ماند تا خودتان دستی (از File Manager وب پنل) آپلودش کنید.

## روش دستی (فقط اگر می‌خواهید خودتان انجام دهید)

::: details اگر ترجیح می‌دهید دستی جلو بروید، این بخش را باز کنید
اگر اسکریپت بالا را اجرا کردید، نیازی به خواندن این بخش نیست — مستقیم بروید سراغ [چه فایل‌هایی را باید خودتان تغییر دهید](#چه-فایل‌هایی-را-باید-خودتان-تغییر-دهید).

### مرحله ۱: نصب پیش‌نیازهای Termux

```bash
pkg update && pkg upgrade
pkg install golang git openssl-tool cloudflared openssh
```

### مرحله ۲: ساخت فایل tproxy-server

```bash
git clone https://github.com/telegramdesktop/tproxy-server.git
cd tproxy-server
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -buildvcs=false \
    -o ../tproxy-server-linux ./cmd/tproxy-server
```

### مرحله ۳: ساخت فایل mtg

```bash
git clone https://github.com/9seconds/mtg.git mtg-v1
cd mtg-v1
git checkout v1.0.12
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -buildvcs=false \
    -o ../mtg-v1-linux .
```

### مرحله ۴: ساخت کد اختصاصی (سکرت)

```bash
openssl rand -hex 16
```

خروجی یک رشته‌ی ۳۲ کاراکتری است — این را در مرحله‌ی بعد در `profiles.json` می‌گذاریم و در لینک نهایی تلگرام هم همین مقدار استفاده می‌شود.

### مرحله ۵: تنظیم فایل‌های کانفیگ

#### config.json

```json
{
  "public_hostname": "your-domain.example.com", // [!code focus]
  "base_path": "",
  "listen": "127.0.0.1:8080",
  "admin_listen": "127.0.0.1:8081",
  "public_upstream": "http://127.0.0.1:3000",
  "token_key_file": "./token.key",
  "static_routes": "exact",
  "profiles_file": "./profiles.json",
  "enable_pprof": false,
  "limits": {
    "max_sessions_global": 128,
    "max_streams_global": 4096
  },
  "timeouts": {
    "backend_dial": "5s",
    "long_poll": "25s",
    "reconnect_grace": "2m",
    "idle": "75s"
  }
}
```

فقط خط `public_hostname` را با دامین خودتان جایگزین کنید؛ بقیه را دست نخورده نگه دارید.

#### profiles.json

```json
{
  "profiles": [
    {
      "name": "primary",
      "secret": "REPLACE_WITH_YOUR_OWN_32_HEX_SECRET", // [!code focus]
      "backend": "127.0.0.1:2398",
      "carrier_mode": "https"
    }
  ]
}
```

فقط خط `secret` را با کدی که در مرحله‌ی ۴ ساختید جایگزین کنید.

#### cf-config.yml (فقط اگر دامین اختصاصی دارید)

```json
tunnel: tproxy
credentials-file: ./YOUR-TUNNEL-UUID.json // [!code focus]

ingress:
  - hostname: your-domain.example.com // [!code focus]
    service: http://localhost:8080
    originRequest:
      httpHostHeader: your-domain.example.com // [!code focus]
  - service: http_status:404
```

اگر از حالت Quick Tunnel استفاده می‌کنید، اصلاً نیازی به این فایل نیست.

#### یک سایت قلابی ساده

باید یک `index.html` ساده هم آماده کنید — هر صفحه‌ی معمولی کافی است، فقط باید شبیه یک سایت واقعی به‌نظر برسد.

### مرحله ۶: انتخاب روش تانل

دو راه برای اتصال سرورتان به اینترنت وجود دارد:

::: tip Quick Tunnel (ساده‌ترین، بدون نیاز به دامین)
هیچ ثبت‌نامی نمی‌خواهد. مناسب تست سریع، اما لینک هر بار که سرور را دوباره اجرا کنید عوض می‌شود.
:::

::: info Named Tunnel (پایدار، نیاز به دامین دارد)
یک آدرس ثابت روی دامین خودتان — لینک همیشه یکی می‌ماند.
:::
:::

## چه فایل‌هایی را باید خودتان تغییر دهید؟

::: tip اگر از اسکریپت استفاده کردید
این مقادیر را خود اسکریپت از شما پرسید و مستقیم توی فایل‌ها نوشت — این جدول بیشتر برای روش دستی است، یا برای وقتی که می‌خواهید دوباره چک کنید همه‌چیز درست نوشته شده (همان کاری که جدول پایانی خود اسکریپت هم انجام می‌دهد).
:::

| فایل | چه چیزی را عوض کنید |
|---|---|
| `profiles.json` | فیلد `secret` |
| `config.json` | فیلد `public_hostname` |
| `cf-config.yml` *(فقط Named Tunnel)* | `hostname`، `credentials-file`، `httpHostHeader` |
| `my-site/index.html` | محتوای صفحه (هر HTML ساده‌ای) |
| متغیر محیطی `MTG_PUBLIC_IPV4` | مقدار `IP:PORT` که پنل به شما داده |
| متغیر محیطی `QUICK_TUNNEL` | `1` برای حالت Quick Tunnel، خالی برای Named Tunnel |

فایل‌هایی که نباید دستی بسازید یا ویرایش کنید: `token.key` و `status.html` — این‌ها را خود اسکریپت می‌سازد.

## اجرا روی Katabump

فایل‌های زیر باید در ریشه‌ی پروژه باشند:

```
main.py
config.json
profiles.json
cf-config.yml
tproxy-server-linux
mtg-v1-linux
cloudflared
my-site/index.html
```

::: warning تنظیم PY FILE در پنل Katabump
در پنل Katabump، از بخش **Startup**، فیلد **PY FILE** را پیدا کنید و مقدارش را به `main.py` تغییر دهید — در غیر این صورت پنل نمی‌داند کدام فایل را اجرا کند.
:::

برای اجرا با Quick Tunnel باید در کد پایتون، مقدار QUICK_TUNNEL را از 0 به مقدار 1 تغییر دهید:

```json
# auto-detects it and rewrites config.json + status.html each time.
QUICK_TUNNEL = os.environ.get("QUICK_TUNNEL", "0") == "1" // [!code focus]  
QUICK_TUNNEL_URL_RE = re.compile(r"https://([a-zA-Z0-9.-]+\.trycloudflare\.com)")
```

برای اجرا با Named Tunnel:

```bash
python /home/container/main.py
```

## نکات فیلترینگ و انتخاب دامین

بعضی اپراتورها دامین‌های ساب‌دامین رایگان و شناخته‌شده (مثل `dpdns.org`, `ggff.net`, `filegear-sg.me`) را در سطح DNS مسدود می‌کنند، مستقل از اینکه پشت آن‌ها چه سروری است. با توجه به این تجربه، گزینه‌ها به این ترتیب پیشنهاد می‌شوند:

### ۱. خرید یک دامین شخصی (توصیه‌ی اصلی)

مطمئن‌ترین راه. یک دامین بدون سابقه (حتی ارزان‌ترین TLDها مثل `.xyz` یا `.online`) شانس بیشتری برای عبور از فیلترینگ دارد.

### ۲. Cloudflare Quick Tunnel

اگر خرید دامین فعلاً مقدور نیست، دامین `trycloudflare.com` (متعلق به خود Cloudflare) گزینه‌ی بعدی است. تنها ایرادش این است که لینک هر بار که سرور را دوباره اجرا کنید عوض می‌شود.

### ۳. DigitalPlat FreeDomain

از [dash.domain.digitalplat.org][7] می‌توانید رایگان یک ساب‌دامین (`.us.kg`, `.qzz.io`, `.qd.je`, `.xx.kg`) ثبت کنید.

::: warning احتیاط لازم است
`dpdns.org` هم متعلق به همین ارائه‌دهنده است. قبل از اتکای جدی به این گزینه، حتماً از شبکه‌ی موردنظرتان تستش کنید.
:::

## عیب‌یابی رایج

| خطا | راه‌حل |
|---|---|
| `unknown field "_comment"` | فقط فیلدهای مستند‌شده را در فایل‌های JSON نگه دارید |
| پرمیژن `profiles.json` | خود اسکریپت خودکار درستش می‌کند |
| `token_key_file: no such file` | خود اسکریپت یک‌بار می‌سازدش |
| `incorrect first byte of secret` | باید حتماً از mtg نسخه‌ی ۱ استفاده کنید، نه نسخه‌ی ۲ |
| `cannot resolve any public address` | مقدار `MTG_PUBLIC_IPV4` را تنظیم کنید |
| کلاینت روی «در حال اتصال» می‌ماند | مطمئن شوید `public_hostname` با دامین واقعی یکی است |

## راهنما و پشتیبانی

::: info راهنمایی بیشتر
در صورت مواجهه با هرگونه سوال یا مشکل، می‌توانید از راه‌های زیر با ما در ارتباط باشید:

- **مستندات رسمی پروژه:** [tproxy-server در گیت‌هاب][5]
- **پروژه‌ی mtg:** [9seconds/mtg][6]
:::

## توضیحات تکمیلی (برای علاقه‌مندان)

::: details چرا CGO_ENABLED=0 لازم است؟
موقع کامپایل کردن با Go در ترموکس، اگر CGO فعال باشد، کامپایلر سعی می‌کند بخش‌هایی از کد را با ابزار C مخصوص معماری خودِ گوشی (ARM) بسازد، در حالی که سرور به نسخه‌ی amd64 نیاز دارد. همین باعث خطاهای عجیب کامپایل می‌شود. با `CGO_ENABLED=0` کل این بخش دور زده می‌شود و کراس‌کامپایل تمیز انجام می‌شود.
:::

::: details چرا باید حتماً mtg نسخه‌ی ۱ باشد؟
نسخه‌ی ۲ فقط سکرت‌های نوع FakeTLS (شروع‌شونده با `ee`) را قبول می‌کند، در حالی که `tproxy-server` فقط سکرت‌های کلاسیک یا نوع `dd` را معتبر می‌داند. این دو با هم سازگار نیستند، پس باید از نسخه‌ی ۱ که فرمت کلاسیک را می‌پذیرد استفاده کرد.
:::

::: details چرا httpHostHeader در cf-config.yml لازم بود؟
`tproxy-server` بر اساس هدر Host تصمیم می‌گیرد که آیا درخواست واقعی تلگرام است یا یک بازدیدکننده‌ی معمولی. باید مطمئن شد Cloudflare همیشه همان دامین اصلی را به‌عنوان Host به سرور تحویل می‌دهد، نه چیز دیگری.
:::

::: details mtg چرا به IP عمومی نیاز دارد؟
mtg برای صحبت با سرورهای واسط خود تلگرام، باید بداند از چه آدرس عمومی‌ای قابل‌دسترس است. روی هاست‌های رایگانی مثل Katabump که پشت یک لایه‌ی شبکه‌ی داخلی هستند، این آدرس را نمی‌تواند خودش حدس بزند، پس باید صریح در `MTG_PUBLIC_IPV4` داده شود.
:::

[1]: https://control.katabump.com
[2]: https://dash.cloudflare.com
[3]: https://termux.dev
[5]: https://github.com/telegramdesktop/tproxy-server
[6]: https://github.com/9seconds/mtg
[7]: https://dash.domain.digitalplat.org
[8]: https://orihost.com
[9]: https://www.namecheap.com
