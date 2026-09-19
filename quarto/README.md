# Autorská dokumentace učebnice R101

## Aktuální uspořádání

`lekce_01.qmd` obsahuje základy R a RStudia, práci s projektem, skriptem, objekty, funkcemi, vektory a balíčky. `lekce_02.qmd` obsahuje základy ggplot2 včetně interpretací a samostatné přípravy všech dat a balíčků. Výstupy jsou `_book/quarto/lekce_01.html` a `_book/quarto/lekce_02.html`; pro čtení knihy není třeba instalovat R. Instalační a provozní postupy popisuje kořenový `README.md`.

Každá kapitola má vlastní spuštění kódu; instalační příkazy a interaktivní prohlížení dat či nápovědy mají `eval: false`. Všechna výpočetní řešení se při renderování spouštějí. Řešení jsou v HTML zpočátku sbalená. V první kapitole zůstává lokálně povolená demonstrační chyba ve jménu objektu. U prvního bodového grafu ve druhé kapitole je záměrně viditelné varování o dvou chybějících souřadnicích; další grafy stejných proměnných používají vysvětlené `na.rm = TRUE`. Neočekávaná varování se globálně nepotlačují.

Exporty druhé kapitoly vznikají v `output/figures/tucnaci.png` a `output/figures/tucnaci_samostatne.png`. Opakované spuštění aktualizuje pouze tyto odvozené soubory. Starší samostatné HTML mimo `_book/` není aktuálním výstupem knihy.

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
