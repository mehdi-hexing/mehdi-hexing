---
layout: doc
outline: deep
lang: "fa-IR"
dir: "rtl"
title: "راه‌اندازی پراکسی تلگرام با Katabump"
description: "راهنمای گام‌به‌گام ساخت سرور و اجرای پراکسی MTProto تلگرام با استفاده از Katabump"
date: 2026-10-6
editLink: true
head:
  - - meta
    - name: keywords
      content: MTProto, SOCKS5, HTTP Proxies, Action github, Python, Free Proxy, Telegram Proxies,MT-Proto protocol
---

# راه‌اندازی پراکسی MTProto تلگرام با Katabump

## این روش چیه؟

روشی که با استفاده از <Badge type="danger" text="Katabump" />
(سرویس هاست رایگان Node.js/Python) می‌توان یک پروکسی <Badge type="danger" text="MTProto" /> اختصاصی برای تلگرام راه‌اندازی کرد. این نسخه یک تغییر کوچک نسبت به نسخه‌ی اصلی پروژه دارد: هر بار که سرور استارت می‌شود یک **secret تصادفی جدید** ساخته می‌شود و علاوه بر لینک داخل Console، یک **صفحه‌ی وب ساده** هم روی همان پورت در دسترس است که لینک پراکسی را با یک دکمه قابل کپی نشان می‌دهد.

::: tip **نکته مهم**  
پلن رایگان Katabump هر **۴ روز یک‌بار** نیاز به تمدید دستی (Renew) دارد. اگر سررسید رو فراموش کنید، سرور و پراکسی به‌طور کامل خاموش می‌شوند و باید دوباره استارتش کنید.  
:::

## پیش‌نیازها و لینک‌های لازم

برای این آموزش به این لینک‌ها نیاز است:

- [لینک پنل Katabump][1]
- [لینگ پروژه‌ی اصلی (برای مرجع)][2]

نیازی به مبهم‌سازی یا کامپایل نیست؛ کل پروژه با پایتون خام اجرا می‌شود و از قبل آماده‌ی آپلود است.

📦 **فایل پیوست (zip):**

- [فایل zip آماده‌ی آپلود][3]

::: info **نکته**  
فایل بالا را <Badge type="danger" text="Extract" /> کنید؛ محتوای آن  
(`mtprotoproxy.py`، `config.py` و پوشه‌ی `pyaes`)   
مستقیماً در مرحله‌ی آپلود فایل‌ها استفاده می‌شود.   
:::

<br/>

## مرحله ۱: ثبت‌نام

برای شروع باید یک اکانت در Katabump بسازید. می‌توانید با جیمیل ثبت‌نام کنید. در فیلدهای **First Name** و **Last Name** هرکدام باید بیش از یک کاراکتر باشند. برای رمز عبور می‌توانید خودتان یک رمز وارد کنید یا از رمز پیشنهادی مرورگر استفاده کنید.

**📷 تصویر ۱ از ۱۵:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic.jpg" alt="ثبت‌نام - فرم ساخت اکانت" >
</p><br><br/>

**📷 تصویر ۲ از ۱۵:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic1-fa.jpg" alt="ثبت‌نام - تکمیل اطلاعات و ورود" >
</p><br><br/>

## مرحله ۲: ورود به داشبورد و ساخت سرور جدید

بعد از ورود به داشبورد Katabump، گزینه‌ی ساخت سرور جدید (Create Server) را بزنید.

<br/>

**📷 تصویر ۳ از ۱۵:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic2.jpg" alt="داشبورد - دکمه ساخت سرور جدید" >
</p><br><br/>

**📷 تصویر ۴ از ۱۵:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic3-fa.jpg" alt="انتخاب پلن رایگان سرور" >
</p><br><br/>

**📷 تصویر ۵ از ۱۵:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic4-fa.jpg" alt="ورود به پنل مدیریت سرور ساخته‌شده" >
</p><br><br/>

## مرحله ۳: انتخاب محیط Python

در تب **Startup** پنل سرور، نوع محیط را روی **Python** بگذارید (نه Node.js)، چون پراکسی با پایتون اجرا می‌شود.


**📷 تصویر ۶ از ۱۵:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic5.jpg" alt="انتخاب محیط Python در تب Startup" >
</p><br><br/>

## مرحله ۴: پیدا کردن پورت عمومی سرور

هر سرور در Katabump یک **پورت عمومی اختصاصی** دارد که در بخش **Settings** سرور نمایش داده می‌شود. این پورت معمولاً یک عدد **پنج‌رقمی** است (مثلاً چیزی شبیه `25565` یا `31842`).


**📷 تصویر ۷ از ۱۵:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic6.jpg" alt="لاگین کردن در سرور" >
</p><br><br/>

## مرحله ۵: تنظیم پورت در config.py

عدد پورتی که در مرحله‌ی قبل پیدا کردید را داخل فایل `config.py` جایگزین کنید. توجه کنید عدد `25565` زیر فقط یک نمونه است و باید با پورت واقعی خودتان جایگزین شود:

```python
PORT = 25565  # replace with your own public port
```

<br/>

