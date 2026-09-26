# Projektové instrukce: studijní materiály v R a Quarto

## Cíl projektu
Vytvářej a udržuj ucelenou, odborně správnou, srozumitelnou a reprodukovatelnou
učebnici R v češtině jako Quarto Book. Dodané skripty jsou podklady pro
kapitoly ve formátu Quarto (.qmd), nikoli závazná osnova výkladu.
Výsledkem má být souvislý výukový text, který vysvětluje účel postupu,
jeho provedení a interpretaci výsledků a rozvíjí znalosti napříč kapitolami.

## Referenční kapitola a návaznost výkladu
- Referenční kapitolou je `quarto/lekce_01.qmd`: řiď se její hloubkou výkladu,
vysvětlováním syntaxe a podobou cvičení a řešení. Její délka ani přesné členění
nejsou povinnou šablonou pro každou kapitolu.
- Před tvorbou nebo podstatnou úpravou kapitoly zkontroluj její místo v osnově,
předcházející výklad a návaznosti na další kapitoly. Zachovávej jednotnou
terminologii a přiměřený postup obtížnosti.
- Pozdější kapitoly mohou předpokládat znalosti z předchozích kapitol.
Předpoklady uveď; již vysvětlené pojmy stručně připomeň a odkaž na příslušný
oddíl místo opakování celého výkladu. Nové pojmy vysvětli před použitím.
- Kód každé kapitoly musí fungovat v čisté relaci R bez předchozího spuštění
jiných kapitol. Potřebné balíčky a data načti a objekty vytvoř v dané kapitole;
případné sdílené datové vstupy musí být dostupné a výslovně uvedené.

## Cílová skupina a didaktické zaměření
Materiály jsou určeny studentům psychologie ve volitelném předmětu
„R101: Praktický úvod pro používání statistického programu R“.
Předpokládej znalost základů statistiky a metodologie.
Nepředpokládej předchozí zkušenost s R ani programováním.

- Zaměř výklad na praktické osvojení R při práci s daty z psychologického
výzkumu: od načtení a kontroly dat přes jejich úpravu a vizualizaci
až po analýzu a interpretaci.
- Nové programovací pojmy a konstrukce vysvětluj při prvním použití
na konkrétním příkladu. Postupuj po malých krocích a nezaváděj více nových
principů současně, pokud to není nutné.
- Základní statistické pojmy stručně připomínej tam, kde jsou potřebné pro
pochopení postupu. Podrobněji vysvětluj jejich provedení v R,
čtení výstupů a omezení interpretace.
- Preferuj příklady z psychologie, například dotazníková data, experimentální
podmínky nebo opakovaná měření. U simulovaných dat výslovně uveď, že jsou vytvořena pro výuku.
- Upřednostňuj čitelný a názorný kód před stručnými, ale obtížně srozumitelnými
řešeními. Zpočátku nabídni jeden hlavní postup; alternativy přidávej,
jen pokud mají jasný didaktický přínos.
- Upozorňuj na typické začátečnické chyby a vysvětluj, jak je rozpoznat
a opravit. Veď studenty k průběžné kontrole dat a výsledků.
- Úlohy odstupňuj od úpravy předvedeného příkladu k samostatnému řešení.
Zařazuj také otázky na interpretaci výstupů a vhodnost postupu, nejen na zápis kódu.
- Rozsah a obtížnost drž na úrovni úvodního kurzu. Pokročilá témata zařazuj
pouze tehdy, když jsou nezbytná pro probíraný problém, nebo je označ jako nepovinná.

## Jazyk a výklad
- Piš odbornou, přirozenou češtinou. Preferuj ustálené a přirozeně znějící
české odborné termíny. Pokud vhodný český ekvivalent chybí nebo by doslovný
překlad působil nepřirozeně či zavádějícím dojmem, použij anglický termín
nebo jeho běžnou počeštěnou podobu; například „pipe operátor“ místo
„operátor roury“. Zvolenou terminologii používej jednotně v celé učebnici.
Při prvním výskytu termín srozumitelně vysvětli česky a podle potřeby uveď
také anglický ekvivalent pro orientaci v dokumentaci.
- Vysvětluj nejen co kód dělá, ale také proč je daný postup vhodný
a kdy vhodný není.
- Nové pojmy vysvětli před jejich použitím.
Rozsah výkladu přizpůsob obtížnosti tématu.
- Upřednostňuj souvislý výklad. Výčty, tabulky a zvýrazněné bloky používej tam,
kde podporují porozumění.

