# Data
# Jde o data z výzkumu dvou kohort adolescentů z roku 1999. 
# Jedna kohorta byli šesťáci, druhá prváci na střední škole. 
# Data long2.sav jsou ve formátu .sav (SPSS). 
# Díky tomu budou po importu kompletně olabelována. 
# Nespoléhejte ale na správnost nastavení Column type – 
# jak JASP, tak SPSS si to nastavují podle své hlavy a vy z 1. 
# semináře víte, že na tom nastavení záleží – bude ho možná potřeba měnit.

library(tidyverse)
library(haven)
library(qqplotr)
library(ggh4x)
library(rstatix)
library(janitor)
library(ggmosaic)

df <- read_sav("data/long2.sav")

# Úkol 1: Kontrola a čištění proměnných pohlavi a kohorta
# Postup. Podívejte se na četnosti proměnných pohlavi a kohorta. 
# Kohorta 6 jsou šesťáci, kohorta 10 jsou prváci na střední škole. 
# Jiné hodnoty jsou chybně zaznamenané a je potřeba je označit jako chybějící. 
# Stejně zkontrolujte pohlavi. 
# Do textu: Četnosti proměnných pohlavi a kohorta. 
# Kolik bylo chybějících nebo chybných hodnot u každé proměnné. 
df <- df |> 
  mutate(
    across(
      c(pohlavi, kohorta),
      ~ as_factor(.x)
    )
  )


df |> 
  count(pohlavi) |> 
  mutate(p = n/sum(n)*100)

df |> 
  count(kohorta) |> 
  mutate(p = n/sum(n)*100)

df |> 
  filter(kohorta == 66)

df <- df |> 
  mutate(
    kohorta = if_else(
      kohorta == 66,
      true = "mladší kohorta",
      false = kohorta
    )
  )

df |> 
  count(kohorta) |> 
  mutate(p = n/sum(n)*100)

df |> 
  count(kohorta, pohlavi) |> 
  mutate(
    p = n/sum(n)*100,
    .by = kohorta
  )



# Úkol 2: Kontrola proměnné vekr
# Postup. Podívejte se na rozdělení věku (vekr). 
# Odpovídá tomu, že jsme sbírali data v kohortě šesťáků a středoškolských prváků?
# Do textu: Histogram s popiskem. Dvě až tři věty o tom, zda rozdělení odpovídá 
# očekávaným dvěma věkovým kohortám. Pokud jste našli nevěrohodné hodnoty, 
# uveďte je a popište, jak s nimi hodláte dál v analýze naložit.

df |> 
  ggplot(aes(vekr, fill = kohorta)) +
  geom_histogram()

df |> 
  filter(vekr > 18)

# Postup. Vypočítejte proměnnou monitoring. Tento úkol má tři kroky.
# 1.	Kontrola položek. Podívejte se na četnosti odpovědí u položek c01_99 
# až c09_99. Měly by se vyskytovat jen odpovědi 1–4 (nikdy–vždy). 
# Zároveň ověřte, že žádná položka není reverzní: 
# v korelační matici mezi položkami by žádná korelace neměla být výrazně negativní.
# 2.	Výpočet skóru. Nastavte položky jako scale, aby s nimi JASP počítal 
# aritmeticky. Pak vytvořte počítanou proměnnou monitoring jako průměr 
# položek c01_99 až c09_99. Zkuste to funkcí rowMean i aritmeticky sečtením 
# položek a podělením počtem. V čem je rozdíl? 
# Vyberte si, se kterou variantou chcete dál pracovat.  
# 3.	Popis rozdělení. Popište rozdělení skóru statistikami v textu i grafem.
# Do textu: Konstatování, že všechny položky nabývají jen hodnot 1–4 nebo které 
# nikoli a co jste s tím udělali. Závěr, zda je některá položka reverzní. 
# Popis výpočtu proměnné monitoring s ohledem na chybějící hodnoty. 
# Histogram s popiskem a dvě až tři věty slovního popisu tvaru rozdělení.
df |> 
  select(c01_99:c09_99) |> 
  summary()

df |> 
  select(id, c01_99:c09_99) |> 
  pivot_longer(
    cols = -id,
    names_to = "item",
    values_to = "value"
  ) |> 
  ggplot(aes(value)) +
  geom_bar() +
  facet_wrap(~item)

df |> 
  select(c01_99:c09_99) |> 
  psych::alpha()

df |> 
  select(c01_99:c09_99) |> 
  cor(use = "pairwise") |> 
  round(digits = 2)