::: danger **توجه کنید**  
این تنها مقداری است که باید دستی تنظیم شود؛ بقیه‌ی موارد (secret و لینک‌ها) به‌صورت خودکار ساخته می‌شوند.  
:::  

<br/>

**📷 تصویر ۸ از ۱۵:** <Badge type="danger" text="نمونه‌ی پورت عمومی پنج‌رقمی در پنل" />

<p align="center">
  <img src="/katabump-mtproto-setup/pic7.jpg" alt="نمونه از پورت عمومی سرور" >
</p><br><br/>

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

<br/>

**📷 تصویر ۹ از ۱۵:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic8.jpg" alt="آپلود فایل‌ها از طریق File Manager" >
</p><br><br/>

**📷 تصویر ۱۰ از ۱۵:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic9.jpg" alt="فایل‌ها و پوشه pyaes بعد از آپلود" >
</p><br><br/>

## مرحله ۷: تنظیم Startup (entrypoint)

در تب **Startup** پنل، فیلد **PY FILE** (یا Main File / Entry Point) را پیدا کرده و دقیقاً این مقدار را وارد کنید:

```
mtprotoproxy.py
```

سپس **Save** را بزنید.

<br/>

**📷 تصویر ۱۱ از ۱۵:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic10.jpg" alt="تنظیم فایل اجرایی در Startup" >
</p><br><br/>

## مرحله ۸: استارت سرور و دریافت لینک از Console

سرور را از پنل استارت کنید.

<br/>

**📷 تصویر ۱۲ از ۱۵:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic11.jpg" alt="استارت کردن سرور از تب Console" >
</p><br><br/>

در تب Console، خطی مشابه زیر ظاهر می‌شود که همان لینک آماده‌ی پراکسی است (مقادیر IP، PORT و SECRET با اطلاعات واقعی سرور شما جایگزین می‌شوند):

```
tg: tg://proxy?server=IP&port=PORT&secret=SECRET
```

همین لینک را کپی کرده و در تلگرام باز کنید.

<br/>

**📷 تصویر ۱۳ از ۱۵:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic12.jpg" alt="خروجی Console با لینک پراکسی" >
</p><br><br/>

## مرحله ۹: صفحه‌ی وب اختصاصی پراکسی

به‌جای کپی‌کردن دستی از داخل Console، می‌توانید همان آدرس سرور را در مرورگر باز کنید. جای `SERVER_IP` و `PORT` رو با IP و پورت واقعی سرور خودتون بذارید:

```
http://SERVER_IP:PORT/
```

<br/>

**📷 تصویر ۱۴ از ۱۵:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic13.jpg" alt="باز کردن آدرس سرور در مرورگ" >
</p><br><br/>

یک صفحه‌ی ساده باز می‌شود که لینک پراکسی را در یک باکس قابل انتخاب نشان می‌دهد، همراه با دکمه‌ی **Copy** برای کپی سریع و یک لینک **Open in Telegram** برای باز شدن مستقیم در اپ. این صفحه با همان پورت اصلی پراکسی سرو می‌شود و نیازی به پورت جداگانه ندارد.

<br/>

**📷 تصویر ۱۵ از ۱۵:**

<p align="center">
  <img src="/katabump-mtproto-setup/pic14.jpg" alt="صفحه وب اختصاصی پراکسی با دکمه کپی" >
</p><br><br/>

## نکات پایانی

::: danger **فراموش نکنید**

هر **۴ روز یک‌بار** باید وارد پنل **Katabump** شده و سرور را **Renew** کنید، در غیر این صورت سرور و پراکسی از کار می‌افتند.

<br/>

هر بار که سرور را **ری‌استارت** یا **Renew** می‌کنید، secret به‌صورت خودکار عوض می‌شود؛ لینک قبلی از کار می‌افتد و باید لینک جدید را از Console یا همان صفحه‌ی وب بردارید.
- پلن رایگان منابع محدودی دارد (۳۰۸ مگابایت RAM، ۲۵٪ از یک هسته CPU)؛ برای استفاده‌ی شخصی یا چند نفره کافی است.

<br/>

اگر پیام خطایی مثل "ModuleNotFoundError" یا "No such file" در Console دیدید، یعنی یا فایل `mtprotoproxy.py` سر جایش نیست یا پوشه‌ی `pyaes` کنارش آپلود نشده است.

:::

## راهنما و پشتیبانی

::: info **راهنمایی بیشتر**

در صورت مواجهه با هرگونه سوال یا مشکل در حین راه‌اندازی یا استفاده از این پروژه، می‌توانید از راه‌های زیر با ما در ارتباط باشید:

- **ارتباط مستقیم:** [اکانت شخصی من در تلگرام][4]
- **پرسش و پاسخ عمومی:** [گروه پشتیبانی در تلگرام][5]
 
:::

[1]: https://control.katabump.com
[2]: https://github.com/alexbers/mtprotoproxy
[3]: https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/katabump-mtproto-setup/mtprotoproxy-katabump[NeedToExtract].zip
[4]: https://t.me/mehdiasmart
[5]: https://t.me/NiREvil_GP
