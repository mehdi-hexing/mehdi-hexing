---
title: ProxyIP-Tel-Bot — ربات تلگرام چک ProxyIP با پشتیبانی گروه/کانال
description: مستندات ریپوی ProxyIP-Tel-Bot — ربات پایتونی تلگرام برای تست پروکسی‌آی‌پی، رنج، دامنه و فایل، با تست زنده‌ی قابل Pause/Resume، ارسال خودکار به کانال/گروه، و ریسک‌اسکور با API رسمی Scamalytics + بازگشت خودکار به میرور عمومی
---

# ProxyIP-Tel-Bot

## این پروژه چیه؟

یک **ربات تلگرام** (پایتون) برای تست پروکسی‌آی‌پی — یک IP‏ تکی، یک رنج، همه‌ی آی‌پی‌های پشت یک دامنه، یا لیستی از یک فایل — که نتیجه رو با جزئیات کامل (تأخیر، کشور، ریسک‌اسکور) برمی‌گردونه.

![خروجی /start](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/proxyip-tel-bot/pic.jpg)

## معماری

سه بخش مجزا که با هم کار می‌کنن:

| بخش | نقش |
| --- | --- |
| **Backend API (پایتون)** | فقط تست اتصال TCP‏ خام رو انجام می‌ده؛ روی Render یا سرور شخصی دیپلوی می‌شه. |
| **Cloudflare Worker** | قلب سیستم؛ اندپوینت اصلی برای بات. برای هر پروکسی، همه‌ی آدرس‌های داخل `apiUrls`‏ **و** یک تست مستقیم TCP‏ از خودِ Worker‏ رو هم‌زمان (موازی) امتحان می‌کنه؛ هرکدوم زودتر جواب موفق بده همون قبول می‌شه — فقط وقتی fail می‌شه که **همه‌شون** (همه‌ی Backend API‏ها + TCP‏ مستقیم) شکست بخورن. |
| **بات تلگرام (پایتون)** | بخش رو-به-کاربر؛ روی سرور خودت اجرا می‌شه و با Cloudflare Worker‏ حرف می‌زنه. |

```
User → Telegram Bot → Cloudflare Worker → ( Backend API (Render/Server) + Cloudflare-Scamalytics API )
```