df <- df |> 
  rowwise() |> 
  mutate(
    monit = mean(
      c_across(c01_99:c09_99),
      na.rm = TRUE
    ),
    na_monit = sum(is.na(c_across(c01_99:c09_99))),
    .after = vekr
  ) |> 
  ungroup()

df |> 
  count(na_monit)

df <- df |> 
  mutate(
    monit = if_else(
      na_monit > 1,
      true = NA_real_,
      false = monit
    )
  )

df |> 
  ggplot(aes(monit)) +
  geom_histogram(aes(y = after_stat(density))) +
  stat_theodensity(aes(color = "Normální"),
                   distribution = "norm",
                   linewidth = 1) +
  geom_density(aes(color = "Empirická"),
               linewidth = 1,
               key_glyph = "path",
               linetype = "dashed") +
  scale_color_manual(values = c("Normální" = "red", "Empirická" = "blue")) +
  labs(color = "Hustota") +
  theme(legend.position = "top")


df |>
  ggplot(aes(sample = monit)) +
  stat_qq_band(bandType = "ts", identity = T) +
  stat_qq_line(identity = T) +
  stat_qq_point() +
  labs(
    x = "Teoretické kvantily normálního rozdělení (v jednotkách skóru)",
    y = "Skór monitorování"
  )
  

df |> 
  summarise(
    M = mean(monit, na.rm = TRUE),
    SD = sd(monit, na.rm = TRUE),
    skew = psych::skew(monit),
    kurt = psych::kurtosi(monit),
    n_valid = sum(!is.na(monit)),
    n_miss = sum(is.na(monit)),
  )

# Postup. Podívejte se na rozdělení monitoringu zvlášť ve skupině chlapců a 
# dívek (bez ohledu a kohortu). Otestujte hypotézu o rovnosti průměrů 
# monitoringu mezi chlapci a dívkami dvouvýběrovým t-testem. 
# Jsou splněny následující předpoklady: intervalovost, normalita, 
# homoskedasticita?
# Do textu: Vyhodnocení všech tří předpokladů, u každého uveďte,
# čím jste ho posoudili — pouhé konstatování, že předpoklady jsou splněny, 
# nestačí. Kterou variantu t-testu (Studentovu / Welchovu) jste použili a proč. 
# Slovní interpretace výsledku v APA formátu. Nezapomeňte, že t-test 
# poskytuje doplňující informaci k tomu srovnání průměrů (ne naopak).
df |> 
  summarise(
    M = mean(monit, na.rm = TRUE),
    SD = sd(monit, na.rm = TRUE),
    skew = psych::skew(monit),
    kurt = psych::kurtosi(monit),
    n_valid = sum(!is.na(monit)),
    n_miss = sum(is.na(monit)),
    .by = pohlavi,
  )

df |>
  drop_na(pohlavi) |> 
  ggplot(aes(monit)) +
  geom_histogram(aes(y = after_stat(density)),
                 binwidth = 1/9) +
  stat_theodensity(aes(color = "Normální"),
                   distribution = "norm",
                   linewidth = 1) +
  geom_density(aes(color = "Empirická"),
               linewidth = 1,
               key_glyph = "path",
               linetype = "dashed") +
  scale_color_manual(values = c("Normální" = "red", "Empirická" = "blue")) +
  facet_wrap(~ pohlavi) +
  labs(color = "Hustota") +
  theme(legend.position = "top")

df |>
  drop_na(pohlavi) |> 
  ggplot(aes(sample = monit)) +
  stat_qq_band(bandType = "ts", identity = T) +
  stat_qq_line(identity = T) +
  stat_qq_point() +
  labs(
    x = "Teoretické kvantily normálního rozdělení (v jednotkách skóru)",
    y = "Skór monitorování"
  ) +
  facet_wrap(~ pohlavi)

df |> 
  drop_na(pohlavi) |> 
  ggplot(aes(pohlavi, monit)) +
  geom_boxplot() +
  geom_point(stat = "summary",
             fun.y = "mean",
             color = "red",
             size = 2)

df |> 
  levene_test(monit ~ pohlavi)


df |> 
  t_test(monit ~ pohlavi, detailed = TRUE,
         var.equal = TRUE)


df |> 
  cohens_d(monit ~ pohlavi,
           ci.type = "norm",
           ci = TRUE,
           var.equal = TRUE)


