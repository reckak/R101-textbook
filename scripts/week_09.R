# LINEÁRNÍ REGRESE V R ---------------------------------------------------


# Cíl skriptu ------------------------------------------------------------
# 1) Načíst a připravit data (rekódování faktorů, filtrace vztahů < 6 měsíců).
# 2) Prozkoumat rozdělení proměnných a jejich korelace.
# 3) Odhadnout jednoduchý model (jen délka vztahu) a rozšířený model
#    (investice, spokojenost, alternativy + kontrola délky vztahu).
# 4) Zhodnotit přírůstek vysvětleného rozptylu, standardizované koeficienty
#    a semiparciální R2.
# 5) Zkontrolovat předpoklady lineární regrese pomocí diagnostických grafů
#    a funkcí balíčků car, performance a broom.
# 6) Vypočítat intervaly spolehlivosti a predikční intervaly 
#    a znázornit je v grafu.
# 7) Ukázat, jak „očistit“ (adjustovat) empirická pozorování na referenční 
#    hodnotyostatních prediktorů pro účely grafického znázornění.


# 0) Balíčky --------------------------------------------------------------

library(betaDelta)   # standardizované beta koeficienty a jejich intervaly spolehlivosti
library(broom)       # převod modelů do tibble (tidy(), glance(), augment())
library(performance) # diagnostika modelů (check_model())
library(tidyverse)   # dplyr, ggplot2, tidyr atd. (implicitně používáme)


# 1) Kontext výzkumu ------------------------------------------------------

# Lucia Mikulíková ve své bakalářce zkoumala souvislosti závazku ve vztahu
# a žárlivosti. Závazek ve vztahu měla teoreticky zarámovaný investičním
# modelem Carol Rusbultové.
# Podle tohoto modelu je závazek ve vztahu formován třemi složkami:
#   - spokojeností ve vztahu,
#   - investicemi do vztahu,
#   - vnímanými alternativami (pocit, že mám „kam odejít“).
#
# Ověříme pomocí lineárního regresního modelu, že závazek je:
#   + pozitivně závisí na investicích a spokojeností,
#   - negativně závisí na dostupnosti alternativ,
#   + zároveň budeme kontrolovat délku vztahu (v měsících/rocích).
#
# Protože počáteční měsíce vztahu mohou mít jinou dynamiku, vyřadíme z analýzy
# vztahy kratší než půl roku (tj. < 6 měsíců).

# 2) Načtení a základní úprava dat ----------------------------------------

# Načtení dat (soubor musí být v podadresáři "data")
df <- haven::read_sav("data/ZZ_ckrvliry.sav") |> 
  janitor::clean_names()
df

# Uložení kompletního datasetu před filtrováním (pro případné srovnání)
df_complete <- df

# Rekódování kategorických proměnných na faktory s čitelnějšími popisky
# (aby se hezky zobrazovaly v tabulkách a grafech)
df <- df %>% 
  mutate(
    pohlavie    = factor(pohlavie,    labels = c("muž", "žena")),
    narodnost   = factor(narodnost,   labels = c("slovenská", "česká")),
    vazny_vztah = factor(vazny_vztah, labels = c("ano", "ne")),
    spolubyvanie= factor(spolubyvanie,labels = c("ano", "ne")),
    zasnuveny   = factor(zasnuveny,   labels = c("ano", "ne"))
  )


# 3) Základní deskriptivní pohled na data ---------------------------------

# Počet respondentů podle pohlaví (kontrola rozložení)
df %>% 
  count(pohlavie)

# Rozdělení délky vztahu (v měsících)
df %>% 
  ggplot(aes(delka_vztahu)) +
  geom_histogram()

# Rozdělení věku
df %>% 
  ggplot(aes(vek)) +
  geom_bar()


# 4) Filtrování vztahů kratších než 6 měsíců ------------------------------

# Vyřazujeme velmi krátké vztahy – chceme se soustředit na vztahy, kde
# dává investiční model závazku větší smysl.
df <- df %>% 
  filter(delka_vztahu >= 6)


# 5) Deskriptivní statistiky hlavních proměnných --------------------------

# Základní sada proměnných, které nás zajímají v regresi
vars_reg <- c("delka_vztahu", "spokojenost", 
              "alternativy", "investice", "zavazek")

