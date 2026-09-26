# Autorská dokumentace učebnice R101

## Aktuální uspořádání

`lekce_01.qmd` obsahuje základy R a RStudia, práci s projektem, skriptem, objekty, funkcemi, vektory a balíčky. `lekce_02.qmd` obsahuje základy ggplot2 a `lekce_03.qmd` úpravy dat v dplyr. Každá lekce samostatně připravuje všechny potřebné objekty a balíčky. Výstupy jsou `_book/quarto/lekce_01.html`, `_book/quarto/lekce_02.html` a `_book/quarto/lekce_03.html`; pro čtení knihy není třeba instalovat R. Instalační a provozní postupy popisuje kořenový `README.md`.

Každá kapitola má vlastní spuštění kódu; instalační příkazy a interaktivní prohlížení dat či nápovědy mají `eval: false`. Všechna výpočetní řešení se při renderování spouštějí. Řešení jsou v HTML zpočátku sbalená. V první kapitole zůstává lokálně povolená demonstrační chyba ve jménu objektu. U prvního bodového grafu ve druhé kapitole je záměrně viditelné varování o dvou chybějících souřadnicích; další grafy stejných proměnných používají vysvětlené `na.rm = TRUE`. Neočekávaná varování se globálně nepotlačují.

Exporty druhé kapitoly vznikají v `output/figures/tucnaci.png` a `output/figures/tucnaci_samostatne.png`. Opakované spuštění aktualizuje pouze tyto odvozené soubory. Starší samostatné HTML mimo `_book/` není aktuálním výstupem knihy.

## Třetí kapitola: úpravy dat v dplyr, 26. 9. 2026

Podkladem je uživatelem dodaný `scripts/week_03.R`, uchovaný beze změny (SHA-256 `649b13a4f85c3cd19c4906a6317a2bc66dbd12dbfba339c2e7bc078ee2e75c98`). Kapitola navazuje na práci s objekty z první a na grafy z druhé lekce. Nové výpočetní postupy vysvětluje před použitím; úvodní souhrnná pipeline ze skriptu byla rozložena do jednotlivých kroků. Opakující se varianty byly sloučeny, interaktivní nápověda a instalace odděleny od běžného spuštění. Výklad doplňují průběžná cvičení, interpretace a samostatně spustitelná závěrečná úloha s ručně vytvořenými psychologickými daty. Pokročilejší výběr sloupců, `.by`, trvání seskupení a převod HHMM jsou nepovinné.

### Opravy podkladu a analytická rozhodnutí

