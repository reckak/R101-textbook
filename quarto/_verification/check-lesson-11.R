# Run from the project root in a separate Rscript --vanilla process.
lines <- readLines("quarto/lekce_11.qmd", encoding = "UTF-8")
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
                    c("l11-instalace", "l11-url-rds", "l11-url-download")))

# Package-build notes from the local R installation are allowed only where packages load.
loading_chunks <- c("l11-nacteni", "l11-reseni-samostatne")
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

# Data: public teaching file, complete analysis variables, rows ordered by event id.
stopifnot(identical(dim(cykliste), c(2355L, 9L)), !is.unsorted(cykliste$id),
          identical(names(cykliste), c("id", "vozidlo", "barva", "ulice", "vzdalenost_predjeti",
                                       "helma", "okraj", "cyklopruh", "mesto")),
          sum(is.na(cykliste)) == 14L, sum(is.na(cykliste$barva)) == 14L,
          is.factor(cykliste$okraj), !is.ordered(cykliste$okraj),
          identical(levels(cykliste$okraj), c("0,25", "0,50", "0,75", "1,00", "1,25")),
          identical(as.integer(table(cykliste$vozidlo)), c(1708L, 293L, 143L, 46L, 82L, 49L, 34L)),
          identical(as.integer(table(cykliste$helma)), c(1206L, 1149L)),
          identical(unname(c(table(cykliste$helma, cykliste$okraj))),
                    c(426L, 244L, 270L, 275L, 153L, 186L, 197L, 272L, 160L, 172L)))

# Descriptives, cell means and the city exercise.
y <- cykliste$vzdalenost_predjeti
stopifnot(near(mean(y), 1.553, 0.001), near(sd(y), 0.381, 0.001), near(median(y), 1.514, 0.001),
          near(range(y), c(0.394, 3.787), 1e-8),
          near(c(psych::skew(y), psych::skew(sqrt(y)), psych::skew(log(y))), c(0.752, 0.249, -0.265), 0.001),
          near(mean(sqrt(y))^2, 1.530, 0.001),
          near(prumery$M, c(1.73, 1.63, 1.55, 1.49, 1.44, 1.55, 1.51, 1.47, 1.50, 1.44), 0.006),
          near(range(prumery$SD), c(0.33, 0.41), 0.006),
          near(prumery$dolni[1], 1.69, 0.006), near(prumery$horni[1], 1.77, 0.006),
          near(tapply(y, cykliste$mesto, mean), c(1.56, 1.52), 0.006),
          identical(unname(c(table(cykliste$mesto, cykliste$okraj)[, 4:5])), c(446L, 23L, 328L, 4L)))

# One-way model: coefficients, F test, effect sizes, back-transformed means, Welch.
a1 <- anova(model_vozidlo)
eta1 <- effectsize::eta_squared(model_vozidlo, alternative = "two.sided")
om1 <- effectsize::omega_squared(model_vozidlo, alternative = "two.sided")
ev <- as.data.frame(emm_vozidlo)
welch <- oneway.test(sqrt(vzdalenost_predjeti) ~ vozidlo, data = cykliste)
stopifnot(near(coef(model_vozidlo)[c(1, 4)], c(1.246, -0.107), 0.001),
          near(a1$`F value`[1], 9.295, 0.001), identical(a1$Df, c(6L, 2348L)),
          near(a1$`Sum Sq`, c(1.245, 52.435), 0.001), near(a1$`Mean Sq`, c(0.2076, 0.0223), 0.0001),
          near(deviance(model_nulovy), 53.680, 0.001),
          near(anova(model_nulovy, model_vozidlo)$F[2], a1$`F value`[1], 1e-8),
          near(eta1$Eta2, 0.0232, 0.0001), near(c(eta1$CI_low, eta1$CI_high), c(0.011, 0.034), 0.001),
          near(eta1$Eta2, summary(model_vozidlo)$r.squared, 1e-10), near(om1$Omega2, 0.0207, 0.0001),
          near(ev$response, c(1.55, 1.49, 1.54, 1.30, 1.37, 1.41, 1.67), 0.006),
          near(c(ev$lower.CL[4], ev$upper.CL[4]), c(1.20, 1.40), 0.006),
          near(welch$statistic, 9.583, 0.001), near(welch$parameter[2], 175.8, 0.05),
          near(range(tapply(sqrt(y), cykliste$vozidlo, sd)), c(0.135, 0.172), 0.001))

