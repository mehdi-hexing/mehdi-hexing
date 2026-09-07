---
layout: doc
outline: deep
lang: "fa-IR"
dir: "rtl"
title: "ECH-Workers — DoH Worker با انتخاب خودکار سریع‌ترین مسیر"
description: "مستندات ریپوی ECH-Workers — یه Cloudflare Worker که رکوردهای DNS-over-HTTPS (برای مواردی مثل ECH) رو از میان چند Resolver و چند پراکسی واسط، با بنچمارک خودکار و کش KV برمی‌گردونه"
date: 2026-9-25
editLink: true
head:
  - - meta
    - name: keywords
      content: DoH, DNS over HTTPS, ECH, Cloudflare Worker, Resolver, KV Cache
---

# ECH-Workers

## این پروژه چیه؟

یک **Cloudflare Worker** که رکوردهای DNS-over-HTTPS (DoH) را — از جمله مواردی که برای lookup کانفیگ ECH استفاده می‌شن — از میان چند **Resolver** (Cloudflare, Google, Quad9, NextDNS, OpenDNS) و چند **پراکسی واسط** برمی‌گرداند.

## نحوه‌ی کارکرد

۱. لیستی از ترکیب‌های (Resolver × پراکسی) ساخته می‌شود.
۲. همه‌ی این ترکیب‌ها با یک درخواست تست (`cloudflare.com`, نوع `A`) بنچمارک می‌شوند و نتیجه (سالم/ناسالم + تأخیر) به مدت **۱۰ دقیقه** در KV کش می‌شود.
۳. برای هر درخواست واقعی، یکی از ۵ مسیر سریع‌تر به‌صورت **تصادفی** انتخاب می‌شود (تا بار به‌جای یک مسیر ثابت، بین چند مسیر پخش شود).
۴. اگر مسیر انتخاب‌شده جواب نداد، تا **۴ بار** با مسیر دیگری از همان ۵تای برتر دوباره تلاش می‌شود.
۵. پاسخ موفق دامنه/نوع به مدت **۳ ساعت** در KV کش می‌شود تا درخواست‌های بعدی مستقیم از کش برگردند.

## اندپوینت‌ها

### `GET /`

فقط یک پیام راهنما با فرمت اندپوینت‌ها برمی‌گرداند.

### `GET /resolve/{domain}/{type?}`

رکورد DoH دامنه را برمی‌گرداند. `{type}` اختیاری است و پیش‌فرض `HTTPS` است.

```bash
curl https://your-worker.your-subdomain.workers.dev/resolve/example.com
curl https://your-worker.your-subdomain.workers.dev/resolve/example.com/A
```

### `GET /resolve/{domain}/{type?}/download`

همان پاسخ، ولی با هدر `Content-Disposition: attachment` تا مرورگر آن را به‌عنوان فایل دانلود کند (اسم فایل: `{domain}_{type}.json`).

### هدرهای پاسخ

| هدر | توضیح |
| --- | --- |
| `x-cache` | `HIT` یا `MISS` |
| `x-resolver-used` | کدام Resolver پاسخ داده (فقط در MISS؛ در HIT مقدار `cache`) |
| `x-proxy-used` | کدام پراکسی واسط استفاده شده (فقط در MISS) |
| `x-resolver-ms` | زمان پاسخ آن Resolver بر حسب میلی‌ثانیه |

پاسخ JSON خام هم قبل از برگشت پردازش می‌شود: رکوردهای نوع `HTTPS` (کد ۶۵) و `OPT` (کد ۴۱) به فیلدهای خوانا (`priority`, `target`, `params` برای HTTPS؛ `edns` برای OPT) شکسته می‌شوند، نه فقط یک رشته‌ی خام.

## Resolverها و پراکسی‌های پیش‌فرض

```js
// Resolverها
cloudflare, google, quad9, nextdns, opendns

// پراکسی‌های واسط
direct (بدون واسط), allorigins, corsproxy
```

::: tip `نکته`
این لیست‌ها سرویس‌های عمومی و رایگان‌اند، بدون تضمین آپ‌تایم؛ در صورت نیاز باید مستقیم در فایل `src/index.js` (ثابت‌های `DEFAULT_RESOLVERS` و `DEFAULT_PROXIES`) ویرایش و دوباره دیپلوی شوند.
:::

## پیش‌نیازها

- حساب کاربری **Cloudflare** (با Workers KV فعال).
- حساب کاربری **GitHub** (برای دیپلوی خودکار از طریق Actions)
- یک **API Token** اختصاصی کلادفلر (مراحل ساختش در ادامه)

## راه‌اندازی اولیه (یک‌بار)