# Histogramy pro každou proměnnou zvlášť
#   – scales = "free_x" dovolí, aby měla každá proměnná 
#     svou vlastní (nesdílenou) osu X

df %>% 
  select(all_of(vars_reg)) %>% 
  pivot_longer(
    everything(),
    names_to  = "variable",
    values_to = "value"
  ) %>% 
  ggplot(aes(value)) +
  geom_histogram() +
  facet_wrap(~variable, scales = "free_x")

# Histogramy po z‑skórování (scale() centruje a škáluje v rámci každé proměnné)
#   – přidáme hustotu a teoretickou normální křivku pro hrubé posouzení normality
df %>% 
  select(all_of(vars_reg)) %>% 
  pivot_longer(everything(),
               names_to  = "variable",
               values_to = "value") %>% 
  mutate(value = scale(value), .by = variable) %>% 
  ggplot(aes(value)) +
  geom_histogram(aes(y = after_stat(density)),
                 fill = "grey", color = "grey50") +
  geom_density(linewidth = 1, linetype = "11", color = "blue") +
  stat_function(fun = dnorm, color = "red", linewidth = 1) +
  facet_wrap(~variable, scales = "free_x")

# Korelační matice (Pearsonův korelační koeficient)
df %>% 
  select(all_of(vars_reg)) %>% 
  cor() %>% 
  round(digits = 2)


# 6) Převod délky vztahu na roky + shrnující statistiky --------------------

# Pro interpretaci je často přirozenější pracovat s roky než měsíci
df <- df %>% 
  mutate(delka_vztahu_roky = delka_vztahu / 12)

# Shrnutí: průměr, směrodatná odchylka, min, max, šikmost a špičatost
#   – psych::skew() a psych::kurtosi() dávají rychlý vhled do tvaru rozdělení
df %>% 
  select(delka_vztahu_roky, spokojenost, alternativy, investice, zavazek) %>% 
  pivot_longer(
    everything(),
    names_to  = "variable",
    values_to = "value"
  ) %>% 
  group_by(variable) %>% 
  summarise(
    M    = mean(value),
    SD   = sd(value),
    Min  = min(value),
    Max  = max(value),
    skew = psych::skew(value),
    kurt = psych::kurtosi(value)
  )


# 7) Jednoduchý model: jen délka vztahu -----------------------------------

# Model 1: závazek ~ délka vztahu (v měsících)
fit_1 <- lm(zavazek ~ delka_vztahu, data = df)
summary(fit_1)

# Stejný model s délkou ve letech (koeficient je pak „na 1 rok“)
fit_1 <- lm(zavazek ~ delka_vztahu_roky, data = df)
summary(fit_1)


# 8) Plný model: investiční model + kontrola délky vztahu ------------------

# Model 2: závazek ~ délka vztahu + investice + spokojenost + alternativy
fit_2 <- lm(zavazek ~ delka_vztahu_roky +
              investice + spokojenost + alternativy, 
            data = df)
summary(fit_2)


# 9) Přírůstek R2 (kolik navíc vysvětlí složky investičního modelu?) -------

# R2 jednoduchého modelu a plného modelu
summary(fit_1)$r.squared
summary(fit_2)$r.squared

# Rozdíl R2 = přírůstek vysvětleného rozptylu při přidání investice,
# spokojenosti a alternativ do modelu, kde už je délka vztahu
summary(fit_2)$r.squared - summary(fit_1)$r.squared

# Formální test přírůstku pomocí anova():
#   H0: přidání nových prediktorů nezlepší model (přírůstek R2 = 0)
anova(fit_1, fit_2)


# 10) Standardizované beta koeficienty a semiparciální R2 ------------------

# Standardizované regresní koeficienty (z = 0, SD = 1)
#   – umožňují porovnávat sílu prediktorů mezi sebou
betaDelta::BetaDelta(fit_2, alpha = .05)

# Semiparciální R2 (unikátní podíl vysvětleného rozptylu pro každý prediktor)
effectsize::r2_semipartial(fit_2)

effectsize::r2_semipartial(fit_2) %>% 
  effectsize::interpret_r2_semipartial()


# 11) Základní diagnostické grafy lm --------------------------------------