- **Hraniční podmínka zpoždění:** slovnímu „alespoň hodinu“ odpovídá `dep_delay >= 60`, nikoli původní `> 60`. Při současném zmenšení zpoždění o více než 30 minut se počet změní z 1 819 na 1 844; přibude 25 záznamů s odletovým zpožděním přesně 60 minut. V celé lekci jsou rozlišeny ostré a neostré hranice.
- **Chybějící hodnoty:** `filter()` ponechá pouze `TRUE`. Průměry s `na.rm = TRUE` proto provázejí počty dostupných hodnot, které nejsou zaměňovány s `n()`. Z původních dat nic plošně neodstraňujeme ani neimputujeme. U grafu podle hodiny je po souhrnu výslovně vynechána skupina s nulovým počtem dostupných zpoždění (hodina 1, jediný záznam); její `NaN` není nulový průměr.
- **Čas odletu a nejčasnější lety:** `hour` a `time_hour` popisují plánovaný čas. Původní `filter(hour > 4) |> arrange(time_hour)` nevyhledává nejnižší skutečný čas odletu na hodinách. Nová úloha používá dostupné `dep_time`, odlišuje kalendářní pořadí a odlety po půlnoci. Převod HHMM zachovává původní sloupce a na 1 207 dostupných záznamech dokládá posun o 1 440 minut; nepředstavuje univerzální opravu všech časů a pásem.
- **Čárka v mutate():** komentář podkladu, že závěrečná čárka nutně způsobí chybu, neplatí pro zde ověřené dplyr 1.1.4; tato funkce ji přijímá. Výukový kód používá čitelný zápis bez nadbytečné čárky a neprezentuje neexistující chybu. Test ověřuje shodu obou forem. Skutečné demonstrační chyby (`filter(month = 1)` a řazení podle již odstraněného sloupce) mají lokální `error: true`; ostatní chyby zůstávají zakázány.
- **Výběr sloupců:** pasáž podkladu ptající se na `any_of()` ve skutečnosti volala `all_of()`. Nová ukázka má záměrně chybějící název a vysvětluje rozdíl. Pomocníci se řídí textem názvu, nikoli významem: `contains("arr")` zachytí i `carrier`. Přesný seznam a výběr `starts_with("dep_")`, `starts_with("arr_")` dávají na současných datech stejný výsledek, ale nejsou zárukou stejného výběru při změně struktury.
- **Jednotky a odvozené veličiny:** rychlost je jednotně v km/h s explicitním převodem mílí, kontrola nejrychlejších letů vyžaduje kladné dostupné `air_time`. Význam rozdílu `arr_delay - dep_delay` není vydáván za izolované zpoždění ve vzduchu. Přepočet rychlosti zachovává původní vzorec v km/h; varianta v mph byla sloučena s vysvětlením jednotek.
- **Skupiny a slice:** `group_by()` ponechává řádky v jednom objektu a samo je neřadí. Původní zadání s „destination“ bylo uvedeno do souladu s `group_by(origin)`: jde o letiště odletu. Vysvětleny jsou shody, `with_ties`, odlišné `na_rm`, první řádek versus minimum a rozdíl `mutate()`/`summarise()`. Náhodný výběr má seed a vysvětlení výběru jednoho záznamu za každý měsíc. Záporné `n` a opakované ekvivalentní varianty nejsou součástí základní lekce.
- **Graf po hodinách:** průměry se nejprve vypočítají do kontrolovatelné tabulky a pak kreslí pomocí `geom_line()` a `geom_point()`. Zachován je průměr dostupných odletových zpoždění, nikoli jen kladných. Osa x je plánovaná hodina, osa y lineární v minutách; chybný komentář podkladu o logaritmické ose nebyl převzat. Doplněno vysvětlení nestejných počtů a omezení kauzálních závěrů.
- **Psychologický příklad:** nová ručně vytvořená data jsou takto označena. Průměr změn používá dostupné dvojice týchž osob; jedna chybějící následná hodnota není imputována. Sloupcový graf je popisný a neprokazuje účinek programu. Tabulka, graf i interpretace patří celé do sbaleného řešení.

Přidání kapitoly zahrnuje navigaci knihy, úvod a dokumentaci. `nycflights13` bylo přidáno do samostatné instalace i do sestavení na GitHubu. Původní lekce ani rozpracované uživatelské změny se nepřenášejí do této tematické větve. Hlavním didaktickým zdrojem je R4DS, kapitola Data transformation; přesné chování funkcí bylo ověřeno v oficiální dokumentaci a místním R. Zdrojové odkazy jsou přímo v lekci.

### Ověření

`check-lesson-03.R`, volaný z `check-r.R` v samostatné čisté relaci, spouští všechny výpočetní bloky nové kapitoly včetně řešení, ověřuje dvě záměrné chyby, číselné interpretace, počty dostupných hodnot, převody jednotek, časové nesoulady, skupiny a shodu ekvivalentních zápisů s podkladem. Závěrečné psychologické řešení spouští ještě samostatně bez předchozích objektů kapitoly. Instalace a interaktivní prohlížeč dat či nápovědy se automaticky neprovádějí. HTML kontrola byla rozšířena na třetí kapitolu a generuje i její snímky a přehled obou grafů.

Finální verze prošla vykreslením celé knihy (úvod a tři lekce), kontrolou R a kontrolou HTML. Ověřeno v R 4.5.1, dplyr 1.1.4, nycflights13 1.0.2 a Quarto 1.9.38. R upozornilo na sestavení tibble, purrr a stringr pod R 4.5.3; tyto zprávy nejsou potlačené a načtení i výpočty proběhly úspěšně. Samostatný test potvrdil nezávislost závěrečného řešení na předchozím stavu relace.

