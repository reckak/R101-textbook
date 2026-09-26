# R101: Praktický úvod do R

Česká učebnice pro studenty psychologie bez předchozí zkušenosti s programováním. Projekt používá [Quarto Book](https://quarto.org/docs/books/); aktuálně obsahuje úvod a kapitoly o základech R/RStudia, grafech v ggplot2 a úpravách dat v dplyr.

## Práce s projektem

Otevřete `R101-textbook.Rproj` v RStudiu. Potřebujete R, Quarto a balíčky uvedené v `scripts/00_instalace_balicku.R`. Instalační skript spusťte jednorázově podle potřeby, nikoli při každém vykreslení.

Z kořene projektu vykreslete celou učebnici:

```sh
quarto render
```

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
- `_quarto.yml`: pořadí kapitol a společné nastavení knihy.
- `quarto/lesson.css`: společné styly včetně tlačítek kopírování.
- `scripts/`: původní podklady a samostatná instalace balíčků.
- `screenshots/`: zdrojové snímky RStudia.
- `tests/`: otázky pro IS MUNI; nejde o automatické softwarové testy.
- `quarto/_verification/`: technické kontroly lekce.
- `quarto/README.md`: autorská dokumentace a záznamy ověření.

Novou kapitolu přidejte jako `.qmd` do `quarto/` a zapište ji do `book.chapters` v `_quarto.yml`. Řiďte se `AGENTS.md`; původní skripty uchovávejte beze změn. Každá kapitola musí běžet bez objektů vytvořených v jiné kapitole.

## Kontroly a GitHub

Po změně vykreslete celou knihu. Kontrolu výpočtů spusťte příkazem `Rscript --vanilla quarto/_verification/check-r.R`. Pro kontrolu HTML je potřeba Node.js a Playwright: jednorázově spusťte `npm install --no-save --package-lock=false playwright` a `npx playwright install chromium`, potom `node quarto/_verification/check-html.cjs`. Alternativně lze cestu k modulu Playwright předat proměnnou `PLAYWRIGHT_MODULE` a cestu k existujícímu prohlížeči proměnnou `CHROME_PATH`.

Kontrola R ověřuje samostatná závěrečná řešení všech tří kapitol, číselné interpretace a vybrané grafické výpočty. Třetí kapitolu navíc spouští celou v samostatné čisté relaci pomocí `check-lesson-03.R`, včetně všech řešení a obou očekávaných demonstračních chyb. Kontrola HTML prochází všechny tři kapitoly: ověřuje navigaci knihy, pravou osnovu, skrytí a rozbalení všech řešení, skutečné kopírování všech ukázek kódu, obrázky, odkazy uvnitř knihy a mobilní rozložení. Vytváří také snímky stránek a přehledy grafů ve `quarto/_verification/` pro vizuální kontrolu. Na úzkých obrazovkách se pravá osnova standardně skrývá, aby zůstal prostor pro text. Generované výstupy a lokální pracovní soubory se do Gitu neukládají.

Další větší změny připravujte v samostatné větvi a před sloučením kontrolujte rozdíly a vykreslený výsledek.

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

Dokumentace: [GitHub Pages a vlastní workflows](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages), [Quarto v GitHub Actions](https://github.com/quarto-dev/quarto-actions).