# Exercises 3 and 4: colour and the planned contrast.
ab <- anova(model_barva)
bila <- table(cykliste$vozidlo[which(cykliste$barva == levels(cykliste$barva)[4])])
kontrast <- emm_vozidlo |> regrid() |>
  contrast(method = list(k = vahy), infer = TRUE) |> as.data.frame()
stopifnot(nobs(model_barva) == 2341L, near(ab$`F value`[1], 1.825, 0.001), near(ab$`Pr(>F)`[1], 0.090, 0.001),
          near(effectsize::eta_squared(model_barva)$Eta2, 0.0047, 0.0001),
          bila[[2]] / sum(bila) > 0.5, abs(sum(vahy)) < 1e-12,
          near(kontrast$estimate, -0.195, 0.001),
          near(c(kontrast$lower.CL, kontrast$upper.CL), c(-0.26, -0.13), 0.006),
          near(kontrast$t.ratio, -6.05))

# Factorial model: sequential tests depend on order, joint tests do not.
jt <- as.data.frame(testy)
stopifnot(length(coef(model_helma)) == 16L, df.residual(model_helma) == 2339L,
          near(summary(model_helma)$r.squared, 0.0849, 0.0001),
          near(anova(model_helma)[1, "F value"], 48.97),
          near(anova(model_jine_poradi)[2, "F value"], 30.715, 0.001),
          isTRUE(all.equal(fitted(model_helma), fitted(model_jine_poradi))),
          identical(as.character(jt$`model term`), c("helma", "okraj", "vozidlo", "helma:okraj")),
          near(jt$F.ratio, c(20.301, 18.894, 8.220, 6.240), 0.001), all(jt$p.value < 0.001))
# joint_tests() reproduces Type III tests with sum-to-zero contrasts
# (joint_tests() stores F rounded to three decimals, hence the tolerances).
model_sum <- lm(sqrt(vzdalenost_predjeti) ~ helma * okraj + vozidlo, data = cykliste,
                contrasts = list(helma = contr.sum, okraj = contr.sum, vozidlo = contr.sum))
typ3 <- car::Anova(model_sum, type = 3)
typ3_rows <- c("helma", "okraj", "vozidlo", "helma:okraj")
stopifnot(near(typ3[typ3_rows, "F value"], jt$F.ratio, 1e-3))

# Effect sizes: non-partial by hand, partial via effectsize.
stopifnot(near(velikosti$eta2, c(0.0079, 0.0296, 0.0193, 0.0098), 0.0001),
          near(velikosti$omega2, c(0.0075, 0.0280, 0.0169, 0.0082), 0.0001),
          near(velikosti$eta2_p, c(0.0086, 0.0313, 0.0207, 0.0106), 0.0001),
          near(velikosti$omega2_p, c(0.0082, 0.0296, 0.0181, 0.0089), 0.0001),
          near(sum(velikosti$eta2), 0.067, 0.001), near(ss_celkem, 53.680, 0.001),
          near(velikosti$SS, typ3[typ3_rows, "Sum Sq"], 1e-4),
          all(velikosti$eta2_p >= velikosti$eta2), all(velikosti$omega2 < velikosti$eta2))
bez <- anova(model_bez_interakce, model_helma)
stopifnot(near(bez$F[2], jt$F.ratio[4], 1e-3),
          near(summary(model_bez_interakce)$r.squared, 0.075, 0.001))

# Estimated marginal means, their relation to raw means, and conditional effects.
eb <- as.data.frame(emm_bunky)
eb <- eb[order(eb$helma, eb$okraj), ]
vazene <- as.data.frame(emmeans(model_helma, ~ helma | okraj, type = "response",
                                weights = "proportional"))
vazene <- vazene[order(vazene$helma, vazene$okraj), ]
prumer_odmocnin <- cykliste |>
  dplyr::summarise(m = mean(sqrt(vzdalenost_predjeti))^2, .by = c(helma, okraj)) |>
  dplyr::arrange(helma, okraj)
hlavni <- emmeans(model_helma, ~ helma, type = "response") |> regrid() |>
  pairs(reverse = TRUE) |> as.data.frame()
