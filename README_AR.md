<p align="center"><img src="res/app_icon.png" width="120" alt="أيقونة VLC Modern"></p>
<h1 align="center">VLC Modern</h1>
<p align="center">مشغّل وسائط لويندوز مبني باستخدام Delphi وVCL وLibVLC.</p>
<p align="center"><a href="README.md"><img alt="English" src="https://img.shields.io/badge/English-243850?style=for-the-badge&amp;logo=googletranslate&amp;logoColor=white"></a> &nbsp;·&nbsp; <a href="https://diagoo1.github.io/VLC-Modern/#screenshots"><strong>معرض الصور</strong></a> &nbsp;·&nbsp; <a href="https://diagoo1.github.io/VLC-Modern/#download"><strong>التحميل</strong></a></p>

<p align="center"><a href="https://github.com/Diagoo1/VLC-Modern/releases/tag/v1.0.12"><img src="https://img.shields.io/badge/Release-v1.0.12-1473E6" alt="Release: v1.0.12"></a> <img src="https://img.shields.io/badge/Platform-Windows%20x86-1473E6" alt="Platform: Windows x86"> <img src="https://img.shields.io/badge/Language-Delphi%2013-E62431" alt="Language: Delphi 13"> <img src="https://img.shields.io/badge/UI-VCL-6D4AFF" alt="UI: VCL"> <img src="https://img.shields.io/badge/Playback-LibVLC%203.0.20-E56A16" alt="Playback: LibVLC 3.0.20"> <img src="https://img.shields.io/badge/Theme-Dark-333333" alt="Theme: Dark"></p>

<blockquote dir="rtl" align="right"><strong>الإصدار الرسمي v1.0.12.</strong> اختر EXE للتثبيت في Program Files أو ZIP محمول للتشغيل بعد فك الضغط.</blockquote>

<p align="center"><a href="https://github.com/Diagoo1/VLC-Modern/releases/download/v1.0.12/VLC-Modern-v1.0.12-Setup-Full-Windows.exe"><strong>تثبيت Full &#183; EXE</strong></a> &nbsp;·&nbsp; <a href="https://github.com/Diagoo1/VLC-Modern/releases/download/v1.0.12/VLC-Modern-v1.0.12-Portable-Full-Windows.zip"><strong>محمول Full &#183; ZIP</strong></a></p>

<p align="center"><a href="https://github.com/Diagoo1/VLC-Modern/releases/download/v1.0.12/VLC-Modern-v1.0.12-Setup-Lite-Windows.exe"><strong>تثبيت Lite &#183; EXE</strong></a> &nbsp;·&nbsp; <a href="https://github.com/Diagoo1/VLC-Modern/releases/download/v1.0.12/VLC-Modern-v1.0.12-Portable-Lite-Windows.zip"><strong>محمول Lite &#183; ZIP</strong></a></p>

<p dir="rtl" align="right">نسخة Lite بتشغّل الملفات المحلية الشائعة فورًا. تقدر تنزّل مجموعة الإضافات الكاملة وFFmpeg أثناء التثبيت أو بعده. لو انقطع الاتصال، يكتمل تثبيت المشغّل وتقدر تعيد المحاولة من الإعدادات ← Components.</p>

<ul dir="rtl">
  <li><strong>Full</strong> تشمل إضافات تشغيل LibVLC وFFmpeg للقص الدقيق على ويندوز 64 بت.</li>
  <li><strong>Lite</strong> تشمل المشغّل وملفات DLL الأساسية. ثبّت إضافات LibVLC لتشغيل الوسائط، واختر FFmpeg بشكل منفصل للقص الدقيق.</li>
  <li><strong>YouTube</strong> النسختين بيشغّلوا YouTube بالبث المباشر باستخدام QuickJS‑NG المرفق. Node.js بديل اختياري في <strong>Settings → Playback Components</strong>.</li>
  <li><strong>الإعدادات ← Playback Components</strong> تفتح نافذة تثبيت المكوّنات ومزامنتها. أعد تشغيل المشغّل بعد تثبيت أو تحديث إضافات LibVLC.</li>
</ul>

<p align="center"><a href="https://diagoo1.github.io/VLC-Modern/#download"><strong>تحميل لويندوز</strong></a> &nbsp;·&nbsp; <a href="https://github.com/Diagoo1/VLC-Modern/issues/new"><strong>الإبلاغ عن خطأ</strong></a> &nbsp;·&nbsp; <a href="https://github.com/Diagoo1/VLC-Modern/releases/tag/v1.0.12"><img alt="v1.0.12" src="https://img.shields.io/badge/v1.0.12-243850?style=for-the-badge&amp;logo=github&amp;logoColor=white"></a></p>

