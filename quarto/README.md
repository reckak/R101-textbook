# Autorská dokumentace učebnice R101

## Sedmá kapitola: APA, cor_test, Shapirův–Wilkův test, 25. 10. 2026

Na pokyn uživatele (jen kapitola 7):

- **APA:** kurzíva u statistických značek v textu, popiscích grafů, tabulkách,
  vzorových zápisech a nadpisech (*M*, *SD*, *n*, *N*, *t*, *F*, *p*, *d*, *r*,
  *df*, *W*, *z*; „*t*-test“, „*p*-hodnota“, „Cohenovo *d*“). Bez kurzívy zůstávají
  řecká písmena (χ², α, μ, ρ), CI, kód, `fig-alt` a LaTeX. Provedeno skriptem
  omezeným na prózu a `fig-cap` a zkontrolováno ručně; ve vykresleném HTML
  nezůstaly neuzavřené hvězdičky.
- **`cor_test()`** vedle `cor.test()`: tabulka jako první argument, tibble,
  respektuje `group_by()` (cvičení 4); upozornění, že `cor` zaokrouhluje na
  2 desetinná místa. Výsledky shodné s `cor.test()` (ověřuje kontrola).
- **Shapirův–Wilkův test** (`sec-testy-shapiro`) před Levenovým testem;
  připomenutí principů testování hypotéz přesunuto sem jako k prvnímu testu.
  Chlapci *W* = 0,990, *p* = 0,032; dívky *W* = 0,983, *p* < 0,001; ve čtyřech
  skupinách kohorta × pohlaví *p* < 0,001 až 0,069. Výhrada o síle testu podle
  Ghasemi & Zahediasl (2012; tvrzení ověřena v plném textu PMC3693611)
  a Lumley et al. (2002) k platnosti *t*-testu u velkých vzorků (metadata
  ověřena přes Crossref).
- **Q-Q pás i ve skupinách** (`fig-testy-qq-pohlavi`, `"ts"`, `identity = TRUE`):
  mimo pás u chlapců 1 pod / 77 nad, u dívek 121 / 47.
- **Cvičení 6** doplněno o empirickou hustotu; **nové cvičení 7** – Q-Q grafy
  `facet_grid(kohorta ~ pohlavi)`; mimo pás 5, 30, 0 a 6 bodů.
- Tabulky rozhodnutí a častých potíží, shrnutí a zdroje doplněny.

Ověření: render sedmé kapitoly, `check-lesson-07.R` (nově přímka y = x
a opakovatelnost pásu ve skupinách a ve cvičení 7, `cor_test()`, Shapirův–Wilkův
test), `check-r.R` a `check-html.cjs` (sedmá kapitola: 8 řešení,
70 kopírování, 15 grafů, mobil 390/390 px) prošly; nové grafy prohlédnuty.

## Sedmá kapitola: připomínky a redakce, 25. 10. 2026

Commit zahrnuje redakční úpravy uživatele v `lekce_07.qmd` (formátování
argumentů kódu na více řádků, stylistika, původ dat přímo z projektu Cesty
do dospělosti, termín „rovnice modelu“, exces a chvosty u špičatosti aj.).
V nich opraveno: „datouvou“ → „datovou“, „mezi 5 až 12“ → „od 5 do 12“;
termín „rovnice modelu“ doplněn o *formula* a sjednocen u `t_test()`
a `cor.test()` (dříve „formule“).

- **Histogram věku:** bez `na.rm = TRUE`; očekávané varování „Removed 3 rows
  containing non-finite outside the scale range (`stat_bin()`)“ výklad využívá
  jako kontrolu počtu chybějících hodnot. `check-lesson-07.R` má nově seznam
  očekávaných varování (tento blok, právě jedno).
- **Q-Q grafy s `identity = TRUE`** (jako podkladový skript): referenční přímka
  y = x; osa x odpovídá normálnímu rozdělení s průměrem a SD z dat (ověřeno:
  shoda s `qnorm(ppoints(n), mean, sd · √((n − 1)/n))`), tedy stejné křivce jako
  `stat_theodensity()`. Mimo pás `"ts"` 130 bodů pod a 274 nad (dříve 127/270);
  interpretace se nemění. Kontrola ověřuje přímku y = x u obou grafů
  a opakovatelnost pásu.
- **Nezávislost pozorování:** doplněno, že podobnost uvnitř tříd a škol lze
  posoudit a zohlednit smíšeným (víceúrovňovým) modelem se školou a třídou jako
  náhodnými faktory; je to nad rámec lekce a výřez tyto proměnné neobsahuje.
  Stručně i v omezeních závěru.
- Tabulka rozhodnutí doplněna o ponechané varování a přímku y = x.

Ověření: render sedmé kapitoly, `check-r.R` (7 kapitol) a `check-html.cjs`
(sedmá kapitola: 7 řešení, 67 kopírování, 14 grafů, mobil 390/390 px) prošly;
oba nové Q-Q grafy vizuálně zkontrolovány.

## Sedmá kapitola bez ggmosaic, 24. 10. 2026

Po sloučení PR #30 selhalo sestavení v GitHub Actions: `pak` nenašel
`any::ggmosaic` a hlásil konflikt závislostí i u ostatních balíčků. Balíček
ggmosaic byl 10. 11. 2025 odstraněn z CRAN (nebyly opraveny hlášené problémy),
takže by jej přes `install.packages()` nenainstalovali ani studenti. Místní
render prošel jen díky starší instalaci.

Nepovinný mozaikový graf (`sec-testy-mozaika`) nahradil sloupcový graf podílů
s `position = "fill"` (`sec-testy-graf-podilu`, `fig-testy-podily`), známý
z druhé lekce. Výklad upozorňuje, že graf podílů na rozdíl od mozaiky
nezobrazuje velikost kohort. ggmosaic odstraněn z instalace, CI a z instalačního
bloku lekce. `check-lesson-07.R` ověřuje podíly dívek v grafu (57,7 % a 60,0 %);
z podkladového skriptu dál vyřazuje `library(ggmosaic)`. Výsledky testů se nemění.

Ověření: render celé knihy, `check-r.R` (7 kapitol) a `check-html.cjs`
(sedmá kapitola: 7 řešení, 67 kopírování, 14 grafů, mobil 390/390 px) prošly;
nový graf vizuálně zkontrolován. Běh GitHub Actions ověří pull request.

**Doplněk po prvním běhu CI:** `check-lesson-07.R` v CI selhal na varování
„The package "fitdistrplus" is required for `stat_theodensity()`“. Balíček
je u ggh4x jen v `Suggests`, takže se automaticky neinstaluje; render přitom
proběhl a grafy neměly normální křivku. Místně byl balíček nainstalovaný
z dřívějška, proto chybu místní kontrola nezachytila. `fitdistrplus` doplněn
do instalačního bloku lekce (s vysvětlením), `00_instalace_balicku.R`, CI
a do tabulky častých potíží. Místně znovu prošly `check-lesson-07.R`, render
sedmé kapitoly a `check-html.cjs`; selhání bez balíčku nebylo místně
reprodukováno, vychází z logu GitHub Actions.

## Sedmá kapitola: základní statistické testy, 24. 10. 2026

Podkladem je `scripts/week_07.R`, zachovaný beze změny (SHA-256
`d4e9e790057fbad9b5ba5f83aeb48a7535f5c7a234332294898339cec403252b`).
Kapitola `lekce_07.qmd` navazuje na boxplot a panely (lekce 2), `.by` (3),
faktory (4), SPSS a popisky (5) a skóry, alfa a Q-Q grafy (6). Obsahuje šest
průběžných cvičení a samostatně spustitelnou závěrečnou úlohu; všech 7 řešení
je sbalených. Název určil uživatel.

### Rozhodnutí uživatele

- **Data:** zveřejněn jen výukový výřez `data/raw/monitoring_teaching.sav`
  (13 sloupců, viz `data/README.md`); původní `long2.sav` (SHA-256
  `ae5cc618ba3e7fc1b4718301094ef9c37995cb9bcb618401c7de3dd522dea6fe`) je
  v `.gitignore`. Generátor `scripts/prepare_lesson_07_data.R`.
- **Původ:** uživatel uvedl, že data jsou „myslím“ z projektu Cesty do dospělosti.
  Stránka FSS MU (GAČR GAP407/12/0854, 2012–2016) sběr z roku 1999 ani kohorty
  nepopisuje; kapitola proto vazbu uvádí jako údaj vyučujícího. **Neověřeno.**
- **Kohorta 66:** opravena na 6 (věk 12,2; mladší kohorta 11,8–13,9, starší
  15,8–19,1). Komentář podkladu žádal `NA`, kód podkladu hodnotu přeřazoval.