## Výstupy a jejich interpretace
- U každého výukově podstatného výstupu připoj stručný komentář přímo
u něj: čeho si má student všimnout, co výsledek znamená v kontextu příkladu
a jak souvisí s řešenou otázkou. Nestačí vysvětlit pouze kód nebo obecně
popsat, co daná funkce vrací. U jednoduchých pomocných výpisů stačí krátké
vysvětlení v okolním textu; rozsah komentáře přizpůsob významu výstupu.
- U grafů upozorni na hlavní patrný vzorec, rozdíly či neobvyklé hodnoty,
pokud jsou pro otázku relevantní. U tabulek a statistických modelů vyber
podstatné hodnoty a vysvětli jejich význam; například u regrese interpretuj
směr a velikost relevantních koeficientů vzhledem k jednotkám a kódování
proměnných a podle cíle výkladu také nejistotu odhadů a omezení závěrů.
Neomezuj interpretaci na statistickou významnost ani nepřepisuj celý výstup.
- Stejné pravidlo platí pro vzorová řešení cvičení; jejich komentář ponech
uvnitř sbaleného bloku „Ukázat řešení“.

## Samostatný studijní text a poznámky pro autora
- Piš pro studenta, který má k dispozici pouze výsledné HTML a postupuje
samostatně. Nepředpokládej přístup k původním skriptům, autorskému projektu
ani znalost zadání a historie tvorby materiálu.
- Do výukového textu nevkládej zprávy o jeho vzniku, převodu a úpravách:
například „základem je dodaný skript“, „oproti původnímu skriptu jsme opravili“
nebo zdůvodnění zachování příkladu kvůli návaznosti na podklad.
Správný postup vysvětli přímo, bez srovnávání s materiálem, který student nevidí.
- Technické podrobnosti přípravy dokumentu
(například `_quarto.yml`, `execute-dir`, renderování, testovací prostředí
a umístění autorských souborů) uváděj pouze tehdy, jsou-li samy probíraným
tématem a student je potřebuje k vlastnímu úkolu. V úvodních lekcích R je
nahraď konkrétními pokyny pro práci studenta.
- Informace o podkladech, provedených opravách, změnách analytických rozhodnutí
a technickém ověření zaznamenávej odděleně do dokumentace pro autora,
například `quarto/README.md`. Neumisťuj je ani do rozbalovacích bloků
studentské lekce.
- Zachovej informace, které student potřebuje: původ a povahu dat,
označení simulovaných příkladů, předpoklady a omezení metod,
vysvětlení chyb, potřebné balíčky, datové vstupy a praktické cesty používané
ve cvičeních. Zachovej odborné citace i stručné označení inspirace či převzetí
zadání; nesupluj jimi zprávu o tvorbě lekce.
- Při závěrečné redakci posuď každý odstavec z hlediska samostudia:
pomáhá pochopit látku, provést krok nebo interpretovat výsledek bez autorského
kontextu? Pokud slouží pouze autorovi, přesuň jej do autorské dokumentace
nebo odstraň.

## Struktura kapitoly
Obvykle zařaď cíle učení, předpokládané znalosti, vysvětlení problému,
komentovaný postup v R, interpretaci výsledků, průběžná cvičení,
časté chyby a shrnutí. Na závěr lze přidat souhrnné úlohy.
Strukturu přizpůsob tématu; nevytvářej prázdné nebo samoúčelné oddíly.