## صور البرنامج

![واجهة VLC Modern الرئيسية](docs/screenshots/player.png)

**واجهة المشغّل.** شاشة البداية بهوية VLC Modern، وأسفلها شريط التحكم بحوافه المستديرة.

| الإعدادات | المؤثرات الصوتية |
| --- | --- |
| [![الإعدادات بالوضع الداكن](docs/screenshots/preferences.png)](docs/screenshots/preferences.png) | ![الإكولايزر](docs/screenshots/equalizer.png) |
| زرا Components وReset بمحاذاة القائمة الجانبية. | إعدادات جاهزة وتحكم في كل نطاق ترددي. |

| قائمة التشغيل | ملء الشاشة |
| --- | --- |
| ![قائمة التشغيل](docs/screenshots/playlist.png) | ![ملء الشاشة](docs/screenshots/fullscreen.png) |
| قائمة جانبية تبرز الملف الجاري تشغيله. | شريط تحكم عائم بحواف مستديرة فوق الفيديو. |

### الوضع الفاتح

![المشغّل أثناء تشغيل Cartoon Sky بالوضع الفاتح](docs/screenshots/light-player.png)

**واجهة التشغيل.** الوضع الفاتح يظهر في شريط العنوان والقوائم وأدوات التشغيل، مع الحفاظ على ألوان الفيديو.

| الإعدادات | الإكولايزر |
| --- | --- |
| [![الإعدادات العامة بالوضع الفاتح](docs/screenshots/light-preferences.png)](docs/screenshots/light-preferences.png) | [![الإكولايزر بالوضع الفاتح](docs/screenshots/light-equalizer.png)](docs/screenshots/light-equalizer.png) |
| اختيار السمة ومكوّنات التشغيل. | الإعدادات المسبقة والمضخّم والتحكم في كل نطاق ترددي. |

من **الإعدادات ← عام ← السمة**، تقدر تختار **فاتح** أو **داكن** أو **اتباع النظام**. الخيار الافتراضي هو **اتباع النظام**، وتُطبّق السمة عند إعادة تشغيل المشغّل.

### البث وIPTV وتحويل الوسائط

| واجهة IPTV بالعربية | واجهة IPTV بالإنجليزية |
| --- | --- |
| ![واجهة عربية](docs/screenshots/iptv-ar-grid-light.png) | ![واجهة إنجليزية](docs/screenshots/iptv-en-grid-light.png) |

اضغط على أي لقطة لفتحها بالحجم الكامل.

| البث التلفزيوني وIPTV | فتح بث شبكي | تحويل الوسائط |
| --- | --- | --- |
| [![إعداد مصادر البث التلفزيوني](docs/screenshots/iptv.png)](docs/screenshots/iptv.png) | [![فتح رابط بث شبكي](docs/screenshots/open-media.png)](docs/screenshots/open-media.png) | [![إعداد تحويل ملف وسائط](docs/screenshots/convert-stream.png)](docs/screenshots/convert-stream.png) |
| اتصل بمزوّد Xtream Codes أو Stalker / MAC، أو افتح رابط M3U أو ملفًا محليًا، أو جرّب عينات التشغيل. | افتح مصدر HTTP أو RTSP أو RTMP واضبط التخزين المؤقت للشبكة. تبويبات منفصلة للأقراص وأجهزة الالتقاط. | اختَر ملفًا أو رابطًا، وصيغة الإخراج، ومكان الحفظ. اللقطة بتوضح H.264 + AAC داخل MP4. |

استخدمنا [IPTVnator](https://github.com/4gray/iptvnator) مرجعًا لتجربة إضافة مصادر IPTV. اللقطات اللي فوق من VLC Modern، وتقدر تشوف واجهة المشروع المرجعي ومميزاته على [موقع IPTVnator](https://4gray.github.io/iptvnator/).

[معرض الصور بالحجم الكامل](docs/SCREENSHOTS.md)

يدعم المشغّل الملفات المحلية وبث الشبكة وقوائم التشغيل وIPTV والترجمة الخارجية، مع إكولايزر وأدوات لضبط الصورة والصوت.

## البناء والتشغيل

ثبّت Delphi 13 مع مترجم Win32، وWindows SDK، وPowerShell 7. أضف `dcc32` إلى PATH وشغّل `build.bat` من جذر المشروع. يحتاج التشغيل إلى LibVLC إصدار 32 بت، مع وضع `libvlc.dll` و`libvlccore.dll` ومجلد `plugins` بجانب البرنامج في `bin`.

[تعليمات البناء وتنظيم السورس](README.md#build-from-source)
