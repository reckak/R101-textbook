# Run from the project root in a separate Rscript --vanilla process.
lines <- readLines("quarto/lekce_09.qmd", encoding = "UTF-8")
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
stopifnot(!anyDuplicated(names(chunks)),
          !any(vapply(chunks, function(x) x$expected_error, logical(1))),
          identical(names(chunks)[vapply(chunks, function(x) x$skip, logical(1))],
                    c("l09-instalace", "l09-oprava-ukazka")))

# Package-build notes from the local R installation are allowed only where packages load.
loading_chunks <- c("l09-nacteni", "l09-reseni-samostatne")
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
  if (inherits(error, "error")) stop("Unexpected error in ", chunk$label, ": ", conditionMessage(error))
  relevant <- if (chunk$label %in% loading_chunks) {
    seen_warnings[!grepl("was built under R version", seen_warnings, fixed = TRUE)]
  } else seen_warnings
  if (length(relevant)) stop("Unexpected warning in ", chunk$label, ": ", paste(relevant, collapse = "; "))
}
grDevices::dev.off()

near <- function(x, value, tol = 0.005) isTRUE(all(abs(x - value) < tol))
run <- function(label) eval(parse(text = chunks[[label]]$code), envir = .GlobalEnv)

# Sample description and selection of relationships.
stopifnot(identical(dim(vztahy), c(124L, 13L)), !anyNA(vztahy),
          identical(as.integer(table(vztahy$pohlavi)), c(62L, 62L)),
          identical(as.integer(table(vztahy$narodnost)), c(92L, 32L)),
          identical(range(vztahy$vek_roky), c(20, 30)),
          near(mean(vztahy$vek_roky), 22.68), near(sd(vztahy$vek_roky), 2.33),
          identical(as.integer(table(vztahy$vazny_vztah)), c(119L, 5L)),
          identical(as.integer(table(vztahy$spolecne_bydleni)), c(28L, 96L)),
          identical(as.integer(table(vztahy$zasnoubeni)), c(2L, 122L)),
          identical(range(vztahy$delka_vztahu_mesice), c(0, 76)),
          identical(as.integer(table(vztahy$filtr)), c(4L, 120L)),
          nrow(analyza) == 120L, sum(vztahy$delka_vztahu_mesice >= 12) == 114L)

# Descriptive statistics, range check and the three persons with low satisfaction.
popis <- popis[match(promenne_modelu, popis$promenna), ]
stopifnot(all(popis$n == 120L), all(popis$n_chybi == 0L),
          near(popis$M[1:4], c(4.96, 3.42, 4.98, 2.24), 0.01), near(popis$M[5], 36.9, 0.05),
          near(popis$SD[1:4], c(0.83, 1.10, 0.94, 1.05), 0.01), near(popis$SD[5], 15.8, 0.05),
          near(popis$sikmost, c(-1.24, 0.20, -1.94, 0.18, 0.12), 0.01),
          near(popis$spicatost[c(1, 3)], c(1.59, 5.27), 0.01),
          near(popis$Min, c(1.97, 0.6, 0.8, 0, 7), 1e-8), near(popis$Max, c(6, 6, 6, 4.5, 76), 1e-8),
          identical(analyza$id[analyza$spokojenost < 2], c(33L, 39L, 124L)))

# Correlations described in the text.
r <- cor(analyza[promenne_modelu])
stopifnot(near(r["zavazek", c("investice", "spokojenost", "alternativy", "delka_vztahu_mesice")],
               c(0.28, 0.38, -0.34, 0.32), 0.006),
          near(r["spokojenost", "alternativy"], -0.33, 0.006),
          near(r["investice", c("spokojenost", "alternativy", "delka_vztahu_mesice")], c(0.17, -0.18, 0.18), 0.006))
ci_r <- analyza |> rstatix::cor_test(vars = zavazek, vars2 = c(investice, spokojenost))
stopifnot(near(c(ci_r$conf.low, ci_r$conf.high), c(0.11, 0.22, 0.44, 0.53), 0.006))

# Model 1 and the simple model with satisfaction.
s1 <- summary(model_1)
stopifnot(near(coef(model_1), c(4.25, 0.21)), near(s1$r.squared, 0.078, 0.001),
          near(s1$adj.r.squared, 0.070, 0.001), near(s1$sigma, 0.80),
          near(s1$fstatistic[["value"]], 10.01), near(s1$coefficients[2, "t value"], 3.16),
          near(confint(model_1)[2, ], c(0.08, 0.34)), min(analyza$investice) == 0.6,
          near(range(resid(model_1)), c(-3.30, 1.11)), near(median(resid(model_1)), 0.22))
stopifnot(near(coef(model_spokojenost), c(3.29, 0.336), 0.006), near(summary(model_spokojenost)$r.squared, 0.146, 0.001),
          near(confint(model_spokojenost)[2, ], c(0.19, 0.48)))