# 1) Residuals vs. fitted --------------------------------------------------
plot(fit_2, which = 1, id.n = 10)
# Co graf ukazuje
#   Na ose X: predikované hodnoty (fitted).
#   Na ose Y: rezidua (chyby modelu).
# Jaký předpoklad ověřuje
#   Lineární vztah mezi Y a prediktory.
#   Homoskedasticitu = stejný rozptyl chyb při všech úrovních fitted.
# Jak to číst polopaticky
#   Body by měly tvořit náhodný oblak kolem čáry 0.
#   Neměl by být vidět žádný vzor, ohyb, „S“ tvar ani trychtýř.
# Co je problém
#   Zakřivený tvar (oblouk) → model není dostatečně lineární.
#   Trychtýřovitý tvar → heteroskedasticita.
#   Izolované extrémní body → potenciální outliery.


# 2) QQ-plot of residuals --------------------------------------------------
plot(fit_2, which = 2, id.n = 10)
# Co graf ukazuje
#   Porovnání empirických reziduí s teoretickou normální křivkou.
# Jaký předpoklad ověřuje
#   Normalitu reziduí (důležité pro přesné p‑hodnoty a intervaly spolehlivosti).
# Jak to číst polopaticky
#   Body by měly ležet přibližně na přímce – mírné odchylky nevadí.
# Co je problém
#   Výrazné prohnutí na koncích („heavy tails“), velké odchylky od přímky.

# Ještě rychlý histogram reziduí
fit_2 %>% 
  resid() %>% 
  hist(breaks = 25)

# 3) Scale-Location (Absolute residuals vs fitted) -------------------------
plot(fit_2, which = 3, id.n = 10)
# Co graf ukazuje
#   Absolutní (nebo odmocněné) rezidua vůči fitted hodnotám.
# Jaký předpoklad ověřuje
#   Homoskedasticitu = konstantní variabilitu reziduí.
# Jak to číst polopaticky
#   Trendová křivka by měla být zhruba vodorovná.
#   Body by měly mít podobný rozptyl v celé šíři fitted hodnot.
# Co je problém
#   Když křivka stoupá nebo klesá → heteroskedasticita.
#   Trychtýřovitý tvar (zúžení nebo rozšíření).


# 4) Cook's distances ------------------------------------------------------
plot(fit_2, which = 4, id.n = 10)
# Co graf ukazuje
#   Míru vlivu každého pozorování na odhadnuté koeficienty.
# Jaký předpoklad ověřuje
#   Žádné extrémně vlivné pozorování, které by výrazně ovlivnilo model.
# Jak to číst polopaticky
#   Cook’s D by měl být celkově nízký, žádný bod by neměl dramaticky vyčnívat.
# Co je problém
#   Cook’s D > 0.5 → podezřelé, Cook’s D > 1 → potenciálně vážné.


# 5) Residuals vs leverage -------------------------------------------------
plot(fit_2, which = 5, id.n = 10)
# Co graf ukazuje
#   Na ose X: leverage (jak izolovaný je bod v prostoru prediktorů).
#   Na ose Y: rezidua (jak moc se bod liší od predikce).
# Jaký předpoklad ověřuje
#   Stabilitu modelu a absenci vlivných pozorování.
# Jak to číst polopaticky
#   Nebezpečné jsou body vysoko/nízko (velká chyba) a zároveň vpravo (vysoká leverage).
# Co je problém
#   Body vpravo mimo Cookovy křivky → vlivné případy.


# 6) Cook's distance vs leverage ------------------------------------------
plot(fit_2, which = 6, id.n = 10)
# Co graf ukazuje
#   Kombinaci leverage a Cook’s distance.
# Jaký předpoklad ověřuje
#   Neexistenci případů, které mají současně vysokou leverage i vysoké Cook’s D.
# Jak to číst polopaticky
#   Body by měly být uprostřed a nízko; pravá‑horní oblast je nejproblematičtější.


# 12) DFbetas – vliv jednotlivých případů na koeficienty ------------------
# dfbeta měří, o kolik násobku standardních bych by se změnil koeficient β_j,
# kdybychom odstranili dané pozorování.
# Hodnoty kolem 0 → nevýznamné.
# |dfbeta| > 0.3 (u velkých vzorků) nebo > 1/sqrt(n) → vlivné pozorování.
betas <- dfbetas(fit_2) %>% 
  as_tibble() %>% 
  mutate(id = row_number())

betas_long <- betas %>% 
  pivot_longer(
    -id,
    names_to  = "predictor",
    values_to = "df_beta"
  ) 

