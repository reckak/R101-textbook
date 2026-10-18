# Run from the project root in a separate Rscript --vanilla process.
lines <- readLines("quarto/lekce_06.qmd", encoding = "UTF-8")
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
expected_errors <- c("l06-chyba-rozsah" = "NA/NaN argument")
# Every warning of a listed chunk must match its pattern; the count is checked too.
expected_warnings <- list("l06-alfa-pred" = list("negatively correlated", 1L),
                          "fig-skory-bodovy" = list("Removed 6 rows", 1L),
                          "fig-skory-limits" = list("outside the scale range", 2L))
stopifnot(setequal(names(chunks)[vapply(chunks, function(x) x$expected_error, logical(1))],
                   names(expected_errors)))
stopifnot(identical(names(chunks)[vapply(chunks, function(x) x$skip, logical(1))],
                    c("l06-instalace", "l06-url-rds", "l06-url-download")))

grDevices::pdf(file = NULL)
for (chunk in chunks) {
  if (chunk$skip) next
  cat("\nCHUNK:", chunk$label, "\n")
  seen_warnings <- character()
  error <- tryCatch(withCallingHandlers({
    for (expression in parse(text = chunk$code)) {
      value <- withVisible(eval(expression, envir = .GlobalEnv))
      # Printing ggplot objects builds and draws them, so plot warnings are checked too.
      if (value$visible) print(value$value)
    }
    NULL
  }, warning = function(w) {
    seen_warnings <<- c(seen_warnings, conditionMessage(w))
    invokeRestart("muffleWarning")
  }), error = identity)
  if (chunk$expected_error) {
    stopifnot(inherits(error, "error"),
              grepl(expected_errors[[chunk$label]], conditionMessage(error), fixed = TRUE))
    cat("EXPECTED ERROR:", conditionMessage(error), "\n")
  } else if (inherits(error, "error")) {
    stop("Unexpected error in ", chunk$label, ": ", conditionMessage(error))
  }
  # A known local R/package build-version mismatch is allowed only when packages load.
  relevant <- if (chunk$label %in% c("l06-nacteni", "l06-reseni-samostatne")) {
    seen_warnings[!grepl("was built under R version", seen_warnings, fixed = TRUE)]
  } else seen_warnings
  if (chunk$label %in% names(expected_warnings)) {
    expected <- expected_warnings[[chunk$label]]
    cat("EXPECTED WARNINGS:", relevant, sep = "\n  ")
    stopifnot(length(relevant) == expected[[2]],
              all(grepl(expected[[1]], relevant, fixed = TRUE)))
  } else if (length(relevant)) {
    stop("Unexpected warning in ", chunk$label, ": ", paste(relevant, collapse = "; "))
  }
}
grDevices::dev.off()

near2 <- function(x, value) isTRUE(abs(x - value) < 0.005)
plot_from <- function(label) eval(parse(text = chunks[[label]]$code), envir = .GlobalEnv)

# Data, labels and reverse-scoring described in the text.
stopifnot(identical(dim(hs), c(172L, 34L)), inherits(hs$help_02, "haven_labelled"),
          is.factor(hs$gender),
          identical(rev_help, c("help_02", "help_04", "help_08", "help_09", "help_10")),
          length(rev_emo) == 11L,
          identical(as.integer(table(hs$help_02)), c(110L, 31L, 17L, 7L)),
          identical(as.integer(table(hs_kontrola$help_04, hs_kontrola$help_04_r)[cbind(1:4, 4:1)]),
                    c(10L, 38L, 60L, 59L)),
          near2(alfa_pred$total$raw_alpha, -0.07), near2(alfa_emo$total$raw_alpha, 0.92))
# Recoding drops value and variable labels; untouched items keep them.
stopifnot(inherits(hs_rec$help_01, "haven_labelled"), !is.null(labelled::var_label(hs_rec$help_01)),
          identical(class(hs_rec$help_02), "numeric"), is.null(labelled::var_label(hs_rec$help_02)),
          identical(class(hs_kontrola$help_02_r), "numeric"),
          inherits(hs_kontrola$help_02, "haven_labelled"))