# Model 2, increment, standardized and semipartial effects.
s2 <- summary(model_2)
stopifnot(near(s2$r.squared, 0.296, 0.001), near(s2$adj.r.squared, 0.272, 0.001), near(s2$sigma, 0.70),
          near(s2$fstatistic[["value"]], 12.09), near(coef(model_2), c(3.41, 0.11, 0.21, -0.18, 0.0137), 0.006),
          near(s2$coefficients["investice", "Pr(>|t|)"], 0.069, 0.001))
inc <- anova(model_1, model_2)
stopifnot(near(s2$r.squared - s1$r.squared, 0.218, 0.001), near(inc$F[2], 11.86), near(inc$`Sum of Sq`[2], 17.63, 0.01))
beta <- betaDelta::BetaDelta(model_2, alpha = 0.05)
beta_est <- summary(beta)[, "est"]
stopifnot(near(beta_est, c(0.15, 0.24, -0.23, 0.26), 0.006))
sr2 <- effectsize::r2_semipartial(model_2, alternative = "two.sided")
stopifnot(near(sr2$r2_semipartial, c(0.02, 0.05, 0.05, 0.07), 0.01), near(sum(sr2$r2_semipartial), 0.19, 0.01))
stopifnot(near(glance(model_delka)$r.squared, 0.104, 0.001), near(anova(model_delka, model_2)$F[2], 10.48))

# Years instead of months change only the scale of that coefficient.
stopifnot(near(coef(model_3)[["delka_vztahu_roky"]], 12 * coef(model_2)[["delka_vztahu_mesice"]], 1e-10),
          isTRUE(all.equal(fitted(model_2), fitted(model_3))),
          near(range(analyza$delka_vztahu_roky), c(0.58, 6.33)),
          near(confint(model_3)["delka_vztahu_roky", ], c(0.06, 0.26), 0.006),
          near(coef(model_c)[1], 4.96), near(coef(model_c)[-1], coef(model_3)[-1], 1e-10))

# The model formula matches the full model of the source script with renamed variables.
source_lines <- readLines("scripts/week_09.R", encoding = "UTF-8", warn = FALSE)
fit_start <- grep("^fit_2 <- lm", source_lines)
source_env <- new.env()
source_env$df <- analyza |>
  dplyr::rename(delka_vztahu = delka_vztahu_mesice) |>
  dplyr::mutate(delka_vztahu_roky = delka_vztahu / 12)
eval(parse(text = source_lines[fit_start:(fit_start + 2)]), envir = source_env)
stopifnot(isTRUE(all.equal(unname(coef(source_env$fit_2)[c(1, 3, 4, 5, 2)]), unname(coef(model_3)))))

# Diagnostics.
stopifnot(near(range(car::vif(model_3)), c(1.05, 1.16)),
          near(car::ncvTest(model_3)$ChiSquare, 13.23), car::ncvTest(model_3)$p < 0.001,
          near(shapiro.test(resid(model_3))$statistic, 0.94), shapiro.test(resid(model_3))$p.value < 0.001)
curvature <- car::residualPlots(model_3, plot = FALSE)
stopifnot(near(curvature["investice", 2], 0.035, 0.001), near(curvature["Tukey test", 2], 0.22, 0.01),
          all(curvature[c("spokojenost", "alternativy", "delka_vztahu_roky"), 2] > 0.3))
top_cook <- diagnostika |> dplyr::slice_max(.cooksd, n = 3)
stopifnot(identical(top_cook$id, c(124L, 21L, 33L)), near(top_cook$.cooksd, c(0.49, 0.18, 0.16), 0.006),
          near(top_cook$.std.resid, c(-3.28, -3.49, 1.81)), near(top_cook$.hat[c(1, 3)], c(0.185, 0.197), 0.001),
          max(diagnostika$.cooksd[!diagnostika$id %in% top_cook$id]) < 0.06,
          identical(diagnostika$id[order(-diagnostika$.hat)][1:2], c(33L, 124L)),
          sum(abs(diagnostika$.std.resid) > 3) == 2L)

# Predictive accuracy.
groups <- diagnostika |>
  dplyr::mutate(skupina = dplyr::case_when(zavazek <= 4 ~ "nizky", zavazek <= 5 ~ "stredni", .default = "vysoky")) |>
  dplyr::summarise(n = dplyr::n(), m = mean(.resid), .by = skupina) |>
  dplyr::arrange(skupina)
stopifnot(identical(groups$n, c(17L, 35L, 68L)), near(groups$m[c(1, 3)], c(-1.22, 0.375), 0.006),
          near(range(diagnostika$.fitted), c(3.74, 5.90)),
          sum(analyza$zavazek < min(diagnostika$.fitted)) == 10L)

# Bootstrap: reproducible with the seed, and the intervals quoted in the table.
ci_boot <- confint(bootstrap_3, type = "perc")
stopifnot(near(ci_boot[-1, ], c(-0.03, 0.01, -0.31, 0.08, 0.25, 0.42, -0.04, 0.25), 0.006),
          near(summary(bootstrap_3)$bootSE[3], 0.104, 0.001))
