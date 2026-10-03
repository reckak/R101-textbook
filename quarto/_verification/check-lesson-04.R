# Run from the project root in a separate Rscript --vanilla process.
lines <- readLines("quarto/lekce_04.qmd", encoding = "UTF-8")
starts <- which(grepl("^```\\{r\\}", lines))
chunks <- lapply(starts, function(start) {
  end <- start + which(lines[(start + 1):length(lines)] == "```")[1]
  text <- lines[(start + 1):(end - 1)]
  label <- sub("#\\| label: ", "", text[grepl("^#\\| label:", text)])
  stopifnot(length(label) == 1L)
  list(label = label, code = text[!grepl("^#\\|", text)],
       skip = any(text == "#| eval: false"),
       expected_error = any(text == "#| error: true"))
})
names(chunks) <- vapply(chunks, function(chunk) chunk$label, character(1))
stopifnot(!anyDuplicated(names(chunks)))
expected_errors <- c("l04-chyba-indexy" = "negative subscripts",
                     "l04-chyba-tibble" = "compatible sizes")
expected_warnings <- c("l04-varovani-prevod" = "NAs introduced by coercion",
                       "l04-varovani-recyklace" = "not a multiple",
                       "l04-reseni-recyklace" = "not a multiple")
stopifnot(setequal(names(chunks)[vapply(chunks, function(x) x$expected_error, logical(1))],
                  names(expected_errors)))
stopifnot(identical(names(chunks)[vapply(chunks, function(x) x$skip, logical(1))],
                    "l04-instalace"))

grDevices::pdf(file = NULL)
for (chunk in chunks) {
  if (chunk$skip) next
  cat("\nCHUNK:", chunk$label, "\n")
  seen_warnings <- character()
  error <- tryCatch(withCallingHandlers({
    for (expression in parse(text = chunk$code)) {
      value <- withVisible(eval(expression, envir = .GlobalEnv))
      if (value$visible) print(value$value)
    }
    NULL
  }, warning = function(w) {
    seen_warnings <<- c(seen_warnings, conditionMessage(w))
    # Record without muffling: warnings must remain visible in verification logs.
  }), error = identity)
  if (chunk$expected_error) {
    stopifnot(inherits(error, "error"),
              grepl(expected_errors[[chunk$label]], conditionMessage(error)))
    cat("EXPECTED ERROR:", conditionMessage(error), "\n")
  } else if (inherits(error, "error")) {
    stop("Unexpected error in ", chunk$label, ": ", conditionMessage(error))
  }
  # A known local R/package build-version mismatch is allowed only during setup.
  relevant <- if (chunk$label == "l04-balicky") {
    seen_warnings[!grepl("was built under R version", seen_warnings, fixed = TRUE)]
  } else seen_warnings
  if (chunk$label %in% names(expected_warnings)) {
    stopifnot(length(relevant) == 1L,
              grepl(expected_warnings[[chunk$label]], relevant))
  } else if (length(relevant)) {
    stop("Unexpected warning in ", chunk$label, ": ", paste(relevant, collapse = "; "))
  }
}
grDevices::dev.off()

# Check interpretation, selection identities and denominators independently.
stopifnot(identical(typeof(skore), "double"), length(skore) == 5L,
          identical(vyssi_skore, c(FALSE, TRUE, FALSE, TRUE, TRUE)),
          length(body) == 11L, is.integer(body), is.logical(splneno),
          near(odmocnina_na_druhou, 2), near(trojka, 3),
          abs(odmocnina_na_druhou - 2) < 1e-14,
          abs(trojka - 3) < 1e-14,
          identical(prevedene_skore, c(12, NA, 18)),
          identical(c(TRUE, 0L, 2.5, "jedna"), c("TRUE", "0", "2.5", "jedna")),
          sum(dokonceno, na.rm = TRUE) == 3L,
          sum(!is.na(dokonceno)) == 4L,
          mean(dokonceno, na.rm = TRUE) == 0.75)
