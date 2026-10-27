# Chrome-Bleed Mercenaries

Ez a projekt **Androidra készülő telepíthető játék**. A fejlesztési cél a Godot Engine natív Android-exportja. A korábbi helyi HTML-makett nem része ennek a natív projektnek.

GitHub: [dehornedunikorn/Chrome-Bleed_Mercenaries](https://github.com/dehornedunikorn/Chrome-Bleed_Mercenaries)

## Mappa

- [`game/`](game/) — Godot-projektváz, mobil álló nézetre hangolva.
- [`docs/ANDROID_GAME_PRODUCTION.md`](docs/ANDROID_GAME_PRODUCTION.md) — játékirány, architektúra, gyártási kapuk, Android-minőségi elvek és telefonos tesztfolyamat.

## Első taktikai küldetés

A kezdő bevetés 7×7-es pályán játszódik: három zsoldost vezetsz, akciónként mozoghatsz vagy lőhetsz, a fedezék módosítja a találati esélyt, a falak blokkolják a látóvonalat, az ellenfelek pedig a kör végén támadnak vagy közelednek. A futárt előbb ki kell menteni, majd a kijárathoz kell vinni. Ez még prototípus-szintű szabályrendszer, és Godotban/telefonon nem lett ellenőrizve.

## Kipróbálás

A `game/` mappát Godot 4.x-ben kell megnyitni. Android exporthoz Godot Android export sablonok és Android SDK szükségesek. Fejlesztés közben debug APK kerül a telefonra USB-n vagy privát letöltési linken/QR-kódon át. Áruházi kiadáshoz külön aláírt AAB készül. A kiadási aláírókulcsot titokként kell kezelni és soha nem szabad a repóba menteni.

Az Android-export, a Godotban való futtatás és a valódi készülékteszt még hátravan, mert ebben a környezetben a Godot és az Android SDK nem érhető el. Az alapozó PR egyesítve lett; a következő taktikai fejlesztés külön ágon készül.

## Játékterv röviden

Körökre osztott taktikai zsoldosjáték gazdasági/stratégiai kampánnyal; teljes rövid történetkampány, élőszereplős, szándékosan ZS-kategóriás filmátvezetők, majd városi és kontinensnyi quest-sandbox.
