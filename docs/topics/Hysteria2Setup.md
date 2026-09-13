---
layout: doc
outline: deep
lang: "fa-IR"
dir: "rtl"
title: "راه‌اندازی سرور و کانفیگ با Katabump"
description: "راهنمای گام‌به‌گام ساخت سرور و کانفیگ Hysteria با استفاده از Katabump — از ثبت‌نام تا آپلود فایل‌ها و دریافت لینک ساب"
date: 2026-9-13
category: "لینوکس"
icon: "🐧"
editLink: true
head:
  - - meta
    - name: keywords
      content: Hysteria2, Katabump, VPS, Server Setup, Config, Subscription Link, هیستریا, سرور رایگان, ساخت کانفیگ رایگان, کانفیگ ویتوری
---

# راه‌اندازی سرور و ساخت کانفیگ با Katabump {#deploy}

## این روش چیه؟ {#whatis}

روش جدیدی که با استفاده از سرور ارائه شده توسط **Katabump** میتوان چند نوع کانفیگ v2ray راه‌اندازی کرد.

## پیش‌نیازها {#prereq}

برای این آموزش به این لینک‌ها نیاز است:

- لینک وب‌سایت Katabump:  

[katabump.com][1]

- ابزار مبهم‌ساز کد (Code Obfuscator):  

[js-obfuscator.github.io][2]


- مخزن کانفیگ (مرجع):  

[github.com/qlxi/Xray-Sing-node][3]

مبهم‌سازی کد قبل از اینکه استفاده کنید **اجباری** است؛ اما نگران نباشید چون فایل کد زیر با همان ابزار مبهم‌سازی که بهش اشاره شد از قبل مبهم شده است.

📦 **[برای دانلود فایل زیپ مورد نیاز اینجا کلیک کنید][4]**

فایل بالا را extract کنید؛ محتوای آن در مرحله‌ی آپلود فایل‌ها استفاده میشود، یا فایل‌ها را مستقیماً آپلود می‌کنید یا محتوای هرکدام را کپی و در محل مربوطه جای‌گذاری می‌کنید. 

::: danger نکته مهم درباره‌ی کیفیت و تمدید سرور
این کانفیگ Hysteria2 و دیگر پروتکل‌ها روی ایرانسل و سامانتل نتایج خوبی داشته و اتصال پایداری از خود نشان می‌دهند. نکته‌ی مهم این است که هر **۴ روز یک‌بار** باید سرور را از داشبورد سایت **renew** کنید تا غیرفعال نشود.
:::

## نکات فنی مهم قبل از شروع {#tips}

- **حداقل امکانات سرور:** این کانفیگ چند باینری (sing-box + در صورت فعال بودن، Xray-core و Cloudflared) دانلود و اجرا می‌کند. سرویس‌های اصلی (Hysteria2 + VLESS-WS) با پلن‌های خیلی محدود (چند صد مگابایت دیسک/رم) هم بالا می‌آیند، اما اگر **Argo (تانل Cloudflare)** را هم فعال نگه دارید، حداقل چیزی حدود ۲۰۰–۳۰۰ مگابایت فضای دیسک آزاد اضافه لازم دارید؛ در غیر این صورت ممکن است در لاگ با خطای کمبود فضا برای Argo مواجه شوید که این مشکل نیز حل شده و بقیه‌ی سرویس ها بدون مشکل کار می‌کنند.

- **تنظیمات از طریق ویرایش خود فایل:** پنل Katabump (روی برخی پلن‌ها) از تعریف Environment Variable پشتیبانی نمی‌کند. پس اگر لازم شد چیزی را تغییر بدهید (مثلاً مسیر ذخیره‌سازی فایل‌ها، خاموش‌ کردن Argo برای صرفه‌جویی در منابع، یا SNI)، باید مقدار پیش‌فرض همان تنظیم را مستقیماً داخل فایل JS، قبل از آپلود، ویرایش کنید.

- **مسیر ذخیره‌سازی فایل‌ها:** اگر روی سروری هستید که پوشه‌ی موقت (`/tmp`) آن به‌جای دیسک واقعی از RAM استفاده می‌کند، بهتر است مسیر ذخیره‌سازی را به یک زیر پوشه کنار خود پروژه (مثلاً `xray-sing` کنار فایل اصلی) تغییر دهید تا مصرف دیسک را با رم اشتباه نگیرد.