stopifnot(identical(po - pred, c(-3, 0, -5)),
          identical(1:10 + 1:2, c(2L, 4L, 4L, 6L, 6L, 8L, 8L, 10L, 10L, 12L)),
          identical(hodnoty[hodnoty > 5], c(10, NA, 8, NA)),
          identical(hodnoty[!is.na(hodnoty) & hodnoty > 5], c(10, 8)),
          identical(names(casy_ms[!is.na(casy_ms) & casy_ms > 400]), c("P01", "P03")),
          identical(skore_osob, skore_dalsi),
          identical(skore_osob, purrr::set_names(c(12, 18, 9), c("P01", "P02", "P03"))))
stopifnot(is.factor(narocnost), !is.ordered(narocnost), is.ordered(narocnost_ord),
          identical(as.character(narocnost), narocnost_text),
          identical(as.integer(narocnost), c(1L, 3L, 3L, 2L, 1L, 1L, 2L)),
          identical(as.integer(table(narocnost)), c(3L, 2L, 2L)),
          sum(is.na(neuplne_kategorie)) == 1L,
          identical(as.numeric(faktor_cisla), c(1, 2, 1)),
          identical(as.numeric(as.character(faktor_cisla)), c(10, 20, 10)))
plot_data <- ggplot_build(graf_narocnosti)$data[[1]]
stopifnot(identical(as.numeric(plot_data$count), c(3, 2, 2)),
          identical(graf_narocnosti$data$narocnost, narocnost))
stopifnot(is.list(zaznam["skore"]), is.double(zaznam[["skore"]]),
          identical(zaznam[["skore"]], zaznam$skore),
          length(zaznam) == 5L, near(zaznam$prumer, 38 / 3),
          identical(studie[[c("popis", "nazev")]], studie$popis$nazev),
          ucastnik$prumer_bodu == 12)

stopifnot(identical(dim(ucastnici), c(6L, 5L)), length(ucastnici) == 5L,
          identical(ucastnici[, "skore"], ucastnici[["skore"]]),
          identical(ucastnici["skore"], ucastnici[, "skore", drop = FALSE]),
          nrow(ucastnici[ucastnici$vek > 25, ]) == 4L,
          identical(starsi_base$id, c("P02", "P04", "P06")),
          identical(starsi_base$skore, c(18, 25, 16)),
          identical(as_tibble(starsi_base), as_tibble(starsi_dplyr)),
          identical(as_tibble(vyber_base), as_tibble(vyber_dplyr)),
          identical(as_tibble(subset(ucastnici, vek > 25, select = c(id, skore))),
                    as_tibble(starsi_dplyr)),
          identical(as.data.frame(ucastnici_tbl), ucastnici),
          inherits(ucastnici_tbl[, "skore"], "tbl_df"),
          is.double(ucastnici_tbl[["skore"]]),
          mean(ucastnici_tbl$vek, na.rm = TRUE) == 26.4,
          nrow(velka_tabulka) == 10000L)
stopifnot(identical(pouzita_data$id, c("P01", "P02", "P04", "P05", "P06", "P07")),
          nrow(vstup) == 8L, sum(is.na(pripravena_data$skore)) == 1L,
          identical(souhrn_skupin$pocet, c(3L, 3L)),
          isTRUE(all.equal(souhrn_skupin$prumer, c(41 / 3, 59 / 3))),
          podil_alespon_18 == 0.5,
          identical(vysledek[["souhrn"]], souhrn_skupin))
cat("PASS: all lesson-04 chunks, expected errors and warnings, factor codes,\n",
    "list and table selection, base/dplyr equivalence, plot and denominators.\n")

# The final solution must also run without objects from this lesson.
standalone <- "quarto/_verification/standalone-solution.R"
writeLines(enc2utf8(c(chunks[["l04-reseni-samostatne"]]$code,
                     "stopifnot(nrow(vysledek$data) == 6L, podil_alespon_18 == 0.5)")),
           standalone, useBytes = TRUE)
status <- system2(
  file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"),
  c("--vanilla", standalone),
  stdout = "quarto/_verification/standalone-04.log",
  stderr = "quarto/_verification/standalone-04-errors.log"
)
stopifnot(status == 0L)
cat("PASS: final lesson-04 solution in a separate clean R process.\n")
print(sessionInfo())