alfa_help <- psych::alpha(dplyr::select(hs_skory, dplyr::starts_with("help_")))
stopifnot(near2(alfa_help$total$raw_alpha, 0.82),
          near2(alfa_help$alpha.drop["help_04", "raw_alpha"], 0.84),
          near2(alfa_help$item.stats["help_04", "r.drop"], 0.19))

# Scores, rowwise() versus group_by(id), missing-data rule and analysed pairs.
scores_only <- hs_skory[setdiff(names(hs_skory), c("z_emo", "z_help"))]
stopifnot(nrow(hs) == dplyr::n_distinct(hs$id),
          identical(skory_podle_id$tot_help_id, skory_podle_id$tot_help),
          identical(as.integer(table(hs_rec$n_miss_help)), c(123L, 40L, 7L, 2L)),
          identical(as.integer(table(hs_emo_skor$n_miss_emo)), c(101L, 53L, 14L, 4L)),
          sum(!is.na(hs_skory$tot_help)) == 170L, sum(!is.na(hs_skory$tot_emo)) == 168L,
          nrow(hs_dvojice) == 166L,
          identical(tidyr::drop_na(scores_only, tot_emo, tot_help)$id, hs_dvojice$id),
          nrow(tidyr::drop_na(scores_only)) == 58L,
          near2(mean(hs_skory$tot_help, na.rm = TRUE), 3.00),
          near2(sd(hs_skory$tot_help, na.rm = TRUE), 0.555),
          near2(mean(hs_skory$tot_emo, na.rm = TRUE), 3.61),
          identical(hs_rec$tot_help, hs_skory$tot_help),
          identical(hs_emo_skor$tot_emo, hs_skory$tot_emo),
          sum(hs_skory$tot_help == 3, na.rm = TRUE) == 24L)
# The common mean without rowwise() is one value for everybody.
one_mean <- mean(as.matrix(dplyr::select(hs_rec, help_01:help_10)), na.rm = TRUE)
stopifnot(near2(one_mean, 3.00))

# Zooming: limits refit the line inside 2.5-3.5, coord_cartesian() keeps the full fit.
slope <- function(plot, layer = 2) {
  line <- suppressWarnings(ggplot2::layer_data(plot, layer))
  line <- line[order(line$x), ]
  (line$y[nrow(line)] - line$y[1]) / (line$x[nrow(line)] - line$x[1])
}
full_fit <- lm(tot_help ~ tot_emo, data = hs_dvojice)
inside <- dplyr::filter(hs_dvojice, tot_emo >= 2.5, tot_emo <= 3.5)
limits_slope <- slope(plot_from("fig-skory-limits"))
stopifnot(nrow(inside) == 59L,
          near2(limits_slope, coef(lm(tot_help ~ tot_emo, inside))[[2]]),
          limits_slope < 0,
          near2(slope(plot_from("fig-skory-coord")), coef(full_fit)[[2]]),
          near2(coef(full_fit)[[2]], 0.20))
# Both trend layers of the comparison carry their own legend colour.
comparison <- ggplot2::ggplot_build(plot_from("fig-skory-porovnani"))$data
stopifnot(identical(unique(comparison[[2]]$colour), "red"),
          identical(unique(comparison[[3]]$colour), "blue"))

# Distributions and Q-Q bands.
stopifnot(near2(min(hs_skory$z_help, na.rm = TRUE), -3.41),
          near2(max(hs_skory$z_help, na.rm = TRUE), 1.61),
          near2(min(hs_skory$z_emo, na.rm = TRUE), -2.63),
          near2(max(hs_skory$z_emo, na.rm = TRUE), 2.25))
