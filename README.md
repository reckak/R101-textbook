# R101: Praktický úvod do R

Česká učebnice pro studenty psychologie bez předchozí zkušenosti s programováním. Projekt používá [Quarto Book](https://quarto.org/docs/books/); aktuálně obsahuje úvod a první kapitolu.

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

Kontrola HTML ověřuje navigaci knihy, skrytí a rozbalení řešení, kopírování kódu, obrázky, vnitřní odkazy a mobilní rozložení. Generované výstupy a lokální pracovní soubory se do Gitu neukládají.

Další větší změny připravujte v samostatné větvi a před sloučením kontrolujte rozdíly a vykreslený výsledek. Repozitář je propojený s GitHubem; automatické publikování přes GitHub Pages zatím není nastavené.