نکته‌ی مهم: Worker‏ِ این بات اول سعی می‌کنه از **API رسمی Scamalytics** (با یوزرنیم و کلید واقعی، اگه تنظیم شده باشن) ریسک‌اسکور بگیره. اگه این متغیرها اصلاً تنظیم نشده باشن، یا API رسمی خطا بده، quota تموم شده باشه یا پاسخ غیرمعتبر برگردونه، Worker خودکار به همون **میرور عمومی خودِ پروژه‌ی [Cloudflare-Scamalytics](https://mehdi-hexing.github.io/mehdi-hexing/topics/Cloudflare-Scamalytics)** سوییچ می‌کنه (همون `cloudflare-scamalytics.pages.dev`‏ که مستند کردیم). حتی اطلاعات جغرافیایی/ISP‏ هم همین فال‌بک رو دارن: اول `ip-api.com`‏، بعد همون میرور. یعنی **ثبت‌نام Scamalytics اختیاریه** — بات بدون هیچ اکانت Scamalytics‏ هم کار می‌کنه، فقط دقت ریسک‌اسکور (چون از میرور عمومی میاد نه اکانت اختصاصی خودتون) یه‌کم پایین‌تره.

## قابلیت‌ها

- **چند حالت تست:** `/proxyip`‏ (تک/چند IP)، `/iprange`‏، `/domain`‏، `/file`‏ (از روی یک URL‏ فایل)
- **پروکسی‌های رایگان:** `/freeproxyip`‏ با یک منوی کشوری ۳ستونه و مرتب‌شده (منبع: یک ریپوی عمومی جدا)

  ![منوی کشوری /freeproxyip](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/proxyip-tel-bot/pic3.jpg)
- **تست زنده‌ی تعاملی:** پیام نتیجه به‌صورت زنده آپدیت می‌شه، با دکمه‌های **Pause / Resume / Cancel**

  ![نتیجه‌ی /proxyip برای یک IP، همراه با دکمه‌های Pause/Cancel](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/proxyip-tel-bot/pic1.jpg)
- **۵ فرمت خروجی قابل انتخاب** بعد از پایان هر تست: Detailed Info، Rich Table (Collapsible)، Copyable IPs، Files (TXT/CSV)، یا All Formats

  ![منوی انتخاب فرمت خروجی](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/proxyip-tel-bot/pic2.jpg)
- **ارسال به کانال/گروه:**
  - `/addchat`‏ — ثبت چندمرحله‌ای یک کانال/گروه مقصد
  - `/deletechat`‏ — منوی تعاملی برای حذف یک چت ثبت‌شده
  - `/post`‏ — اجرای هر نوع تست در پس‌زمینه و ارسال خودکار نتیجه‌ی تمیزشده به مقصد ثبت‌شده
- **منطق محاوره‌ای:** در چت خصوصی هم می‌تونی مستقیم آرگومان بدی (`/proxyip 1.1.1.1`‏) و هم محاوره‌ای پیش بری؛ در گروه‌ها فقط حالت مکالمه‌ای/ریپلای فعاله (برای پایداری بیشتر)
- **تجربه‌ی کاربری:** شماره‌گذاری با ایموجی برای تست چند-دامنه، حذف خودکار پیام‌های موقت، راهنمای خطا برای دستورات نادرست.

![محیط بات حین اجرای /post — نوار پیشرفت زنده، قبل از اینکه نتیجه‌ی نهایی پست بشه تو کانال/گروه](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/proxyip-tel-bot/pic4.jpg)

## دستورات بات

| دستور | کاربرد |
| --- | --- |
| `/start`‏ | شروع و معرفی بات |
| `/proxyip <ip[:port]>`‏ | تست یک یا چند پروکسی‌آی‌پی |
| `/iprange <cidr>`‏ | تست یک بازه‌ی آی‌پی |
| `/domain <domain>`‏ | تست همه‌ی آی‌پی‌های پشت یک دامنه |
| `/file <url>`‏ | تست لیست آی‌پی از روی یک فایل خام |
| `/freeproxyip`‏ | نمایش منوی کشوری پروکسی‌های رایگان |
| `/addchat`‏ | ثبت یک کانال/گروه مقصد برای `/post`‏ |
| `/deletechat`‏ | حذف یک چت ثبت‌شده |
| `/post`‏ | اجرای یک تست و ارسال نتیجه به یک چت ثبت‌شده |
| `/cancel`‏ | لغو هر مکالمه‌ی در حال انجام |

## پیش‌نیازها

- یک **توکن ربات تلگرام** از [@BotFather](https://t.me/BotFather)
- حساب کاربری **Cloudflare** (رایگان)
- یک سرور/ماشین با **Python 3.8+**‏ و دستور `screen`‏ نصب‌شده
- حساب کاربری **GitHub**
- حساب کاربری **Vercel** (فقط اگه گزینه‌ی Vercel رو برای Backend انتخاب کنی وگرنه می‌تونی در Render هم دپلوی کنی)
- حساب کاربری **Scamalytics** — **اختیاری** (برخلاف چیزی که README رسمی می‌گه، اجباری نیست؛ بدون اون هم Worker خودکار به میرور عمومی سوییچ می‌کنه، فقط دقت ریسک‌اسکور یه‌کم کمتره)

## راهنمای دیپلوی (۴ بخش)

### بخش ۱ — دیپلوی Backend API

فقط **یکی** از این گزینه‌ها رو انتخاب کن (می‌تونی چندتا هم دیپلوی کنی و همه رو تو `apiUrls`‏ بذاری تا Worker به‌صورت موازی امتحانشون کنه — رجوع کن به توضیح بخش «معماری»):

**گزینه‌ی الف) Vercel (پیشنهادی، ساده‌تر):**
۱. به ریپوی [ProxyIP-Checker-Vercel-API](https://github.com/mehdi-hexing/ProxyIP-Checker-Vercel-API) برو
۲. روی دکمه‌ی «Deploy» تو README همون ریپو بزن
۳. آدرس نهایی (مثل `https://my-proxy-checker.vercel.app`‏) رو ذخیره کن — برای بخش ۳ لازمش داری

**گزینه‌ی ب) سلف‌هاست روی سرور شخصی:**
```bash
git clone https://github.com/mehdi-hexing/ProxyIP-Checker-API.git
cd ProxyIP-Checker-API
pip install -r requirements.txt

screen -S tcp-api
python main.py --port 8080
# Press Ctrl+A then D to detach
```
آدرس نهایی: `http://Your_Server_IP:8080`‏ (مطمئن شو پورت تو فایروال بازه)

**گزینه‌ی ج) Render:**
همین ریپو (`ProxyIP-Checker-API`‏) روی Render هم قابل دیپلویه — دقیقاً همون سرویسیه که برای پروژه‌ی CF-ProxyIPChecker مستند کردیم. مراحل کامل (Build/Start Command، env varها، نکته‌ی Cold Start) رو همون‌جا نوشتیم، پس اینجا تکرارش نمی‌کنم: [راهنمای دیپلوی Render](https://mehdi-hexing.github.io/mehdi-hexing/topics/CF-ProxyIPChecker)

### بخش ۲ — راه‌اندازی Scamalytics (اختیاری، ولی توصیه‌شده)

می‌تونی این بخش رو کامل رد کنی — بات بدون اون هم کار می‌کنه (از میرور عمومی استفاده می‌کنه). ولی برای ریسک‌اسکور دقیق‌تر و بدون وابستگی به در دسترس بودن سرویس یه نفر دیگه، بهتره اکانت اختصاصی خودتون رو بسازید:

۱. در [Scamalytics.com](https://scamalytics.com/) با پلن **رایگان** ثبت‌نام کن
۲. ایمیلت رو تأیید کن و منتظر بمون تا دسترسی API دستی تأیید بشه (تا ۲۴ ساعت طول می‌کشه)
۳. بعد از تأیید، **Username** و **API Key** رو از داشبورد Scamalytics بردار

### بخش ۳ — پیکربندی و دیپلوی Cloudflare Worker

۱. این ریپو (`ProxyIP-Tel-Bot`‏) رو **Fork** کن
۲. تو ریپوی فورک‌شده، فایل `_worker.js`‏ رو باز کن و آرایه‌ی `apiUrls`‏ رو با آدرس Backend API از بخش ۱ جایگزین کن:
```javascript
const apiUrls = [
  `https://<Your_Vercel_or_Server>/api/v1/check?proxyip=${encodeURIComponent(proxyIPInput)}`,
  `https://<Your_Vercel_or_Server>/api/v1/check?proxyip=${encodeURIComponent(proxyIPInput)}`
];
```
۳. تغییرات رو Commit کن
۴. تو داشبورد Cloudflare: **Workers & Pages** ← «Create application» ← «Pages» ← «Connect to Git» ← ریپوی فورک‌شده رو انتخاب کن ← Framework preset رو روی **None** بذار ← **Save and Deploy**
۵. تو تنظیمات پروژه (**Settings → Environment variables**) این متغیرها رو اضافه کن:

| متغیر | مقدار | اجباری |
| --- | --- | --- |
| `SCAMALYTICS_USERNAME`‏ | یوزرنیم Scamalytics شما | خیر (بدونش، fallback به میرور عمومی) |
| `SCAMALYTICS_API_KEY`‏ | کلید API شما | خیر (همون‌طور بالا) |
| `SCAMALYTICS_API_BASE_URL`‏ | آدرس Base URL اختصاصی Scamalytics شما | خیر |

۶. آدرس Worker (مثل `https://your-bot-worker.pages.dev`‏) رو کپی کن — این می‌شه `WORKER_URL`‏ بخش بعدی

### بخش ۴ — اجرای بات تلگرام

۱. ریپوی فورک‌شده رو روی سرور خودت clone کن و وابستگی‌ها رو نصب کن:
```bash
git clone https://github.com/mehdi-hexing/ProxyIP-Tel-Bot.git
cd ProxyIP-Tel-Bot
pip install -r requirements.txt
```

۲. **یک مرحله‌ی مهم که تو README اصلی نیومده:** قبل از اجرا، فایل `proxy-ip-bot.py`‏ رو باز کن و خط زیر رو با آدرس Worker واقعی خودت (از بخش ۳) جایگزین کن — این مقدار به‌صورت هاردکد تو کده، نه یک متغیر محیطی:
```python
WORKER_URL = "https://Your-Checker.pages.dev"  # Replace this with your own Worker URL
```
اگه این مرحله رو فراموش کنی، بات همچنان روی آدرس Placeholder اجرا می‌شه و همه‌ی تست‌ها fail می‌شن.

۳. متغیر محیطی `BOT_TOKEN`‏ رو تنظیم کن:
```bash
export BOT_TOKEN="Your_Bot_Token"    # Linux/macOS
```
(برای دائمی‌کردنش، همین خط رو به `~/.bashrc`‏ اضافه کن)

۴. بات رو داخل یک نشست `screen`‏ اجرا کن:
```bash
screen -S proxybot
python proxy-ip-bot.py
# Press Ctrl+A then D to detach
```

برای برگشتن به نشست: `screen -r proxybot`‏ — برای توقف بات: دوباره وصل شو و `Ctrl+C`‏ بزن.

## نکات مهم

- منبع داده‌ی `/freeproxyip`‏ یک ریپوی **شخص‌ثالث** (`NiREvil/vless`‏) روی گیت‌هابه، نه دیتای تولیدشده توسط خودم
- اگه اکانت اختصاصی Scamalytics تنظیم نکنی (یا اون از کار بیفته)، هم ریسک‌اسکور هم اطلاعات جغرافیایی از همون میرور عمومی پروژه‌ی Cloudflare-Scamalytics گرفته می‌شه — یعنی این بات عملاً به در دسترس بودن اون سرویس هم وابسته‌ست.

## عیب‌یابی

- **همه‌ی تست‌ها fail می‌شن:** به احتمال زیاد یادت رفته `WORKER_URL`‏ رو تو `proxy-ip-bot.py`‏ عوض کنی (بخش ۴، مرحله‌ی ۲)
- **ریسک‌اسکور نشون داده نمی‌شه یا خطا می‌ده:** چون یه فال‌بک خودکار به میرور عمومی وجود داره، این نادره. اگه دیدی، هم مقادیر `SCAMALYTICS_USERNAME`‏/`SCAMALYTICS_API_KEY`‏/`SCAMALYTICS_API_BASE_URL`‏ (اگه تنظیمشون کردی) رو چک کن، هم مطمئن شو خودِ `cloudflare-scamalytics.pages.dev`‏ (میرور فال‌بک) در دسترسه
- **بات بعد از قطع اتصال SSH متوقف می‌شه:** مطمئن شو داخل `screen`‏ اجراش کردی، نه مستقیم تو ترمینال
- **`/post`‏ نتیجه رو تو کانال/گروه پست نمی‌کنه:** مطمئن شو بات تو اون چت ادمینه و دسترسی «Post Messages» رو داره، و اینکه چت با `/addchat`‏ درست ثبت شده

## لینک‌های مرتبط

- ریپوی این پروژه: `https://github.com/mehdi-hexing/ProxyIP-Tel-Bot`
- Backend (Vercel): `https://github.com/mehdi-hexing/ProxyIP-Checker-Vercel-API`
- Backend (Python — Render): `https://github.com/mehdi-hexing/ProxyIP-Checker-API`
