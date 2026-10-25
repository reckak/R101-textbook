# Provoz učebnice R101

[Zpět na přehled projektu](../README.md). Všechny příkazy a cesty v ukázkách jsou vztažené ke kořeni repozitáře. Autorská rozhodnutí a historii ověření obsahuje [autorská dokumentace](../quarto/README.md).

## Práce s projektem

Otevřete `R101-textbook.Rproj` v RStudiu. Potřebujete R, Quarto a balíčky uvedené v `scripts/00_instalace_balicku.R`. Instalační skript spusťte jednorázově podle potřeby, nikoli při každém vykreslení.

Z kořene projektu vykreslete celou učebnici:

```sh
quarto render
```

### České znaky při renderu ve Windows

Pokud spouštěcí prostředí předává R linuxové locale `C.UTF-8`, nemusí je
Windows přijmout. R pak může přejít do locale `C` a v grafech nahradit
diakritiku zápisy jako `<U+00F3>`. Samotný úspěšný render ani kontrola HTML
takto poškozený text uvnitř PNG neodhalí.
Souhrnná kontrola `check-r.R` proto vyžaduje UTF-8 locale; kontroluje
aktuální relaci R, nikoli nastavení staršího renderu. Nenahrazuje tedy
nové vykreslení a vizuální prohlédnutí obrázků.

V takovém prostředí nastavte před renderem v PowerShellu UTF-8 locale
podporované Windows a zkontrolujte je ve stejné instalaci R, kterou používá
Quarto:

```powershell
$env:LANG = 'English_United States.utf8'
$env:LC_ALL = 'English_United States.utf8'
$env:LC_CTYPE = 'English_United States.utf8'
Rscript --vanilla -e 'print(Sys.getlocale()); stopifnot(isTRUE(l10n_info()[["UTF-8"]]))'
quarto render
```

Pokud příkazy nejsou v `PATH`, použijte úplné cesty k `Rscript.exe`
a `quarto.exe`. Nastavení platí pro tuto relaci PowerShellu a její potomky;
nemění systémové locale. Na Linuxu tyto windowsové hodnoty nepoužívejte.
Po opravě znovu vykreslete celou knihu a vizuálně ověřte české popisky
v grafech všech dotčených kapitol včetně rozbalených řešení.

### Náhled a umístění výstupu

Pro prohlížení s průběžným obnovováním použijte:

```sh
quarto preview
```

Výstup vzniká ve složce `_book/`, úvodní stránka je `_book/index.html`. Pro přenos nebo publikování uchovejte celou složku `_book/` včetně podpůrných souborů. Starší `quarto/lekce_01.html` není aktuálním výstupem knihy.

## Uspořádání

- `index.qmd`: úvod pro studenty.
- `quarto/lekce_01.qmd`: první kapitola a vzor pro další materiály.
- `quarto/lekce_02.qmd`: základy tvorby a interpretace grafů v ggplot2.
- `quarto/lekce_03.qmd`: úpravy dat, chybějící hodnoty a skupinové souhrny v dplyr.
- `quarto/lekce_04.qmd`: vektory, převody typů, faktory, seznamy a datové tabulky.
- `quarto/lekce_05.qmd`: import CSV, Excelu a SPSS, příprava dat a metadata s labelled.
- `quarto/lekce_06.qmd`: reverzní položky, Cronbachovo alfa, skóry škál, bodový graf s trendovými čarami a tvar rozdělení skórů (Q-Q grafy s qqplotr).
- `quarto/lekce_07.qmd`: základní statistické testy (Levenův test, Welchův a Studentův t-test, Cohenovo d, Pearsonova korelace, χ² test nezávislosti) na datech o rodičovském monitoringu.
- `data/README.md`: původ veřejných vstupů lekcí 5 až 7 a pravidla výukových výřezů.
- `_quarto.yml`: pořadí kapitol a společné nastavení knihy.
- `quarto/lesson.css`: společné styly včetně tlačítek kopírování.
- `scripts/`: původní podklady a samostatná instalace balíčků.
- `screenshots/`: zdrojové snímky RStudia.
- `tests/`: otázky pro IS MUNI; nejde o automatické softwarové testy.
- `quarto/_verification/`: technické kontroly lekce.
- `quarto/README.md`: autorská dokumentace a záznamy ověření.
- `docs/provoz.md`: tento provozní návod pro instalaci, kontroly a publikování.

