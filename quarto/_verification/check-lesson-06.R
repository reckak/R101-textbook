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
expected_warnings <- c("l06-alfa-pred" = "negatively correlated",
                       "fig-skory-bodovy" = "Removed 6 rows")
stopifnot(setequal(names(chunks)[vapply(chunks, function(x) x$expected_error, logical(1))],
                   names(expected_errors)))
stopifnot(identical(names(chunks)[vapply(chunks, function(x) x$skip, logical(1))],
                    "l06-instalace"))

grDevices::pdf(file = NULL)
for (chunk in chunks) {
  if (chunk$skip) next
  cat("\nCHUNK:", chunk$label, "\n")
  seen_warnings <- character()
  error <- tryCatch(withCallingHandlers({
    for (expression in parse(text = chunk$code)) {
      value <- withVisible(eval(expression, envir = .GlobalEnv))
      # Printing ggplot objects builds them, so plot warnings are checked too.
      if (value$visible) print(value$value)
    }
    NULL
  }, warning = function(w) {
    seen_warnings <<- c(seen_warnings, conditionMessage(w))
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
    stopifnot(length(relevant) == 1L,
              grepl(expected_warnings[[chunk$label]], relevant, fixed = TRUE))
  } else if (length(relevant)) {
    stop("Unexpected warning in ", chunk$label, ": ", paste(relevant, collapse = "; "))
  }
}
grDevices::dev.off()

near2 <- function(x, value) isTRUE(abs(x - value) < 0.005)

# Data, labels and reverse-scoring described in the text.
stopifnot(identical(dim(hs), c(172L, 34L)), is.numeric(hs$help_02),
          !inherits(hs$help_02, "haven_labelled"), is.factor(hs$gender),
          identical(rev_help, c("help_02", "help_04", "help_08", "help_09", "help_10")),
          length(rev_emo) == 11L,
          identical(as.integer(table(hs$help_02)), c(110L, 31L, 17L, 7L)),
          identical(as.integer(table(hs_kontrola$help_04, hs_kontrola$help_04_r)[cbind(1:4, 4:1)]),
                    c(10L, 38L, 60L, 59L)),
          near2(alfa_pred$total$raw_alpha, -0.07), near2(alfa_emo$total$raw_alpha, 0.92))
alfa_help <- psych::alpha(dplyr::select(hs_skory, dplyr::starts_with("help_")))
stopifnot(near2(alfa_help$total$raw_alpha, 0.82),
          near2(alfa_help$alpha.drop["help_04", "raw_alpha"], 0.84),
          near2(alfa_help$item.stats["help_04", "r.drop"], 0.19))

# Scores, missing-data rule and analysed pairs.
stopifnot(identical(as.integer(table(hs_rec$n_miss_help)), c(123L, 40L, 7L, 2L)),
          identical(as.integer(table(hs_emo_skor$n_miss_emo)), c(101L, 53L, 14L, 4L)),
          sum(!is.na(hs_skory$tot_help)) == 170L, sum(!is.na(hs_skory$tot_emo)) == 168L,
          nrow(hs_dvojice) == 166L,
          near2(mean(hs_skory$tot_help, na.rm = TRUE), 3.00),
          near2(sd(hs_skory$tot_help, na.rm = TRUE), 0.555),
          near2(mean(hs_skory$tot_emo, na.rm = TRUE), 3.61),
          identical(hs_rec$tot_help, hs_skory$tot_help),
          identical(hs_emo_skor$tot_emo, hs_skory$tot_emo),
          sum(hs_skory$tot_help == 3, na.rm = TRUE) == 24L)
# The common mean without rowwise() is one value for everybody.
one_mean <- mean(as.matrix(dplyr::select(hs_rec, help_01:help_10)), na.rm = TRUE)
stopifnot(near2(one_mean, 3.00))

# Correlations, distributions and regression.
pearson <- cor.test(~ tot_emo + tot_help, data = hs_skory)
spearman <- cor.test(~ tot_emo + tot_help, data = hs_skory, method = "spearman", exact = FALSE)
stopifnot(near2(pearson$estimate, 0.32), pearson$parameter == 164,
          near2(pearson$conf.int[1], 0.18), near2(pearson$conf.int[2], 0.45),
          near2(spearman$estimate, 0.34))
pairwise <- cor(dplyr::select(hs_skory, dplyr::starts_with("help_")), use = "pairwise.complete.obs")
pair_n <- crossprod(!is.na(as.matrix(dplyr::select(hs_skory, dplyr::starts_with("help_")))))
stopifnot(identical(range(pair_n[upper.tri(pair_n)]), c(156, 166)),
          near2(pairwise["help_03", "help_05"], 0.59),
          near2(min(pairwise["help_04", -4]), -0.03), near2(max(pairwise["help_04", -4]), 0.29),
          sum(complete.cases(dplyr::select(hs_skory, dplyr::starts_with("help_")))) == 123L)
stopifnot(near2(min(hs_skory$z_help, na.rm = TRUE), -3.41),
          near2(max(hs_skory$z_help, na.rm = TRUE), 1.61),
          near2(min(hs_skory$z_emo, na.rm = TRUE), -2.63),
          near2(max(hs_skory$z_emo, na.rm = TRUE), 2.25))
stopifnot(near2(coef(fit)[["tot_emo"]], 0.20), near2(coef(fit)[["(Intercept)"]], 2.28),
          near2(summary(fit)$r.squared, 0.10), near2(summary(fit)$sigma, 0.53),
          length(residuals(fit)) == 172L, sum(is.na(hs_skory$rezidua)) == 6L,
          near2(confint(fit)["tot_emo", 1], 0.11), near2(confint(fit)["tot_emo", 2], 0.29),
          nrow(mrizka) == 200L, near2(predikce$ci_lwr[1], 2.30), near2(predikce$ci_upr[1], 2.76),
          near2(predikce$pi_lwr[1], 1.45), near2(predikce$pi_upr[1], 3.60),
          max(predikce$pi_upr) > 4)
# bind_cols() gives the same table as joining by the fitted value on this grid.
joined <- dplyr::left_join(ci_tab, pi_tab, by = "fit")
stopifnot(nrow(joined) == nrow(mrizka),
          isTRUE(all.equal(as.data.frame(joined), as.data.frame(predikce[-1]))))

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
          identical(source_env$hs_rec$tot_help, hs_skory$tot_help),
          identical(source_env$hs_rec$tot_emo, hs_skory$tot_emo),
          identical(source_env$hs_rec$id, hs_skory$id))

# Final task values used in the interpretation.
stopifnot(sum(!is.na(dotaznik$age)) == 167L, nrow(dotaznik_par) == 165L,
          near2(alfa$total$raw_alpha, 0.82),
          isTRUE(abs(cor(dotaznik_par$age, dotaznik_par$tot_help) - 0.008) < 0.001),
          near2(coef(fit_vek)[["age"]] * 10, 0.003))

# The final solution must run without chapter state in a second clean process.
standalone <- "quarto/_verification/standalone-solution.R"
writeLines(enc2utf8(c("grDevices::pdf(file = NULL)",
                      chunks[["l06-reseni-samostatne"]]$code,
                      chunks[["fig-skory-reseni-vek"]]$code,
                      "grDevices::dev.off()")), standalone, useBytes = TRUE)
status <- system2(file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"),
                  c("--vanilla", standalone), stdout = "quarto/_verification/lesson06-standalone.log",
                  stderr = "quarto/_verification/lesson06-standalone-errors.log")
stopifnot(status == 0L)
cat("PASS: every executable lesson 06 block and solution, expected error and warnings, scores, reliability, correlations, regression and source equivalence.\n")
