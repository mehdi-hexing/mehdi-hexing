---
title: HTTP-PROXY — آرشیو خودکار پروکسی‌های رایگان (HTTP/HTTPS/SOCKS4/SOCKS5)
description: مستندات ریپوی HTTP-PROXY — یک GitHub Actions که هر ۶ ساعت پروکسی‌های رایگان عمومی رو جمع، تست و بر اساس کشور/فراد-اسکور دسته‌بندی می‌کنه، به‌همراه کانفیگ‌های ساب آماده
---

# HTTP-PROXY

## این پروژه چیه؟

یک ریپو که به‌صورت **کاملاً خودکار** (بدون هیچ سروری، فقط با GitHub Actions) هر ۶ ساعت:

1. از **۸+ منبع عمومی** پروکسی (proxyscrape, TheSpeedX, monosans, ShiftyTR, iplocate, proxifly و...) لیست خام پروکسی می‌گیرد.
1. هر پروکسی را واقعاً از نظر اتصال تست می‌کند.
1. برای هر پروکسی زنده، کشور و **فراد-اسکور** (fraud score) می‌گیرد.
1. نتایج را به تفکیک پروتکل و کشور، هم به‌صورت txt هم CSV، ذخیره و در همان ریپو کامیت می‌کند.
1. چند فرمت کانفیگ اشتراک آماده (برای MahsaNG، V2rayNG، Exclave) هم با QR کد تولید می‌کند.

## اسکن کن و همین الان استفاده کن 📱

هر کدوم از این QR کدها همیشه با آخرین اسکن (هر ۶ ساعت) هم‌گام‌اند — مستقیم از خودِ ریپو لود می‌شن، پس همیشه به‌روزن:

<div align="center">

| **MahsaNG**<br>HTTP | **V2rayNG**<br>HTTP | **Exclave**<br>HTTP |
| :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/mahsang_http_qr.png" width="220" alt="QR کد MahsaNG HTTP"/> | <img src="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/v2rayng_http_qr.png" width="220" alt="QR کد V2rayNG HTTP"/> | <img src="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_http_qr.png" width="220" alt="QR کد Exclave HTTP"/> |

| **Exclave**<br>HTTPS | **Exclave**<br>SOCKS4 | **V2rayNG**<br>SOCKS5 | **Exclave**<br>SOCKS5 |
| :---: | :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_https_qr.png" width="220" alt="QR کد Exclave HTTPS"/> | <img src="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_socks4_qr.png" width="220" alt="QR کد Exclave SOCKS4"/> | <img src="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/v2rayng_socks5_qr.png" width="220" alt="QR کد V2rayNG SOCKS5"/> | <img src="https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_socks5_qr.png" width="220" alt="QR کد Exclave SOCKS5"/> |

</div>

هر کلاینت را که استفاده می‌کنی، QR متناظرش را با اسکنر داخل اپ اسکن کن — لینک اشتراک خودکار اضافه می‌شود. اگه ترجیح می‌دی لینک را دستی کپی کنی، جدول کامل با لینک‌های خام در بخش «لینک‌های اشتراک» پایین‌تر هست.

