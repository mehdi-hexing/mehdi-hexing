---
title: راه‌اندازی پراکسی MTProto تلگرام با Katabump
description: راهنمای گام‌به‌گام ساخت سرور و اجرای پراکسی MTProto تلگرام با استفاده از Katabump — از ثبت‌نام تا دریافت لینک پراکسی و صفحه‌ی وب اختصاصی
---

# راه‌اندازی پراکسی MTProto تلگرام با Katabump

## این روش چیه؟

روشی که با استفاده از **Katabump** (هاست رایگان Node.js/Python) می‌توان یک پراکسی **MTProto** اختصاصی برای تلگرام راه‌اندازی کرد. این نسخه یک تغییر کوچک نسبت به نسخه‌ی اصلی پروژه دارد: هر بار که سرور استارت می‌شود یک **secret تصادفی جدید** ساخته می‌شود و علاوه بر لینک داخل Console، یک **صفحه‌ی وب ساده** هم روی همان پورت در دسترس است که لینک پراکسی را با یک دکمه قابل کپی نشان می‌دهد.

> ⚠️ **یادآوری مهم:** پلن رایگان Katabump هر **۴ روز یک‌بار** نیاز به تمدید دستی (Renew) دارد. اگر سررسید رو فراموش کنید، سرور و پراکسی به‌طور کامل خاموش می‌شوند و باید دوباره استارتش کنید.

## پیش‌نیازها و لینک‌های لازم

برای این آموزش به این لینک‌ها نیاز است:

- پنل Katabump: `https://control.katabump.com`
- پروژه‌ی اصلی (برای مرجع): `https://github.com/alexbers/mtprotoproxy`

نیازی به مبهم‌سازی یا کامپایل نیست؛ کل پروژه با پایتون خام اجرا می‌شود و از قبل آماده‌ی آپلود است.

📦 **فایل پیوست (zip):**

[فایل zip آماده‌ی آپلود](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/mtprotoproxy-katabump[NeedToExtract].zip)

فایل بالا را extract کنید؛ محتوای آن (`mtprotoproxy.py`، `config.py` و پوشه‌ی `pyaes`) مستقیماً در مرحله‌ی آپلود فایل‌ها استفاده می‌شود.

## مرحله ۱: ثبت‌نام

برای شروع باید یک اکانت در Katabump بسازید. می‌توانید با جیمیل ثبت‌نام کنید. در فیلدهای **First Name** و **Last Name** هرکدام باید بیش از یک کاراکتر باشند. برای رمز عبور می‌توانید خودتان یک رمز وارد کنید یا از رمز پیشنهادی مرورگر استفاده کنید.

📷 تصویر ۱ از ۱۵:

![ثبت‌نام - فرم ساخت اکانت](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic.jpg)

📷 تصویر ۲ از ۱۵:

![ثبت‌نام - تکمیل اطلاعات و ورود](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic1-fa.jpg)

## مرحله ۲: ورود به داشبورد و ساخت سرور جدید

بعد از ورود به داشبورد Katabump، گزینه‌ی ساخت سرور جدید (Create Server) را بزنید.

📷 تصویر ۳ از ۱۵:

![داشبورد - دکمه ساخت سرور جدید](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic2.jpg)

📷 تصویر ۴ از ۱۵:

![انتخاب پلن رایگان سرور](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic3-fa.jpg)

📷 تصویر ۵ از ۱۵:

![ورود به پنل مدیریت سرور ساخته‌شده](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic4-fa.jpg)

## مرحله ۳: انتخاب محیط Python

در تب **Startup** پنل سرور، نوع محیط را روی **Python** بگذارید (نه Node.js)، چون پراکسی با پایتون اجرا می‌شود.

📷 تصویر ۶ از ۱۵:

![انتخاب محیط Python در تب Startup](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic5.jpg)

## مرحله ۴: پیدا کردن پورت عمومی سرور

هر سرور در Katabump یک **پورت عمومی اختصاصی** دارد که در بخش **Settings** سرور نمایش داده می‌شود. این پورت معمولاً یک عدد **پنج‌رقمی** است (مثلاً چیزی شبیه `25565` یا `31842`).

📷 تصویر ۷ از ۱۵ — نمونه‌ی پورت عمومی پنج‌رقمی در پنل:

![نمونه پورت عمومی پنج‌رقمی سرور](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic6.jpg)

## مرحله ۵: تنظیم پورت در config.py