# Úkol 5: Souvislost věku a monitoringu
# Postup. Náš vzorek tvořily dvě docela vzdálené věkové kohorty a věk by tu 
# mohl hrát roli. Podívejte se exploračně na vztah věku a monitoringu: 
# scatterplot a Pearsonův korelační koeficient. Pak se zamyslete, 
# jestli je Pearsonův koeficient pro tato data vhodný nástroj. 
# Do textu: Scatterplot s popiskem. Zdůvodněná odpověď na otázku, 
# zda Pearsonův koeficient tento vztah dobře popisuje, s odkazem na to, 
# co je vidět ve scatterplotu. Pokud si myslíte, že ne, uveďte, 
# co byste použili místo něj.
df |> 
  ggplot(aes(vekr, monit, color = kohorta)) +
  geom_jitter(width = .1,
              height = .05)

df |> 
  select(vekr, monit) |> 
  psych::corr.test() |> 
  print(short = FALSE)


df |> 
  summarise(
    M = mean(monit, na.rm = TRUE),
    SD = sd(monit, na.rm = TRUE),
    skew = psych::skew(monit),
    kurt = psych::kurtosi(monit),
    n_valid = sum(!is.na(monit)),
    n_miss = sum(is.na(monit)),
    .by = kohorta,
  )

df |>
  drop_na(kohorta) |> 
  ggplot(aes(monit)) +
  geom_histogram(aes(y = after_stat(density)),
                 binwidth = 1/9) +
  stat_theodensity(aes(color = "Normální"),
                   distribution = "norm",
                   linewidth = 1) +
  geom_density(aes(color = "Empirická"),
               linewidth = 1,
               key_glyph = "path",
               linetype = "dashed") +
  scale_color_manual(values = c("Normální" = "red", "Empirická" = "blue")) +
  facet_wrap(~ kohorta) +
  labs(color = "Hustota") +
  theme(legend.position = "top")

df |>
  drop_na(kohorta) |> 
  ggplot(aes(sample = monit)) +
  stat_qq_band(bandType = "ts", identity = T) +
  stat_qq_line(identity = T) +
  stat_qq_point() +
  labs(
    x = "Teoretické kvantily normálního rozdělení (v jednotkách skóru)",
    y = "Skór monitorování"
  ) +
  facet_wrap(~ kohorta)

df |> 
  drop_na(pohlavi) |> 
  ggplot(aes(kohorta, monit)) +
  geom_boxplot() +
  geom_point(stat = "summary",
             fun.y = "mean",
             color = "red",
             size = 2)

df |> 
  levene_test(monit ~ kohorta)


df |> 
  t_test(monit ~ kohorta, detailed = TRUE,
         var.equal = TRUE)


df |> 
  cohens_d(monit ~ kohorta,
           ci.type = "norm",
           ci = TRUE,
           var.equal = TRUE)

# Úkol 6: Může být rozdíl mezi pohlavími zkreslen věkem?
# Postup. V Úkolu 4 jsme srovnávali monitoring chlapců a dívek. 
# V Úkolu 5 jsme zjistili, jestli s monitoringem souvisí věk. 
# Pokud spolu věk a monitoring souvisejí, mohl by být rozdíl mezi 
# chlapci a dívkami zkreslen věkem, pokud se poměr chlapců a dívek liší 
# mezi kohortami. Kdyby v jedné kohortě bylo výrazně víc dívek než v druhé, 
# část zjištěného rozdílu mezi pohlavími by ve skutečnosti byla rozdílem mezi 
# věkovými kohortami.
# Ověřte tedy tuto druhou podmínku: kontingenční tabulka pohlavi × kohorta 
# s testem nezávislosti (viz Úkol 1).
# Čistě tréninkově si k tomu vytvořte vlastní proměnnou kohorta_moje z proměnné 
# vekr: vekr ≥ 11 a vekr < 15 → mladší kohorta, vekr ≥ 15 a 
# vekr ≤ 17 → starší kohorta, ostatní hodnoty → chybějící. 
# Do textu: Kontingenční tabulka s řádkovými nebo sloupcovými procenty. 
# Explicitní odpověď, zda se poměr pohlaví mezi kohortami liší. 
# Jak velký počet (n) se shoduje a neshoduje v zařazení 
# podle kohorta a kohorta_moje?
df <- df |> 
  mutate(
    kohorta_moje = case_when(
      vekr >= 11 & vekr < 15 ~ 1L,
      vekr >= 15 & vekr <= 17 ~ 2L,
    ) |> 
      factor(levels = 1:2,
             labels = c("Mladší", "Starší"))
  )

