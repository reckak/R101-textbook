# Data k páté lekci

Veřejné vstupy lekce jsou výslovně vyjmenované v `_quarto.yml`. Kopírují se do
`_book/data/raw/`, odkud je lze stáhnout i bez přístupu do IS MUNI. Kapitola
v online ukázkách navíc používá přímé adresy GitHubu s pevnou revizí. Tabulka
ke stažení uvádí jeden odkaz pro každý soubor. Render používá místní soubory
a nestahuje data ze sítě.

| Soubor | Původ a použití |
| --- | --- |
| `raw/ceske_odpovedi.csv` | Šest fiktivních českých odpovědí vytvořených pro výuku kódování textu. Soubor je uložen v Windows-1250, nikoli UTF-8; tento rozdíl je záměrný. Generátor je `scripts/prepare_lesson_05_encoding.R`. `.gitattributes` zachovává přesné bajty souboru. |
| `raw/students.txt` | Výukový příklad z [R4DS 2e, Data import](https://r4ds.hadley.nz/data-import.html). Dodaná kopie zachována včetně původních konců řádků; soubor je CSV navzdory příponě TXT. |
| `raw/international.sav` | Dodaný kurzový soubor, 20 zemí a 7 proměnných. Slouží pouze k ukázce importu a metadat SPSS. Primární zdroj a období ukazatelů nebyly dodány; neprezentovat jako aktuální statistiku. |
| `raw/help_seeking.xlsx` | Podle vyučujícího data z malého studentského seminárního projektu. 172 pozorování, 34 proměnných, listy `data` a `codebook`. Nesimulovaná data; metodika výběru nebyla dodána. Původní soubor se neupravuje. |
| `raw/four_countries_teaching.xlsx` | Schválený výřez z dodaného `four_countries_data.xlsx`, souvisejícího podle vyučujícího s níže uvedeným článkem. 1 084 pozorování, 20 uzavřených položek a země, původní tři řádky metadat. Nejde o kompletní analytický soubor článku. |

Zdroj výzkumného kontextu čtyř zemí: Marmolejo-Ramos, F., Bulut, O., Anunciação,
L., Marques, L., Barthakur, A., Kundrat, J., Rečka, K., Karakale, Ö., Correa,
J. C., Pinos-Ullauri, L. A., Ospina, R., & Tejada, J. (2025). From human artefact
to machine output: automating the “art” of psychological measurement.
*Journal of Psychology and AI, 1*(1), 2561692.
<https://doi.org/10.1080/29974100.2025.2561692>

## Výukový výřez čtyř zemí

Výběr je povoleným seznamem názvů: `q1_prop_1` až `q6_prop_1`, `q1_anx_1` až
`q8_anx_1`, `q1_p_ai_1` až `q3_p_ai_1`, `q4_ado_ai_1` až `q6_ado_ai_1` a
`Country`. Pořadí řádků, hodnoty i tři řádky metadat vybraných sloupců zůstávají
zachovány. Nevkládají se IP adresy, souřadnice, identifikátory odpovědí,
časové údaje, demografie ani otevřené odpovědi. Toto je konkrétní minimalizace
sdílených údajů, nikoli tvrzení o formálně prokázané anonymitě.

Pomocný skript `scripts/prepare_lesson_05_data.mjs` vytváří novou tabulku jen
z povolených sloupců pomocí `@oai/artifact-tool`. Vyžaduje lokálně dostupný
původní export a tuto autorskou knihovnu; není součástí renderu, CI ani
studentského postupu. Pro lokální regenerování z kořene projektu použijte
`node scripts/prepare_lesson_05_data.mjs`. Hotový výukový soubor je v Gitu,
takže jej lze používat bez původního exportu i bez generátoru. Diagnostika
generátoru patří do ignorovaného `output/lesson05/`.

Oba původní soubory `four_countries_data.xlsx` a `four_countries_data2.xlsx`
zůstávají lokálně a jsou v `.gitignore`. Nezahrnujte je do veřejného commitu
ani do zdrojů Quarto. Ostatní dosud nezařazené datasety nejsou součástí této
lekce ani jejího publikačního balíčku.

Výsledky studentského skriptu vznikají v ignorované složce `data/clean/`.
Původní místní `data/cleaned/` je jiná složka a tato lekce ji nepoužívá.