# plot_from() reruns set.seed(), so the simulated "ts" band is identical each time.
# Points below/above a band, split into the lower and upper half of the x axis.
outside <- function(data, band_layer, point_layer) {
  band <- data[[band_layer]][order(data[[band_layer]]$x), ]
  points <- data[[point_layer]][order(data[[point_layer]]$x), ]
  left <- points$x < 3
  c(low = sum(points$y < band$ymin), high = sum(points$y > band$ymax),
    low_left = sum(points$y < band$ymin & left), low_right = sum(points$y < band$ymin & !left),
    high_at_3 = sum(points$y > band$ymax & points$y == 3))
}
pasy_a <- ggplot2::ggplot_build(plot_from("fig-skory-qqplotr-pasy"))$data
pasy_b <- ggplot2::ggplot_build(plot_from("fig-skory-qqplotr-pasy"))$data
stopifnot(identical(pasy_a[[2]][c("ymin", "ymax")], pasy_b[[2]][c("ymin", "ymax")]))
pointwise_out <- outside(pasy_a, 1, 4)
ts_out <- outside(pasy_a, 2, 4)
help_band <- outside(ggplot2::ggplot_build(plot_from("fig-skory-qqplotr-help"))$data, 1, 3)
emo_out <- outside(ggplot2::ggplot_build(plot_from("fig-skory-reseni-qq-emo"))$data, 1, 3)
cat("Q-Q points outside: pointwise", pointwise_out, "| ts", ts_out, "| default", help_band,
    "| emo ts", emo_out, "\n")
stopifnot(pointwise_out[["low_left"]] == 31L, pointwise_out[["low_right"]] == 2L,
          pointwise_out[["high"]] == 0L,
          ts_out[["low_left"]] == 11L, ts_out[["low_right"]] == 0L,
          ts_out[["high"]] == ts_out[["high_at_3"]], ts_out[["high"]] > 0L,
          identical(help_band, pointwise_out), sum(emo_out[c("low", "high")]) == 0L,
          sum(hs_skory$tot_help == 3, na.rm = TRUE) == 24L)
# The text says the "ks" and "ell" simultaneous bands would contain the lowest scores.
for (band_type in c("ks", "ell")) {
  other <- ggplot2::ggplot(hs_skory, ggplot2::aes(sample = tot_help)) +
    qqplotr::stat_qq_band(bandType = band_type) + qqplotr::stat_qq_line() + qqplotr::stat_qq_point()
  stopifnot(outside(ggplot2::ggplot_build(other)$data, 1, 3)[["low_left"]] == 0L)
}
stopifnot(shapiro.test(hs_skory$tot_help)$p.value < 0.001)

# The source script's scoring (with its own %>% style and RDS inputs) gives identical scores.
source_lines <- readLines("scripts/week_06.R", encoding = "UTF-8")[1:307]
source_lines <- source_lines[!grepl("^library\\(rstatix\\)", source_lines)]
source_lines <- gsub("data/help_seeking_", "data/clean/help_seeking_", source_lines, fixed = TRUE)
source_env <- new.env()
source_errors <- 0L
for (expression in parse(text = source_lines)) {
  tryCatch(suppressWarnings(eval(expression, envir = source_env)),
           error = function(e) source_errors <<- source_errors + 1L)
}
stopifnot(source_errors == 1L,
          identical(as.numeric(source_env$hs_rec$tot_help), hs_skory$tot_help),
          identical(as.numeric(source_env$hs_rec$tot_emo), hs_skory$tot_emo),
          identical(source_env$hs_rec$id, hs_skory$id))

# Final task values used in the interpretation.
stopifnot(sum(!is.na(dotaznik$age)) == 167L, nrow(dotaznik_par) == 165L,
          near2(alfa$total$raw_alpha, 0.82),
          median(dotaznik$age, na.rm = TRUE) == 24, min(dotaznik$age, na.rm = TRUE) == 16,
          max(dotaznik$age, na.rm = TRUE) == 78,
          identical(dotaznik$tot_help, hs_skory$tot_help),
          abs(coef(lm(tot_help ~ age, data = dotaznik_par))[["age"]] * 10) < 0.01)

# The final solution must run without chapter state in a second clean process.
standalone <- "quarto/_verification/standalone-solution.R"
writeLines(enc2utf8(c("grDevices::pdf(file = NULL)",
                      chunks[["l06-reseni-samostatne"]]$code,
                      chunks[["fig-skory-reseni-vek-histogram"]]$code,
                      chunks[["fig-skory-reseni-vek"]]$code,
                      "grDevices::dev.off()")), standalone, useBytes = TRUE)
status <- system2(file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"),
                  c("--vanilla", standalone), stdout = "quarto/_verification/lesson06-standalone.log",
                  stderr = "quarto/_verification/lesson06-standalone-errors.log")
stopifnot(status == 0L)
cat("PASS: every executable lesson 06 block and solution, expected error and warnings, labels, scores, reliability, zooming, Q-Q bands and source equivalence.\n")
