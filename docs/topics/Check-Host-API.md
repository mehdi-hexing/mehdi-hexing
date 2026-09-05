---
title: Check-Host-API — سرویس تست شبکه از چندکشور (Ping/HTTP/TCP/UDP/DNS)
description: مستندات ریپوی Check-Host-API — سرویس FastAPI که با استفاده از نودهای جهانی check-host.net، دسترس‌پذیری یک هاست را از چند کشور مختلف تست می‌کند؛ بک‌اند تب Check-Host در پروژه‌ی Cloudflare-Scamalytics
---

# Check-Host-API

## این پروژه چیه؟

یک سرویس **FastAPI** (پایتون) که با استفاده از نودهای جهانی [check-host.net](https://check-host.net)، دسترس‌پذیری یک هاست را از هر کشوری که بخواهید تست می‌کند — با پنج نوع تست: **ping، http، tcp، udp، dns**.

این سرویس همون بک‌اندیه که تب **«Check-Host Network Test»** در پروژه‌ی [Cloudflare-Scamalytics](https://mehdi-hexing.github.io/mehdi-hexing/topics/Cloudflare-Scamalytics) بهش وصل می‌شه.

## سازگاری با Worker پروژه‌ی Cloudflare-Scamalytics

ریپوی `Cloudflare-Scamalytics` مستقیماً مسیر Legacy این سرویس (`GET /{country}/{host}`) را صدا می‌زند و آدرسش را ثابت (hardcode) روی `https://check-host.onrender.com` گذاشته. این ریپو عمداً با آن سازگار نگه داشته شده:

- هر نتیجه‌ی ping شامل فیلد `ping_ms` است (فرانت‌اند Worker دقیقاً همین کلید را می‌خواند تا تأخیر هر نود را نشان دهد)
- هر پاسخ خطا شامل هر دو فیلد `detail` و `message` است (Worker مقدار `message` را می‌خواند تا به‌جای یک خطای عمومی «HTTP 502»، پیام واقعی خطا را به کاربر نشان دهد)
- CORS کاملاً باز است (`Access-Control-Allow-Origin: *`) چون این API عمومی و فقط-خواندنی است

اگر این API را زیر آدرسی غیر از `check-host.onrender.com` دیپلوی کنی، باید مقدار ثابت `CH_RENDER_API_BASE` در فایل `_worker.js` همان Worker را متناسب با آدرس جدید به‌روزرسانی کنی.

## بخش فنی

```txt [requirements]
fastapi>=0.110
uvicorn[standard]>=0.29
httpx[http2]>=0.27
```

همه‌ی منطق ها و توابع در یک فایل (`api/index.py`) نوشته شده؛ بدون دیتابیس یا وابستگی سنگین.

## اندپوینت‌ها (Routes)

### بررسی با نوع مشخص

```js
GET /api/{check_type}/{country}/{host}
```

- `check_type`: یکی از `ping`, `http`, `tcp`, `udp`, `dns`
- `country`: کد ۲ حرفی کشور (مثل `de`) یا `all` برای همه‌ی نودها — **اجباری، بدون مقدار پیش‌فرض**
- مثال: `/api/ping/de/example.com`

**پارامترهای Query اختیاری:**

| پارامتر | محدوده | پیش‌فرض | توضیح |
| --- | --- | --- | --- |
| `max_nodes` | ۱ تا ۵۰ | بدون محدودیت | حداکثر تعداد نودی که از اون کشور استفاده می‌شه |
| `timeout` | ۳ تا ۶۰ ثانیه | ۱۵ ثانیه | حداکثر زمان انتظار برای جمع‌شدن نتایج همه‌ی نودها |

### بررسی همه‌ی انواع با هم

```js
GET /api/full/{country}/{host}
```

هر ۵ نوع تست را به‌صورت موازی اجرا می‌کند. مثال: `/api/full/all/example.com`

### لیست کشورها

```js
GET /nodes
```

لیست همه‌ی کد کشورهای موجود را برمی‌گرداند، به‌صورت زنده از `check-host.net/nodes/hosts` خونده و در حافظه کش می‌شود.

### مسیرهای قدیمی (Legacy)

```js
GET /{country}/{host}
GET /check/{country}/{host}
```

همیشه یک تست **ping** اجرا می‌کنند (فقط برای سازگاری با نسخه‌های قبلی نگه داشته شده‌اند — همینی که Cloudflare-Scamalytics ازش استفاده می‌کنه).

### فرم Query String

```js
GET /?host=<host>&country=<country>&type=<check_type>
```

معادل همون `/api/{type}/{country}/{host}` است؛ اینجا هم `country` اجباری است — ندادنش خطای ۴۰۰ برمی‌گرداند. اگه بدون پارامتر `host` باز بشه، فقط یک پیام راهنمای usage برمی‌گردونه.

## ساختار پاسخ

پاسخ `/api/{check_type}/{country}/{host}` این شکلی است:

```json
{
  "check_type": "ping",
  "host": "example.com",
  "country": "de",
  "is_accessible": true,
  "nodes_checked": 3,
  "elapsed_seconds": 2.14,
  "details": {
    "de1.node.check-host.net": { "status": "OK", "ping_ms": 24.5, "...": "..." }
  },
  "nodes_meta": { "...": "..." },
  "report_url": "https://check-host.net/check-report/<request_id>"
}
```

فیلدهای داخل `details` بسته به نوع تست فرق می‌کند:

| نوع | فیلدهای کلیدی |
| :---: | :--- |
| `ping` | `status`, `sent`, `received`, `loss_percent`, `ping_ms`, `ping_ms_min`, `ping_ms_avg`, `ping_ms_max` |
| `http` | `status`, `http_code`, `http_message`, `code_display`, `response_time_s`, `ip` |
| `tcp` / `udp` | `status` (`OK`/`FAIL`/`FILTERED` برای تایم‌اوت)، `ip`, `time_s` یا `error` |
| `dns` | `status`, `ips` (لیست رکوردهای A/AAAA), `ttl` |

اگر یک نود در زمان `timeout` جواب ندهد، `status: "TIMEOUT"` برای آن نود برمی‌گردد؛ کل درخواست fail نمی‌شود، فقط همان نود.

## کشینگ

لیست کشورها/نودها به مدت **۶ ساعت** در حافظه (in-memory) کش می‌شود تا هر درخواست باعث زدن مستقیم به check-host.net نشود؛ بعد از ۶ ساعت خودکار رفرش می‌شود.

## پیش‌نیازها

- **بدون نیاز به هیچ متغیر محیطی** — این سرویس کاملاً بدون کانفیگ کار می‌کند.
- Python 3 (برای اجرای محلی یا سلف‌هاست)

## اجرای محلی

```bash
python -m venv venv
source venv/bin/activate     # windows
venv\Scripts\activate
pip install -r requirements.txt
uvicorn api.index:app --reload --port 8000
```

مستندات تعاملی API در `http://localhost:8000/docs` در دسترس است.

## راهنمای دیپلوی

### روی Render

<div style="text-align:right">

۱. این ریپو رو Fork کن یا لینکش رو کپی کن برای وصل کردن به Render در بخش Web Service.

</div>

<div style="text-align:left">

:تنظیمات .۳
**Build Command:** `pip install -r requirements.txt`
**Start Command:** `uvicorn api.index:app --host 0.0.0.0 --port $PORT`

</div>

۴. برای پلن سرور، پلن رایگان (Free) رو انتخاب کن.

![صفحه‌ی New Web Service روی Render با Build/Start Command پر شده](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/check-host-api/pic.jpg)

### روی Vercel

این ریپو یک `vercel.json` هم دارد (که همه‌ی مسیرها را به `api/index` هدایت می‌کند)، پس مستقیماً با اتصال ریپو به Vercel هم قابل دیپلوی است، بدون تنظیم اضافه‌ای.

### روی هر هاست دیگری با پایتون (بدون داکر)

```bash
pip install -r requirements.txt
uvicorn api.index:app --host 0.0.0.0 --port 8000 --workers 2
```

اگر HTTPS و دامنه‌ی اختصاصی لازم داری، پشت Nginx یا Caddy قرارش بده.

## یک نکته

- `country` هیچ‌جا مقدار پیش‌فرض ندارد؛ هر درخواست باید صریحاً یک کد کشور بدهد (یا `all`)

## عیب‌یابی

- **خطای HTTP 502:** معمولاً به‌خاطر ریت‌لیمیت خودِ check-host.net است — چون این سرویس مجبوره برای جلوگیری از شلوغ شدن نودهاش محدودیت نرخ بگذاره. چند دقیقه بعد دوباره امتحان کن؛ کسی که این پروژه رو نگه‌داری می‌کنه داره دنبال راهی برای بهتر شدن این مورد می‌گرده
- **یک نود همیشه `TIMEOUT` برمی‌گرداند:** یا اون نود موقتاً از دسترس خارجه، یا مقدار `timeout` درخواست کوتاه‌تر از چیزیه که اون نود لازم داره — با پارامتر `timeout` (تا ۶۰ ثانیه) امتحان کن
- **`/nodes` لیست خالی یا قدیمی برمی‌گرداند:** کش ۶ ساعته‌ی نودها هنوز رفرش نشده؛ چند ساعت صبر کن یا سرویس رو ری‌استارت کن

## لینک‌های مرتبط

- ریپوی این سرویس: `https://github.com/mehdi-hexing/Check-Host-API`
- پروژه‌ای که از این سرویس استفاده می‌کند: `https://github.com/mehdi-hexing/Cloudflare-Scamalytics`