- **Welchův t-test** jako výchozí (Delacre et al., 2017; Zimmerman, 2004);
  Levene jen popisně, Studentův test pro srovnání.
- **χ² test bez Yatesovy korekce** (`correct = FALSE`; Campbell, 2007).
- Výklad každého testu: účel, princip, předpoklady, funkce, výstup; tabulka
  rozhodnutí; závěr s odpovědí na otázku, velikostí rozdílu a omezeními.

### Opravy podkladu a jejich dopad

- Cesta `data/long2.sav` neexistuje; kapitola čte `data/raw/monitoring_teaching.sav`.
- `if_else(kohorta == 66, "mladší kohorta", kohorta)` po `as_factor()` tiše
  převádělo kohortu na text a ponechávalo prázdnou úroveň „66“. Oprava kódu
  probíhá před převodem; převod přes `factor(levels, labels)` s českými názvy
  (`chlapci`/`dívky`, `mladší`/`starší`). Výsledky se nemění.
- `stat_theodensity(distribution = "norm")` – argument se ignoroval (ggh4x
  používá `distri`); výchozí rozdělení je normální, takže grafy se nemění.
- `geom_point(stat = "summary", fun.y = "mean")` – `fun.y` se ignoroval a
  použil se `mean_se()` se zprávou; nahrazeno `stat_summary(fun = mean,
  geom = "point")`. Poloha bodu (průměr) se nemění.
- Chybějící `+` před `theme_mosaic()`: motiv se nepoužil a vypisoval se
  objekt motivu. Opraveno.
- Boxplot kohort používal `drop_na(pohlavi)`; kapitola vyřazuje chybějící skór
  a u analýz pohlaví i pohlaví (`analyza_pohlavi`, 755 osob).
- Úkol 7 míchal `kohorta_moje` (souhrny), `kohorta` (grafy, testy). Kapitola
  používá zaznamenanou `kohorta` všude; `kohorta_moje` (`case_when()`) slouží
  jen k nácviku a srovnání (16 nezařazených: 3 bez věku, 13 starších 17 let).
- χ² test: podklad testoval `kohorta_moje` na vektorech s NA (výstup n = 768,
  χ² = 0,235, p = 0,63, s Yatesovou korekcí). Kapitola: `kohorta`, 765 úplných
  případů, bez korekce χ²(1) = 0,40, p = 0,53 (s korekcí 0,31, p = 0,58).
  Závěr se nemění.
- Studentův test (t(753) = −3,30, p = 0,001) nahrazen Welchovým
  (t(681,95) = −3,31, p = 0,00098); intervaly se liší v tisícinách.
- `cohens_d(ci = TRUE)` počítá bootstrap; podklad bez seedu a s `ci.type =
  "norm"`. Kapitola: výchozí percentilový bootstrap a `set.seed(123)`
  (d = −0,24 [−0,38; −0,09]); kontrola ověřuje opakovatelnost.
- `psych::corr.test()` nahrazen `cor.test()` (jedna dvojice, přímý výstup
  s CI); výsledek r = −0,28 [−0,35; −0,22] shodný. Doplněna korelace uvnitř
  kohort (−0,16 a 0,01) jako argument, proč celková korelace hlavně opakuje
  rozdíl kohort.
- Q-Q grafy: podklad `identity = TRUE`; kapitola nastavení šesté lekce.
  **Zjištění:** skór má jen 36 hodnot a při n = 758 leží asi polovina bodů mimo
  pás `"ts"` (127 pod, 270 nad), u pásu `"pointwise"` 274; po rozprostření
  hodnot uvnitř jejich intervalu (jitter ±1/18, jen autorská kontrola) zůstává
  mimo pás jen 19 bodů u stropu 4. Kapitola proto pás u celkového grafu ukazuje
  a vysvětluje, proč jej nelze číst doslova; skupinové Q-Q grafy jsou bez pásu.
- Histogramy mají šířku 1/9 s `center = 1` místo výchozích 30 intervalů.
- Komentáře podkladu o JASP a pokyny „Do textu“ nejsou v lekci; jejich obsah
  pokrývají cvičení, vzorový zápis výsledku a závěr analýzy.
- Přejmenování: `df` → `adolescenti` (`df` je i funkce stats),
  `na_monit` → `n_miss_monit` jako v lekci 6. Kontrola ověřuje shodu skóru
  `monit` i pořadí osob s podkladem (ř. 1–144, opravená cesta).

### Ověření

Nový `check-lesson-07.R` (zapojený do `check-r.R`) spouští všechny bloky a
řešení v čisté relaci bez neočekávaných varování, ověřuje číselné interpretace,
shodu skóru s podkladem, Welch/Student/`t.test()`, opakovatelnost bootstrapu,
χ² bez korekce, `case_when()`, testy uvnitř kohort, samostatné závěrečné řešení
a při místním `long2.sav` shodu výřezu s originálem. `check-html.cjs` rozšířen
na sedmou kapitolu (stažení s bajtovou shodou, obsah publikovaného `data/raw`,
klávesnicově dostupné tabulky).

Render celé knihy (Quarto 1.9.38, R 4.5.1, UTF-8 locale), `check-r.R` pro všech
sedm kapitol a `check-html.cjs` prošly. V sedmé kapitole 7 sbalených
a rozbalitelných řešení, kopírování 67 bloků, 14 grafů, 419 místních cílů odkazů,
mobil 390/390 px, bez chyb JavaScriptu. Všech 14 grafů bylo prohlédnuto
a interpretace upraveny podle nich. Zdroje ověřeny přes scite (Delacre et al.
2017 má opravu doplňkových simulací, 10.5334/irsp.661; hlavní závěr nemění).
R hlásí obvyklá upozornění na balíčky sestavené pod R 4.5.3. Nové balíčky
`rstatix`, `ggh4x`, `ggmosaic` doplněny do instalace a CI. Test pro IS MUNI
k lekci zatím nevznikl. Veřejné nasazení lokální kontrola nepotvrzuje. Kontrola
rozdílů prošla u všech autorských souborů; původní `week_07.R` obsahuje vlastní
koncové mezery, které se kvůli zachování podkladu neupravují.

## Mobilní tabulka častých potíží, 18. 10. 2026

GitHub Actions odhalily v šesté lekci přesah tabulky „Časté potíže“
na 416 px při šířce obrazovky 390 px. Předchozí místní kontrola
na Windows tento přesah nezachytila. Tabulka nyní používá vlastní
vodorovně posuvný obal `table-responsive`, pojmenovaný pro čtečky
obrazovky a dostupný klávesnicí. Obsah tabulky a výpočty se nemění.

Kontrola HTML navíc záměrně zvětšuje písmo kódu v této tabulce:
ověřuje vznik místního přesahu, zachování šířky stránky a posun
šipkou na klávesnici. Po návratu původního písma ukládá mobilní
snímek tabulky pro vizuální kontrolu.

Ověření: render celé knihy (Quarto 1.9.38), souhrnná kontrola R
v UTF-8 relaci a úplná kontrola HTML prošly. Všech šest kapitol má
na mobilu šířku 390/390 px, všech 61 řešení a 514 kopírování funguje,
bez chyb JavaScriptu. Prošel i nový test širokého kódu a posouvání
klávesnicí; mobilní snímek tabulky byl vizuálně zkontrolován.
Prošel `git diff --check`. Místní ověření proběhlo na Windows;
linuxový běh GitHub Actions je samostatná kontrola pull requestu.

## Šestá kapitola: připomínky k názvu a grafům, 18. 10. 2026

Název je „Práce se skóry dotazníkových škál“. Všechny blokové ukázky
lekce nyní pokračují po pipe na novém řádku; všechna nastavení
`base_size` v lekci jsou 13. Porovnání přímky a loess používá
červenou a modrou i v závěrečném řešení, včetně barev pásů.

