# Data k páté až sedmé a deváté lekci

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

Výsledky studentského skriptu páté lekce vznikají ve složce `data/clean/`,
kterou Git jinak ignoruje. Původní místní `data/cleaned/` je jiná složka
a lekce ji nepoužívají.

## Vstupy šesté lekce

| Soubor | Původ a použití |
| --- | --- |
| `clean/help_seeking_data.rds` | Dodal vyučující 17. 10. 2026 jako připravenou verzi `help_seeking.xlsx`: 172 × 34, `-99` převedeno na `NA`, demografie jako faktory s anglickými kategoriemi, položky `help_` a `emo_` jako `haven_labelled` s popisky ze slovníku a sloupec `financial_situation` s opraveným názvem. Ověřeno: všech 33 sdílených sloupců má stejné hodnoty jako sešit po převodu `-99`. |
| `clean/help_seeking_codebook.rds` | Dodaný datový slovník ke stejným datům (34 řádků, `reversed` jako logický sloupec). Popisky hodnot zachovávají původní znění sešitu. |

Oba soubory jsou výjimkou z ignorování `data/clean/` (viz `.gitignore`) a jsou
výslovně uvedené v `project.resources`. Generátor nebyl dodán; jde o soubory
vyučujícího, nikoli o výstup páté lekce. Ostatní soubory v `data/clean/`
zůstávají místními výstupy a nezveřejňují se.

## Vstup sedmé lekce

| Soubor | Původ a použití |
| --- | --- |
| `raw/monitoring_teaching.sav` | Schválený výukový výřez z místního souboru `long2.sav` (768 × 210): data dvou kohort dospívajících z roku 1999 (6. třídy a 1. ročníky SŠ). Podle vyučujícího souvisí s projektem [Cesty do dospělosti](https://www.fss.muni.cz/vyzkum/resene-projekty/18505) (FSS MU, GAČR GAP407/12/0854, 2012–2016); stránka projektu sběr z roku 1999 sama nepopisuje. Nesimulovaná data. |

Výřez je povoleným seznamem 13 sloupců: `id`, `pohlavi`, `kohorta`, `vekr` a položky
`c01_99` až `c09_99`. Zachovává všech 768 řádků, hodnoty i popisky proměnných a hodnot,
včetně jedné chybně zapsané kohorty 66, kterou lekce opravuje. Neobsahuje školu, třídu,
věk v měsících, národnost, známky, rodinnou situaci ani další dotazníky. Jde o konkrétní
minimalizaci sdílených údajů, nikoli o tvrzení o formálně prokázané anonymitě.

Generátor `scripts/prepare_lesson_07_data.R` vyžaduje místní `data/raw/long2.sav`, který je
v `.gitignore`; spouští se z kořene projektu příkazem
`Rscript --vanilla scripts/prepare_lesson_07_data.R` a ověřuje shodu výřezu s originálem.
Soubor SPSS obsahuje časové razítko vytvoření, takže opakované spuštění změní bajty souboru,
nikoli jeho obsah; hotový výřez v Gitu proto bez potřeby nepřegenerovávejte.

## Vstup deváté lekce

| Soubor | Původ a použití |
| --- | --- |
| `clean/vztahy_zavazek.rds` | Výukový výřez z místního souboru `raw/ZZ_ckrvliry.sav` (124 × 21), dat z bakalářské práce: Mikulíková, L. (2008). *Záväzok a žiarlivosť vo vzťahu. Kvalita alternatív moderujúca vzťah záväzku a žiarlivosti.* Masarykova univerzita, Fakulta sociálních studií. <https://is.muni.cz/th/r2kr5/>. Data jsou pro výuku upravena (viz níže). |

Výřez má 124 řádků ve stejném pořadí jako zdroj a 12 sloupců s českými názvy:
`id` (doplněné pořadí 1–124), `pohlavi` (`pohlavie`), `narodnost` (`národnosť`),
`vek_roky` (`vek`), `vazny_vztah`, `spolecne_bydleni` (`spolubyvanie`), `zasnoubeni`
(`zasnuveny`), `delka_vztahu_mesice` (`cas_mesiace`), `spokojenost` (`spokojnost`),
`alternativy`, `investice` (`investicie`) a `zavazek` (`zavazok`). Kategorie jsou faktory
s českými úrovněmi (kód 1 = `muž`, `slovenská`, `ano`; kód 2 = `žena`, `česká`, `ne`),
skóry škál jsou průměry položek na škále 0–6 (rozsah potvrdil vyučující). Vynechány jsou
škály žárlivosti, `nezavezne_chodenie` a téměř konstantní `manželia`, `rozvedený` a `deti`.
Popisky a formáty SPSS se do RDS neukládají.

**Didaktické úpravy.** Zdrojový soubor `.sav` obsahuje oproti starším místním exportům
(`ZZ.csv`, `ZZ.jasp`) úpravy provedené vyučujícím pro výukové účely. Vyučující rozhodl
upravené hodnoty ponechat a v lekci uvést jen, že některá data jsou upravena pro didaktické
účely, bez uvedení jejich počtu a identity. Protože je repozitář veřejný, neuvádí je ani
tato dokumentace; lze je zjistit porovnáním místních souborů.

Generátor `scripts/prepare_lesson_09_data.R` vyžaduje místní `data/raw/ZZ_ckrvliry.sav`,
který je v `.gitignore`; spouští se z kořene projektu příkazem
`Rscript --vanilla scripts/prepare_lesson_09_data.R` v UTF-8 locale a ověřuje shodu hodnot.
Hotový soubor je v Gitu jako výjimka z ignorované složky `data/clean/` a je uvedený
v `project.resources`.
