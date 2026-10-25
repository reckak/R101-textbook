# Run from the project root in a separate Rscript --vanilla process.
lines <- readLines("quarto/lekce_07.qmd", encoding = "UTF-8")
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
                    c("l07-instalace", "l07-url-sav", "l07-url-download")))

# Package-build notes from the local R installation are allowed only where packages load.
loading_chunks <- c("l07-nacteni", "l07-reseni-samostatne")
# The age histogram deliberately keeps the warning about the three missing ages.
expected_warnings <- list("fig-testy-vek" = list("Removed 3 rows", 1L))
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

near <- function(x, value, tol = 0.005) isTRUE(all(abs(x - value) < tol))
run <- function(label) eval(parse(text = chunks[[label]]$code), envir = .GlobalEnv)

# Data, correction of the cohort code and factor conversion.
raw <- haven::read_sav("data/raw/monitoring_teaching.sav")
stopifnot(identical(dim(raw), c(768L, 13L)), sum(raw$kohorta == 66) == 1L,
          raw$vekr[raw$kohorta == 66] > 12 && raw$vekr[raw$kohorta == 66] < 12.3,
          identical(as.integer(table(raw$pohlavi)), c(316L, 449L)), sum(is.na(raw$pohlavi)) == 3L,
          identical(levels(adolescenti$pohlavi), c("chlapci", "dívky")),
          identical(levels(adolescenti$kohorta), c("mladší", "starší")),
          identical(as.integer(table(adolescenti$kohorta, useNA = "ifany")), c(443L, 325L)),
          sum(adolescenti$vekr > 18, na.rm = TRUE) == 2L,
          n_distinct(adolescenti$id) == 768L)
age_ranges <- adolescenti |> summarise(min = min(vekr, na.rm = TRUE), max = max(vekr, na.rm = TRUE), .by = kohorta)
stopifnot(max(age_ranges$max[age_ranges$kohorta == "mladší"]) < 14,
          min(age_ranges$min[age_ranges$kohorta == "starší"]) > 15.7)

# Items, reliability and score.
item_cor <- adolescenti |> select(c01_99:c09_99) |> cor(use = "pairwise.complete.obs")
stopifnot(all(item_cor > 0), near(min(item_cor), 0.20), near(max(item_cor[item_cor < 1]), 0.58),
          nrow(polozky_dlouhe) == 6835L, near(alfa_monit$total$raw_alpha, 0.82, 0.01))
stopifnot(identical(as.integer(table(adolescenti$n_miss_monit)), c(743L, 15L, 2L, 2L, 1L, 5L)),
          sum(!is.na(adolescenti$monit)) == 758L,
          near(mean(adolescenti$monit, na.rm = TRUE), 2.80),
          near(psych::skew(adolescenti$monit), -0.10, 0.01),
          near(psych::kurtosi(adolescenti$monit), -0.66, 0.01),
          length(unique(na.omit(adolescenti$monit))) == 36L,
          sum(adolescenti$monit == 3, na.rm = TRUE) == 59L)
manual <- with(adolescenti, (c01_99 + c02_99 + c03_99 + c04_99 + c05_99 + c06_99 + c07_99 + c08_99 + c09_99) / 9)
stopifnot(sum(is.na(manual)) == 25L, isTRUE(all.equal(as.numeric(manual), adolescenti$monit[!is.na(manual)] |>
  (\(x) { y <- rep(NA_real_, length(manual)); y[!is.na(manual)] <- x; y })())))

# Q-Q plots use the identity line: the normal with the data's mean and SD.
qq_twice <- lapply(1:2, function(i) ggplot2::ggplot_build(run("fig-testy-qq"))$data)
qq_line <- qq_twice[[1]][[2]]
qq_points <- qq_twice[[1]][[3]]
monit_valid <- na.omit(adolescenti$monit)
n_valid <- length(monit_valid)
stopifnot(isTRUE(all.equal(qq_line$y, qq_line$x)),
          isTRUE(all.equal(sort(qq_points$x), qnorm(ppoints(n_valid), mean(monit_valid),
                                                    sd(monit_valid) * sqrt((n_valid - 1) / n_valid)))),
          identical(qq_twice[[1]][[1]][c("ymin", "ymax")], qq_twice[[2]][[1]][c("ymin", "ymax")]))
group_twice <- lapply(1:2, function(i) ggplot2::ggplot_build(run("fig-testy-qq-pohlavi"))$data)
group_line <- group_twice[[1]][[2]]
stopifnot(isTRUE(all.equal(group_line$y, group_line$x)),
          identical(group_twice[[1]][[1]][c("ymin", "ymax")], group_twice[[2]][[1]][c("ymin", "ymax")]))
grid_line <- ggplot2::ggplot_build(run("fig-testy-reseni-qq-mrizka"))$data[[2]]
stopifnot(isTRUE(all.equal(grid_line$y, grid_line$x)), length(unique(grid_line$PANEL)) == 4L)