set.seed(123)
again <- car::Boot(model_3, R = 5000)
stopifnot(identical(bootstrap_3$t, again$t))
ci_1000 <- confint(bootstrap_1000, type = "perc")
stopifnot(max(abs(ci_1000 - ci_boot)) < 0.02, near(ci_1000["spokojenost", ], c(0.01, 0.42), 0.006))

# Sensitivity analysis without the two most influential persons.
stopifnot(identical(vlivne_id, c(124L, 21L)), nobs(model_bez_vlivnych) == 118L,
          near(coef(model_bez_vlivnych)[-1], c(0.12, 0.16, -0.12, 0.16), 0.006),
          near(confint(model_bez_vlivnych)["investice", ], c(0.01, 0.24), 0.006),
          confint(model_bez_vlivnych)["alternativy", 2] < 0,
          near(summary(model_bez_vlivnych)$r.squared, 0.27))

# Confidence and prediction intervals, DFBETAS.
stopifnot(nrow(intervaly) == 100L,
          near(intervaly$.fitted[c(1, 100)], c(4.56, 5.50)),
          near(unlist(intervaly[50, c("ci_dolni", "ci_horni", "pi_dolni", "pi_horni")]), c(4.89, 5.16, 3.62, 6.42)),
          all(intervaly$pi_horni - intervaly$pi_dolni > intervaly$ci_horni - intervaly$ci_dolni))
top_dfb <- dfbetas_3 |> dplyr::filter(koeficient != "(Intercept)") |>
  dplyr::slice_max(abs(dfbetas), n = 2, by = koeficient)
stopifnot(identical(top_dfb$id[top_dfb$koeficient == "spokojenost"], c(124L, 33L)),
          identical(top_dfb$id[top_dfb$koeficient == "investice"], c(124L, 21L)),
          identical(top_dfb$id[top_dfb$koeficient == "alternativy"], c(21L, 124L)),
          all(top_dfb$dfbetas[top_dfb$koeficient == "alternativy"] < 0),
          max(abs(top_dfb$dfbetas[top_dfb$koeficient == "delka_vztahu_roky"])) < 0.3)

# Final task: separate models and the interaction test.
stopifnot(nobs(model_muzi) == 60L, nobs(model_zeny) == 60L,
          near(coef(model_muzi)[-1], c(0.22, 0.08, -0.06, 0.19), 0.006),
          near(coef(model_zeny)[-1], c(0.04, 0.38, -0.20, 0.11), 0.006),
          near(c(summary(model_muzi)$r.squared, summary(model_zeny)$r.squared), c(0.30, 0.37), 0.006))
interaction_test <- anova(model_spolecny, model_interakce)
stopifnot(near(interaction_test$F[2], 2.27), near(interaction_test$`Pr(>F)`[2], 0.066, 0.001))

# The standalone final solution must run without objects from the lesson.
standalone <- "quarto/_verification/standalone-solution-09.R"
writeLines(enc2utf8(c(chunks[["l09-reseni-samostatne"]]$code, chunks[["l09-reseni-interakce"]]$code)),
           standalone, useBytes = TRUE)
status <- system2(file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"),
                  c("--vanilla", standalone), stdout = TRUE, stderr = TRUE)
stopifnot(is.null(attr(status, "status")) || attr(status, "status") == 0L,
          any(grepl("0.371", status, fixed = TRUE)))
unlink(standalone)

# When the local SPSS source is available, the public RDS must reproduce its values.
if (file.exists("data/raw/ZZ_ckrvliry.sav")) {
  original <- haven::zap_labels(haven::read_sav("data/raw/ZZ_ckrvliry.sav"))
  public <- readRDS("data/clean/vztahy_zavazek.rds")
  stopifnot(identical(public$id, seq_len(nrow(original))),
            identical(as.integer(public$pohlavi), as.integer(original$pohlavie)),
            identical(as.integer(public$narodnost), as.integer(original[[2]])),
            identical(as.numeric(public$vek_roky), as.numeric(original$vek)),
            identical(as.integer(public$vazny_vztah), as.integer(original$vazny_vztah)),
            identical(as.integer(public$spolecne_bydleni), as.integer(original$spolubyvanie)),
            identical(as.integer(public$zasnoubeni), as.integer(original$zasnuveny)),
            identical(as.numeric(public$delka_vztahu_mesice), as.numeric(original$cas_mesiace)),
            identical(as.numeric(public$spokojenost), as.numeric(original$spokojnost)),
            identical(as.numeric(public$alternativy), as.numeric(original$alternativy)),
            identical(as.numeric(public$investice), as.numeric(original$investicie)),
            identical(as.numeric(public$zavazek), as.numeric(original$zavazok)))
  cat("PASS: public RDS matches the local SPSS source.\n")
}

cat("PASS lesson 09: all chunks and solutions, sample and filter, descriptives, correlations,",
    "both models, increment, beta and sr2, unit change, diagnostics, reproducible bootstrap,",
    "sensitivity, intervals, DFBETAS, models by sex and standalone final solution.\n")