# Boxploty dfbeta pro každý prediktor – hrubý přehled extrémů
betas_long %>% 
  ggplot(aes(x = predictor, y = df_beta)) +
  geom_boxplot()

# Výpis 5 nejvlivnějších případů pro každý prediktor
betas_long %>% 
  group_by(predictor) %>% 
  slice_max(abs(df_beta), n = 5) %>% 
  arrange(predictor, df_beta) %>% 
  print(n = Inf)


# 13) Funkce balíčku car – detailnější diagnostika ------------------------

# 1) Residual plots (vs predictor values) -------------------------
car::residualPlots(fit_2)
# Co dělá:
#   – kreslí rezidua na osu y a na osu x postupně jednotlivé prediktory
#     (a na konci i fitted hodnoty).
#   – přidá vodorovnou čáru v nule a hladkou křivku (loess).
# Interpretace:
#   – náhodný mrak kolem nuly + téměř rovná křivka → OK.
#   – oblouky, „S“ tvary → nelinerita vztahu.
#   – měnící se rozptyl bodů → náznak heteroskedasticity.

# 2) Component + residual plots (partial residual plots) ----------
car::crPlots(fit_2)
# Idea:
#   – chceme vidět vztah mezi Y a X_j po odečtení vlivu ostatních proměnných.
#   – osa x = X_j, osa y = parciální rezidua.
#   – přímka = lineární vztah podle modelu, hladká křivka = empirický tvar ve
#     vztahu k datům.
# Pokud se křivka ≈ přímka → lineární člen postačuje.
# Pokud je křivka výrazně zakřivená → uvažovat transformaci nebo nelineární model.

# 3) Added-variable (partial-regression) plots --------------------
car::avPlots(fit_2)
# Idea:
#   – „očistíme“ Y od vlivu ostatních prediktorů (rezidua Y ~ ostatní X),
#   – „očistíme“ X_j od vlivu ostatních prediktorů (rezidua X_j ~ ostatní X),
#   – kreslíme rezidua Y vs. rezidua X_j.
# Sklon přímky v tomto grafu = odhadnutý koeficient β_j.
# Užitečné pro posouzení unikátního příspěvku X_j a vlivných případů.

# Variance inflation factor – kontrola multikolinearity
car::vif(fit_2)

# Durbin-Watson test (autokorelace reziduí – důležité hlavně u časových řad)
car::durbinWatsonTest(fit_2)

# Přibližně
tibble(
  res = resid(fit_2),
  res_lagged = lag(res)
) %>% 
  cor(use = "pair")

# 14) broom – model jako tibble (výstupy pro tabulky, grafy) ---------------

# tidy() – koeficienty modelu v jedné tabulce + intervaly spolehlivosti
broom::tidy(fit_2, conf.int = TRUE, conf.level = 0.95)

# glance() – souhrnné statistiky modelu (R2, AIC, BIC, …)
broom::glance(fit_1)
broom::glance(fit_2)

# Srovnání fit_1 a fit_2 v jedné tabulce
bind_rows(
  m1 = broom::glance(fit_1),
  m2 = broom::glance(fit_2),
  .id = "model"
)


# augment() – přidá k datům predikce, rezidua, Cookovy vzdálenosti atd.
df_aug <- broom::augment(fit_2)
df_aug

# Výběr pozorování s nejvyšší Cookovou vzdáleností
df_aug %>% 
  slice_max(.cooksd, n = 10) %>% 
  print(width = Inf)

# Výběr pozorování s nejvyšším (absolutním) reziduem
df_aug %>% 
  slice_max(abs(.resid), n = 10) %>% 
  print(width = Inf)

# Histogram standardizovaných reziduí s teoretickou normální křivkou
df_aug %>% 
  ggplot(aes(.std.resid)) +
  geom_histogram(
    fill = "grey",
    color = "grey50",
    aes(y = after_stat(density))
  ) +
  geom_density(color = "blue", linetype = "11", linewidth = 1) +
  stat_function(fun = dnorm, color = "red", linewidth = 1)


# 15) Intervaly spolehlivosti a predikční intervaly -----------------------

# Vytvoříme mřížku hodnot délky vztahu, pro které chceme odhadnout
# očekávaný závazek (ostatní prediktory držíme na referenčních hodnotách).
new_data <- expand.grid(
  delka_vztahu_roky = seq(0.5, 6.5, by = 0.01),
  investice          = 3.5,
  spokojenost        = 5,
  alternativy        = 2.5
) %>% 
  as_tibble()

