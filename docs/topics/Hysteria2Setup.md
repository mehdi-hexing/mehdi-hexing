---
title: راه‌اندازی سرور و کانفیگ Hysteria با Katabump
description: راهنمای گام‌به‌گام ساخت سرور و کانفیگ Hysteria با استفاده از Katabump — از ثبت‌نام تا آپلود فایل‌ها و دریافت لینک ساب
---

# راه‌اندازی سرور و کانفیگ Hysteria با Katabump

## این روش چیه؟

روش جدیدی که با استفاده از **Katabump** می‌توان سرور و کانفیگ را پیاده کرد.

## پیش‌نیازها و لینک‌های لازم

برای این آموزش به این لینک‌ها نیاز است:

- پنل Katabump: `https://dashboard.katabump.com`
- مبهم‌ساز کد (JS Obfuscator): `https://js-obfuscator.github.io/`
- مخزن کانفیگ: `https://github.com/qlxi/Xray-Sing-node`

مبهم‌سازی کد قبل از اینکه استفاده کنید **اجباری** است؛ اما نگران نباشین چون با مبهم‌ساز که بالاتر اشاره کردم مبهم (obfuscate) شده.

📦 **فایل پیوست (zip):**

[فایل zip کانفیگ](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/hysteria2-setup/KataBumpJSCode[NeedToExtract].zip)

فایل بالا را extract کنید؛ محتوای آن در مرحله‌ی آپلود فایل‌ها استفاده می‌شود — یا فایل‌ها را مستقیماً آپلود می‌کنید یا محتوای هرکدام را کپی و در محل مربوطه وارد می‌کنید.

## نکته مهم درباره‌ی کیفیت و تمدید سرور

این کانفیگ Hysteria روی ایرانسل خروجی خوبی می‌دهد و اتصال پایداری دارد. نکته‌ی مهم این است که هر **۴ روز یک‌بار** باید سرور را **renew** کنید.

## مرحله ۱: ثبت‌نام

برای شروع باید یک اکانت در Katabump بسازید:

- می‌توانید با جیمیل ثبت‌نام کنید
- در فیلدهای **First Name** و **Last Name**، هرکدام باید بیش از یک کاراکتر باشند (مثلاً وارد کردن چیزی مثل `ali k` در یکی از این فیلدها قبول نمی‌شود.)
- برای رمز عبور، می‌توانید خودتان یک رمز وارد کنید یا از رمز قوی پیشنهادی مرورگر کروم استفاده کنید.

📷 **تصاویر این مرحله:**

تصویر ۱ از ۲:

![مرحله ثبت‌نام - تصویر ۱](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/cf-proxyipchecker/pic.jpg)

تصویر ۲ از ۲:

![مرحله ثبت‌نام - تصویر ۲](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/cf-proxyipchecker/pic1-fa.jpg)

## مرحله ۲: ساخت و ورود به پنل مدیریت سرور

در این مرحله سرور ساخته شده و وارد پنل مدیریت آن می‌شوید.

📷 **تصاویر این مرحله:**

تصویر ۱ از ۵:

![مرحله ساخت و ورود به پنل - تصویر ۱](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/cf-proxyipchecker/pic2-fa.jpg)

تصویر ۲ از ۵:

![مرحله ساخت و ورود به پنل - تصویر ۲](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/cf-proxyipchecker/pic3-fa.jpg)

تصویر ۳ از ۵:

![مرحله ساخت و ورود به پنل - تصویر ۳](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/cf-proxyipchecker/pic4.jpg)

تصویر ۴ از ۵:

![مرحله ساخت و ورود به پنل - تصویر ۴](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/cf-proxyipchecker/pic5.jpg)

تصویر ۵ از ۵:

![مرحله ساخت و ورود به پنل - تصویر ۵](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/cf-proxyipchecker/pic6.jpg)

## مرحله ۳: آپلود فایل‌ها

فایل zip که در بخش پیش‌نیازها آورده شد را extract کنید؛ محتوای آن اکنون در این مرحله استفاده می‌شود. در تصاویر زیر، محل و نحوه‌ی آپلود فایل‌های JS و JSON با رنگ سبز مشخص شده است.

📷 **تصاویر این مرحله:**

تصویر ۱ از ۳:

![مرحله آپلود فایل‌ها - تصویر ۱](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/cf-proxyipchecker/pic7.jpg)

تصویر ۲ از ۳:

![مرحله آپلود فایل‌ها - تصویر ۲](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/cf-proxyipchecker/pic8.jpg)

تصویر ۳ از ۳:

![مرحله آپلود فایل‌ها - تصویر ۳](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/cf-proxyipchecker/pic9.jpg)

## مرحله ۴: مرحله آخر — دریافت آدرس پنل و ساب

در این مرحله، همان‌طور که در تصاویر زیر دیده می‌شود، آدرس پنل و لینک ساب داخل لاگ‌ها نمایش داده می‌شود و نیازی به کار اضافه‌ای نیست و میتونید به پنل و ساب ها دسترسی داشته باشید.

📷 **تصاویر این مرحله:**

تصویر ۱ از ۳:

![مرحله آخر - تصویر ۱](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/cf-proxyipchecker/pic10.jpg)

تصویر ۲ از ۳:

![مرحله آخر - تصویر ۲](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/cf-proxyipchecker/pic11.jpg)

تصویر ۳ از ۳:

![مرحله آخر - تصویر ۳](https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/cf-proxyipchecker/pic12.jpg)
