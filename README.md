# Chrome-Bleed Mercenaries

Ez a projekt **Androidra készülő telepíthető játék**. A fejlesztési cél a Godot Engine natív Android-exportja. A korábbi helyi HTML-makett nem része ennek a natív projektnek.

GitHub: [dehornedunikorn/Chrome-Bleed_Mercenaries](https://github.com/dehornedunikorn/Chrome-Bleed_Mercenaries)

## Mappa

- [`game/`](game/) — Godot-projektváz, mobil álló nézetre hangolva.
- [`docs/ANDROID_GAME_PRODUCTION.md`](docs/ANDROID_GAME_PRODUCTION.md) — játékirány, architektúra, gyártási kapuk, Android-minőségi elvek és telefonos tesztfolyamat.

## Kipróbálás

A `game/` mappát Godot 4.x-ben kell megnyitni. Android exporthoz Godot Android export sablonok és Android SDK szükségesek. Fejlesztés közben debug APK kerül a telefonra USB-n vagy privát letöltési linken/QR-kódon át. Áruházi kiadáshoz külön aláírt AAB készül. A kiadási aláírókulcsot titokként kell kezelni és soha nem szabad a repóba menteni.

Ebben a környezetben a Godot és az Android SDK nem volt elérhető, ezért az APK-export és valódi készülékteszt még nem történt meg. A játékdedikált GitHub-repó már létrejött; a kezdőcsomag külön fejlesztői ágon kerül felülvizsgálatra.

## Játékterv röviden

Körökre osztott taktikai zsoldosjáték gazdasági/stratégiai kampánnyal; teljes rövid történetkampány, élőszereplős, szándékosan ZS-kategóriás filmátvezetők, majd városi és kontinensnyi quest-sandbox.