Novou kapitolu přidejte jako `.qmd` do `quarto/` a zapište ji do `book.chapters` v `_quarto.yml`. Řiďte se [AGENTS.md](../AGENTS.md); původní skripty uchovávejte beze změn. Každá kapitola musí běžet bez objektů vytvořených v jiné kapitole.

## Kontroly podle rozsahu změny

Rozsah místních kontrol volte podle změny v souladu s [AGENTS.md](../AGENTS.md):

- **Obsahová úprava existující kapitoly:** spusťte její kód včetně všech vzorových řešení, vykreslete upravenou kapitolu a zkontrolujte skutečné výstupy a interpretace. V HTML ověřte rozbalování řešení, kopírování kódu, obrázky, čitelnost grafů a tabulek i mobilní zobrazení.
- **Nová kapitola nebo změna společné konfigurace, stylů či navigace:** vykreslete celou knihu a ověřte dotčené stránky, navigaci a odkazy mezi kapitolami.
- **Pouze instrukce nebo autorská dokumentace bez dopadu na knihu:** zkontrolujte věcnou správnost, odkazy a rozdíly pomocí `git diff --check`; nový render není nutný.
- **Testy pro IS MUNI:** použijte zvláštní kontroly formátu a příkladů z oddílu „Testy pro IS MUNI“ v `AGENTS.md`; samotný test nevyžaduje render celé knihy.

Kontrola jiné kapitoly nebo starší verze nenahrazuje ověření aktuální změny. Po změně kódu či dat ověřte všechny dotčené výstupy a interpretace, grafy také vizuálně. Kontroly podle nového obsahu rozšiřujte a neověřené části i důvody uveďte v autorské dokumentaci a při předání.

Následující příkazy spouštějí souhrnné kontroly celé knihy, nikoli jen změněné kapitoly. Pro úplné ověření nejprve spusťte `quarto render`: kontroly využívají vykreslené HTML a exportované soubory. Tento úplný postup používá také GitHub Actions při každém pull requestu; místní kontrola čistě dokumentační změny může mít užší rozsah podle pravidel výše.

Kontrolu výpočtů spusťte příkazem `Rscript --vanilla quarto/_verification/check-r.R`. Pro kontrolu HTML je potřeba Node.js a Playwright: jednorázově spusťte `npm install --no-save --package-lock=false playwright` a `npx playwright install chromium`, potom `node quarto/_verification/check-html.cjs`. Alternativně lze cestu k modulu Playwright předat proměnnou `PLAYWRIGHT_MODULE` a cestu k existujícímu prohlížeči proměnnou `CHROME_PATH`.

Kontrola R ověřuje samostatná závěrečná řešení všech sedmi kapitol, číselné interpretace a vybrané grafické výpočty. Třetí až sedmou kapitolu navíc spouští celé v samostatných čistých relacích pomocí `check-lesson-03.R` až `check-lesson-07.R`, včetně všech řešení a očekávaných demonstračních chyb či varování. U čtvrté kapitoly kontroluje význam kódů faktorů, strukturu výběrů, shodu základního R a dplyr a jmenovatele podílů. U páté ověřuje typy importu, kódy chybění, popisky, shodu hodnot před a po jejich přidání, exporty a přesný seznam sloupců veřejného výřezu. Je-li lokálně přítomen původní výzkumný export, porovná také každou ponechanou hodnotu. U šesté kontroluje obrácení položek a ztrátu popisků, alfa, pravidlo chybění, shodu `rowwise()` s `group_by(id)`, `drop_na()`, rozdíl mezi `limits` a `coord_cartesian()`, reprodukovatelnost pásů qqplotr a shodu skórů s podkladovým skriptem. U sedmé ověřuje opravu kohorty, pravidlo chybění a shodu skóru s podkladem, výsledky Welchova, Studentova i základního t-testu, opakovatelnost bootstrapového intervalu Cohenova d, korelace, χ² test bez Yatesovy korekce a testy uvnitř kohort; je-li lokálně přítomen původní export `long2.sav`, porovná s ním veřejný výřez.

