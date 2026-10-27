# Chrome-Bleed Mercenaries — Android-játék gyártási terv

## Irány és termék

**Cél:** valódi, telepíthető Android-játék (APK fejlesztői kipróbáláshoz, AAB áruházi kiadáshoz), nem böngészőoldal. A mobil az elsődleges platform és kezelési mód; a desktop csak fejlesztői szerkesztő/ellenőrző felület.

**Játékmag:** cyberpunk szabadúszó zsoldos iroda. A játékos megbízásokat vállal, pénzt és hírnevet kezel, csapatot és felszerelést állít össze, majd X-COM / Door Kickers ihletésű körökre osztott taktikai bevetéseket vezet. Egy rövidebb, elejétől végéig játszható kampány lezárása után a város, majd a kontinens quest-sandboxként nyílik meg.

**Filmes irány:** a kampány fontos fordulópontjain teljes mozgóképes, élőszereplős, szándékosan túljátszott ZS-kategóriás filmjelenetek jelennek meg. A játékmenet közbeni rövid reakciókhoz olcsóbb, újrahasznosítható snittek és feliratok készülnek. A videók képarányát, bitrátáját, feliratát, hangkeverését és eszközönkénti tárhelyét már gyártáskor rögzíteni kell.

## Alap technológia

- **Motor:** Godot 4.x, GDScript, első körben 2D/2.5D izometrikus taktikai pályával. Ez ingyenes, nyílt forrású, kereskedelmi játékhoz is használható motor; Android-exportot támogat. A motor licencét a kiadott játék dokumentációjában fel kell tüntetni.
- **Android:** natív motor-exportból aláírt APK a saját telefonos fejlesztői próbákhoz; Play-kiadási csomagként AAB. A kiadási kulcsot offline biztonsági mentéssel kell őrizni, és soha nem kerülhet a GitHub-repóba.
- **Grafika:** saját, egységes 2D/2.5D art direction; Blender csak akkor, ha valódi 3D díszlet/karakter-assetek kellenek. A korai taktikai pálya rácsos és jól olvasható, nem igényel drága 3D-t.
- **Mentés:** első kampányhoz helyi mentés, verziózott sémával és biztonságos írással. Fiók, szerver és online funkció nem része az első kiadásnak, így nincs szükség backend-előfizetésre.
- **Tartalom:** küldetések, tárgyak, ellenfelek, dialógusok és filmes jelenetek adatai külön, ellenőrizhető erőforrásokban legyenek; a játékszabályok ne legyenek a képernyőelemekbe beégetve.

## Android-first szabályok

1. Portré nézet a főhadiszállásnak és gazdasági képernyőknek; taktikai pályán kipróbáljuk az álló és fekvő nézetet, majd egyet véglegesítünk a UX-próbák alapján.
2. Minden fontos gomb legalább 48 dp körüli célfelületet kap; a pálya cellái, feliratok és akciógombok kis telefonon, egy kézzel is vizsgálandók.
3. Rendszer-vissza gomb, megszakadó alkalmazás, telefonhívás, képernyőváltás és alvás után a küldetés állapota ne vesszen el.
4. A beállítások között külön hangerőcsúszkák, feliratméret, rezgés és színvakbarát kontraszt legyen.
5. Legyen grafikai minőségi fokozat, korlát a videók felbontására, valamint alacsony tárhelyű letöltési opció.
6. A mobilos teljesítményt és memóriahasználatot a leggyengébb támogatott eszközön is mérni kell, nem csak fejlesztői gépen.

## Tervezett komponensek

| Rendszer | Felelősség | Első kiadási cél |
| --- | --- | --- |
| Kampányállapot | fejezet, küldetések, városrészek, zászlók | egy teljes fő történetszál és lezárás |
| Zsoldos iroda | megbízások, díjak, adósság, hírnév | következményes választás, egyszerű gazdasági kör |
| Csapat és felszerelés | karakteradatok, sérülés, fegyverek, páncél | 3–4 tag, szerepek és cserélhető tárgyak |
| Taktikai harc | körök, AP, mozgás, fedezék, látótér, lövés, állapotok | rövid, újrajátszható bevetések |
| Küldetésrendszer | célok, mellékcélok, időnyomás, kivonás | többféle teljesítés és kudarcállapot |
| Történet és dialógus | döntések és visszajelzés | fő kampány, teljes lokalizálhatóság |
| Filmes lejátszó | videó, felirat, hang, átugrás/újranézés | kampánycsomópontok és stáblista |
| Mentés/beállítások | helyi állapot, verziózás, accessibility | legalább 3 mentési hely, automentés |
| Város és kontinens | feloldások, questek, frakciók | kampány után nyíló sandbox |

## Gyártási szakaszok és kapuk

