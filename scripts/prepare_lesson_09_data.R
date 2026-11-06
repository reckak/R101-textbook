# Příprava veřejného výukového výřezu pro devátou lekci.
# Spouští se ručně z kořene projektu: Rscript --vanilla scripts/prepare_lesson_09_data.R
# Vyžaduje místní soubor data/raw/ZZ_ckrvliry.sav, který se do Gitu neukládá.
# Není součástí renderu ani studentského postupu.

library(haven)

stopifnot(isTRUE(l10n_info()[["UTF-8"]]))

source_file <- "data/raw/ZZ_ckrvliry.sav"
target_file <- "data/clean/vztahy_zavazek.rds"

# Bez popisků a formátů SPSS: výsledkem mají být obyčejné číselné sloupce a faktory.
original <- zap_widths(zap_formats(zap_label(zap_labels(read_sav(source_file)))))
stopifnot(nrow(original) == 124L, ncol(original) == 21L, !anyNA(original))
# Sloupec národnosti má v souboru název s diakritikou, proto jej vybíráme podle pozice.
stopifnot(grepl("^n.rodnos", names(original)[2]))

ano_ne <- function(x) {
  stopifnot(all(x %in% c(1, 2)))
  factor(x, levels = c(1, 2), labels = c("ano", "ne"))
}

vyrez <- data.frame(
  id                  = seq_len(nrow(original)),
  pohlavi             = factor(original$pohlavie, levels = c(1, 2),
                               labels = c("muž", "žena")),
  narodnost           = factor(original[[2]], levels = c(1, 2),
                               labels = c("slovenská", "česká")),
  vek_roky            = original$vek,
  vazny_vztah         = ano_ne(original$vazny_vztah),
  spolecne_bydleni    = ano_ne(original$spolubyvanie),
  zasnoubeni          = ano_ne(original$zasnuveny),
  delka_vztahu_mesice = original$cas_mesiace,
  spokojenost         = original$spokojnost,
  alternativy         = original$alternativy,
  investice           = original$investicie,
  zavazek             = original$zavazok
)
vyrez <- tibble::as_tibble(vyrez)
stopifnot(!anyNA(vyrez),
          all(vapply(vyrez, function(x) is.null(attr(x, "label")) &&
                       is.null(attr(x, "format.spss")), logical(1))))

dir.create(dirname(target_file), recursive = TRUE, showWarnings = FALSE)
saveRDS(vyrez, target_file)

# Kontrola po uložení: stejné hodnoty jako v originálu, rozsah škál 0–6.
check <- readRDS(target_file)
stopifnot(
  identical(check, vyrez),
  identical(as.integer(check$pohlavi), as.integer(original$pohlavie)),
  identical(as.integer(check$narodnost), as.integer(original[[2]])),
  identical(check$delka_vztahu_mesice, original$cas_mesiace),
  identical(check$zavazek, original$zavazok),
  identical(check$investice, original$investicie),
  all(vapply(check[c("spokojenost", "alternativy", "investice", "zavazek")],
             function(x) all(x >= 0 & x <= 6), logical(1)))
)
cat("Written", target_file, "with", nrow(check), "rows and", ncol(check), "columns.\n")