Kontrola HTML prochází všech sedm kapitol: ověřuje navigaci knihy, pravou osnovu, skrytí a rozbalení všech řešení, skutečné kopírování všech ukázek kódu, obrázky, odkazy uvnitř knihy a mobilní rozložení. V páté až sedmé kapitole klikne na všechny odkazy ke stažení a ověří i shodu stažených bajtů se vstupy a přesný obsah publikovaných datových složek. Vytváří snímky stránek a přehledy grafů ve `quarto/_verification/` pro vizuální kontrolu. Na úzkých obrazovkách se pravá osnova standardně skrývá. Generované výstupy a lokální pracovní soubory se do Gitu neukládají.

Render páté až sedmé lekce používá místní data a nepotřebuje síť. Osm veřejných souborů je výslovně vyjmenovaných v `project.resources`; nepřidávejte sem celou složku `data`, protože obsahuje i místní výzkumné exporty. Přímé GitHub URL v lekci používají pevný commit s daty. Volitelné online příklady nejsou vykonávány při renderu; při změně odkazů je ověřte samostatně pomocí `Rscript --vanilla quarto/_verification/check-lesson-05-downloads.R`, `Rscript --vanilla quarto/_verification/check-lesson-06-downloads.R` a `Rscript --vanilla quarto/_verification/check-lesson-07-downloads.R`.

Změny připravujte v samostatné větvi a předávejte pull requestem. Před sloučením kontrolujte rozdíly a podle rozsahu změny také vykreslený výsledek; sloučení provádí uživatel na GitHubu.

## Publikování na GitHub Pages

Postup v `.github/workflows/publish.yml` při pull requestu do `main` sestaví celou knihu a spustí kontroly R a HTML popsané výše. Po změně `main` navíc zveřejní ověřený obsah `_book/` na GitHub Pages. Neúspěšná kontrola zabrání publikování. Generované soubory se neukládají do zdrojové větve a není potřeba větev `gh-pages` ani osobní přístupový token.

Při prvním zprovoznění:

1. V repozitáři na GitHubu otevřete **Settings → Pages**.
2. V části **Build and deployment → Source** vyberte **GitHub Actions**. Nevytvářejte další nabízený workflow; projekt již vlastní obsahuje.
3. Slučte pull request s publikačním postupem do `main`.
4. Na kartě **Actions** sledujte postup **Build and publish textbook**. Po úspěšném dokončení bude učebnice dostupná na <https://reckak.github.io/R101-textbook/>.

Pokud jste Pages zapnuli až po sloučení, spusťte na kartě **Actions → Build and publish textbook → Run workflow** běh pro větev `main`. Ruční běh na jiné větvi pouze ověří sestavení a nepublikuje web. V nastavení repozitáře musí být povolené GitHub Actions a použité akce; dostupnost Pages pro soukromý repozitář závisí na plánu GitHubu.

Pro sestavení se používá R 4.5.1 a Quarto 1.9.38. Seznam R balíčků v kroku `setup-r-dependencies` odpovídá `scripts/00_instalace_balicku.R`; při přidání závislostí aktualizujte obě místa. Verze balíčků nejsou uzamčené, takže jejich aktualizace mohou vyžadovat úpravu příkladů nebo kontrol. Instalace probíhá samostatně před vykreslením. Na web se odesílá pouze `_book/`.

Po prvním nasazení zkontrolujte také veřejnou adresu, přechody mezi kapitolami a načítání obrázků. Lokální kontrola HTML sama neověřuje nastavení GitHub Pages ani chování pod veřejnou cestou `/R101-textbook/`.

Akce `checkout@v7`, `setup-node@v7`, `configure-pages@v6` a `deploy-pages@v5`
používají vlastní běhové prostředí Node.js 24. `upload-pages-artifact@v5`
volá `upload-artifact@v7`, rovněž s Node.js 24. Toto prostředí je nezávislé
na `node-version: '22'`, které určuje Node.js pro projektovou kontrolu HTML.
Při varování o zastaralém Node.js u akce aktualizujte příslušnou akci
(u vnořených akcí také její nadřazenou akci); samotná změna `node-version`
takové varování neřeší. Viz [oznámení GitHubu o přechodu na Node.js 24](https://github.blog/changelog/2025-09-19-deprecation-of-node-20-on-github-actions-runners/).

Dokumentace: [GitHub Pages a vlastní workflows](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages), [Quarto v GitHub Actions](https://github.com/quarto-dev/quarto-actions).