1. **Alapozás:** repó, játéktervezési dokumentum, Godot-projekt, mobil UI-készlet, adatmodell, Android build és első telefonos telepítés.
2. **Játékmeneti próba:** egy kis pálya, 3 karakter, egy ellenségtípus, mozgás/fedezék/lövés/kivonás, tesztelhető döntés és küldetésvégi jutalom. Itt dől el a rács, a kör/AP modell és a mobilképernyő.
3. **Vertical slice:** egy teljes, minőségi küldetés a főhadiszállástól a videós lezárásig, kész UI-val, hanggal, mentéssel és telefonos teljesítménnyel. Új tartalmat csak e kapu után gyártunk tömegével.
4. **Kampánygyártás:** fő történetszál, karakterívek, küldetéslánc, gazdaság, ellenfél- és felszereléskészlet, teljes mozgóképes jelenetek.
5. **Sandbox és stabilizálás:** városi/regionális questek, kiegyensúlyozás, mentésmigráció, akadálymentesség, eszközparkos tesztek és kiadási csomag.

## Telefonos tesztfolyamat

- Minden fő fejlesztési mérföldkőből készül debug APK.
- Az elsődleges teszt: Android-telefon USB-kábellel a fejlesztői géphez; a build közvetlenül települ, log és összeomlás visszakövethető.
- Kényelmes próbához a debug APK privát letöltési linkkel vagy QR-kóddal adható át. Ismeretlen APK-nál a telefon külön engedélyt kérhet telepítés előtt.
- Belső tesztelői körhöz később Google Play belső tesztcsatorna használható; ez már fejlesztői fiókot és áruházi beállítást igényel.
- Minden buildnél feljegyezzük az alkalmazásverziót, készüléket, Android-verziót és a tesztelt küldetést. Fő ellenőrzések: telepítés/frissítés, touch UI, képernyőarányok, mentés, megszakításból visszatérés, akkumulátor/melegedés, videólejátszás, hang és teljesítmény.
- Kézi programozás nem szükséges a kipróbáláshoz: a felhasználó linket/QR-kódot nyit vagy APK-t telepít, majd a játékot érintéssel próbálja.

## Minőségi elvárások

- Minden rendszernek legyen rövid, érthető játékosmagyarázata és tesztelhető elfogadási feltétele.
- A taktikai szabályok determinisztikusak és visszajátszható hibajelentést adnak; a véletlen találat/AI viselkedés reprodukálható maggal fusson.
- A küldetések és tárgyak szerkeszthetők adatból; a lokalizáció ne a jelenetekben szétszórt karakterlánc legyen.
- Hozzáférhetőség: felirat, olvasható betűméret, kontraszt, alternatív színjelölés, állítható kameraeffekt és kikapcsolható rezgés.
- Tartalomjogok: minden zene, videó, fotó, színész-szerződés, betűtípus és külső asset licencét a kiadás előtt dokumentáljuk.
- Kiadási kapu: mentésvesztés, blokkoló crash, telepítési hiba vagy befejezhetetlen fő küldetés nem maradhat ismert hibaként.

## Eszközök és pluginok

**Szükséges alap:** Godot Editor, Android SDK/export sablonok, GitHub repó. Ezek fejlesztői eszközök, nem Codex-bővítmények. A Godot és a Godot Android-export nem igényel fizetős motordíjat.

**Ajánlott opcionális kapcsolatok:**

- **GitHub** már csatlakoztatva van: kód, verziókezelés, kiadási build és hibakövetés.
- **Figma** UI- és design-rendszer egyeztetéshez hasznos; nem szükséges a játék futtatásához.
- **Linear** akkor hasznos, ha a feladatokat és bugokat GitHubon kívül, külön gyártási táblán szeretnénk vezetni. Egy kis projekt indulhat GitHub Issues-szal is.

Egyéb opcionális, ingyenes/nyílt eszközök: Blender 3D-hez, Audacity hangvágáshoz, Krita vagy GIMP 2D grafikához. Nem kell mindet telepíteni; az art irány és a vertical slice dönti el, mire van szükség.

**Nem szükséges most:** Unity-szerű fizetős szolgáltatás, online backend, felhőmentés, analitika/ads SDK, multiplayer, AI-szöveg API. Ezek növelik a költséget és a kockázatot, az első történetkampányhoz nem kellenek.

## Jelenlegi állapot és következő blokkoló

A `game/` könyvtárban létrejött a Godot Android-projektváz és az első natív képernyőváz. A korábbi helyi `index.html` csak eldobható UI-koncepció; nem kerül a játék repójába. A dedikált [Chrome-Bleed_Mercenaries repó](https://github.com/dehornedunikorn/Chrome-Bleed_Mercenaries) már elérhető, alapállapotban csak egy README volt benne. A Godot Editor és Android SDK nem volt elérhető a munkakörnyezetben, ezért APK-export és készülékteszt még nem történt.

Következő technikai lépés: Godot Editor és Android exportkörnyezet, majd az első telepíthető APK és telefonos vertikális szelet.
