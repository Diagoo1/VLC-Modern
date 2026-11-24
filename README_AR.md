<p align="center"><img src="res/app_icon.png" width="120" alt="أيقونة VLC Modern"></p>
<h1 align="center">VLC Modern</h1>
<p align="center">مشغّل وسائط لويندوز مبني باستخدام Delphi وVCL وLibVLC.</p>
<p align="center"><a href="README.md">English</a> · <a href="https://github.com/Diagoo1/VLC-Modern/issues/new">الإبلاغ عن مشكلة</a></p>

<p align="center"><a href="https://github.com/Diagoo1/VLC-Modern/releases/tag/v0.1.0"><img src="https://img.shields.io/badge/Status-Public%20Beta-D97706" alt="Status: Public Beta"></a> <img src="https://img.shields.io/badge/Platform-Windows%20x86-1473E6" alt="Platform: Windows x86"> <img src="https://img.shields.io/badge/Language-Delphi%2013-E62431" alt="Language: Delphi 13"> <img src="https://img.shields.io/badge/UI-VCL-6D4AFF" alt="UI: VCL"> <img src="https://img.shields.io/badge/Playback-LibVLC%203.0.20-E56A16" alt="Playback: LibVLC 3.0.20"> <img src="https://img.shields.io/badge/Theme-Dark-333333" alt="Theme: Dark"></p>

> **Public Beta · نسخة تجريبية عامة.** البرنامج لسه تحت التطوير، وممكن تقابل أخطاء أو ميزات غير مكتملة. النسخة متاحة للتجربة وإرسال الملاحظات.

<p align="center"><a href="https://github.com/Diagoo1/VLC-Modern/releases/download/v0.1.0/VLC-Modern-v0.1.0-Windows-x86.zip"><img alt="تحميل نسخة ويندوز" src="https://img.shields.io/badge/Download-Windows%20ZIP-1473E6?style=for-the-badge"></a> <a href="https://github.com/Diagoo1/VLC-Modern/issues/new"><img alt="الإبلاغ عن خطأ" src="https://img.shields.io/badge/Report%20a%20bug-GitHub-586069?style=for-the-badge"></a></p>
<p align="center"><a href="https://github.com/Diagoo1/VLC-Modern/releases/download/v0.1.0/VLC-Modern-v0.1.0-Windows-x86.zip">تحميل نسخة ويندوز</a> · <a href="https://github.com/Diagoo1/VLC-Modern/issues/new">الإبلاغ عن خطأ</a> · <a href="https://github.com/Diagoo1/VLC-Modern/releases/tag/v0.1.0">v0.1.0 Beta</a></p>

## صور البرنامج

![واجهة VLC Modern الرئيسية](docs/screenshots/player.png)

**واجهة المشغّل.** شاشة البداية بهوية VLC Modern، وأسفلها شريط التحكم بحوافه المستديرة.

| فتح الوسائط | الإعدادات | المؤثرات الصوتية |
| --- | --- | --- |
| ![نافذة فتح الوسائط](docs/screenshots/open-media.png) | ![نافذة الإعدادات](docs/screenshots/preferences.png) | ![الإكولايزر](docs/screenshots/equalizer.png) |
| بث الشبكة والأقراص وأجهزة الالتقاط. | قائمة جانبية لتنظيم خيارات المشغّل. | إعدادات جاهزة وتحكم في كل نطاق ترددي. |

| قائمة التشغيل | ملء الشاشة | Live TV وIPTV |
| --- | --- | --- |
| ![قائمة التشغيل](docs/screenshots/playlist.png) | ![ملء الشاشة](docs/screenshots/fullscreen.png) | ![إعداد IPTV](docs/screenshots/iptv.png) |
| قائمة جانبية تبرز الملف الجاري تشغيله. | شريط تحكم عائم بحواف مستديرة فوق الفيديو. | اختيار المصدر وإعداد الاتصال. |

[معرض الصور بالحجم الكامل](docs/SCREENSHOTS.md)

يدعم المشغّل الملفات المحلية وبث الشبكة وقوائم التشغيل وIPTV والترجمة الخارجية، مع إكولايزر وأدوات لضبط الصورة والصوت.

## البناء والتشغيل

ثبّت Delphi 13 مع مترجم Win32، وWindows SDK، وPowerShell 7. أضف `dcc32` إلى PATH وشغّل `build.bat` من جذر المشروع. يحتاج التشغيل إلى LibVLC إصدار 32 بت، مع وضع `libvlc.dll` و`libvlccore.dll` ومجلد `plugins` بجانب البرنامج في `bin`.

[تعليمات البناء وتنظيم السورس](README.md#build-from-source)