Kontrola bílých znaků je čistá u vytvořeného výukového textu a upravených podpůrných souborů. Převzatý `week_03.R` obsahuje původní koncové mezery a prázdné řádky na konci souboru, které byly záměrně zachovány spolu s ostatním podkladem; úplný `git diff --check` je proto u tohoto jediného souboru hlásí.

HTML třetí kapitoly má 11 zpočátku sbalených řešení, 67 kopírovatelných bloků a dva grafy. Všechna řešení byla rozbalena a všechny bloky skutečně zkopírovány do schránky; ověřeno 322 místních cílů odkazů, pravá osnova a navigace. Celá kniha prošla bez chyb JavaScriptu a bez vodorovného přetékání při šířce 390 px (kapitola 1: 10 řešení / 47 bloků; kapitola 2: 13 řešení / 40 bloků). Oba nové grafy byly vizuálně porovnány s interpretací, prohlédnuty byly i snímky tabulky, rozbaleného řešení a mobilního rozložení. První pokus o HTML kontrolu se zastavil na neexistujícím cíli pomocného snímku tabulky; kontrola byla opravena na stabilní identifikátor oddílu a celý běh poté prošel. Ověření je místní; veřejné nasazení vyžaduje sloučení uživatelem a úspěšný publikační běh.

## Rozdělení kapitol a nová kapitola o grafech, 19. 9. 2026

Výklad od původního oddílu „První graf: od dat k otázce“ byl přesunut do druhé kapitoly. Závěrečná úloha byla rozdělena: fiktivní dotazníkové skóry zůstaly v první kapitole, samostatný graf tučňáků přešel do druhé. Obě řešení nyní používají explicitní `print()`, aby fungovalo zobrazení výsledků také při spuštění skriptu přes Source. Cíle, předpoklady, shrnutí, časté potíže a úvod knihy byly přizpůsobeny novému členění. Přesunuté grafy zachovávají původní štítky pro odkazy a kontrolu shody výsledků. Nové mezi-kapitolové odkazy používají stabilní identifikátory oddílů.

Novým podkladem je uživatelem dodaný `scripts/week_02.R`, zachovaný beze změny. Z jeho grafické části byly doplněny kratší zápisy, pipe operátor, četnosti a řazení kategorií, histogramy, hustoty, boxploty, podíly, panely a práce s exportem. Opakující se varianty jsou sloučeny do výkladu a cvičení. Legenda pro více trendových čar je nepovinná. Část `Data Transformation` s `flights` zůstává podkladem pro další kapitolu; nespadá do současného tématu. Pro budoucí zpracování: tvrzení skriptu, že tidyverse automaticky načte `nycflights13`, je nesprávné a bude nutné doplnit samostatné připojení datového balíčku.

### Opravy a didaktická rozhodnutí

- V první kapitole bylo „freewarový software“ nahrazeno přesnějším označením svobodného softwaru s otevřeným zdrojovým kódem podle R Project. Odstraněno bylo lokální potlačení všech varování při připojení balíčků; varování o sestavení balíčků v jiné verzi R zůstávají viditelná.
- V přesunutém výkladu byly opraveny překlepy a porušené věty u `aes()`, popisu Gentoo, `geom_smooth()` a mapování tvaru. Doplněny konkrétní interpretace bodů, skupinových křivek i přímek. Analytický postup ani vstupní hodnoty přesunutých grafů se nezměnily.
- V návaznosti na podklad rozlišujeme varování o chybějících hodnotách od chyby. Kontrola `NA` předchází jejich vynechávání. Počty druhů využívají všech 344 řádků; grafy hmotnosti nebo hmotnosti a ploutve využívají 342 dostupných měření. Žádná nová imputace ani plošné odstranění neúplných řádků nebyly provedeny.
- Histogramy mají pro srovnávání šířek explicitní `boundary = 0`. Tím je oproti výchozímu nastavení ve skriptu určeno umístění hranic, které může změnit četnosti konkrétních intervalů; původní hodnoty a celkový počet měření zůstávají stejné. Z mnoha variant ve skriptu zůstávají šířky 200, 20 a 2000 g, další možnost `bins` je vysvětlena stručně.
- Hustota je vysvětlena jako hustota, nikoli četnost nebo procento. Boxplot dostal vysvětlení kvartilů a vousů; podílové sloupce výslovně určují jmenovatel. Interpretace zohledňují provázanost druhu a ostrova a nevyvozují kauzální účinky.
- Nepovinné porovnání lineární a loess čáry používá pojmenované ruční škály a modrou/oranžovou paletu. Vazba názvu čáry na barvu je tak explicitní, nezávislá na pořadí kategorií; samotné odhady zůstávají stejné.
- Export vytváří cílovou složku a vždy uvádí `plot =`. Původní obecné spojení 72 dpi s vhodností pro prezentaci bylo nahrazeno vysvětlením fyzických rozměrů, pixelů a čitelnosti. `View()` a úplný výpis tabulky jsou ukázky pro interaktivní práci, nejsou spouštěny při renderu.
- Výklad a vlastní cvičení navazují na R4DS, kapitolu Data visualization; konkrétní funkce byly ověřeny v dokumentaci ggplot2, forcats a palmerpenguins. Závěrečné interpretační scénáře používají psychologické otázky a nepředstírají existenci naměřených dat.

