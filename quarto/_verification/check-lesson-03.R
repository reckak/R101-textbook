# Run from the project root; called by check-r.R in a separate R session.
lines <- readLines("quarto/lekce_03.qmd", encoding = "UTF-8")
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

expected_errors <- c("l03-chyba-rovnitko", "l03-chyba-select")
stopifnot(setequal(names(chunks)[vapply(chunks, function(x) x$expected_error, logical(1))],
                  expected_errors))
grDevices::pdf(file = NULL)
for (chunk in chunks) {
  if (chunk$skip) next
  cat("\nCHUNK:", chunk$label, "\n")
  error <- tryCatch({
    for (expression in parse(text = chunk$code)) {
      value <- withVisible(eval(expression, envir = .GlobalEnv))
      if (value$visible) print(value$value)
    }
    NULL
  }, error = identity)
  if (chunk$expected_error) {
    stopifnot(inherits(error, "error"))
    message <- conditionMessage(error)
    stopifnot(if (chunk$label == "l03-chyba-rovnitko") grepl("named input", message)
              else grepl("arr_delay", message))
    cat("EXPECTED ERROR:", message, "\n")
  } else if (inherits(error, "error")) {
    stop("Unexpected error in ", chunk$label, ": ", conditionMessage(error))
  }
}
grDevices::dev.off()

# Check numerical claims and important analytical choices against the actual data.
stopifnot(identical(dim(flights), c(336776L, 19L)),
          sum(is.na(flights$dep_delay)) == 8255L,
          sum(is.na(flights$arr_delay)) == 9430L,
          nrow(zpozdene_lety) == 9723L, nrow(leden_prvni) == 842L,
          nrow(dohnane_lety) == 1844L,
          sum(dohnane_lety$dep_delay == 60) == 25L,
          nrow(trasy) == 224L,
          nrow(distinct(flights, year, month, day)) == 365L,
          max(flights$dep_delay, na.rm = TRUE) == 1301)
stopifnot(all(houston_zpozdene$dest %in% c("IAH", "HOU")),
          all(houston_zpozdene$arr_delay >= 120),
          identical(as.integer(table(houston_zpozdene$dest)), c(58L, 162L)))
stopifnot(isTRUE(all.equal(celkem$prumer_min, mean(flights$dep_delay, na.rm = TRUE))),
          round(celkem$prumer_min, 2) == 12.64,
          celkem$pocet_platnych == 328521L,
          round(mesicni_souhrn$prumer_min[mesicni_souhrn$month == 7], 1) == 21.7,
          round(mesicni_souhrn$prumer_min[mesicni_souhrn$month == 11], 1) == 5.4,
          !is_grouped_df(mesicni_souhrn))
stopifnot(identical(lety_vypocty$zmena_zpozdeni,
                   flights$arr_delay - flights$dep_delay),
          isTRUE(all.equal(lety_vypocty$rychlost_kmh,
                           (flights$distance * 1.609344) / (flights$air_time / 60))))
stopifnot(nrow(maxima_odletu) == 3L, nrow(kontrolni_vyber) == 12L,
          n_distinct(kontrolni_vyber$month) == 12L,
          is.na(kontrolni_vyber$dep_delay[kontrolni_vyber$month == 6]),
          nrow(slice_max(shody, skore, n = 1)) == 2L,
          nrow(slice_max(shody, skore, n = 1, with_ties = FALSE)) == 1L)
stopifnot(hodinovy_souhrn$pocet_platnych[hodinovy_souhrn$hour == 1] == 0L,
          is.nan(hodinovy_souhrn$prumer_min[hodinovy_souhrn$hour == 1]),
          hodinovy_souhrn$hour[which.max(hodinovy_souhrn$prumer_min)] == 19)
stopifnot(nrow(neshody_casu) == 1207L,
          all(neshody_casu$dep_delay - neshody_casu$rozdil_hodin == 1440))
stopifnot(identical(souhrn_zmen$pocet_dvojic, c(3L, 4L)),
          isTRUE(all.equal(souhrn_zmen$prumer_zmeny, c(-10 / 3, -0.5))))
bar_heights <- ggplot_build(graf_zmen)$data[[1]]$ymin
stopifnot(isTRUE(all.equal(bar_heights, c(-10 / 3, -0.5))))

# Equivalent forms retained from week_03.R: filters, selection and grouping.
stopifnot(identical(filter(flights, month == 1, day == 1),
                    filter(flights, month == 1 & day == 1)),
          identical(filter(flights, month %in% c(1, 2, 3)),
                    filter(flights, month == 1 | month == 2 | month == 3)),
          identical(select(flights, dep_time, dep_delay, arr_time, arr_delay),
                    select(flights, starts_with("dep_"), starts_with("arr_"))))
grouped_result <- mereni |>
  group_by(skupina, sezeni) |>
  summarise(prumer = mean(skore), .groups = "drop") |>
  arrange(skupina, sezeni)
by_result <- mereni |>
  summarise(prumer = mean(skore), .by = c(skupina, sezeni)) |>
  arrange(skupina, sezeni)
stopifnot(isTRUE(all.equal(grouped_result, by_result)))
# The source comment about a trailing comma is false for mutate's dynamic dots.
stopifnot(identical(tibble(x = 1:2) |> mutate(y = x + 1,),
                    tibble(x = 1:2) |> mutate(y = x + 1)))
cat("PASS: all executable lesson-03 chunks, expected errors, numerical claims,\n",
    "missing-data denominators, unit conversion, grouping and equivalent source forms.\n")

# The final solution must also work without earlier objects from lesson 03 itself.
standalone <- "quarto/_verification/standalone-solution.R"
writeLines(enc2utf8(c("grDevices::pdf(file = NULL)",
                     chunks[["fig-l03-reseni-samostatne"]]$code,
                     "stopifnot(nrow(souhrn_zmen) == 2L)",
                     "grDevices::dev.off()")), standalone, useBytes = TRUE)
status <- system2(
  file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"),
  c("--vanilla", standalone),
  stdout = "quarto/_verification/standalone.log",
  stderr = "quarto/_verification/standalone-errors.log"
)
stopifnot(status == 0L)
cat("PASS: standalone psychological example in a separate clean R process.\n")
print(sessionInfo())