## Průběžná cvičení a řešení
- Výklad pravidelně prokládej krátkými cvičeními bezprostředně po vysvětlení
nového postupu, aby si jej studenti mohli sami vyzkoušet.
Procvičování nesoustřeď pouze na konec kapitoly.
- Zadání musí být srozumitelné, uvádět potřebná data a navazovat na dosud
vysvětlené funkce a pojmy. Střídej úpravy předvedeného kódu,
samostatné úkoly a otázky na interpretaci výsledků.
- Ke každému cvičení, včetně závěrečných a interpretačních úloh,
připoj vzorové řešení s vysvětlením postupu a podle potřeby také interpretací
výstupu. Samotný kód bez vysvětlení nestačí.
- Zadání zobraz vždy. Celé řešení včetně kódu, výstupů, grafů a vysvětlení
umísti bezprostředně pod zadání do bloku, který je ve výchozím stavu sbalený
a rozbalí se až po kliknutí na „Ukázat řešení“.
- V HTML výstupu Quarto používej rozbalovací callout s atributy
`.callout-note collapse="true" title="Ukázat řešení"`.
Pouhé skrytí kódu pomocí `code-fold` nestačí, protože by zůstaly viditelné
ostatní části řešení. Viz [dokumentace rozbalovacích bloků Quarto](https://quarto.org/docs/authoring/callouts.html).

## Výchozí zdroj a styl kódu
- V tématech, která pokrývá, vycházejí cvičení primárně z knihy [R for Data Science (2. vydání)](https://r4ds.hadley.nz/)
od Hadleyho Wickhama, Mine Çetinkaya-Rundel a Garretta Grolemunda.
Výběr témat a obtížnost přizpůsob úvodnímu kurzu a podle vhodnosti používej
příklady z psychologie.
- U cvičení vycházejících z knihy uveď odkaz na konkrétní kapitolu nebo cvičení
a rozlišuj vlastní zadání inspirované knihou od převzatého zadání.
- Výukový kód orientuj primárně na tidyverse, zejména při načítání,
úpravách a vizualizaci dat. Základní R a další balíčky používej tam,
kde mají věcný nebo didaktický přínos; případný přechod vysvětli.
- Podkladové skripty již primárně používají tidyverse. Záměrné ukázky
základního R nebo jeho srovnání s tidyverse zachovej; nepřeváděj je automaticky
do tidyverse kvůli sjednocení stylu. Pro témata mimo rozsah R4DS používej
odpovídající odborné zdroje a oficiální dokumentaci.

## Zacházení s původními skripty
- Původní skripty zachovej jako podklady. Upravené výukové verze vytvářej
samostatně.
- Zachovej analytický záměr. Zjištěné chyby a jejich opravy výslovně zaznamenej
v dokumentaci pro autora. Studentům vysvětli správný postup a relevantní typické
chyby bez odkazování na chyby původního skriptu.
- Změny metody, výběru dat, zacházení s chybějícími hodnotami a dalších
rozhodnutí ovlivňujících výsledky zdůvodni v dokumentaci pro autora.
Ve výukovém textu samostatně vysvětli použitou metodu a rozhodnutí důležitá
pro porozumění výsledkům.
- Zachovej styl a balíčky původního kódu, pokud není věcný nebo didaktický
důvod ke změně. Při stylistické úpravě nebo změně implementace bez změny
analytického postupu ověř shodu výsledků.
- Původní skripty nejsou autoritou pro odbornou správnost. Při opravě věcné
nebo analytické chyby dej přednost správnému postupu před zachováním chybných
výsledků; zdokumentuj důvod opravy i její dopad na výsledky a interpretaci.
- O každé věcné, stylistické nebo kódové opravě informuj uživatele v chatu:
uveď místo, co se změnilo a proč, případně dopad na výsledky. Přehled může
sdružovat opakované opravy stejného typu, ale musí uvést jejich rozsah.
Záznam v autorské dokumentaci nenahrazuje informování v chatu.

## Uspořádání učebnice
- Úvod je v `index.qmd`, kapitoly v `quarto/`. Novou kapitolu zařaď do
`book.chapters` v `_quarto.yml` v didakticky odůvodněném pořadí.
- Společnou konfiguraci udržuj v `_quarto.yml`, společné styly v
`quarto/lesson.css`. Nastavení v kapitole přepisuj pouze z konkrétního důvodu.
- Upravuj zdrojové soubory; generované HTML v `_book/` neopravuj ručně.
Lokální dočasné soubory a generované výstupy neukládej do Gitu; respektuj
`.gitignore`. Zdrojové kontrolní a pomocné skripty do repozitáře patří.
- Používej stabilní a v celé knize jedinečné identifikátory oddílů, obrázků,
tabulek a bloků kódu. Čísla kapitol, obrázků a tabulek nevpisuj do odkazů
ručně; používej křížové odkazy a po změnách ověř jejich cíle.
- Rozlišuj cesty potřebné k vykreslení knihy a cesty ve studentském projektu.
Student musí mít přístup ke všem vstupům potřebným pro cvičení a jasné pokyny,
kam je uložit; nesmí potřebovat neveřejné soubory autora.
- Provozní a instalační postupy udržuj v kořenovém `README.md`, podrobnosti
k obsahu a jeho ověření v `quarto/README.md`. V instrukcích je neduplikuj.

## R a Quarto
- Rozděl kód do logických, přiměřeně krátkých spustitelných bloků
a propoj je výkladem.
- Všechny blokové ukázky kódu, včetně kódu v zadáních a rozbalených řešeních,
musí být kopírovatelné pomocí trvale viditelného tlačítka „Zkopírovat“.
Kód zapisuj jako text, nikoli jako obrázek, a nepřidávej do kopírovaného kódu
konzolové prompty ani výstupy.
- Pro HTML nastav `format: html: code-copy: true` (v YAML jako vnořené položky),
aby se tlačítko zobrazovalo trvale, nikoli pouze při najetí myší.
Zajisti český popisek „Zkopírovat“; pokud výchozí tlačítko obsahuje jen ikonu,
doplň i viditelný text. Viz [dokumentace kopírování kódu Quarto](https://quarto.org/docs/output-formats/html-code.html#copy-button).
- Rozbalování řešení a tlačítka pro kopírování ověřuj v HTML výstupu
se standardním motivem Quarto podporujícím tyto funkce.
U případných statických exportů (například PDF) počítej s tím,
že tyto interaktivní prvky nejsou dostupné.
- Používej relativní cesty a výslovně uveď potřebné balíčky a datové vstupy.
- Materiál nemá záviset na objektech z dřívější interaktivní relace R.
U náhodných postupů nastav seed.
- Instalaci balíčků odděl od běžného vykreslení dokumentu.
- Tabulky a grafy opatři srozumitelnými českými popisky, jednotkami
a věcnou interpretací.

## Odborná správnost
- Rozlišuj mezi popisem dat, statistickou inferencí a kauzálními závěry.
- U metod vysvětli relevantní předpoklady a omezení.
Nezaměňuj statistickou významnost za praktickou důležitost.
- Nevymýšlej výsledky, zdroje ani citace. Ilustrační nebo simulovaná data
jasně označ.
- Odborná tvrzení, která vyžadují oporu, podlož ověřenými zdroji;
preferuj odbornou literaturu a oficiální dokumentaci.

## Kontrola a pracovní postup
- Před dokončením obsahové změny ověř spuštění kódu a vykreslení každé nové
nebo upravené kapitoly, pokud to dostupné prostředí umožňuje. Úspěšná kontrola
jiné kapitoly ani starší verze není ověřením aktuální změny.
- Po přidání kapitoly a po změně společné konfigurace, stylů nebo navigace
vykresli celou knihu a ověř dotčené stránky, navigaci a odkazy mezi kapitolami.
- Používej kontroly popsané v `README.md`, ale ověř jejich skutečný rozsah.
Kontroly v `quarto/_verification/` původně pokrývají první kapitolu; s novým
obsahem je přiměřeně rozšiřuj. Pevné počty prvků nejsou normou pro další kapitoly.
- Před dokončením konkrétní interpretace spusť příslušný kód a prohlédni
si skutečně vygenerované výstupy; grafy zkontroluj i vizuálně. Komentář
opři o tyto výsledky, nikoli pouze o očekávání podle kódu. Po změně kódu
nebo dat znovu ověř všechny dotčené výstupy a navazující interpretace.
Pokud spuštění nebo prohlédnutí výstupu není možné, konkrétní výsledky
neodhaduj; neověřenou interpretaci nepovažuj za dokončenou a omezení uveď
v autorské dokumentaci i ve zprávě uživateli.
- Ověř také kód všech vzorových řešení. Ve vykresleném HTML zkontroluj,
že řešení jsou zpočátku skrytá, kliknutí na „Ukázat řešení“ odkryje jejich
celý obsah a tlačítko „Zkopírovat“ funguje u všech ukázek kódu včetně řešení.
- Pokud ověření nelze provést, přesně uveď, co zůstalo neověřené a proč.
- Ověř také načítání obrázků, čitelnost grafů a tabulek a mobilní zobrazení
bez nechtěného vodorovného přetékání. Záměrné demonstrační chyby označ;
ostatní chyby neopomíjej ani plošně nepotlačuj varování.
- Při změně pouze instrukcí nebo autorské dokumentace zkontroluj jejich
správnost a rozdíly; bez dopadu na výstup knihy není nutný nový render.

## Git a dokončení úkolu
- Výchozím místem práce je hlavní pracovní složka projektu, v tomto
repozitáři `D:\R Projects\github\R101-textbook`. Upravuj soubory přímo zde,
také když již obsahují necommitované změny. Před úpravou přečti jejich
aktuální obsah a rozdíly vůči Gitu a navazuj na uživatelovu redakci.
Zachování rozpracovaných změn znamená zachovat jejich obsah a záměr,
nikoli se úpravě souboru vyhnout.
- Kvůli samotným necommitovaným změnám, požadavku na tematickou větev
ani snaze získat čistý pracovní strom nevytvářej další pracovní složky,
paralelní kopie repozitáře, worktrees ani dočasné verze kapitol, které
by se staly druhým místem pro úpravy. Oddělenou pracovní kopii použij
jen na výslovnou žádost uživatele nebo při konkrétní nezbytné potřebě
izolace, kterou předem vysvětlíš a kterou nelze rozumně vyřešit v hlavní
pracovní složce. Případná záloha či pomocný soubor pro kontrolu nesmí
nahrazovat úpravu cílového souboru ani zanechat soupeřící verze výsledku.
- Tematická větev nevyžaduje jinou pracovní složku. Při změně větve
bezpečně zachovej rozpracované změny; neodstraňuj je ani neobnovuj starší
obsah jen pro získání čistého pracovního stromu. Pokud se změny překrývají,
spoj je podle dohodnutého záměru; ptej se pouze při skutečně nejasném
obsahovém konfliktu. Dočasně odložené změny vrať do původních souborů
a ověř jejich zachování.
- Po dokončení ověř, že úplný aktuální výsledek je na uživatelem očekávané
cestě v hlavní pracovní složce, nikoli pouze v jiné kopii nebo na GitHubu.
Pokud se pracovalo v odůvodněně oddělené kopii, zajisti před jejím vyřazením
dostupnost výsledku v hlavní složce a zachování rozpracované práce.
Nepotřebný spravovaný worktree archivuj určeným nástrojem; jiné pracovní
složky neodstraňuj bez ověření jejich účelu, obsahu a případného používání.
- Každou kapitolu připravuj v samostatné větvi, například
`codex/lekce-02`. Další úpravy dosud nesloučené kapitoly patří do její větve;
po sloučení založ pro nový úkol novou větev z aktuálního `main`.
- Změny společné infrastruktury nebo instrukcí připravuj v samostatné
tematické větvi. Nesouvisející kapitoly nespojuj do jedné větve.
- Před prací ověř stav repozitáře a zachovej rozpracované uživatelské změny.
Do commitu zahrň jen soubory a změny patřící k danému úkolu.
- Součástí dokončeného úkolu se změnami souborů je po kontrole vytvoření
commitu a odeslání pracovní větve na GitHub. V chatu uveď přehled oprav,
provedené kontroly a jejich omezení, identifikaci commitu a odkaz na větev
nebo pull request pro kontrolu a sloučení.
- Sloučení do `main` provádí uživatel na GitHubu. Pracovní změny neslučuj
ani neodesílej přímo do `main`; nepřepisuj vzdálenou historii.
- Pokud commit nebo odeslání selže, popiš skutečný stav a překážku;
neoznačuj neodeslanou změnu za dostupnou na GitHubu.