عدد پورتی که در مرحله‌ی قبل پیدا کردید را داخل فایل `config.py` جایگزین کنید. توجه کنید عدد `25565` زیر فقط یک نمونه است و باید با پورت واقعی خودتان جایگزین شود:

```python
PORT = 25565  # replace with your own public port
```

⚠️ این تنها مقداری است که باید دستی تنظیم شود؛ بقیه‌ی موارد (secret و لینک‌ها) به‌صورت خودکار ساخته می‌شوند.

📷 تصویر ۸ از ۱۵:

![ویرایش PORT در config.py](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic7.jpg)

## مرحله ۶: آپلود فایل‌ها

فایل zip که در بخش پیش‌نیازها آورده شد را extract کنید. تمام فایل‌ها و پوشه‌ی `pyaes` باید مستقیماً (بدون پوشه‌ی تودرتو) داخل روت سرور یعنی `/home/container/` آپلود شوند — از طریق **Web File Manager** یا **SFTP**.

ساختار نهایی باید این‌شکلی باشد:

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

📷 تصویر ۹ از ۱۵:

![آپلود فایل‌ها از طریق File Manager](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic8.jpg)

📷 تصویر ۱۰ از ۱۵:

![فایل‌ها و پوشه pyaes بعد از آپلود](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic9.jpg)

## مرحله ۷: تنظیم Startup (entrypoint)

در تب **Startup** پنل، فیلد **PY FILE** (یا Main File / Entry Point) را پیدا کرده و دقیقاً این مقدار را وارد کنید:

```
mtprotoproxy.py
```

سپس **Save** را بزنید.

📷 تصویر ۱۱ از ۱۵:

![تنظیم فایل اجرایی در Startup](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic10.jpg)

## مرحله ۸: استارت سرور و دریافت لینک از Console

سرور را از پنل استارت کنید.

📷 تصویر ۱۲ از ۱۵:

![استارت کردن سرور از تب Console](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic11.jpg)

در تب Console، خطی مشابه زیر ظاهر می‌شود که همان لینک آماده‌ی پراکسی است (مقادیر IP، PORT و SECRET با اطلاعات واقعی سرور شما جایگزین می‌شوند):

```
tg: tg://proxy?server=IP&port=PORT&secret=SECRET
```

همین لینک را کپی کرده و در تلگرام باز کنید.

📷 تصویر ۱۳ از ۱۵:

![خروجی Console با لینک پراکسی](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic12.jpg)

## مرحله ۹: صفحه‌ی وب اختصاصی پراکسی

به‌جای کپی‌کردن دستی از داخل Console، می‌توانید همان آدرس سرور را در مرورگر باز کنید. جای `SERVER_IP` و `PORT` رو با IP و پورت واقعی سرور خودتون بذارید:

```
http://SERVER_IP:PORT/
```

📷 تصویر ۱۴ از ۱۵:

![باز کردن آدرس سرور در مرورگر](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic13.jpg)

یک صفحه‌ی ساده باز می‌شود که لینک پراکسی را در یک باکس قابل انتخاب نشان می‌دهد، همراه با دکمه‌ی **Copy** برای کپی سریع و یک لینک **Open in Telegram** برای باز شدن مستقیم در اپ. این صفحه با همان پورت اصلی پراکسی سرو می‌شود و نیازی به پورت جداگانه ندارد.

📷 تصویر ۱۵ از ۱۵:

![صفحه وب اختصاصی پراکسی با دکمه کپی](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/pic14.jpg)

## نکات پایانی

> ⚠️ **فراموش نکنید:** هر **۴ روز یک‌بار** باید وارد پنل Katabump شده و سرور را **Renew** کنید، در غیر این صورت سرور و پراکسی از کار می‌افتند.

- هر بار که سرور را **ری‌استارت** یا **Renew** می‌کنید، secret به‌صورت خودکار عوض می‌شود؛ لینک قبلی از کار می‌افتد و باید لینک جدید را از Console یا همان صفحه‌ی وب بردارید.
- پلن رایگان منابع محدودی دارد (۳۰۸ مگابایت RAM، ۲۵٪ از یک هسته CPU)؛ برای استفاده‌ی شخصی یا چند نفره کافی است.
- اگر پیام خطایی مثل `ModuleNotFoundError` یا `No such file` در Console دیدید، یعنی یا فایل `mtprotoproxy.py` سر جایش نیست یا پوشه‌ی `pyaes` کنارش آپلود نشده است.
