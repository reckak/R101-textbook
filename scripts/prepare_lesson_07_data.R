# Příprava veřejného výukového výřezu pro sedmou lekci.
# Spouští se ručně z kořene projektu: Rscript --vanilla scripts/prepare_lesson_07_data.R
# Vyžaduje místní původní export data/raw/long2.sav, který se do Gitu neukládá.
# Není součástí renderu ani studentského postupu.

library(haven)

source_file <- "data/raw/long2.sav"
target_file <- "data/raw/monitoring_teaching.sav"
allowed <- c("id", "pohlavi", "kohorta", "vekr", sprintf("c%02d_99", 1:9))

original <- read_sav(source_file)
stopifnot(all(allowed %in% names(original)))

teaching <- original[allowed]
write_sav(teaching, target_file)

# Round trip: stejné sloupce, hodnoty, popisky proměnných i hodnot.
check <- read_sav(target_file)
stopifnot(identical(names(check), allowed), nrow(check) == nrow(original))
for (column in allowed) {
  stopifnot(
    identical(as.vector(zap_labels(check[[column]])),
              as.vector(zap_labels(original[[column]]))),
    identical(attr(check[[column]], "label"), attr(original[[column]], "label")),
    identical(attr(check[[column]], "labels"), attr(original[[column]], "labels"))
  )
}
# Chybně zapsaná kohorta zůstává ve výřezu záměrně, lekce ji opravuje.
stopifnot(sum(check$kohorta == 66, na.rm = TRUE) == 1L)
cat("Written", target_file, "with", nrow(check), "rows and", ncol(check), "columns.\n")