این پروژه‌ برای فراد-اسکور به پروژه [Cloudflare-Scamalytics](https://github.com/mehdi-hexing/Cloudflare-Scamalytics) متصله اینجویه که:
اگه نسخه‌ی Pages جواب نده، به نسخه‌ی Workers سوییچ می‌کند؛ اگه هر دو جواب ندهند، متادیتای پیش‌فرض (`Unknown`/`N/A`) برای آن پروکسی ثبت می‌شود — کل پروکسی از لیست حذف نمی‌شود، فقط ستون‌های کشور/ریسک خالی می‌مانند.

## نحوه‌ی کارکرد (خودکار، هر ۶ ساعت)

یک workflow گیت‌هاب اکشنز (`Scan_Proxies.yml`) به صورت خودکار و زمان‌بندی شده اجرا میشه و اتومات اسکن رو آغاز می‌کند:

1. لیست خام هر پروتکل را از منابع بالا می‌گیرد و با پول محلی قبلی (`Raw_Sources/raw_<protocol>.txt`) ادغام می‌کند (حداکثر ۳۰۰٬۰۰۰ ورودی نگه داشته می‌شود)
1. هر پروکسی را با حداکثر **۵۰ ترد هم‌زمان** تست می‌کند:

- برای `http`/`https`: یک درخواست به `clients3.google.com/generate_204` و سپس یک **Cross-check** جدا به `api.ipify.org` — اگر Cross-check رد شود، پروکسی به‌عنوان یک relay تک‌مصرفی (احتمال false-positive) کنار گذاشته می‌شود.
- برای `socks4`/`socks5`: یک درخواست به `gstatic.com/generate_204` (نیازمند کتابخانه‌ی `requests[socks]`/PySocks)

1. پروکسی‌های زنده بر اساس (کشور، فراد-اسکور) مرتب و در قالب‌های زیر ذخیره می‌شوند:

- `proxies/protocol/<protocol>/all.txt` و `all.csv` (لیست جهانی)
- `proxies/countries/<protocol>/<CC>.txt` و `<CC>.csv` (به تفکیک کد کشور؛ کشورهای نامشخص در `UNKNOWN`)

1. فایل‌های اشتراک (`proxies/subscriptions/`) و QR کدهایشان ساخته می‌شوند و جدول داخل `README.md` بین دو کامنت `SUBSCRIPTION_TABLE_START/END` خودکار به‌روزرسانی می‌شود.
1. تغییرات با کاربر `github-actions[bot]` کامیت و پوش می‌شوند.

## ستون‌های فایل CSV

| ستون | توضیح |
| --- | --- |
| Proxy | آدرس `ip:port` |
| Protocol | HTTP/HTTPS/SOCKS4/SOCKS5 |
| Country / Country Code / Flag | از متادیتای Cloudflare-Scamalytics |
| Fraud Score / Risk | فراد-اسکور و سطح ریسک |
| VPN | آیا این IP به‌عنوان VPN شناخته شده |
| ISP | ارائه‌دهنده‌ی سرویس اینترنت |
| Latency (ms) | زمان پاسخ در لحظه‌ی تست |

## سازگاری با Psiphon

پروکسی‌های تأییدشده در Psiphon هم قابل استفاده‌اند:

۱. Psiphon را باز کن
۲. **Options → More Options**
۳. تیک **Upstream Proxy** را بزن
۴. یکی از پروکسی‌ها و پورت‌های زنده‌ی لیست را وارد کن

## لیست‌های زنده

### لیست جهانی (هر پروتکل)

```
proxies/protocol/{http,https,socks4,socks5}/all.txt
proxies/protocol/{http,https,socks4,socks5}/all.csv
```

### لیست به تفکیک کشور

```
proxies/countries/{http,https,socks4,socks5}/{CC}.txt
proxies/countries/{http,https,socks4,socks5}/{CC}.csv
```

### لینک‌های اشتراک (برای import مستقیم در کلاینت)

QR کدهای این لینک‌ها بالای همین صفحه هستن؛ این‌جا فقط خودِ لینک‌های خام برای کپی دستی:

| کلاینت | پروتکل | لینک خام (کپی‌کردنی) |
| --- | --- | --- |
| **MahsaNG** | HTTP | `https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/mahsang_http.txt` |
| **V2rayNG** | HTTP | `https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/v2rayng_http.txt` |
| **Exclave** | HTTP | `https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_http.txt` |
| **Exclave** | HTTPS | `https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_https.txt` |
| **Exclave** | SOCKS4 | `https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_socks4.txt` |
| **V2rayNG** | SOCKS5 | `https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/v2rayng_socks5.txt` |
| **Exclave** | SOCKS5 | `https://raw.githubusercontent.com/mehdi-hexing/HTTP-PROXY/main/proxies/subscriptions/exclave_socks5.txt` |

## اجرای محلی (اختیاری)

```bash
pip install -r requirements.txt   # requests[socks] و qrcode[pil]
python Scanner.py
```

- اگر `requests[socks]` نصب نباشد، پروکسی‌های socks4/socks5 با دلیل `missing_pysocks_dependency` رد می‌شوند (نه کرش کل اسکریپت)
- اگر `qrcode` نصب نباشد، فقط تولید QR کد غیرفعال می‌شود؛ بقیه‌ی اسکن ادامه پیدا می‌کند

## نکات مهم

- **این پروژه هیچ سرویس زنده/API‌ای ندارد** — فقط یک آرشیو خودکار از فایل‌های استاتیک است که هر ۶ ساعت به‌روز می‌شود.
- طبق هشدار خودِ اسکریپت: پروکسی‌های رایگان عمومی ممکن است در عرض چند دقیقه بعد از تأیید از کار بیفتند؛ همیشه از تازه‌ترین اسکن استفاده کن و در CSV به ستون **Latency** کمتر اولویت بده.
- درباره نکته بالایی درواقع شما میتونین از کانفیگ های بالانسر (Balancer) در کلاینت های V2rayNG با نام Policy Group و در Exclave با همون اسم بالانسر، لینک سابتون رو که وارد کردین و کانفیگ ها لود شد، بیاین همون کانفیگ ها رو بر اساس کمترین پینگ URL Test جدا کنین و در سایفون ازشون استفاده کنین. پیشنهاد خودم استفاده از بالانسر Exclave هست.

## عیب‌یابی

- **یک پروکسی که در CSV هست کار نمی‌کند:** طبیعی است؛ پروکسی‌های رایگان عمر کوتاهی دارند. منتظر اسکن بعدی (حداکثر ۶ ساعت دیگر) بمان
- **ستون‌های Country/Fraud Score خالی یا `Unknown`اند:** یعنی هم نسخه‌ی Pages هم نسخه‌ی Workers سرویس Cloudflare-Scamalytics در لحظه‌ی اسکن جواب نداده‌اند؛ خودِ پروکسی هنوز معتبر است، فقط متادیتایش گم شده
- **Workflow جدید commit نمی‌کند:** اگر هیچ پروکسی‌ای تغییر نکرده باشد (`git diff --quiet`)، عمداً کامیت خالی زده نمی‌شود؛ این خطا نیست

## لینک‌های مرتبط

- ریپوی این پروژه: `https://github.com/mehdi-hexing/HTTP-PROXY`
- منبع فراد-اسکور: `https://github.com/mehdi-hexing/Cloudflare-Scamalytics`