eh <- as.data.frame(summary(efekty_helmy, by = NULL, adjust = "holm", infer = TRUE))
stopifnot(near(eb$response, c(1.65, 1.55, 1.48, 1.42, 1.36, 1.47, 1.43, 1.40, 1.43, 1.38), 0.006),
          near(mean(prumery$M - eb$response), 0.072, 0.002),
          near(range(prumery$M - eb$response), c(0.061, 0.084), 0.001),
          near(mean(vazene$response - eb$response), 0.052, 0.002),
          near(mean(prumery$M - prumer_odmocnin$m), 0.021, 0.002),
          near(hlavni$estimate, -0.068, 0.001),
          near(eh$estimate, c(-0.176, -0.116, -0.079, 0.007, 0.016), 0.001),
          near(eh$lower.CL, c(-0.250, -0.194, -0.177, -0.077, -0.080), 0.001),
          near(eh$upper.CL, c(-0.102, -0.038, 0.020, 0.091, 0.112), 0.001),
          eh$p.value[1] < 0.001, near(eh$p.value[2:3], c(0.0006, 0.117), 0.001),
          all(eh$p.value[4:5] == 1), near(eh$SE[1], 0.029, 0.001))
eo <- as.data.frame(summary(efekty_okraje, by = NULL, adjust = "holm", infer = TRUE))
stopifnot(near(eo$estimate, c(-0.28, -0.09), 0.006), near(eo$lower.CL, c(-0.36, -0.17), 0.006),
          near(eo$upper.CL, c(-0.21, -0.01), 0.006), near(eo$p.value[2], 0.008, 0.001))

# Assumptions.
sw <- shapiro.test(residuals(model_helma))
lev <- rstatix::levene_test(cykliste_odm, odmocnina ~ helma * okraj)
sd_bunky <- tapply(cykliste_odm$odmocnina, list(cykliste_odm$helma, cykliste_odm$okraj), sd)
stopifnot(near(sw$statistic, 0.993, 0.001), sw$p.value < 0.001,
          near(lev$statistic, 1.33), near(lev$p, 0.217, 0.001),
          identical(c(lev$df1, lev$df2), c(9L, 2345L)),
          near(range(sd_bunky), c(0.132, 0.157), 0.001),
          near((max(sd_bunky) / min(sd_bunky))^2, 1.41),
          sum(abs(diagnostika$.std.resid) > 3) == 17L, sum(diagnostika$.std.resid < -3) == 6L,
          near(max(diagnostika$.cooksd), 0.017, 0.001),
          identical(diagnostika$id[which.max(diagnostika$.std.resid)], 1059L),
          identical(diagnostika$id[which.min(diagnostika$.std.resid)], 988L),
          near(range(diagnostika$vzdalenost_predjeti[diagnostika$.std.resid < -3]), c(0.394, 0.70), 0.001),
          near(range(diagnostika$vzdalenost_predjeti[diagnostika$.std.resid > 3]), c(2.88, 3.787), 0.001))
jm <- as.data.frame(joint_tests(model_metry))
em <- emmeans(model_metry, ~ helma | okraj) |> pairs(reverse = TRUE) |>
  summary(by = NULL, adjust = "holm", infer = TRUE) |> as.data.frame()
stopifnot(near(c(psych::skew(residuals(model_metry)), psych::skew(residuals(model_helma))),
               c(0.73, 0.22), 0.006),
          near(jm$F.ratio[4], 6.52), near(em$estimate, c(-0.19, -0.12, -0.08, 0.01, 0.01), 0.006),
          near(em$p.value[3], 0.106, 0.001), max(abs(em$estimate - eh$estimate)) < 0.0105,
          max(rstandard(model_metry)) > 6)

# Independence: blocks, Durbin-Watson, lag-1 correlation, Newey-West sensitivity check.
useky <- rle(paste(cykliste$helma, cykliste$okraj))$lengths
set.seed(123)
dw <- car::durbinWatsonTest(model_helma)
set.seed(123)
dw_again <- car::durbinWatsonTest(model_helma)
r1 <- cor(diagnostika$.resid[-1], diagnostika$.resid[-nrow(diagnostika)])
stopifnot(length(useky) == 47L, median(useky) == 41, max(useky) == 139L,
          near(dw$r, 0.197, 0.001), near(dw$dw, 1.604, 0.001), dw$p == 0,
          identical(dw$p, dw_again$p), near(r1, 0.197, 0.001))
nw <- emmeans(model_helma, ~ helma | okraj, type = "response", vcov. = vcov_nw) |> regrid() |>
  pairs(reverse = TRUE) |> summary(by = NULL, adjust = "holm", infer = TRUE) |> as.data.frame()