# Shapiro-Wilk is significant in both large groups although W is close to 1.
shapiro <- analyza_pohlavi |> group_by(pohlavi) |> shapiro_test(monit)
stopifnot(near(shapiro$statistic, c(0.990, 0.983), 0.001), near(shapiro$p[1], 0.032, 0.001), shapiro$p[2] < 0.001)
# Exercise 7 commentary: smaller groups give p-values around 0.05; no older boy scores 4.
shapiro4 <- analyza_pohlavi |> group_by(kohorta, pohlavi) |> shapiro_test(monit)
stopifnot(min(shapiro4$p) < 0.001, near(max(shapiro4$p), 0.069, 0.001),
          max(analyza_pohlavi$monit[analyza_pohlavi$kohorta == "starší" & analyza_pohlavi$pohlavi == "chlapci"]) < 3.8)

# The score matches the source script after correcting the input path.
source_lines <- readLines("scripts/week_07.R", encoding = "UTF-8", warn = FALSE)
score_end <- grep("^df \\|> $", source_lines)
score_end <- score_end[score_end > grep("na_monit > 1", source_lines)[1]][1] - 1L
source_env <- new.env()
source_code <- sub('read_sav("data/long2.sav")', 'read_sav("data/raw/monitoring_teaching.sav")',
                   source_lines[1:score_end], fixed = TRUE)
# Plot-only packages are not needed for the score; ggmosaic is no longer on CRAN.
source_code <- source_code[!grepl("^library\\((ggh4x|ggmosaic|qqplotr)\\)", source_code)]
invisible(capture.output(suppressWarnings(suppressMessages(
  eval(parse(text = source_code), envir = source_env)))))
stopifnot(identical(source_env$df$id, adolescenti$id),
          isTRUE(all.equal(source_env$df$monit, adolescenti$monit)),
          identical(as.character(source_env$df$kohorta), c("mladší kohorta", "starší kohorta")[as.integer(adolescenti$kohorta)]))

# Group comparisons described in the text.
stopifnot(nrow(analyza_pohlavi) == 755L)
desc <- analyza_pohlavi |> summarise(M = mean(monit), SD = sd(monit), n = n(), .by = pohlavi) |> arrange(pohlavi)
stopifnot(near(desc$M, c(2.72, 2.86)), near(desc$SD, c(0.56, 0.58)), identical(desc$n, c(313L, 442L)))
lev <- analyza_pohlavi |> levene_test(monit ~ pohlavi)
stopifnot(lev$df1 == 1L, lev$df2 == 753L, near(lev$statistic, 0.29), near(lev$p, 0.59))
stopifnot(near(welch_pohlavi$estimate, -0.139, 0.001), near(welch_pohlavi$statistic, -3.31),
          near(welch_pohlavi$df, 681.95), welch_pohlavi$p < 0.001,
          near(c(welch_pohlavi$conf.low, welch_pohlavi$conf.high), c(-0.22, -0.06)),
          identical(c(welch_pohlavi$group1, welch_pohlavi$group2), c("chlapci", "dívky")))
student <- analyza_pohlavi |> t_test(monit ~ pohlavi, var.equal = TRUE)
stopifnot(student$df == 753, near(student$statistic, -3.30))
base_t <- t.test(monit ~ pohlavi, data = analyza_pohlavi)
stopifnot(near(unname(base_t$statistic), welch_pohlavi$statistic, 1e-8), near(unname(base_t$parameter), welch_pohlavi$df, 1e-6))
d_twice <- lapply(1:2, function(i) { set.seed(123); cohens_d(analyza_pohlavi, monit ~ pohlavi, var.equal = TRUE, ci = TRUE) })
stopifnot(identical(unlist(d_twice[[1]][c("effsize", "conf.low", "conf.high")], use.names = FALSE),
                    unlist(d_twice[[2]][c("effsize", "conf.low", "conf.high")], use.names = FALSE)),
          near(d_twice[[1]]$effsize, -0.24),
          near(c(d_twice[[1]]$conf.low, d_twice[[1]]$conf.high), c(-0.38, -0.09), 0.006),
          near(cohens_d(analyza_pohlavi, monit ~ pohlavi)$effsize, -0.24))

stopifnot(nrow(analyza_kohorta) == 758L)
welch_kohorta <- analyza_kohorta |> t_test(monit ~ kohorta, detailed = TRUE)
stopifnot(near(welch_kohorta$estimate, 0.31, 0.006), near(welch_kohorta$df, 711.40),
          near(c(welch_kohorta$conf.low, welch_kohorta$conf.high), c(0.24, 0.39), 0.006))
set.seed(123)
d_kohorta <- cohens_d(analyza_kohorta, monit ~ kohorta, var.equal = TRUE, ci = TRUE)
stopifnot(near(d_kohorta$effsize, 0.57), near(c(d_kohorta$conf.low, d_kohorta$conf.high), c(0.42, 0.72), 0.006))

# Correlation and the within-cohort decomposition.
ct <- cor.test(~ vekr + monit, data = analyza_vek)
stopifnot(nrow(analyza_vek) == 755L, near(unname(ct$estimate), -0.28), unname(ct$parameter) == 753,
          near(ct$conf.int, c(-0.35, -0.22)))