### Osnova a ověření

Společná konfigurace výslovně nastavuje `toc-location: right`, český nadpis „Obsah kapitoly“, hloubku tři a počáteční rozbalení jedné úrovně. Hlavní oddíly jsou viditelné a pododdíly se rozvíjejí při čtení podobně jako v R4DS. Na úzké obrazovce standardní motiv pravý panel skrývá. Chování odpovídá [dokumentaci Quarto](https://quarto.org/docs/output-formats/html-basics.html#table-of-contents).

Kontroly byly rozšířeny na obě kapitoly. `check-r.R` ověřuje obě závěrečná řešení v samostatných čistých procesech, původní číselné příklady, shodu přesunutého grafu s `week_01.R`, nové četnosti, mediány, součty v histogramu, podíly, počet skupinových přímek a panelů. `check-html.cjs` odvozuje počet řešení ze zdroje místo pevného počtu, prochází všechny ukázky v obou kapitolách a ověřuje také pravou osnovu a cíle odkazů napříč knihou. Generuje snímky stránek a přehled všech grafů pro vizuální posouzení.

Úspěšně vykreslena celá kniha v R 4.5.1 a Quarto 1.9.38, včetně všech spustitelných řešení. Numerické a grafické kontroly prošly. R upozornilo na sestavení tibble, purrr a stringr pod R 4.5.3; nevedlo to k selhání. Automatická kontrola neotvírá interaktivní prohlížeč dat RStudia ani neprovádí instalace balíčků.

HTML kontrola ověřila v první kapitole 10 sbalených řešení, 47 kopírovatelných ukázek a 8 obrázků; ve druhé 13 řešení, 40 ukázek a 27 grafů. Všech 87 ukázek bylo skutečně zkopírováno do schránky, všechna řešení šla rozbalit včetně textu a obrázků. Ověřena navigace i místní odkazy, pravá osnova na desktopu, nulové chyby JavaScriptu a žádné vodorovné přetékání při šířce 390 px. Grafy byly vizuálně prohlédnuty a porovnány s interpretacemi, včetně českých popisků a legend.

## Historické záznamy

Následující záznamy popisují tehdejší podobu první lekce před tematickým rozdělením; jejich počty a umístění grafů nejsou popisem současného stavu.


## Kontrola

### Doplnění základní syntaxe 13. 9. 2026

Do lekce byly přidány spustitelné ukázky hashtagu uvnitř textové hodnoty, výpisu pomocí `print()` a samotného jména objektu, přiřazení v závorkách, přiřazování argumentů podle jména a pořadí a volání funkce přes `::`. Výklad rozlišuje automatický výpis při interaktivním spuštění od `source()` a připojení balíčku od načtení jeho jmenného prostoru. Příklad shodných jmen používá `dplyr::filter()` a `stats::filter()`. Analytické příklady a původní skript se neměnily.

Úspěšně dokončeno vykreslení `lekce_01.qmd`, včetně všech spustitelných řešení. Samostatně v čisté relaci R ověřeno, že `dplyr::n_distinct(c(1, 1, 2, 3))` vrátí `3` bez připojení `dplyr`, a že jej ani následně nepřipojí do vyhledávací cesty. Kontrola HTML ověřila všech 12 zpočátku sbalených řešení a jejich rozbalení, skutečné kopírování všech 62 bloků, trvale viditelný český popisek, 16 načtených obrázků, funkční vnitřní odkazy a nulové chyby JavaScriptu. Při šířce 390 px stránka nepřetéká. Quarto a samostatná kontrola R vyžadovaly spuštění mimo omezené prostředí agenta kvůli přístupu k AppData a uživatelské knihovně balíčků.

### Předchozí ověření

Po redakční úpravě pro samostudium jsou veškeré informace o převodu podkladu a technické přípravě ponechány pouze v této autorské dokumentaci. Výukový kód, zadání a řešení se při této úpravě nezměnily; studentský text vysvětluje postupy bez předpokladu přístupu k původnímu skriptu.

Ověřeno 12. 9. 2026 v R 4.5.1 a Quarto 1.9.38:

- Vykreslení všech výpočtů a řešení včetně očekávaných demonstračních chyb.
- Nezávislé spuštění závěrečného řešení v nové relaci `Rscript --vanilla`.
- Shoda souřadnic, barev, tvarů, velikostí bodů a modelové přímky i jejího intervalu s konečným grafem původního `week_01.R`.
- 11 rozbalovacích řešení, 52 tlačítek kopírování včetně bloků v řešeních, 15 načtených obrázků a grafů.
- Skutečné kopírování obsahu všech 52 bloků do schránky, český viditelný popisek, prázdný seznam chyb JavaScriptu a rozložení při šířce 390 px.

Záznamy a pomocné kontroly jsou ve `_verification/`. Během ověřování mělo prostředí agenta nastavenou linuxovou hodnotu `LC_ALL=C.UTF-8`, kterou Windows R nepřijalo. Pro kontrolní spuštění byla pouze v daném procesu nahrazena hodnotou `English_United States.utf8`; globální nastavení RStudia ani projektu se neměnilo. V běžné správně nastavené instalaci tato úprava není potřeba. Finální grafy byly zkontrolovány i vizuálně kvůli české diakritice.

Nové ověření pro prostředí Windows s instalacemi použitými při přípravě:

```powershell
$env:LC_ALL = 'English_United States.utf8'
& 'C:\Program Files\R\R-4.5.1\bin\Rscript.exe' --vanilla quarto/_verification/check-r.R
node quarto/_verification/check-html.cjs
```

Pomocná kontrola HTML používá Playwright a Chromium; instalaci nebo nastavení proměnných PLAYWRIGHT_MODULE a CHROME_PATH popisuje kořenový README.md. Tyto závislosti nejsou potřeba ke čtení ani k vykreslení lekce.

## Oprava pořadí publikačních kroků 19. 9. 2026

První běh na GitHubu selhal při kontrole existence `output/figures/tucnaci.png`: soubor vzniká v bloku `export-grafu` při vykreslení druhé kapitoly, ale kontrola R byla ve workflow zařazena před render. Lokální ověření tuto závislost neodhalilo, protože render a kontrola byly spuštěny souběžně. Workflow nyní nejprve vykreslí celou knihu a poté spustí kontroly R a HTML, v souladu s pořadím v kořenovém README. Kontroly ani podmínky publikování se neoslabují; obsah kapitol a výpočty zůstávají beze změny.

Oprava byla lokálně ověřena v nové pracovní kopii bez předchozích výstupů: postupně prošlo vykreslení celé knihy, kontrola R a kontrola HTML (23 řešení, 87 kopírovacích tlačítek, obě kapitoly bez mobilního přetékání). Veřejné nasazení vyžaduje sloučení opravy.

## Publikační postup 19. 9. 2026

Přidán `.github/workflows/publish.yml`: sestavení a existující kontroly R a HTML při pull requestu do `main`, publikování pouze z `main` po úspěšných kontrolách. Provozní návod je v kořenovém `README.md`. Obsah kapitol ani výpočty se neměnily.

V oddělené pracovní kopii z aktuálního `main` prošlo vykreslení celé knihy v Quarto 1.9.38, kontrola výpočtů v R 4.5.1 a kontrola HTML: 23 skrytých a rozbalitelných řešení, 87 ověřených kopírovacích tlačítek, 35 obrázků, vnitřní odkazy a obě kapitoly bez přetékání při šířce 390 px; žádné chyby JavaScriptu. Ověřena syntaxe YAML a rozdíly souborů. Prostředí Windows hlásilo varování o locale a balíčcích sestavených pod R 4.5.3; kontroly přesto úspěšně skončily.

Toto lokální ověření neověřuje instalaci závislostí na linuxovém runneru GitHubu ani veřejné nasazení. První část ověří běh pull requestu; nasazení a veřejnou cestu je nutné ověřit po zapnutí Pages a sloučení.

## Podklady a odborné úpravy při přípravě lekce

Podkladem je `scripts/week_01.R` a sedm dodaných snímků ve složce `screenshots`. Postupy byly při přípravě porovnány s oficiální dokumentací dne 12. 9. 2026. Příklad s tučňáky a jeho analytický záměr zůstaly zachovány. Následující poznámky dokumentují převod pro autora; studentům jsou příslušné principy vysvětleny přímo v jednotlivých oddílech.

- Označení odstraněných řádků v `geom_point()` jako „error“ bylo opraveno: jde o varování a graf vzniká. Záměrné chyby ve jménech objektů jsou odděleny a označeny.
- `seq(from = 1, to = 10, by = 2)` vrací lichá čísla do 9, nikoli všechna celá čísla do 10. Ukázky stylů jmen v podkladu byly samostatné názvy bez vytvoření objektů, a proto je nelze úspěšně spustit jako souvislý skript.
- Doporučení začínat jméno písmenem bylo odlišeno od úplných syntaktických pravidel R.
- Výchozí metoda `geom_smooth()` není vždy `loess`. Doplněno bylo vysvětlení globálního a lokálního mapování a omezení společné regresní přímky pro různé druhy.
- Konečný graf zachovává data, proměnné i lineární specifikaci podkladu. `na.rm = TRUE` pouze potlačuje již vysvětlená varování; nemění původní tabulku ani nedoplňuje chybějící hodnoty. Doplněny jsou české popisky a opakovatelný export.
- Tvrzení o reprodukovatelnosti byla upřesněna: samotné použití projektu nebo R ji nezaručuje. Preference motivu byla oddělena od odborných tvrzení a psaní speciálních znaků od zkratek RStudia.

Označená cvičení jsou vlastní zadání inspirovaná uvedenými oddíly R4DS, nikoli doslovné překlady; ostatní cvičení jsou vlastní procvičení lekce. Ve studentském textu zůstávají stručné odkazy na inspiraci a odborné zdroje.

## Převod na učebnici 18. 9. 2026

Projekt nyní používá Quarto Book s nečíslovaným úvodem a první kapitolou. Společná nastavení HTML jsou v kořenovém `_quarto.yml`; výstup vzniká v `_book/`. Zdroj kapitoly zůstává na původním místě, výukové příklady ani původní R skripty se při tomto převodu neměnily. Starší samostatné HTML není výstupem knihy a Git je ignoruje.

V novém adresáři úspěšně proběhlo vykreslení celé knihy a kontrola výpočtů v R 4.5.1 včetně samostatného závěrečného řešení a shody grafu s původním skriptem. R upozornilo, že balíčky tibble, purrr a stringr byly sestaveny pod R 4.5.3; kontroly přesto prošly.

Kontrola výsledného HTML potvrdila navigaci z úvodu do kapitoly, správné číslo kapitoly 1, 12 zpočátku skrytých a rozbalitelných řešení, skutečné kopírování všech 62 ukázek, 16 načtených obrázků, vnitřní odkazy a nulové chyby JavaScriptu. Při šířce 390 px stránka nepřetékala. Kontrola HTML nyní používá výstup `_book/` a umožňuje nastavit Playwright a prohlížeč proměnnými prostředí místo pevných osobních cest.