۱. یک API Token کلادفلر با این دسترسی‌ها بساز:
- **Workers Scripts: Edit**
- **Workers KV Storage: Edit**
- **Account: Read**

مراحل: به [dash.cloudflare.com/profile/api-tokens](https://dash.cloudflare.com/profile/api-tokens) برو و سپس بر روی **Create Token** کلیک کن و قالب **«Edit Cloudflare Workers»** را انتخاب کن (این قالب خودکار KV Storage:Edit و Workers Scripts:Edit را اضافه می‌کند؛ Zone→Workers Routes:Edit را هم می‌گذارد که برای این پروژه لازم نیست و می‌تونی حذفش کنی)
یک دسترسی دیگر هم دستی اضافه کن:
**Account → Account Settings → Read** →
زیر «Account Resources» فقط همون اکانت مشخص خودت را انتخاب کن نه «All accounts»
**Continue to summary** → **Create Token**
و API TOKEN را به همراه AccountID همون‌جا کپی کن (فقط یک‌بار نشان داده می‌شود)
این پارامتر ها رو برای گیت هاب اکشن نیاز داریم پس مطمئن شو که رپو رو فورک کرده باشی.

۲. این دو Secret را در تنظیمات ریپوی فورک شده گیت‌هابت اضافه کن (Settings → Secrets and variables → Actions):

| Secret | مقدار |
| --- | --- |
| `CF_API_TOKEN` | همان توکنی که بالا ساختی |
| `CF_ACCOUNT_ID` | آی‌دی اکانت کلادفلرت |

## راهنمای دیپلوی

### خودکار

هر پوش به شاخه‌ی `main` که فایل‌های `src/**` یا `wrangler.toml` را تغییر بدهد، خودکار دیپلوی می‌شود.

### دستی (با اسم دلخواه برای Worker)

۱. به تب **Actions** در رپو برو.
۲. ورک‌فلوی **«Deploy Worker»** را انتخاب کن.
۳. **Run workflow** بزن.
۴. اختیاری: یک اسم دلخواه در فیلد `worker_name` بنویس (خالی بگذاری، همون اسم داخل `wrangler.toml` استفاده می‌شود).
۵. دوباره **Run workflow** بزن تا شروع شود.

## مدیریت KV Namespace

ورک‌فلوی دیپلوی خودش تضمین می‌کند دو KV Namespace وجود دارد: یکی برای کش پاسخ DNS (باقاعده `DNS_CACHE`) و یکی برای کانفیگ زمان اجرا (باقاعده `CONFIG_KV`).

- عنوان namespaceها از الگوی `{worker_name}-{binding}-{پسوند تصادفی}` پیروی می‌کند
- قبل از ساخت یک namespace جدید، ورک‌فلو چک می‌کند آیا از قبل namespaceای با همین پیشوند وجود دارد؛ اگر بود، همان استفاده می‌شود.
- یعنی اجرای مجدد دیپلوی با همان اسم Worker باعث ساخته‌شدن namespaceهای تکراری نمی‌شود‌.

## امنیت لاگ‌ها

ورک‌فلو به‌محض مشخص شدن API Token، Account ID و آی‌دی هر KV Namespace، آن‌ها را با مکانیزم `::add-mask::` گیت‌هاب اکشنز ماسک می‌کند. پاسخ‌های API فقط با `jq` پردازش می‌شوند و مستقیم در لاگ چاپ نمی‌شوند؛ ردیابی دستورات شل (`set -x`) هم در استپ ساخت درخواست‌های احرازهویت‌شده خاموش هست.

## عیب‌یابی

- **خطای ۵۰۲ (`no healthy route available`):** هیچ ترکیب Resolver+پراکسی‌ای در بنچمارک آخر جواب نداده؛ چند دقیقه صبر کن (کش بنچمارک هر ۱۰ دقیقه رفرش می‌شود) یا لیست پراکسی/Resolver را در کد بررسی کن
- **خطای ۵۰۲ (`all attempts failed`):** بنچمارک مسیرهای سالم پیدا کرده بود ولی هر ۴ تلاش واقعی fail شدند (فیلد `reason` دلیل آخرین تلاش را نشان می‌دهد)؛ معمولاً یعنی پراکسی‌های واسط عمومی موقتاً از کار افتاده‌اند
- **پاسخ خیلی کند است:** اگر `x-cache: MISS` باشد و بنچمارک تازه رفرش شده، طبیعی است — درخواست بعدی از کش (`HIT`) خیلی سریع‌تر برمی‌گردد

## لینک‌های مرتبط

- ریپوی این پروژه: `https://github.com/mehdi-hexing/ECH-Workers`