tidy_cor <- analyza_vek |> cor_test(vekr, monit)
stopifnot(tidy_cor$cor == -0.28, near(tidy_cor$statistic, unname(ct$statistic), 1e-6),
          near(c(tidy_cor$conf.low, tidy_cor$conf.high), ct$conf.int, 1e-6))
within_r <- analyza_vek |> summarise(r = cor(vekr, monit), n = n(), .by = kohorta) |> arrange(kohorta)
stopifnot(near(within_r$r, c(-0.16, 0.01), 0.006), identical(within_r$n, c(432L, 323L)))

# Contingency table and chi-square test without continuity correction.
stopifnot(identical(unname(as.integer(cetnosti)), c(186L, 130L, 254L, 195L)),
          !grepl("Yates", chi_kohorta$method), near(unname(chi_kohorta$statistic), 0.40),
          near(chi_kohorta$p.value, 0.53), all(chi_kohorta$expected > 134))
shares <- ggplot2::ggplot_build(run("fig-testy-podily"))$data[[1]]
boys <- shares[shares$fill == "#3F72AF", ]
boys <- boys[order(boys$x), ]
# Boys (first level) are stacked on top; the girls' share is the boundary height.
stopifnot(all(abs(boys$ymax - 1) < 1e-12), near(boys$ymin, c(0.577, 0.600), 0.001))
yates <- chisq.test(cetnosti)
stopifnot(near(unname(yates$statistic), 0.31), near(yates$p.value, 0.58))
# rstatix agrees with chisq.test(); the Monte Carlo p-value is reproducible with the seed.
tidy_chi <- chisq_test(cetnosti, correct = FALSE)
stopifnot(tidy_chi$n == 765L, tidy_chi$df == 1L, tidy_chi$p.signif == "ns",
          near(tidy_chi$statistic, unname(chi_kohorta$statistic), 0.001),
          near(tidy_chi$p, chi_kohorta$p.value, 0.001),
          isTRUE(all.equal(unname(expected_freq(tidy_chi)), unname(chi_kohorta$expected))))
simulated_p <- function() { set.seed(123); chisq.test(cetnosti, simulate.p.value = TRUE, B = 10000)$p.value }
sim_p <- simulated_p()
stopifnot(identical(sim_p, simulated_p()), near(sim_p, 0.55))
na_category <- run("l07-reseni-case-when-na")
stopifnot(identical(na_category$n[na_category$kohorta_vek == "neuvedeno"], c(2L, 1L)),
          !anyNA(na_category$kohorta_vek))
stopifnot(identical(as.integer(table(adolescenti$kohorta, adolescenti$kohorta_moje, useNA = "ifany")),
                    c(441L, 0L, 0L, 311L, 2L, 14L)),
          sum(adolescenti$vekr > 17 & is.na(adolescenti$kohorta_moje), na.rm = TRUE) == 13L)

# Sex differences within cohorts.
within_t <- analyza_pohlavi |> group_by(kohorta) |> t_test(monit ~ pohlavi, detailed = TRUE)
stopifnot(near(within_t$estimate, c(-0.145, -0.148), 0.001), near(within_t$df, c(390.85, 291.12)),
          near(within_t$p, c(0.008, 0.014), 0.001))
set.seed(123)
within_d <- analyza_pohlavi |> group_by(kohorta) |> cohens_d(monit ~ pohlavi, var.equal = TRUE, ci = TRUE)
stopifnot(near(within_d$effsize, c(-0.26, -0.28)))

# The standalone final solution must run without objects from the lesson.
standalone <- "quarto/_verification/standalone-solution-07.R"
writeLines(enc2utf8(c("grDevices::pdf(file = NULL)", chunks[["l07-reseni-samostatne"]]$code,
                      chunks[["fig-testy-reseni-samostatne"]]$code, "grDevices::dev.off()")),
           standalone, useBytes = TRUE)
status <- system2(file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"),
                  c("--vanilla", standalone), stdout = TRUE, stderr = TRUE)
stopifnot(is.null(attr(status, "status")) || attr(status, "status") == 0L,
          any(grepl("0.32", status, fixed = TRUE)))
unlink(standalone)

# When the original local export is available, the public subset must reproduce it exactly.
if (file.exists("data/raw/long2.sav")) {
  original <- haven::read_sav("data/raw/long2.sav")
  stopifnot(identical(names(raw), c("id", "pohlavi", "kohorta", "vekr", sprintf("c%02d_99", 1:9))))
  for (column in names(raw)) {
    stopifnot(identical(as.vector(haven::zap_labels(raw[[column]])), as.vector(haven::zap_labels(original[[column]]))),
              identical(attr(raw[[column]], "labels"), attr(original[[column]], "labels")),
              identical(attr(raw[[column]], "label"), attr(original[[column]], "label")))
  }
  cat("PASS: public subset matches the local original export.\n")
}

cat("PASS lesson 07: all chunks and solutions, corrected cohort, score rule and source match,",
    "Welch/Student/base t-tests, reproducible bootstrap d, correlation, chi-square without Yates,",
    "within-cohort tests and standalone final solution.\n")