# Intervaly spolehlivosti (průměrná očekávaná hodnota Y)
ci <- broom::augment(fit_2,
                     newdata  = new_data,
                     interval = "confidence")
ci <- ci %>% 
  rename(ci_lower = .lower,
         ci_upper = .upper)

# Graf CI\ nci %>% 
ci %>% 
  ggplot(aes(x = delka_vztahu_roky, y = .fitted)) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              alpha = .1, fill = "blue") +
  geom_line(color = "blue", linewidth = 1) +
  scale_x_continuous(breaks = seq(0, 6, by = 1))

# Predikční intervaly (variabilita jednotlivých budoucích pozorování)
pi <- broom::augment(fit_2,
                     newdata  = new_data,
                     interval = "prediction")
pi <- pi %>% 
  rename(pi_lower = .lower,
         pi_upper = .upper)

# Spojení CI a PI do jednoho objektu
cpi <- ci %>% 
  left_join(pi)
cpi

# Graf CI + PI (bez empirických bodů)
cpi %>% 
  ggplot(aes(delka_vztahu_roky, .fitted)) +
  geom_ribbon(aes(ymin = pi_lower, ymax = pi_upper),
              fill = "pink", alpha = .5) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              fill = "blue", alpha = .3) +
  geom_line(color = "blue") +
  scale_x_continuous(breaks = seq(0, 6, by = 1))


# 16) Přidání empirických pozorování do grafu -----------------------------

# Varianta 1: původní predikce + rezidua (tj. skutečná Y)
cpi %>% 
  ggplot(aes(delka_vztahu_roky, .fitted)) +
  geom_ribbon(aes(ymin = pi_lower, ymax = pi_upper),
              fill = "pink", alpha = .5) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              fill = "blue", alpha = .3) +
  geom_line(color = "blue") +
  scale_x_continuous(breaks = seq(0, 6, by = 1)) +
  geom_point(
    data = df_aug,
    aes(y = .fitted + .resid)
  )


# 17) „Očištěná“ pozorování (adjusted values) -----------------------------

# 1) Predikce pro skutečné hodnoty prediktorů
pred_orig <- predict(fit_2)

# 2) Predikce pro „stejná“ pozorování, ale s referenčními hodnotami
#    investic, spokojenosti a alternativ (např. průměr nebo zvolená úroveň)
df_ref <- df %>% 
  mutate(
    investice   = 3.5,
    spokojenost = 5,
    alternativy = 2.5
  )

pred_ref <- predict(fit_2, newdata = df_ref)

# 3) Adjustovaná Y: skutečný závazek minus rozdíl mezi pred_orig a pred_ref
#    – tím odstraníme efekt rozdílů v investicích/spokojenosti/alternativách
#      a necháme variabilitu spojenou hlavně s délkou vztahu.
#    - chceme tím odhadnout, jaký by asi byla pozorovaná hodnota závazků
#      v  závislosti na původní délce vztahu,  
#      ale kdyby investice, spokojenost a  alternativy byly drženy 
#      na konstantní úrovni (viz df_ref)
df <- df %>% 
  mutate(
    y_adj = zavazek - (pred_orig - pred_ref)
  )

# Graf CI + PI + adjustovaná pozorování (vše vztažené k referenčním hodnotám)
cpi %>% 
  ggplot(aes(delka_vztahu_roky, .fitted)) +
  geom_ribbon(aes(ymin = pi_lower, ymax = pi_upper),
              fill = "pink", alpha = .5) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              fill = "blue", alpha = .3) +
  geom_line(color = "blue") +
  scale_x_continuous(breaks = seq(0, 6, by = 1)) +
  geom_point(
    data = df,
    aes(y = y_adj)
  )


# 18) Rychlá souhrnná diagnostika pomocí performance::check_model --------
check_model(fit_2)  # přehledná mřížka diagnostických grafů


# 19) Analýza senzitivity ------------------------------------------------
fit_3 <- lm(zavazek ~ delka_vztahu_roky +
              investice + spokojenost + alternativy, 
            data = df,
            subset = -c(64, 74))
summary(fit_2)
summary(fit_3)


car::avPlots(fit_3)
car::avPlots(fit_2)