Histogram emoční otevřenosti vzniká ve třech krocích: samotný histogram
s hustotou na svislé ose, červená plná normální hustota a modrá tečkovaná
empirická hustota. Barvy se mapují v `aes()`, takže vzniká legenda;
`key_glyph = "path"` zobrazuje empirickou hustotu v legendě jako čáru.
Výklad vysvětluje odhad hustoty, vyhlazení a pozorovaný plošší vrchol
empirické křivky. Oporou je oficiální dokumentace
[geom_density](https://ggplot2.tidyverse.org/reference/geom_density.html).
Data, skórování a statistické postupy se nemění.

Ověření: celá lekce včetně všech řešení prošla `check-lesson-06.R`
v čisté relaci R s UTF-8 locale; zachována shoda skórů s podkladem.
Prošel render celé knihy a po závěrečné úpravě legendy nový render
šesté kapitoly. Kontroly R a HTML byly přizpůsobeny novým barvám
a názvu kapitoly. Úplná kontrola HTML prošla: v šesté kapitole 7 řešení,
66 kopírovaných bloků a 20 grafů; všech šest kapitol bez chyb JavaScriptu
a bez přetékání při šířce 390 px. Vizuálně zkontrolováno všech 20 grafů
šesté lekce, nové legendy také samostatně v plném rozlišení.
Prošel rovněž `git diff --check`.

## Oprava lokálního renderu českých popisků, 18. 10. 2026

Po předchozím renderu uživatel upozornil na náhradní zápisy `<U+00F3>`
a podobné v grafech. Diagnostika R 4.5.1 ve stejném prostředí potvrdila,
že zděděné `LANG`, `LC_ALL` a `LC_CTYPE` s hodnotou `C.UTF-8` Windows
nepřijalo: `Sys.getlocale()` vracelo `C` a UTF-8 v `l10n_info()` bylo
`FALSE`. Po nastavení `English_United States.utf8` je UTF-8 `TRUE`.
Zdrojové české popisky zůstaly správné; poškození vzniklo při lokální
tvorbě PNG, nikoli zalamováním URL v CSS. Předchozí kontrola HTML
ověřovala načtení obrázků, nikoli správnost textu uvnitř nich, a tuto
chybu nezachytila. Postup pro Windows je doplněn v `docs/provoz.md`.

Kontrola `check-r.R` nyní nevyhovující locale odmítá s pokynem k opravě
a novému renderu. Ověřeno: původní prostředí skončí touto chybou;
UTF-8 prostředí projde celou kontrolou R. Celá kniha byla znovu vykreslena
a prošla kontrolou HTML všech šesti kapitol (61 řešení, 512 kopírování,
390/390 px, bez chyb JavaScriptu). Vizuálně byly zkontrolovány aktuální
přehledy všech 50 vykreslených grafů kapitol 2, 3, 4 a 6, včetně řešení;
popisky mají správnou diakritiku. Q-Q graf s oběma pásy z uživatelova
snímku byl zkontrolován také samostatně v plném rozlišení.

## Mobilní přetékání URL, 18. 10. 2026

Kontrolu GitHub Actions zastavoval mobilní layout. V seznamu literatury
šesté kapitoly se dlouhý DOI odkaz nezalamoval; při šířce viewportu 390 px
a fontu Arial dosahovala stránka 413 px. Společný styl nyní umožňuje
zalamování doslovných URL (`main a.uri`, `overflow-wrap: anywhere`).
Text odkazů, jejich cíle, výukový kód ani analytické výsledky se nemění.

Kontrola HTML navíc testuje URL šesté kapitoly s náhradním fontem Arial.
Při přetékání vypisuje kapitolu, naměřené šířky a prvky přesahující viewport;
vynechává obsah uzavřený v lokálně posuvných či oříznutých kontejnerech.
Původní kontrola šířky celé stránky zůstává zachována.

Ověření: úspěšný render celé knihy v Quarto 1.9.38 a úplná kontrola HTML
všech šesti kapitol (61 řešení, 513 kopírovaných bloků, obrázky, lokální
odkazy a stahování, bez chyb JavaScriptu). Všechny kapitoly mají při
viewportu 390 px šířku stránky 390 px. Regresní kontrola s Arialem prošla;
dočasné vypnutí opravy na novém renderu reprodukovalo 413 px. Výsledný
mobilní seznam literatury byl zkontrolován také vizuálně. `git diff --check`
prošel. Samostatná kontrola výpočtů R nebyla opakována; změna se týká pouze
CSS a kontroly HTML, celý výukový kód se vykonal při renderu.

## Šestá kapitola: revize a zkrácení, 18. 10. 2026

Na pokyn uživatele (připomínky k `lekce_06.qmd`) byla kapitola zkrácena
a upravena. Záznam níže z 17. 10. 2026 platí, pokud jej tato revize nemění.

- **Vyřazeno:** oddíly Korelace (Pearson, Spearman, korelační matice,
  cvičení 6) a Jednoduchá lineární regrese (`lm`, rezidua, `predict`,
  intervaly, cvičení 8). Odpovídající části `week_06.R` zůstávají
  nezpracované pro případnou další lekci. Úvod oddílu o rozdělení skórů
  nyní navazuje na bodový graf; zmínka o reziduích je obecná. Závěrečná
  úloha (věk) je grafická: histogram věku, bodový graf s přímkou a loess,
  bez testů. Cvičení přečíslována (6 = rozdělení), lekce má 7 řešení.
- **Popisky hodnot:** `remove_val_labels()` odstraněno (i ze závěrečné úlohy).
  Ověřeno: `5 - x` u `haven_labelled` vrací `numeric` bez popisků hodnot
  i `var_label`; neobrácené položky zůstávají `haven_labelled`; `psych::alpha()`
  a `c_across()` fungují při načteném labelled. Nový oddíl vysvětluje ztrátu
  atributů a tři způsoby, jak popisky zachovat. Skóry jsou identické.
- **Doplněno:** načtení z URL (`read_rds()` přímo i `download.file()` do
  `data/clean`) s pevným commitem `9a078dd07469f7188224031f35b93ecf3c84dccf`,
  který je díky běžnému sloučení PR #21 součástí historie `main`.
  `group_by(id)` jako ekvivalent `rowwise()` (ověřena jedinečnost
  `id` a `identical()` skórů), `drop_na()` (166 vs. 58 řádků bez sloupců),
  srovnání `limits` (sklon −0,06, n = 59, dvě varování) a `coord_cartesian()`
  (sklon 0,20), legenda trendových čar podle `sec-legenda-modelu`.
- **qqplotr 0.0.7:** Q-Q grafy s bodovým a simultánním tail-sensitive pásem
  (Aldor-Noiman et al., 2013, DOI ověřeno; s opravou 10.1080/00031305.2014.970871).
  Pás `"ts"` je simulovaný, proto `set.seed(123)`; kontrola ověřuje shodu
  pásu při opakovaném sestavení. Postoj k pomoci: 31 + 2 body mimo bodový
  pás, 11 nejnižších pod pásem `"ts"`, 4 body ze schodu u skóru 3 nad ním;
  pásy `"ks"` a `"ell"` nejnižší skóry pokrývají (text na závislost na typu
  pásu upozorňuje). Shapiro–Wilk pro `tot_help` p ≈ 1,3 × 10⁻⁵ (jen
  autorská kontrola, v textu neuvedeno); emoční otevřenost celá v pásu `"ts"`.
  Balíček doplněn do instalace, CI a varování o maskování `stat_qq_line()`.
- **Jazyk:** „Cronbachovo alfa“ jako nesklonné neutrum v kapitole, `index.qmd`
  a README; „psychometrika“; osy jako `x` a `y` v textu (ne v `fig-alt`);
  loess popsán jako podmíněný průměr proměnné na ose `y`.
- **Ověření:** `check-lesson-06.R` přepsán (popisky, `group_by`, `drop_na`,
  sklony obou přiblížení, legenda, počty bodů mimo pásy, `ks`/`ell`,
  samostatné závěrečné řešení), nový síťový `check-lesson-06-downloads.R`
  (bajtová shoda obou RDS). Render celé knihy (Quarto 1.9.38, R 4.5.1),
  `check-r.R` a `check-html.cjs` (cíl osnovy `sec-skory-rozdeleni`, snímek
  `html-qqbands`) prošly; nové grafy prohlédnuty a interpretace upraveny podle
  nich (popisek osy u grafu pásů ořezán legendou → legenda dole).

## Šestá kapitola: skóry škál, korelace a regrese, 17. 10. 2026

Podkladem je `scripts/week_06.R`, zachovaný beze změny (SHA-256
`ce8e104469995a6de90d4916c7a4b82a7d52a47b82cc97a6acf4ea6c0ad1dd16`).
Kapitola `lekce_06.qmd` navazuje na grafy (lekce 2), dplyr (3), vektory
a recyklaci (4) a na data o vyhledávání pomoci, `across()` a popisky (5).
Obsahuje osm průběžných cvičení a samostatně spustitelnou závěrečnou úlohu;
všechna řešení jsou sbalená.

### Rozsah a vstupy

- **Vynechaná část podkladu:** na pokyn uživatele lekce končí jednoduchou
  regresí. Část od ř. 705 (`Comparing men and women`: boxplot/violin
  s `mean_cl_normal`, t-testy včetně rstatix, Cohenovo d, Levene,
  Shapiro–Wilk) zůstává nezpracovaná pro případnou další lekci. Proto nejsou
  potřeba balíčky rstatix ani Hmisc; nově je v instalaci a CI pouze `psych`.
- **Data:** uživatel dodal `data/clean/help_seeking_data.rds`
  (SHA-256 `9d37eb06777e119be5472c265ba47ca22e38e34e9ea193bfdfe1f9fd06eb1c0a`)
  a `data/clean/help_seeking_codebook.rds`
  (`7111a09afc3a937518ef59203fcd8887d586f72ba1b87bf0dbe056cd60c00991`).
  Podklad je čte z `data/…`; kapitola používá skutečné umístění `data/clean/…`.
  Shoda všech 33 sdílených sloupců s `help_seeking.xlsx` po převodu `-99`
  byla ověřena. Kategorie jsou anglické, odlišné od české přípravy v lekci 5;
  kapitola to studentům výslovně vysvětluje. Oba soubory jsou výjimkou
  v `.gitignore`, publikované přes `project.resources` a ke stažení z kapitoly.

### Úpravy podkladu a jejich důvody

- **Popisky hodnot:** aritmetika i `psych::alpha()` s `haven_labelled`
  fungují jen při načteném jmenném prostoru haven (zde přes labelled);
  bez něj skončí chybou `<double> - <haven_labelled> is not permitted`,
  resp. selháním převodu v psych. Kapitola proto po načtení výslovně volá
  `remove_val_labels()`. Hodnoty se nemění; kontrola dokládá shodu skórů
  s podkladem.
- **Neúplný kód:** druhý histogram v podkladu (ř. 540) nemá `hs_rec %>%`
  a skončil by chybou; opraveno. Duplicitní blok ř. 151–162 a druhý Q-Q graf
  téže proměnné sloučeny. Pipe `%>%` nahrazen `|>` jako v lekcích 3–5;
  `check-lesson-06.R` spouští skórování z podkladu (ř. 1–307) a ověřuje
  identické `tot_help`, `tot_emo` i pořadí osob.
- **Demonstrace chyb:** `mean(help_01:help_10)` je označená záměrná chyba
  (`NA/NaN argument`). Text ukazuje i tiché chyby bez `na.rm` a bez
  `rowwise()`; společný průměr bez `rowwise()` je 3,00 pro všechny.
- **Alfa:** komentář „alfa kolem 0,82 je dobrá“ nahrazen výkladem výstupu
  (`raw_alpha`, interval, `alpha if dropped`, `r.drop`) a omezení
  s ověřenými zdroji (Sijtsma, 2009; McNeish, 2018) a dokumentací psych
  (výchozí `check.keys = FALSE`, párové korelace). Slabá položka `help_04`
  se nevyřazuje; pevné prahy nejsou vydávány za univerzální.
- **Jitter:** `geom_jitter()` nemá v ggplot2 4.0 argument `seed`, takže by
  grafy nebyly reprodukovatelné. Používá se `position_jitter(..., seed = 123)`
  uložené v objektu `posun`; posun 0,05 jako v podkladu (variantu 0,1/0,3
  pro ukázku motivu nahrazuje stejný posun). Od prvního grafu s vysvětleným
  varováním „Removed 6 rows“ se pracuje s `hs_dvojice` (166 úplných dvojic).
- **Trendové čáry:** `geom_smooth()` má výslovně `method` i `formula`, aby
  nevznikaly zprávy o výchozí metodě; 99% pás z podkladu zachován.
- **Spearman:** `exact = FALSE` místo nevysvětleného varování o shodách.
  Formule s `conf.level = 0.99` sloučena s ukázkou zápisu přes `data`.
  Korelační matice používá plné `"pairwise.complete.obs"` místo částečné
  shody `"pairwise"`; doplněn rozsah n 156–166 a srovnání se 123 úplnými.
- **Rozdělení:** z-skóry počítány výslovně v `mutate()` místo `scale()`
  v `aes()` (matice). Doplněno, že normalita samotných proměnných není
  podmínkou korelace/regrese; přidán Q-Q graf reziduí, který využívá
  `na.exclude` (rezidua délky 172 lze připojit k tabulce).
- **Predikce:** mřížka omezena na pozorovaný rozsah 1,24–5,65 místo 1–6
  (extrapolace). Objekt `pi` přejmenován na `pi_tab`, protože zakrýval
  konstantu π. `left_join(ci, pi, by = "fit")` (párování podle desetinného
  odhadu) nahrazeno `bind_cols()`; kontrola dokládá shodu obou výsledků
  na této mřížce. Výklad upozorňuje, že predikční pás přesahuje hranici 4.
- **Závěrečná úloha:** nová, nevychází z podkladu: věk a postoj k pomoci
  (165 osob, *r* = 0,01 [−0,14; 0,16]). Interpretace odlišuje nezjištěný
  vztah od důkazu nulového vztahu.
- **Popisky a jazyk:** české popisky os; škála emoční otevřenosti pojmenována
  jako v lekci 5. Pracovní překlad položek v textu není validovaným překladem.

### Ověření

Nový `check-lesson-06.R` (zapojený do `check-r.R`) spouští všechny bloky
a řešení v čisté relaci, vyžaduje jedinou označenou chybu a dvě očekávaná
varování (psych před obrácením, „Removed 6 rows“ u prvního grafu; grafy
se při kontrole skutečně vykreslují), ověřuje číselné interpretace, shodu
`bind_cols()` s `left_join()`, shodu skórů s podkladem a samostatně spouští
závěrečné řešení. `check-html.cjs` rozšířen na šestou kapitolu včetně dvou
stažení s bajtovou shodou a přesného obsahu publikovaných `data/raw`
a `data/clean`.

Prošel render celé knihy (Quarto 1.9.38, R 4.5.1), `check-r.R` pro všech
šest kapitol a po závěrečných textových úpravách znovu render šesté kapitoly
a `check-lesson-06.R`. Kontrola HTML prošla pro všech šest kapitol: v šesté
9 sbalených a rozbalitelných řešení, skutečné kopírování 70 úseků kódu,
15 grafů, 496 místních cílů odkazů, šířka 390 px bez přetékání, bez chyb
JavaScriptu. První běh odhalil přetékání dvou vzorců MathJax a dvou dlouhých
inline kódů na mobilu; vzorce byly zkráceny a kód rozdělen. Všech 15 grafů
bylo prohlédnuto a interpretace upraveny podle skutečného vzhledu (plochý
začátek křivky loess, konce rozdělení, predikční pás nad 4). Externí odkazy
vrátily HTTP 200; kotva R4DS opravena na `#sec-across`. Místní Playwright
neměl svou verzi prohlížeče, kontrola proto běžela s `CHROME_PATH` na
nainstalovaný Chrome. R hlásí obvyklá upozornění na balíčky sestavené
pod R 4.5.3. Veřejné nasazení tato lokální kontrola nepotvrzuje.
Kontrola rozdílů je čistá u všech autorských souborů; původní `week_06.R`
obsahuje vlastní koncové mezery, které se kvůli zachování podkladu neupravují.

## Chybějící kódy ve výpočtech a datum z Excelu, 10. 10. 2026

- Doplněno skutečně spuštěné porovnání `mean(..., na.rm = TRUE)` pro
  `haven_labelled_spss` s hodnotami 1, 2, 9, NA a pro vektor po
  `user_na_to_na()`. Výsledky 4 a 1,5 dokládají zahrnutí kódu 9 před
  převodem; `is.na()` přitom respektuje jeho definici jako chybějícího.
  Jde o demonstraci výpočtu, nikoli věcnou interpretaci průměru Ne/Ano.
- Rozšířen výklad sériového čísla dne v Excelu a rozdílu mezi číselnou
  reprezentací a formátem buňky. Ukázka nyní vypisuje původní čísla,
  převedená data i třídu `Date`. Vysvětluje, proč se mohou načíst čísla,
  potřebu ověřit jejich význam, systém 1900/1904 i ztrátu času při převodu.
- Začleněna uživatelská redakce navazujících oddílů o faktorech, popiscích,
  hlavičkách, ukládání a závěrečné úloze. Opraveny drobné gramatické chyby,
  mezery kolem inline kódu a koncové mezery. Výrok o reprodukovatelnosti
  uloženého prostředí upřesněn: uložené objekty samy nedokládají postup
  přípravy a nenahrazují skript. Původní `week_05.R` zůstává beze změny.

Ověření této redakce: prošel render upravené kapitoly a její kontrola
v čistém R včetně všech řešení a nových kontrol průměrů a kalendářních dat.
Kontrola HTML všech pěti kapitol skončila bez chyb; v páté kapitole ověřila
9 sbalených řešení, kopírování všech 101 bloků kódu, 391 místních odkazů
a mobilní šířku 390 px bez přetékání. Nové výstupy a jejich okolní výklad
byly zkontrolovány také vizuálně. Při spuštění se objevila pouze očekávaná
varování o sestavení některých balíčků v novější verzi R a záměrná ukázka
varování při parsování. Celá kniha se při této dílčí redakci znovu nerenderovala.

## Redakce páté kapitoly podle připomínek, 10. 10. 2026

- Zachována a začleněna místní uživatelská redakce lekce. Opraveny drobné
  překlepy v zadáních a výkladu (cesta, údaj, věk a jídlo, výsledný sloupec,
  Asie) a neúplná věta o opětovném importu. Původní `week_05.R` se nemění.
- Tabulka ke stažení má jeden odkaz pro každý vstup; GitHub URL zůstávají
  v online příkladech. Nový pátý vstup `ceske_odpovedi.csv` je čistě fiktivní
  výuková ukázka v Windows-1250, vytvořená samostatným reprodukovatelným
  skriptem. Zařazen výslovně mezi publikované zdroje a kontrolované downloady.
- Online ukázky používají `stringr::str_c()` místo `paste0()`. Vysvětlen
  binární zápis `wb`, zachování bajtů, úprava konců řádků ve Windows
  a možné poškození binárního souboru při textovém zápisu. Upřesněn dosah
  `showWarnings` u `dir.create()`. Doplněn význam zkratek CSV a TSV.
- Standardizaci názvů předchází ruční `rename()` bez přiřazení, následované
  kontrolou nezměněného objektu; pak `clean_names()` a kombinace obou funkcí.
  Rozveden význam každého argumentu `if_else()`, volba pro každou pozici,
  zachování původních hodnot a chování při `NA`.
- Nový oddíl ukazuje skutečně nesprávný výchozí import češtiny, odhad
  `guess_encoding()` a opětovný import s doloženým kódováním. Odhad není
  vydáván za jistotu a jeho confidence není interpretována jako přesnost.
- Rozšířen rozdíl `as.factor()` a funkcí pro metadata haven; ponechání
  číselných kódů ordinálních položek je vysvětleno ve vztahu k pravidlům
  skórování, nikoli jako automatické oprávnění k průměrování.
- Doplněn záměr seminárního projektu a význam předpon `help_` a `emo_`;
  sjednoceno označení emoční otevřenosti podle upřesnění vyučujícího.
- `setdiff()` je předvedeno před opravou, po změně pouze dat a po opravě
  slovníku. Původní názvy se shodují včetně překlepu, takže první kontrola
  správně nic nehlásí. Průběžná kontrola dokládá oba rozdíly po přejmenování.

Ověření této redakce: prošel render celé knihy, projektová kontrola R
v čistých relacích i síťové ukázky se `str_c()`. Rozšířená kontrola potvrzuje
shodu ruční a automatické standardizace názvů, zachování objektu bez
přiřazení, oba rozdíly po přejmenování jen dat a správný i chybný import
fiktivního souboru. Odhad jeho kódování v ověřeném prostředí uvedl
Windows-1250 s confidence 0,53; výklad na této číselné hodnotě nezávisí.
HTML kontrola prošla pro všech pět kapitol: u páté 9 sbalených řešení,
97 skutečně zkopírovaných úseků kódu, 383 místních cílů odkazů a všech
5 stažení včetně bajtové shody s originály. Bez chyb JavaScriptu a bez
přetékání stránky při 390 px. Nové výstupy a mobilní tabulka byly
vizuálně prohlédnuty. Kontrola rozdílů prošla. Upozornění na balíčky
sestavené pod novějším R a záměrné varování parseru zůstávají stejné
jako v předchozím ověření. Nasazení nové redakce na veřejný web není
součástí lokálních kontrol.

## Pátá kapitola: import a základní příprava dat, 10. 10. 2026

Podkladem je `scripts/week_05.R`, zachovaný beze změny (SHA-256
`1643c71fb5f9f113acaf9ec3480233140afb8f7ef1b7957c8f5317a6e72e7ce1`).
Lekce navazuje na projekty, dplyr, typy, faktory a pojmenované seznamy.
Zahrnuje osm průběžných cvičení a samostatně spustitelnou závěrečnou úlohu.
Všechna řešení jsou ve výchozím stavu sbalená. Skórování škál a reliabilita
nejsou předmětem této lekce.

### Úpravy podkladu a jejich důvody

- **Vstupy a dostupnost:** místo IS MUNI používá kapitola čtyři místní vstupy
  v `data/raw`, tlačítka ke stažení z výsledného webu a přímé GitHub URL
  s pevným datovým commitem. Online varianty se při renderu nespouštějí;
  hlavní postup funguje bez internetu. `_quarto.yml` zveřejňuje výslovný
  seznam čtyř souborů, nikoli celou složku s dalšími místními daty.
- **Původ dat:** vyučující doložil seminární projekt pro `help_seeking.xlsx`
  a článek s DOI `10.1080/29974100.2025.2561692` pro data čtyř zemí. Obojí
  je uvedeno v kapitole a `data/README.md`. U `international.sav` nebyl
  dodán primární zdroj ani rok ukazatelů; využití je omezeno na nácvik
  metadat, nikoli současné faktografické závěry.
  Vyučující výslovně potvrdil veřejné sdílení `help_seeking.xlsx` se
  172 záznamy; pro data čtyř zemí schválil pouze uvedený výukový výřez.
- **Výřez čtyř zemí:** na výslovný pokyn vyučujícího vznikl nový soubor
  `four_countries_teaching.xlsx` pouze s 20 uzavřenými položkami a zemí.
  Neobsahuje identifikátory, IP, geolokaci, časové údaje, demografii ani
  otevřené odpovědi. Zachovává 1 084 řádků a všechny hodnoty i tři řádky
  metadat vybraných sloupců; není prezentován jako kompletní vzorek článku.
  Původní exporty zůstaly lokálně beze změny a jsou ignorované Gitem.
  Autorský generátor vytváří nový sešit z povoleného seznamu sloupců;
  nepublikuje skryté listy, vazby ani vlastnosti původního sešitu.
- **Textový import:** soubor `students.txt` se čte jako CSV podle obsahu,
  zachovává se ukázka `five`, explicitní kódy chybění a sjednocení názvů.
  Přidána ukázka zachování počátečních nul ID, desetinné čárky a rozdílu
  mezi plánovaným `NA` a `NA` z neúspěšného čtení. Vložený CSV text se
  předává přes `I()`. Jediné záměrné varování je jasně označené.
- **Kódování a cesty:** vysvětleny pracovní adresář, relativní cesty, raw URL,
  `download.file(mode = "wb")`, oddělovač, desetinný znak a znakové kódování.
  Hlavní vstupy se při renderu nepřepisují. Odvozené soubory patří do
  ignorované `data/clean/`, nikoli do původní místní `data/cleaned/`.
- **Nesoulad názvu finanční situace:** dodaný sešit i codebook používají
  `finantial_situation`, zatímco skript očekává `financial_situation`.
  Kapitola oba názvy sjednocuje v paměti a kontroluje soulad pomocí
  `setdiff()` v obou směrech. Původní XLSX se nemění. Typografické chyby
  v původních popiscích odpovědí (`Ohter`, `Accptable`) nenapodobuje;
  používá české pracovní popisky odpovídajících kategorií.
- **Chybění a faktory:** `-99` se při importu převádí na `NA`, žádný řádek
  se plošně nevyřazuje. Převody na faktor předchází četnosti. `across()`
  a význam `~` a `.x` jsou vysvětleny na společném kódování tří sloupců.
  Pořadí úrovní není ztotožněno s ekvidistancí ani automaticky s `ordered`.
- **Metadata:** rozšířen výklad `var_label()`, `set_variable_labels()`,
  `val_labels()`, `haven::labelled()`, `look_for()` a `generate_dictionary()`.
  Popisky proměnných se přebírají z codebooku bez duplicitního ručního
  přepisu; výchozí přísná kontrola názvů zůstává zapnutá. U `lifeexpt`
  je výslovně interpretován skutečný popisek školní délky vzdělávání.
- **Převod před analýzou:** `to_factor()` předvádí kategoriální reprezentaci,
  `remove_val_labels()` číselnou. Vektory s popisky nejsou vydávány za
  univerzální vstup modelů ani za důkaz intervalové úrovně měření.
  Je vysvětlen rozdíl od `as.factor()` a chování `unlabelled()`.
  Nepovinný příklad používá `na_values()` a `user_na_to_na()` a rozlišuje
  slovní popisek neodpovědi od skutečné definice chybění.
- **Neuspořádaný Excel:** zachován samostatný import názvů, popisků a dat,
  výslovné `col_names` chrání první odpověď. Kontrolní chybný `skip = 2`
  demonstruje 1 085 řádků a textový typ. Datum z Excelu je ukázáno na
  fiktivním vektoru, protože časové sloupce nejsou ve veřejném výřezu.
  Doplněna ztráta času při převodu na `Date` a závislost na datovém systému.
  `remove_empty()` a `remove_constant()` jsou vysvětleny jako volitelné
  nástroje; sloupce se neodstraňují bez posouzení jejich významu.
- **Ukládání:** RDS zachovává typy a metadata, CSV ne. Doplněn původní
  codebook a výslovné upozornění na odlišné kódování připraveného CSV
  (české kategorie faktorů, kódy číselných položek, chybění `NA`). U
  `load()` je vysvětlen návrat jmen a možné přepsání existujících objektů.
  Původní soubor `my_data.Rdata` se nenačítá ani nepublikuje.
- **Rozsah a styl:** nepoužitý `psych` a opakované načítání balíčků nejsou
  v lekci. Pipe `|>` odpovídá dosavadním kapitolám; analytický záměr
  přípravy zůstává stejný. Obráceně skórované položky se nyní neskórují,
  pouze se čte informace `reversed`. Česká odpovědní škála není vydávána
  za validovaný překlad nástroje.

### Ověření

`check-lesson-05.R` spouští každý prováděný blok a všechna řešení v čisté
relaci. Kontroluje konkrétní interpretace, záměrné varování parseru,
zachování čísel při doplnění popisků, shodu `across()` s jednotlivými
převody, počty chybění a metadata při uložení a načtení. Závěrečné řešení
spouští navíc v další čisté relaci. Je součástí `check-r.R`.
Kontrola výřezu porovnává přesný seznam povolených sloupců a při dostupném
místním originálu všechny hodnoty a popisky ponechaných sloupců.

Síťová kontrola `check-lesson-05-downloads.R` je oddělená od offline CI:
stahuje všechny čtyři pevné GitHub URL, porovnává soubory bajtově a spouští
obě nepovinné online ukázky z kapitoly. Kontrola HTML je rozšířena na pátou
lekci a skutečné klikání na odkazy ke stažení. Zároveň vyžaduje, aby
publikovaná datová složka obsahovala právě čtyři schválené soubory.

Prošel render celé knihy i projektová kontrola R včetně všech řešení.
Po závěrečné úpravě mobilní tabulky byla pátá lekce znovu vykreslena.
Kontrola HTML prošla pro všech pět kapitol; v páté ověřila devět zpočátku
skrytých a rozbalitelných řešení, skutečné kopírování všech 87 vykreslených
úseků kódu, 351 místních cílů odkazů a kliknutí na čtyři soubory ke stažení.
Všechny kapitoly mají při šířce 390 px šířku stránky 390 px, bez chyb
JavaScriptu. Široká tabulka ke stažení se na mobilu posouvá uvnitř svého
kontejneru. Nové tabulky, výstupy, řešení a mobilní zobrazení byly vizuálně
prohlédnuty. Síťová kontrola potvrdila bajtovou shodu všech čtyř veřejných
GitHub souborů s místními vstupy a spustila obě online ukázky z lekce.
Kontrola rozdílů nových zdrojů prošla. Veřejné nasazení knihy tato lokální
kontrola nepotvrzuje.

R 4.5.1 upozorňuje na tři balíčky sestavené pod R 4.5.3. Tato upozornění
zůstala viditelná, nezpůsobila selhání. Importní varování z ukázky tečky
místo čísla je záměrné a vyžadované testem.

Původní `week_05.R` obsahuje koncové mezery a `students.txt` neobvyklé
konce řádků. Kvůli zachování podkladů nebyly normalizovány; kontrola
rozdílů tyto původní soubory posuzuje odděleně od nového autorského kódu.
`.gitattributes` chrání přesný obsah textového vstupu. Nesouvisející
`tests/test_03.txt` a ostatní místní datasety nebyly upraveny ani přidány.

## Výběry, faktory, seznamy a výpis tabulek v kapitole 4, 4. 10. 2026

Další redakce kapitoly navazuje na místní uživatelské změny, které zůstávají zachovány. Původní `scripts/week_04.R` se nemění.

- **Indexování a pojmenování:** výklad označuje index jako další vektor a rozlišuje číselné pozice, logické podmínky a textová jména. U číselných indexů připouští zápis celých čísel typu `double`. `which()` má spustitelnou ukázku pozic 1 a 5 a výběru hodnot 10 a 8, včetně rozdílu oproti přímému logickému indexování a shody s `filter()` při vynechání neznámého výsledku podmínky. `purrr::set_names()` je samostatná spustitelná alternativa se stejným výsledkem jako `names()`.
- **Logické podmínky:** zachováno vysvětlení `FALSE & NA`, odstraněno jeho opakování a propojen vznik logického indexu s porovnáním původního vektoru. Výslovný srovnávací index má nyní sedm prvků místo šesti; druhý zápis tak již sám nevyužívá recyklaci. Oba výběry dávají stejné hodnoty včetně `NA`.
- **Faktory:** doplněno, proč obvykle popisujeme četnosti kategorií místo průměru interních kódů. Nepovinná poznámka odlišuje věcné pořadí kategorií od volby `ordered` a výchozího regresního kódování: běžný faktor používá treatment/dummy kontrasty, uspořádaný polynomické. Nejde o obecný zákaz uspořádaných faktorů; nastavení kontrastů lze změnit. Výchozí argument `ordered = FALSE` je vztažen k vytváření z textu, protože `factor()` může u již uspořádaného vstupu zachovat jeho třídu.
- **Pořadí a popisky:** dvě nové ukázky obracejí pořadí pomocí argumentu `levels`, případně společně s `labels`. Kontroluje se zachování odpovědí osob a změna interních kódů. Výklad upozorňuje, že přímé přiřazení do `levels()` přejmenovává úrovně a může zaměnit jejich význam. Převod číselných popisků nyní výslovně ukazuje mezikrok `as.character()`, jeho výstup a následné `as.integer()` i `as.double()`.
- **Seznamy a průměr:** přidáno přirovnání vytažení obsahu jedné položky přes `[[`/`$` a zachování seznamu přes `[`. Výběr nemaže položky z původního objektu; zachována je nepovinná poznámka k rekurzivnímu indexu. V řešení cvičení 7 je vysvětlen vstup pro `mean()`, automatický převod logických hodnot i nutnost výslovného převodu textových čísel. Funkce není popsána jako omezená pouze na číselné vektory, protože má také metody pro jiné třídy.
- **Tabulky a konzole:** `data.frame` je vysvětlen jako seznam sloupců se společným počtem řádků, u běžných vektorových sloupců tedy se stejnou délkou. Výklad připouští i složitější sloupce. U tibble přidána spustitelná ukázka `print(..., n = 20)` a vysvětlení rozdílu mezi omezením výpisu a výběrem dat.
- **Další opravy:** v interpretaci průměru věku identifikována osoba P03 místo chybného označení šesté osoby; příčina chybění není domýšlena. `filter()` vyřazuje řádky podle chybějícího výsledku podmínky, nikoli automaticky podle libovolného chybění. V poznámce k vnořenému seznamu opraven název položky `nazev`; opraven také pád ve spojení „kvůli chybějícímu věku“ a popis nově vzniklých řádků vyplněných `NA` v přehledu potíží.

Odborná kontrola vychází z oficiální dokumentace `which()`, `factor()`, `mean()`, kontrastů, `data.frame()` a výpisu tibble. Samostatné ověření v čistém R potvrdilo výchozí `contr.treatment`/`contr.poly` i to, že `mean()` číselné texty a seznam automaticky nerozbalí ani nepřevede. Nové porovnávací kontroly v `check-lesson-04.R` ověřují zachování hodnot po změně pořadí faktorů, převod popisků, shodu pojmenování a shodu výběru přes `which()` s `filter()`.

Ověření: prošel render celé knihy, samostatná kontrola kapitoly 4 i projektová kontrola R včetně všech vzorových řešení. HTML kontrola prošla pro všechny čtyři kapitoly. V kapitole 4 ověřila deset zpočátku skrytých a rozbalitelných řešení, skutečné kopírování všech 185 vykreslených úseků kódu, jeden načtený graf a 387 místních cílů odkazů. Mobilní šířka 390 px nepřetéká, bez chyb JavaScriptu. Nové příklady a pasáže byly vizuálně prohlédnuty ve vykresleném HTML. Kontrola rozdílů prošla. R 4.5.1 upozorňuje na některé balíčky sestavené pod R 4.5.3; kontroly však uspěly. Veřejné nasazení tato kontrola nepotvrzuje.

## Upřesnění typů a recyklace v kapitole 4, 4. 10. 2026

Na uživatelovu průběžnou redakci kapitoly navazují tato doplnění:

- V přehledu vektorů je „složitost“ vysvětlena jako obecnost typu a možnosti reprezentace hodnot, nikoli délka vektoru. `double` zahrnuje i desetinné hodnoty a má omezený rozsah i přesnost; chybění je možné u všech čtyř probíraných typů.
- Výklad `c()` používá přirovnání ke společnému jmenovateli, ale výslovně uvádí, že rozhodují vstupní typy podle hierarchie R, nikoli kontrola konkrétních hodnot.
- Za `as.integer()` přibyla ukázka `round()` s vysvětlením, že zaokrouhlený výsledek zůstává typu `double`, i krátká poznámka k zaokrouhlování přesné poloviny na sudé číslo.
- Pasáž o rlang vysvětluje závislost mezi balíčky a přidává kontrolu typu i délky argumentem `n`, včetně příkladů nesouhlasící délky a typu.
- Recyklace porovnává násobení jedinou tisícovkou s `c(1000, 1000, 1000)` a přičtení jediné desítky s `c(10, 10, 10)`; výsledky jsou shodné.
- V navazujícím textu je výslovně zachováno `NA` při logickém převodu a opravena formulace o desetinné čárce pro `as.numeric()`. Původní skript, data a analytické postupy se nemění. Dosavadní místní redakce kapitoly je zachována a zahrnuta do stejné změny; nesouvisející `tests/test_03.txt` zůstává mimo commit.

Chování bylo ověřeno proti oficiální dokumentaci R (`c()`, `round()`) a rlang, odkazované v kapitole, i spuštěním příkladů. Prošlo vykreslení celé knihy a po poslední textové korektuře nový render kapitoly 4. Projektová kontrola R prošla včetně všech bloků a řešení čtvrté kapitoly v čisté relaci. Kontrola HTML prošla pro všechny čtyři kapitoly; v kapitole 4 ověřila deset skrytých a rozbalitelných řešení, skutečné kopírování všech 172 vykreslených úseků kódu, načtení grafu a 358 místních cílů odkazů. Při šířce 390 px není vodorovné přetékání a nebyly zaznamenány chyby JavaScriptu. R 4.5.1 hlásilo upozornění na některé balíčky sestavené pod R 4.5.3; kontroly prošly. Veřejné nasazení nebylo ověřováno.

Nové pasáže o zaokrouhlování, kontrole typu a délky a recyklaci byly prohlédnuty také na snímcích vykresleného HTML; text, výstupy i tlačítka jsou čitelné.

## Čtvrtá kapitola: datové struktury, 3. 10. 2026

Podkladem je `scripts/week_04.R`, zachovaný beze změny (SHA-256 `da0d5aedaa65ff7e3a0925f0354cc4b6cc0d15af7f6d18a46ae18eb6ceee8ca6`). Nová `lekce_04.qmd` navazuje na základní vektory z první lekce, grafy z druhé a úpravy tabulek z třetí. Obsahuje devět průběžných cvičení a samostatně spustitelnou závěrečnou úlohu. Všechna řešení včetně výstupů a interpretací jsou ve sbalených blocích. Pokročilejší výjimky a alternativy jsou označeny jako nepovinné.

### Úpravy podkladu a jejich důvody

- **Příklady a uspořádání:** planetární tabulku, počasí a další izolované příklady nahrazují malé výslovně fiktivní psychologické údaje. Zachovány jsou výukové operace: typ a délka, převody, recyklace, pojmenování a výběr prvků, faktory, seznamy, tvorba a výběr tabulek i srovnání základního R s dplyr. Nejde o přepočet původních planetárních výsledků; jde o jiná didaktická data. Z původních obměn je vybrán jeden hlavní postup a smysluplné alternativy, nikoli všechny duplicitní ukázky.
- **Balíčky a predikáty:** podklad neobsahuje načtení potřebných balíčků. Lekce načítá tidyverse a odděluje instalaci od výpočtů. Pro základní kontrolu typu používá `is.*()` ze základního R a výslovně odlišuje funkce `rlang::is_*()`. Nevytváří dojem, že názvy s tečkou a podtržítkem jsou zaměnitelné nebo že všechny funkce rlang zpřístupní samotné `library(tidyverse)`. `set_names()` je označeno jako alternativa z purrr; hlavní výklad používá `names()`.
- **Typy a atributy:** čtyři nejčastější atomické typy nejsou prezentovány jako vyčerpávající seznam. Datová tabulka není popsána jako seznam výhradně atomických vektorů ani jako objekt s atributem `dim`; lekce rozlišuje sloupce, třídu, názvy, jména řádků a rozměry zjištěné pomocí `dim()`. Typ a třída jsou vysvětleny samostatně.
- **Převody a přesnost:** doplněny důsledky textu v `c()`, převod nenulových čísel na `TRUE`, ořezání desetinné části pomocí `as.integer()` a záměrně viditelné varování při neúspěšném číselném převodu. `near()` řeší numerickou toleranci, nikoli věcnou ekvivalenci měření. Konkrétní odchylky byly ověřeny místním R; text připouští odlišnost posledních číslic mezi prostředími.
- **Recyklace a chybění:** zachovány aritmetické ukázky a obě záměrná varování. Doplněno riziko tichého opakování i rozdíl mezi aritmetikou, `data.frame()` a tibble. Logické souhrny uvádějí počet dostupných údajů a jmenovatel. Výběr přes `[` výslovně ošetřuje `NA` a je porovnán s `filter()`; chybějící hodnoty nejsou imputovány.
- **Výběr `[[` a `$`:** upřesněno původní absolutní tvrzení, že `[[` vždy přijímá jediný index. Vektor indexů může u vnořených seznamů označovat rekurzivní cestu. Základní výklad používá jednu pozici nebo jméno a jasně rozlišuje seznam od jeho obsahu. Popsáno je také riziko částečné shody u `$` v základním R.
- **Faktory:** pořadí úrovní se nezaměňuje s přeskupením pozorování ani s třídou `ordered`. `levels` a `labels` mají odlišnou úlohu; interní kódy nevyjadřují automaticky vzdálenosti kategorií. Nové příklady ukazují tichý vznik `NA` při nesouladu kategorií i nebezpečí přímého `as.numeric(faktor)`.
- **Datové tabulky:** doplněny význam čárky, `drop = FALSE`, rozdíl `length()` a `nrow()` a zachování tibble při výběru jediného sloupce. Srovnání základního R a dplyr kontroluje hodnoty, pořadí osob a sloupce; záměrně nevyžaduje shodná automatická jména řádků. `subset()` zůstává jako nepovinná alternativa.
- **Náhodnost a závěrečný příklad:** náhodný `sample()` není potřeba pro vysvětlení logických souhrnů; nahrazen je malým průhledným příkladem s chyběním. Velká tibble z `runif()` má `set.seed(104)`. Závěrečná úloha předem definuje zahrnutí potvrzených dokončení se známým skórem a zachovává původní sloupce. Šest z osmi osob je zahrnuto, každá skupina má tři; průměry jsou 41/3 a 59/3 a podíl skórů alespoň 18 je 3/6. Výsledky nejsou interpretovány kauzálně.

Hlavní didaktické zdroje: R4DS 2e, kapitoly Logical vectors, Factors a A field guide to base R; přesné chování ověřeno proti oficiální dokumentaci R, tibble a rlang a spuštěním příkladů. Odkazy a označení vlastních obměn cvičení jsou přímo v lekci. Pro tuto kapitolu nejsou potřeba další balíčky nad rámec stávající instalace a CI.

### Ověření

`check-lesson-04.R` spouští všechny výpočetní bloky včetně řešení v čisté relaci, vyžaduje dvě označené chyby a tři označená varování a odmítá ostatní neočekávané chyby či varování. Výjimkou jsou doložená upozornění na verzi sestavení balíčků při jejich načtení, která zůstávají v protokolu. Samostatně kontroluje číselné interpretace, struktury, jmenovatele, výšky sloupců grafu a úplné závěrečné řešení v další čisté relaci. Je zapojen do `check-r.R`. Kontrola HTML byla rozšířena na čtvrtou kapitolu; zahrnuje i její tabulky, graf a řešení.

Úspěšně vykreslena celá kniha v R 4.5.1 a Quarto 1.9.38; po závěrečné jazykové úpravě odkazů znovu vykreslena čtvrtá kapitola. Prošel `check-r.R` pro celou učebnici včetně nové kapitoly a jejího samostatného závěrečného řešení. Všechny výpisy nové lekce byly prohlédnuty a graf zkontrolován i vizuálně. Tři upozornění na sestavení balíčků pod R 4.5.3 jsou vlastností místního prostředí, zůstala viditelná a nevedla k selhání. Instalace balíčků se v rámci kontrol nespouštěla.

Finální kontrola HTML prošla pro všechny čtyři lekce. V nové kapitole ověřila deset zpočátku skrytých a rozbalitelných řešení, skutečné kopírování všech 164 vykreslených úseků kódu, jeden načtený graf a 350 místních cílů odkazů. Zdroj obsahuje 60 R bloků; knitr je při prokládání příkazů a výstupů rozděluje na více kopírovatelných úseků. Počet bloků proto není počet odlišných postupů. Prošla navigace knihy, pravá osnova a mobilní šířka 390 px bez vodorovného přetékání; nebyly zaznamenány chyby JavaScriptu. Vizuálně zkontrolovány úvod, tabulkový výstup, graf, rozbalené závěrečné řešení a mobilní zobrazení. Ověřeny také cíle použitých odkazů do R4DS; chybně předpokládaná kotva v dokumentaci tibble byla nahrazena odkazem na existující stránku. Veřejné nasazení tato lokální kontrola neověřuje.

Kontrola rozdílů nehlásí potíže v nových ani upravených autorských souborech. U nově zařazeného původního `week_04.R` upozorňuje pouze na jeho již přítomné koncové mezery na 11 řádcích a prázdný řádek na konci souboru. Podklad nebyl kvůli formátování měněn; jeho shodný SHA-256 potvrzuje zachování dodané verze. Nesouvisející místní `tests/test_03.txt` nebyl upravován ani zahrnut do změny.

## Přejmenování při výběru a přesunu sloupců, 27. 9. 2026

V oddílu „Přejmenování a přesun“ lekce 3 byly doplněny dvě spustitelné ukázky zápisu `novy_nazev = stary_nazev` přímo v `relocate()` a `select()`. Výklad rozlišuje zachování všech sloupců při přesunu od ponechání vybraných sloupců a vysvětluje, kdy není potřeba samostatné `rename()`. Chování bylo ověřeno v oficiální dokumentaci obou funkcí. Původní příklad i analytické postupy zůstávají zachovány.

Úspěšně proběhlo vykreslení celé knihy a projektové kontroly R i HTML. Samostatně byla ověřena úplná shoda výsledku kombinace `rename()` a `relocate()` s jediným voláním `relocate()` a zachování hodnot při výběru s přejmenováním. Výpisy obou nových ukázek byly zkontrolovány. V lekci 3 prošlo kopírování všech 72 ukázek, rozbalování 11 řešení, načítání obrázků, místní odkazy a mobilní šířka 390 px bez přetékání; žádné chyby JavaScriptu. R upozornilo na balíčky sestavené pod R 4.5.3, kontroly v R 4.5.1 však prošly. Součástí změny je také zachovaná místní uživatelská úprava oddělovacích řádků tří tabulek. Veřejné nasazení nebylo ověřováno.

## Upřesnění lekce 3, 27. 9. 2026

Na žádost uživatele byly doplněny plné názvy letišť a přesnější označení newyorské metropolitní oblasti. Interaktivní ukázka používá `tibble::view()` dostupné po načtení tidyverse; text vysvětluje vztah k `View()`. Nový oddíl srovnává `%>%` z magrittr a nativní `|>` od R 4.1.0, na spustitelných příkladech ukazuje shodu běžného řetězce a rozdíl `.$dep_delay` oproti `_$dep_delay` (od R 4.3.0). Uživatelem dodaný `screenshots/pipe.png` doprovází nastavení klávesové zkratky. Chování bylo porovnáno s dokumentací R, magrittr a tibble; historii verzí potvrzuje také [srovnání pipe operátorů od Hadleyho Wickhama](https://tidyverse.org/blog/2023/04/base-vs-magrittr-pipe/).

Výklad nyní zdůvodňuje výsledek `NA` při porovnání `== NA`, podrobně rozepisuje řazení podle více sloupců včetně zachování vstupního pořadí při úplné shodě a vysvětluje četnosti, unikátní řádky i rozdíl řádků a sloupců. Zadání o dohnání zpoždění používá formulaci „mezi odletem a příletem“, která nepřipisuje změnu výhradně pobytu ve vzduchu. Jazykové úpravy zahrnují „cestu pasažéra“, „název funkce“, průměr bez jediné platné hodnoty a zrušení seskupení pro následné operace. Původní analytické postupy, data a výsledky se nemění; podkladový skript zůstává beze změn.

Úspěšně proběhl render celé knihy a projektové kontroly R i HTML. Všechny spustitelné bloky lekce 3 včetně řešení prošly v čisté relaci; samostatně byla ověřena shoda obou pipe zápisů, porovnání s `NA`, konstantní rok 2013 a stabilní řazení všech záznamů `flights`. Kontrola HTML u lekce 3 ověřila 11 sbalených a rozbalitelných řešení, skutečné kopírování všech 70 bloků, načtení tří obrázků, 329 místních cílů odkazů a šířku 390 px bez přetékání. Celá kniha prošla bez chyb JavaScriptu. Nový snímek byl vizuálně zkontrolován na desktopu i mobilu; jeho text je rovněž popsán v okolním výkladu. Varování o balíčcích sestavených pod jinou verzí R nebyla potlačena a kontroly neovlivnila. Interaktivní otevření `view()` v RStudiu se automaticky netestovalo; ověřena byla dokumentace a implementace funkce. Veřejné nasazení není součástí tohoto lokálního ověření.

## Aktuální uspořádání

`lekce_01.qmd` obsahuje základy R a RStudia, práci s projektem, skriptem, objekty, funkcemi, vektory a balíčky. `lekce_02.qmd` obsahuje základy ggplot2, `lekce_03.qmd` úpravy dat v dplyr a `lekce_04.qmd` vektory, faktory, seznamy a datové tabulky. Každá lekce samostatně připravuje všechny potřebné objekty a balíčky. Výstupy jsou `_book/quarto/lekce_01.html` až `_book/quarto/lekce_04.html`; pro čtení knihy není třeba instalovat R. Instalační a provozní postupy popisuje kořenový `README.md`.

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

## Doplnění kapitoly 2 dne 20. 9. 2026

- V oddílu dokončeného grafu vysvětleno, že podporované vizuální vlastnosti závisejí na geomu: `shape` patří k bodům, zatímco čáry lze odlišovat například pomocí `linetype`. Mapování tvaru zůstává lokální v `geom_point()`.
- Při prvním výkladu pipe operátoru doplněna zkratka Ctrl + Shift + M (macOS Cmd + Shift + M) a nastavení RStudia pro vkládání `|>`.
- U četností přidány tabulka z `count(species)`, graf `geom_col()` s explicitním `y = n` a krátká interpretační úloha. Nový postup dává stejné četnosti 152, 68 a 124 jako původní `geom_bar()`.
- U histogramu vysvětleno výchozí `bins = 30`, které nepoužívá datově řízený výběr počtu intervalů. Výpočet šířky pro běžné nastavení byl ověřen v instalovaném ggplot2 4.0.0 i proti aktuálnímu zdrojovému kódu: rozsah 3600 g dělený 29 dává přibližně 124,14 g. Původní výukový histogram s šířkou 200 g se nezměnil.
- V obou příkladech panelů použit `facets = vars(...)`; starší zápis s formulí zůstává vysvětlen jako platná alternativa. Shoda rozdělení a pořadí panelů ověřena výpočtem.
- Před grafem s vlastní legendou přidán spustitelný příklad pevných barev bez legendy a komentář k jeho omezení. Lineární i loess odhady včetně intervalů zůstávají shodné; mění se pouze barvy a legenda.

Odborné zdroje jsou uvedeny přímo u doplnění: oficiální dokumentace ggplot2, jeho zdrojový soubor `R/bin.R` a dokumentace zkratek Posit. Nejde o změnu analytické metody ani vstupních dat.

Ověření: úspěšný render celé knihy; kontrola R v čisté relaci včetně samostatných závěrečných řešení a nových porovnání; kontrola HTML obou kapitol. Kapitola 2 obsahuje 14 zpočátku sbalených a funkčních řešení, 43 skutečně zkopírovaných ukázek a 29 načtených obrázků. Odkazy i mobilní šířka 390 px prošly, bez chyb JavaScriptu. Nový sloupcový graf a obě verze modelových čar byly prohlédnuty i vizuálně. R upozornilo na některé balíčky sestavené pod R 4.5.3 při běhu R 4.5.1; kontroly prošly. Render zahrnoval také již rozpracované místní redakční změny autora; ty zůstávají zachovány mimo commit tohoto doplnění.
