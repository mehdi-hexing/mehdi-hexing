---
title: Domain-Resolve — ابزار Resolve و گروه‌بندی آی‌پی برای بررسی ریسک ساب‌دامنه های حاوی آیپی های انبوه
description: مستندات ریپوی Domain-Resolve — سرویس کمکی که Cloudflare-Scamalytics برای دور زدن محدودیت SubRequest ورکر روی ساب‌دامنه‌های با بیش از ۵۰ آی‌پی ازش استفاده می‌کنه
---

# Domain-Resolve

## این پروژه برای چه مشکلی ساخته شد؟

Cloudflare Workers برای هر اجرا یک سقف مشخص روی تعداد **Subrequest** (درخواست‌های خروجی) داره. وقتی پروژه‌ی [Cloudflare-Scamalytics](https://mehdi-hexing.github.io/mehdi-hexing/topics/Cloudflare-Scamalytics) می‌خواست ریسک‌اسکور یک دامنه رو بررسی کنه، اگه اون دامنه پشتش بیشتر از ۵۰ آی‌پی داشت، تلاش برای گرفتن ریسک تک‌تک آن‌ها به Scamalytics باعث پر شدن سقف SubRequest ورکر می‌شد و کل عملیات با لیمیت مواجه می‌شد.

**Domain-Resolve**برای حل همین مشکل ساخته شده: به‌جای اینکه خودِ Worker مستقیم DNS دامنه رو resolve کنه و همه‌ی آی‌پی‌ها رو یک‌جا به Scamalytics بفرسته، این سرویس واسط این کارها رو انجام می‌ده:

1. دامنه رو resolve می‌کند (هم رکورد A هم AAAA)
1. آی‌پی‌ها را بر اساس طول رشته و سپس به‌ترتیب حروفی/عددی مرتب می‌کند. (بعدا میفهمی چرا این کار رو انجام دادم.)
1. آن‌ها را به گروه‌های حداکثر **۴۰ تایی** تقسیم می‌کند، چون که حد لیمیت SubRequest های ورکر ، 50 تا SubRequest هست.

سپس ورکر Cloudflare-Scamalytics اندپوینت را با fetch فراخوانی می‌کند، سپس رشته‌ی JSON پاسخ را می‌خواند و هر گروه ۴۰تایی را جداگانه برای ریسک‌سنجی به Scamalytics می‌فرستد — بدون اینکه سقف Subrequest پر شود.

اگرچه از نظر ساختار کد یک سرویس کاملاً مجزاست (ریپو و دیپلوی جدا)، اما از نظر عملکردی بخشی از زیرساخت Cloudflare-Scamalytics به‌حساب می‌آید.

<div style="text-align:right">

> یه نکته خواستم بگم بهتون اونم اینه که، از اونجایی که به خاطر محدودیت SubRequest در طرح رایگان کلادفلر مجبوریم از این روش استفاده کنیم، تعداد Request های ورکرمون میره بالا.

</div>

## نحوه‌ی کارکرد

```js
Cloudflare-Scamalytics Worker → fetch → domain-resolve (/resolve?domain=...) → JSON Response
```

### اندپوینت `/resolve`

```js
GET /resolve?domain=<domain>
```

یه مثال واسه درخواست زدن بگم که بهتر بفهمی:

```bash
curl "https://domain-resolve.onrender.com/resolve?domain=tr.diam4.ggff.net"
```

نمونه‌ی پاسخ واقعی:

```json
{
  "success": true,
  "domain": "tr.diam4.ggff.net",
  "total_ips": 29,
  "total_groups": 1,
  "groups": [
    ["3.29.240.49", "45.89.52.85", "130.94.1.150", "..."]
  ]
}
```

**فیلدهای پاسخ:**

| فیلد | نوع | توضیح |
| --- | --- | --- |
| `success` | boolean | نتیجه‌ی موفق بودن resolve |
| `domain` | string | دامنه‌ای که بررسی شده (بعد از پاک‌سازی از `http(s)://` و مسیر) |
| `total_ips` | number | تعداد کل آی‌پی‌های یکتا (IPv4 + IPv6) پیدا شده |
| `total_groups` | number | تعداد گروه‌های ۴۰تایی ساخته‌شده |
| `groups` | array of array of string | آی‌پی‌ها، تقسیم‌شده به دسته‌های حداکثر ۴۰تایی |

اگر پارامتر `domain` ارسال نشود، پاسخ خطای ۴۰۰ برمی‌گردد. اگر دامنه هیچ آی‌پی‌ای نداشته باشد، پاسخ ۴۰۴ همراه با `total_ips: 0` و `groups: []` برمی‌گردد. در صورت خطای DNS، پاسخ ۵۰۰ همراه با پیام خطا برمی‌گردد.

### منطق مرتب‌سازی و گروه‌بندی

آی‌پی‌ها ابتدا بر اساس **طول رشته** (تعداد کاراکتر) و در صورت برابر بودن طول، به‌صورت الفبایی/رقمی مرتب می‌شوند — این ترتیب برای آی‌پی‌های IPv4 هم‌طول عملاً همان ترتیب عددی صحیح را نتیجه می‌دهد. سپس آرایه‌ی مرتب‌شده به قطعات ۴۰تایی (`groupSize = 40`) بریده می‌شود.

### اندپوینت `/health`

```js
GET /health
```

فقط برای بررسی زنده‌بودن سرویس (health check)، بدون پارامتر؛ پاسخ ساده‌ی `{ "status": "ok" }` برمی‌گرداند — مثلاً برای مانیتورینگ یا برای پینگ دوره‌ای جهت جلوگیری از خواب رفتن سرویس روی پلن رایگان مفید است.

## بک اِند رپو

سرویس با **Node.js + Express** نوشته شده و از ماژول داخلی `dns/promises` برای resolve کردن دامنه استفاده می‌کند؛ هیچ دیتابیس یا وابستگی سنگینی ندارد.

```json
"dependencies": {
    "cors": "^2.8.5",
    "express": "^4.19.2"
}
```

## پیش‌نیازها

- حساب کاربری **GitHub میخوای واسه فورک کردن رپو یا اینکه از لینک رپوی من که پایین گذاشتم واست استفاده کنی.**
- حساب کاربری روی هر پلتفرم دپلوی رایگان Node.js (در ادامه پلتفرم برای دپلوی شده).
- **بدون نیاز به متغیر محیطی خاص** — سرویس بدون هیچ کانفیگی هم آماده‌ی اجراست.

## راهنمای استقرار

چون این سرویس فقط یک اپ ساده‌ی Express است، روی هر پلتفرم Node.js قابل اجراست. در حال حاضر (۲۰۲۶)، **Render** گزینه‌ای واقعاً رایگان و بدون نیاز به تمدید دستیه. (برای اطلاع: Railway دیگه پلن رایگان دائمی نداره و Glitch از ژوئیه‌ی ۲۰۲۵ میزبانی اپ رو کاملاً متوقف کرده و Vercel هم یه مقدار حساس ئه و بن میکنه اکانت رو.)

### دیپلوی روی Render (رایگان، دائمی)

۱. وارد داشبورد [Render](https://render.com) شو و روی **New کلیک کن**
و سپس روی **Web Service** بزن.
۲. ریپوی `domain-resolve` را از گیت‌هاب متصل کن (یا اول Fork کن)
۳. تنظیمات را وارد کن:
- **Build Command:** `npm install`
- **Start Command:** `node server.js`
- **Plan:** Free

![صفحه‌ی New Web Service روی Render با Build/Start Command پر شده](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/domain-resolve/pic.jpg)

۴. روی **Create Web Service** بزن؛ بعد از پایان بیلد، یک نشانی HTTPS دائمی (مثل `https://domain-resolve.onrender.com`) دریافت می‌کنی

> **نکته‌ی پلن رایگان:** بعد از مدتی بی‌فعالیتی، سرویس می‌خوابد و اولین درخواست بعدی چند ثانیه Cold Start می‌خورد. برای بیدار نگه‌داشتنش می‌توانی همان اندپوینت `/health` را با یک Cron/Ping دوره‌ای (مثلاً هر ۱۰ دقیقه) صدا بزنی.

### تست بعد از دپلوی

```bash
curl "https://<your-deployed-url>/resolve?domain=google.com"
curl "https://<your-deployed-url>/health"
```

## اتصال به Worker

در Cloudflare-Scamalytics، کافیست همان‌جایی که دامنه بیش از ۵۰ آی‌پی دارد، به‌جای resolve مستقیم، یک `fetch` به همین اندپوینت زده شود:

```js
const res = await fetch(`https://domain-resolve.onrender.com/resolve?domain=${encodeURIComponent(domain)}`);
const data = await res.json();
// data.groups یک آرایه از آرایه‌های حداکثر ۴۰ آی‌پی است؛
// هر گروه را جداگانه برای ریسک‌سنجی به Scamalytics بفرست
```

## عیب‌یابی

- **خطای ۴۰۰ (`Domain query parameter is required`):** پارامتر `domain` در URL فراموش شده
- **خطای ۴۰۴ با `total_ips: 0`:** دامنه هیچ رکورد A یا AAAA معتبری ندارد
- **خطای ۵۰۰:** خطای DNS (مثلاً دامنه اصلاً وجود ندارد)؛ پیام دقیق در فیلد `details` برمی‌گردد
- **سرویس کند بالا می‌آید:** طبیعی است اگر روی پلن رایگان Render باشد (Cold Start)؛ با پینگ دوره‌ای اندپوینت `/health` قابل رفع است.

## لینک‌های مرتبط

- ریپوی این سرویس: `https://github.com/mehdi-hexing/Domain-Resolve`
- پروژه‌ی اصلی که از این سرویس استفاده می‌کند: `https://github.com/mehdi-hexing/Cloudflare-scamalytics`