df |> 
  count(kohorta, kohorta_moje)


df |> 
  count(kohorta_moje, pohlavi) |> 
  mutate(
    p = n/sum(n)*100,
    .by = kohorta_moje
  )

df |> 
  count(kohorta_moje, pohlavi) |> 
  drop_na() |> 
  mutate(
    p = n/sum(n)*100,
    .by = kohorta_moje
  )

df |>
  drop_na(kohorta_moje, pohlavi) |> 
  tabyl(kohorta_moje, pohlavi) |>
  adorn_totals(c("row", "col")) |>
  adorn_percentages("row") |>
  adorn_pct_formatting(digits = 1) |>
  adorn_ns(position = "front")

chisq_test(df$kohorta_moje, df$pohlavi)


df |> 
  drop_na(kohorta_moje, pohlavi) |> 
  ggplot() + 
  geom_mosaic(aes(x = product(kohorta_moje), fill = pohlavi), 
              show.legend = FALSE) +
  scale_fill_manual(values = c("#3F72AF", "#FC5185"))
  theme_mosaic()

# Úkol 7: t-test uvnitř každé kohorty
# Postup. Otestujte, zda se průměrný monitoring chlapců a dívek liší 
# uvnitř mladší kohorty a uvnitř starší kohorty zvlášť. V JASPu na to jde 
# přes filtr, což je zpočátku nezvyklé. Do filtračního pole napíšete podmínku 
# pro mladší kohortu a filtr aplikujete. Všechny výsledky v celém souboru se 
# přepočítají na filtrovaný vzorek, takže si výstupy t-testu nejdřív 
# zkopírujte nebo poznamenejte, a teprve pak filtr přepněte na starší kohortu 
# a test zopakujte. Na konci filtr zase vypněte. Pozor, zapnutí filtru spustí 
# přepočítání všech dosavadních analýz – je dobré nemít žádné zbytečné.
# Do textu: Stručné vyhodnocení předpokladů v obou kohortách. 
# Srovnání s Úkolem 4: je rozdíl mezi pohlavími přítomný v obou kohortách? 
# Změnila se jeho velikost oproti analýze na celém vzorku? 
# Co z toho plyne pro hypotézu o zkreslení věkem z Úkolu 6?
df |> 
  drop_na(pohlavi, kohorta_moje) |> 
  summarise(
      M = mean(monit, na.rm = TRUE),
      SD = sd(monit, na.rm = TRUE),
      skew = psych::skew(monit),
      kurt = psych::kurtosi(monit),
      n_valid = sum(!is.na(monit)),
      n_miss = sum(is.na(monit)),
      .by = c(kohorta_moje, pohlavi)
    )
  
df |>
  drop_na(pohlavi, kohorta_moje) |> 
  ggplot(aes(monit)) +
  geom_histogram(aes(y = after_stat(density)),
                 binwidth = 1/9) +
  stat_theodensity(aes(color = "Normální"),
                   distribution = "norm",
                   linewidth = 1) +
  geom_density(aes(color = "Empirická"),
               linewidth = 1,
               key_glyph = "path",
               linetype = "dashed") +
  scale_color_manual(values = c("Normální" = "red", "Empirická" = "blue")) +
  facet_grid(kohorta ~ pohlavi) +
  labs(color = "Hustota") +
  theme(legend.position = "top")

df |>
  drop_na(pohlavi, kohorta_moje) |> 
  ggplot(aes(sample = monit)) +
  stat_qq_band(bandType = "ts", identity = T) +
  stat_qq_line(identity = T) +
  stat_qq_point() +
  labs(
    x = "Teoretické kvantily normálního rozdělení (v jednotkách skóru)",
    y = "Skór monitorování"
  ) +
  facet_grid(kohorta ~ pohlavi)
  
df |> 
  drop_na(pohlavi) |> 
  ggplot(aes(pohlavi, monit)) +
  geom_boxplot() +
  geom_point(stat = "summary",
             fun.y = "mean",
             color = "red",
             size = 2) +
  facet_wrap(~ kohorta)
  
df |> 
  group_by(kohorta) |> 
  levene_test(monit ~ pohlavi)  
  
  
df |> 
  group_by(kohorta) |> 
  t_test(monit ~ pohlavi, 
         detailed = TRUE,
         var.equal = TRUE)  
  
df |> 
  group_by(kohorta) |> 
  cohens_d(monit ~ pohlavi,
           ci.type = "norm",
           ci = TRUE,
           var.equal = TRUE)

  