---
layout: doc
outline: deep
lang: "fa-IR"
dir: "rtl"
title: "راه‌اندازی سرور و کانفیگ Hysteria با Katabump"
description: "راهنمای گام‌به‌گام ساخت سرور و کانفیگ Hysteria با استفاده از Katabump — از ثبت‌نام تا آپلود فایل‌ها و دریافت لینک ساب"
date: 2026-9-10
editLink: true
head:
  - - meta
    - name: keywords
      content: Hysteria2, Katabump, VPS, Server Setup, Config, Subscription Link
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

[فایل zip کانفیگ](/public/hysteria2-setup/KataBumpJSCode[NeedToExtract].zip)

فایل بالا را extract کنید؛ محتوای آن در مرحله‌ی آپلود فایل‌ها استفاده می‌شود — یا فایل‌ها را مستقیماً آپلود می‌کنید یا محتوای هرکدام را کپی و در محل مربوطه وارد می‌کنید.

::: danger `نکته مهم درباره‌ی کیفیت و تمدید سرور`
این کانفیگ Hysteria روی ایرانسل خروجی خوبی می‌دهد و اتصال پایداری دارد. نکته‌ی مهم این است که هر **۴ روز یک‌بار** باید سرور را **renew** کنید.
:::

## مرحله ۱: ثبت‌نام

برای شروع باید یک اکانت در Katabump بسازید:

- می‌توانید با جیمیل ثبت‌نام کنید
- در فیلدهای **First Name** و **Last Name**، هرکدام باید بیش از یک کاراکتر باشند (مثلاً وارد کردن چیزی مثل `ali k` در یکی از این فیلدها قبول نمی‌شود.)
- برای رمز عبور، می‌توانید خودتان یک رمز وارد کنید یا از رمز قوی پیشنهادی مرورگر کروم استفاده کنید.

📷 **تصاویر این مرحله:**

تصویر ۱ از ۲:

<p align="center">
<img src="/public/hysteria2-setup/pic.jpg" alt="مرحله ثبت‌نام - تصویر ۱">
</p><br/>

تصویر ۲ از ۲:

<p align="center">
<img src="/public/hysteria2-setup/pic1-fa.jpg" alt="مرحله ثبت‌نام - تصویر ۲">
</p><br/>

## مرحله ۲: ساخت و ورود به پنل مدیریت سرور

در این مرحله سرور ساخته شده و وارد پنل مدیریت آن می‌شوید.

📷 **تصاویر این مرحله:**

تصویر ۱ از ۵:

<p align="center">
<img src="/public/hysteria2-setup/pic2.jpg" alt="مرحله ساخت و ورود به پنل - تصویر ۱">
</p><br/>

تصویر ۲ از ۵:

<p align="center">
<img src="/public/hysteria2-setup/pic3-fa.jpg" alt="مرحله ساخت و ورود به پنل - تصویر ۲">
</p><br/>

تصویر ۳ از ۵:

<p align="center">
<img src="/public/hysteria2-setup/pic4-fa.jpg" alt="مرحله ساخت و ورود به پنل - تصویر ۳">
</p><br/>

تصویر ۴ از ۵:

<p align="center">
<img src="/public/hysteria2-setup/pic5.jpg" alt="مرحله ساخت و ورود به پنل - تصویر ۴">
</p><br/>

تصویر ۵ از ۵:

<p align="center">
<img src="/public/hysteria2-setup/pic6.jpg" alt="مرحله ساخت و ورود به پنل - تصویر ۵">
</p><br/>

## مرحله ۳: آپلود فایل‌ها

فایل zip که در بخش پیش‌نیازها آورده شد را extract کنید؛ محتوای آن اکنون در این مرحله استفاده می‌شود. در تصاویر زیر، محل و نحوه‌ی آپلود فایل‌های JS و JSON با رنگ سبز مشخص شده است.

📷 **تصاویر این مرحله:**

تصویر ۱ از ۳:

<p align="center">
<img src="/public/hysteria2-setup/pic7.jpg" alt="مرحله آپلود فایل‌ها - تصویر ۱">
</p><br/>

تصویر ۲ از ۳:

<p align="center">
<img src="/public/hysteria2-setup/pic8.jpg" alt="مرحله آپلود فایل‌ها - تصویر ۲">
</p><br/>

تصویر ۳ از ۳:

<p align="center">
<img src="/public/hysteria2-setup/pic9.jpg" alt="مرحله آپلود فایل‌ها - تصویر ۳">
</p><br/>

## مرحله ۴: مرحله آخر — دریافت آدرس پنل و ساب

در این مرحله، همان‌طور که در تصاویر زیر دیده می‌شود، آدرس پنل و لینک ساب داخل لاگ‌ها نمایش داده می‌شود و نیازی به کار اضافه‌ای نیست و میتونید به پنل و ساب ها دسترسی داشته باشید.

📷 **تصاویر این مرحله:**

تصویر ۱ از ۳:

<p align="center">
<img src="/public/hysteria2-setup/pic10.jpg" alt="مرحله آخر - تصویر ۱">
</p><br/>

تصویر ۲ از ۳:

<p align="center">
<img src="/public/hysteria2-setup/pic11.jpg" alt="مرحله آخر - تصویر ۲">
</p><br/>

تصویر ۳ از ۳:

<p align="center">
<img src="/public/hysteria2-setup/pic12.jpg" alt="مرحله آخر - تصویر ۳">
</p><br/>