jnw <- as.data.frame(joint_tests(model_helma, vcov. = vcov_nw))
stopifnot(near(nw$estimate, eh$estimate, 1e-10), near(nw$SE[1], 0.039, 0.001),
          near(nw$SE[1] / eh$SE[1], 1.35, 0.02),
          near(c(nw$lower.CL[1], nw$upper.CL[1]), c(-0.28, -0.08), 0.006),
          near(c(nw$lower.CL[2], nw$upper.CL[2]), c(-0.22, -0.01), 0.006),
          nw$p.value[1] < 0.001, near(nw$p.value[2:3], c(0.015, 0.16), 0.006),
          near(jnw$F.ratio[4], 4.12), near(jnw$p.value[4], 0.0025, 0.0003))
dwz <- car::durbinWatsonTest(model_zamichany)
se_sorted <- function(model) sort(unname(sqrt(diag(vcov(model)))))
stopifnot(near(dwz$r, -0.025, 0.001), near(dwz$dw, 2.048, 0.001), dwz$p > 0.05,
          isTRUE(all.equal(coef(model_zamichany), coef(model_helma))),
          isTRUE(all.equal(se_sorted(model_zamichany), se_sorted(model_helma))))

# Final task: passenger cars only.
ja <- as.data.frame(joint_tests(model_auta))
ea <- emm_auta |> regrid() |> pairs(reverse = TRUE) |>
  summary(by = NULL, adjust = "holm", infer = TRUE) |> as.data.frame()
set.seed(123)
dwa <- car::durbinWatsonTest(model_auta)
stopifnot(nrow(auta) == 1708L, identical(range(table(auta$helma, auta$okraj)), c(108L, 332L)),
          near(ja$F.ratio[3], 4.18), near(ja$p.value[3], 0.002, 0.0005), all(ja$p.value[1:2] < 0.001),
          near(ea$estimate, c(-0.16, -0.12, -0.12, 0.02, 0.01), 0.006),
          near(c(ea$lower.CL[1], ea$upper.CL[1]), c(-0.25, -0.08), 0.006),
          near(c(ea$lower.CL[3], ea$upper.CL[3]), c(-0.24, -0.002), 0.006),
          near(ea$p.value[2:3], c(0.007, 0.027), 0.001),
          near(as.data.frame(emm_auta)$response[1], 1.71, 0.006),
          near(dwa$r, 0.153, 0.001), near(dwa$dw, 1.693, 0.001), dwa$p == 0)

# The standalone final solution must run without objects from the lesson.
standalone <- "quarto/_verification/standalone-solution-11.R"
writeLines(enc2utf8(chunks[["l11-reseni-samostatne"]]$code), standalone, useBytes = TRUE)
status <- system2(file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"),
                  c("--vanilla", standalone), stdout = TRUE, stderr = TRUE)
stopifnot(is.null(attr(status, "status")) || attr(status, "status") == 0L,
          any(grepl("4.184", status, fixed = TRUE)))
unlink(standalone)

# When the local JASP source is available, the public RDS must reproduce its values.
jasp_packages <- c("DBI", "RSQLite", "jsonlite")
if (file.exists("data/raw/bicyclists2025.jasp") &&
    all(vapply(jasp_packages, requireNamespace, logical(1), quietly = TRUE))) {
  source("scripts/read_jasp.R", encoding = "UTF-8")
  original <- read_jasp("data/raw/bicyclists2025.jasp")
  original <- original[order(original$id), ]
  public <- readRDS("data/clean/cykliste.rds")
  stopifnot(identical(public$id, as.integer(original$id)),
            identical(public$vzdalenost_predjeti, as.numeric(original$pass_distance)),
            identical(as.integer(public$vozidlo), as.integer(original$vehicle)),
            identical(as.integer(public$barva), as.integer(original$color)),
            identical(as.integer(public$ulice), as.integer(original$street)),
            identical(as.integer(public$helma), as.integer(original$helmet)),
            identical(as.integer(public$okraj), as.integer(original$kerb)),
            identical(as.integer(public$cyklopruh), as.integer(original$bikelane)),
            identical(as.integer(public$mesto), as.integer(original$city)),
            is.null(attr(public, "jasp")))
  cat("PASS: public RDS matches the local JASP source.\n")
}

cat("PASS lesson 11: all chunks and solutions, data and design, descriptives, transformation,",
    "one-way model with Welch and effect sizes, contrast, factorial model, joint tests equal to Type III,",
    "eta and omega squared, marginal means, conditional effects, assumptions, Durbin-Watson,",
    "Newey-West check, shuffled rows and standalone final solution.\n")
