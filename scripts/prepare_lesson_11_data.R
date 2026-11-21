# Příprava veřejného výukového souboru pro jedenáctou lekci (ANOVA).
# Spouští se ručně z kořene projektu: Rscript --vanilla scripts/prepare_lesson_11_data.R
# Vyžaduje místní soubor data/raw/bicyclists2025.jasp, který se do Gitu neukládá,
# a balíčky DBI, RSQLite, jsonlite a tibble (viz scripts/read_jasp.R).
# Není součástí renderu ani studentského postupu.

stopifnot(isTRUE(l10n_info()[["UTF-8"]]))

source("scripts/read_jasp.R", encoding = "UTF-8")

source_file <- "data/raw/bicyclists2025.jasp"
target_file <- "data/clean/cykliste.rds"

original <- read_jasp(source_file)
stopifnot(nrow(original) == 2355L, ncol(original) == 9L,
          !anyDuplicated(original$id),
          sum(is.na(original)) == 14L, sum(is.na(original$color)) == 14L)

# Pořadí podle čísla události: řádky pak tvoří souvislé bloky jízd se stejnými podmínkami.
original <- original[order(original$id), ]

# Překlad úrovní: kontroluje, že zdroj obsahuje přesně očekávané anglické kategorie.
prelozit <- function(x, slovnik) {
  stopifnot(identical(levels(x), names(slovnik)))
  factor(unname(slovnik[as.character(x)]), levels = unname(slovnik))
}

cykliste <- data.frame(
  id = as.integer(original$id),
  vozidlo = prelozit(original$vehicle, c(
    "Ordinary car"        = "osobní auto",
    # Zdroj uvádí "Large Goods Vehicle"; podle Walkera (2007) jde o kategorii LGV,
    # tedy lehká užitková vozidla a minibusy.
    "Large Goods Vehicle" = "dodávka",
    "SUV/pickup"          = "SUV/pick-up",
    "Bus"                 = "autobus",
    "Heavy Goods Vehicle" = "nákladní vozidlo",
    "Taxi"                = "taxi",
    "Powered Two Wheeler" = "motocykl"
  )),
  barva = prelozit(original$color, c(
    "Blue" = "modrá", "Red" = "červená", "Silver/grey" = "stříbrná/šedá",
    "White" = "bílá", "Black" = "černá", "Green" = "zelená", "Other" = "jiná"
  )),
  ulice = prelozit(original$street, c(
    "One-way, one lane"    = "jednosměrná, jeden pruh",
    "one-way, two lanes"   = "jednosměrná, dva pruhy",
    "regular, urban"       = "městská ulice",
    "regular, residential" = "rezidenční ulice",
    "regular, main road"   = "hlavní silnice",
    "rural"                = "silnice mimo město"
  )),
  vzdalenost_predjeti = as.numeric(original$pass_distance),
  helma = prelozit(original$helmet, c("No" = "bez helmy", "Yes" = "s helmou")),
  # V JASP je proměnná ordinální; ve výukovém souboru je obyčejný (neuspořádaný) faktor,
  # aby lm() použilo indikátorové proměnné, nikoli polynomické kontrasty.
  okraj = prelozit(factor(as.character(original$kerb), levels = levels(original$kerb)), c(
    "0.25" = "0,25", "0.5" = "0,50", "0.75" = "0,75", "1" = "1,00", "1.25" = "1,25"
  )),
  cyklopruh = prelozit(original$bikelane, c("No" = "ne", "Yes" = "ano")),
  mesto = prelozit(original$city, c("Salisbury" = "Salisbury", "Bristol" = "Bristol"))
)
cykliste <- tibble::as_tibble(cykliste)

# Bez metadat JASP: žádné popisky ani místní cesty k souborům.
stopifnot(
  is.null(attr(cykliste, "jasp")),
  all(vapply(cykliste, function(x) is.null(attr(x, "label")) &&
               is.null(attr(x, "jasp_type")) && is.null(attr(x, "na_values")), logical(1))),
  !is.ordered(cykliste$okraj)
)

dir.create(dirname(target_file), recursive = TRUE, showWarnings = FALSE)
saveRDS(cykliste, target_file)

# Kontrola po uložení: stejné hodnoty a kódy kategorií jako ve zdroji, řádky podle id.
check <- readRDS(target_file)
stopifnot(
  identical(check, cykliste),
  !is.unsorted(check$id),
  identical(check$id, as.integer(original$id)),
  identical(check$vzdalenost_predjeti, as.numeric(original$pass_distance)),
  all(check$vzdalenost_predjeti > 0),
  identical(as.integer(check$vozidlo), as.integer(original$vehicle)),
  identical(as.integer(check$barva), as.integer(original$color)),
  identical(as.integer(check$ulice), as.integer(original$street)),
  identical(as.integer(check$helma), as.integer(original$helmet)),
  identical(as.integer(check$okraj), as.integer(original$kerb)),
  identical(as.integer(check$cyklopruh), as.integer(original$bikelane)),
  identical(as.integer(check$mesto), as.integer(original$city)),
  identical(unname(c(table(check$helma, check$okraj))),
            c(426L, 244L, 270L, 275L, 153L, 186L, 197L, 272L, 160L, 172L))
)
cat("Written", target_file, "with", nrow(check), "rows and", ncol(check), "columns.\n")