## مرحله ۱: ثبت‌نام {#signup}

برای شروع باید یک اکانت در [Katabump][1] بسازید:

- می‌توانید با جیمیل ثبت‌نام کنید.
- در فیلدهای **First Name** و **Last Name**، هرکدام باید بیش از یک کاراکتر باشند (مثلا وارد کردن چیزی مثل `ali k` در یکی از این فیلدها قبول نمی‌شود.)
- برای رمز عبور، می‌توانید خودتان یک رمز وارد کنید یا از رمز قوی پیشنهادی مرورگر کروم استفاده کنید.

### 📷 تصاویر این مرحله {#signup-pics}

**تصویر ۱ از ۲:**

<p align="center">
<img src="/public/hysteria2-setup/pic.jpg" alt="مرحله ثبتنام - تصویر ۱">
</p><br/>

**تصویر ۲ از ۲:**

<p align="center">
<img src="/public/hysteria2-setup/pic1-fa.jpg" alt="مرحله ثبتنام - تصویر ۲">
</p><br/>

## مرحله ۲: ساخت و ورود به پنل مدیریت سرور {#panel}

در این مرحله سرور ساخته شده و وارد پنل مدیریت آن می‌شوید.

### 📷 تصاویر این مرحله {#panel-pics}

**تصویر ۱ از ۵:**

<p align="center">
<img src="/public/hysteria2-setup/pic2.jpg" alt="مرحله ساخت و ورود به پنل - تصویر ۱">
</p><br/>

**تصویر ۲ از ۵:**

<p align="center">
<img src="/public/hysteria2-setup/pic3-fa.jpg" alt="مرحله ساخت و ورود به پنل - تصویر ۲">
</p><br/>

**تصویر ۳ از ۵:**

<p align="center">
<img src="/public/hysteria2-setup/pic4-fa.jpg" alt="مرحله ساخت و ورود به پنل - تصویر ۳">
</p><br/>

**تصویر ۴ از ۵:**

<p align="center">
<img src="/public/hysteria2-setup/pic5.jpg" alt="مرحله ساخت و ورود به پنل - تصویر ۴">
</p><br/>

**تصویر ۵ از ۵:**

<p align="center">
<img src="/public/hysteria2-setup/pic6.jpg" alt="مرحله ساخت و ورود به پنل - تصویر ۵">
</p><br/>

## مرحله ۳: آپلود فایل‌ها {#upload}

[فایل zip][4] که در بخش پیش‌نیازها اشاره شد را extract کنید؛ محتوای آن اکنون در این مرحله استفاده می‌شود. در تصاویر زیر، محل و نحوه‌ی آپلود هر دو فایل‌ `index.js` و `package.json` با رنگ سبز مشخص شده است.

::: tip قبل از آپلود
اگر می‌خواهید تنظیمات پیش‌فرض (مثل خاموش‌کردن Argo روی پلن‌های کم منبع، یا مسیر ذخیره‌سازی فایل‌ها) را عوض کنید، الان قبل از آپلود زمان مناسبی است. همانطور که در «نکات فنی مهم قبل از شروع» گفته شد، این تغییرات باید مستقیم داخل فایل JS اعمال شوند، چون امکان تعریف Environment Variable از طریق پنل وجود ندارد.

بعد از آپلود، ساختار پوشه‌ی پروژه روی سرور شبیه این است — همان فایلی که آپلود می‌کنید (`index.js`) جایی است که باید ویرایشش کنید:

```
/home/container/              (project root on Katabump)
├── index.js                  ← edit this file
├── package.json
└── xray-sing/                (created automatically by the app at runtime)
```

**نمونه ۱ — خاموش‌کردن Argo روی پلن‌های کم‌منبع:**

داخل `index.js` دنبال این خط بگردید و مقدار جلوی `ENABLE_ARGO` را با `false` جایگزین کنید:

```js
    CFPORT: parseInt(process.env.CFPORT || "443", 10),

    // Argo enabled by default (set ENABLE_ARGO=0 to disable)
    ENABLE_ARGO: !(process.env.ENABLE_ARGO === "0" || process.env.ENABLE_ARGO === "false"), // [!code focus]
    ARGO_DOMAIN: process.env.ARGO_DOMAIN || "",
```

**نمونه ۲ — تغییر مسیر ذخیره‌سازی فایل‌ها:**

اگر مسیر پروژه‌ی شما با `/home/container` فرق دارد، همین خط را به مسیر درست خودتان تغییر بدهید:

```js
    const candidates = [
        "/home/container/xray-sing", // [!code focus]
        path.join(__dirname, "xray-sing"), // next to this script, wherever it runs
        path.join(process.cwd(), "xray-sing"), // current working directory fallback
        path.join(os.tmpdir(), "xray-sing"),   // last resort (may be tmpfs/RAM)
    ];
```
:::

### 📷 تصاویر این مرحله {#upload-pics}

ت**صویر ۱ از ۳:**

<p align="center">
<img src="/public/hysteria2-setup/pic7.jpg" alt="مرحله آپلود فایل‌ها - تصویر ۱">
</p><br/>

**تصویر ۲ از ۳:**

<p align="center">
<img src="/public/hysteria2-setup/pic8.jpg" alt="مرحله آپلود فایل‌ها - تصویر ۲">
</p><br/>

**تصویر ۳ از ۳:**

<p align="center">
<img src="/public/hysteria2-setup/pic9.jpg" alt="مرحله آپلود فایل‌ها - تصویر ۳">
</p><br/>

## مرحله ۴: مرحله آخر — دریافت آدرس پنل و ساب {#final}

در این مرحله، همانطور که در تصاویر زیر دیده می‌شود، آدرس پنل و لینک ساب داخل لاگ‌ها نمایش داده می‌شود و نیازی به کار اضافه‌ای نیست و می‌تونید به پنل و ساب ها دسترسی داشته باشید.

### تصاویر این مرحله {#final-pics}

**تصویر ۱ از ۳:**

<p align="center">
<img src="/public/hysteria2-setup/pic10.jpg" alt="مرحله آخر - تصویر ۱">
</p><br/>

**تصویر ۲ از ۳:**

<p align="center">
<img src="/public/hysteria2-setup/pic11.jpg" alt="مرحله آخر - تصویر ۲">
</p><br/>

**تصویر ۳ از ۳:**

<p align="center">
<img src="/public/hysteria2-setup/pic12.jpg" alt="مرحله آخر - تصویر ۳">
</p><br/>

## مشکلات رایج {#faq}

**در لاگ نوشته "Argo link not ready" یا خطای کمبود فضا برای Argo دیدم، چیکار کنم؟**

یعنی فضای دیسک آزاد کافی (حدود ۶۰ مگابایت یا بیشتر) برای دانلود cloudflared وجود نداشته. بقیه‌ی سرویس‌ها (Hysteria2، VLESS-WS و...) بدون مشکل کار می‌کنند و فقط همین بخش (Argo/تانل Cloudflare) در آن اجرا در دسترس نیست. اگر واقعاً به Argo نیاز ندارید، بهترین راه‌حل همون بلوک کد «نمونه ۱» در بخش «مرحله ۳: آپلود فایل‌ها» است — همون خطِ `ENABLE_ARGO` را داخل `index.js` پیدا کنید و مقدارش را `false` بگذارید:

```js
    CFPORT: parseInt(process.env.CFPORT || "443", 10),

    // Argo enabled by default (set ENABLE_ARGO=0 to disable)
    ENABLE_ARGO: !(process.env.ENABLE_ARGO === "0" || process.env.ENABLE_ARGO === "false"), // [!code focus]
    ARGO_DOMAIN: process.env.ARGO_DOMAIN || "",
```

این کار هم فضا و هم رم بیشتری برای بقیه‌ی سرویس‌ها آزاد می‌کند.

[1]: https://dashboard.katabump.com
[2]: https://js-obfuscator.github.io
[3]: https://github.com/qlxi/Xray-Sing-node
[4]: https://raw.githubusercontent.com/mehdi-hexing/mehdi-hexing/refs/heads/main/docs/public/hysteria2-setup/KataBumpJSCode[NeedToExtract].zip
