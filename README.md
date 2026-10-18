# R101: Praktický úvod do R

Česká učebnice pro studenty psychologie bez předchozí zkušenosti s programováním, vytvořená jako [Quarto Book](https://quarto.org/docs/books/).

**[Otevřít učebnici na webu](https://reckak.github.io/R101-textbook/)**

## Rychlé spuštění

Otevřete `R101-textbook.Rproj` v RStudiu. Potřebujete R, Quarto a balíčky z [instalačního skriptu](scripts/00_instalace_balicku.R); instalaci spusťte jednorázově podle potřeby.

Z kořene projektu spusťte průběžný náhled:

```sh
quarto preview
```

Celou knihu vykreslíte příkazem:

```sh
quarto render
```

Výstup je v `_book/`, úvodní stránka v `_book/index.html`.

## Kde co najít

- `index.qmd` a `quarto/`: úvod, kapitoly a společné styly; pořadí a nastavení knihy určuje `_quarto.yml`.
- `scripts/` a `screenshots/`: podkladové skripty, instalace balíčků a snímky RStudia.
- [data/README.md](data/README.md): původ dat a pravidla veřejných výukových výřezů.
- `tests/`: otázky pro IS MUNI; technické kontroly jsou v `quarto/_verification/`.
- [AGENTS.md](AGENTS.md): pravidla tvorby a úprav; [quarto/README.md](quarto/README.md): autorská rozhodnutí a záznamy ověření.
- [docs/provoz.md](docs/provoz.md): podrobná instalace, přehled souborů, kontroly a publikování.

## Kontroly a publikování

Při obsahové úpravě ověřte kód, řešení a vykreslení upravené kapitoly. Při přidání kapitoly nebo změně společné konfigurace, stylů či navigace ověřte celou knihu. U samotné dokumentace bez dopadu na knihu stačí kontrola obsahu, odkazů a rozdílů; render není nutný. Podrobnosti a pravidla pro testy uvádějí [AGENTS.md](AGENTS.md) a [provozní návod](docs/provoz.md).

Úplná kontrola po vykreslení celé knihy používá tyto příkazy (kontrola HTML vyžaduje Node.js a Playwright, viz provozní návod):

```sh
Rscript --vanilla quarto/_verification/check-r.R
node quarto/_verification/check-html.cjs
```

Změny připravujte v samostatné větvi a předávejte pull requestem. GitHub Actions při PR ověří celou knihu; po změně `main` ji po úspěšných kontrolách publikuje na GitHub Pages. Sloučení samo nepotvrzuje úspěšné nasazení. Nastavení, závislosti a kontrolu veřejného webu popisuje [provozní návod](docs/provoz.md).
