# První lekce R101

`lekce_01.qmd` je zdroj první kapitoly knihy. Aktuální výstup je `_book/quarto/lekce_01.html`; pro přenos knihy je třeba celá složka `_book/`. Starší samostatné HTML je ponecháno pouze lokálně. Pro čtení knihy není třeba instalovat R.

## Úpravy a nové vykreslení

Otevřete projekt `R101-textbook.Rproj`, potom `quarto/lekce_01.qmd` a použijte **Render** v RStudiu. Alternativně z kořene projektu spusťte v terminálu:

```sh
quarto render
```

Je třeba mít R, Quarto a balíčky `tidyverse`, `palmerpenguins`, `ggthemes`, `knitr` a `rmarkdown`. Jednorázová instalace je oddělená v `scripts/00_instalace_balicku.R`. Zdrojový skript `scripts/week_01.R` zůstal beze změny.

Projektová konfigurace `_quarto.yml` určuje kořen projektu jako pracovní adresář kódu. Relativní cesty k obrázkům v textu se vztahují k umístění `.qmd`. Pro nové vykreslení uchovejte celou strukturu projektu, zejména složku `screenshots` a `quarto/lesson.css`. Samotné `.qmd` nestačí.

Při renderování se spouštějí také všechna řešení. V HTML jsou jejich celé obsahy ve výchozím stavu sbalené. Záměrně chybné názvy objektů mají lokálně povoleno zobrazení chyby; ostatní neočekávané chyby render zastaví. Instalace a interaktivní otevření nápovědy nejsou součástí renderu. Běžná informační hlášení balíčků jsou skryta; varování o dvou vynechaných řádcích je u prvního bodového grafu záměrně viditelné.

Render vytváří také `output/figures/tucnaci.png` a `output/figures/tucnaci_samostatne.png`. Opakovaný render tyto odvozené soubory aktualizuje.

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
