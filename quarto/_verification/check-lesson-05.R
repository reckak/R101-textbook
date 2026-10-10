# Run from the project root in a clean Rscript --vanilla session.
lines <- readLines("quarto/lekce_05.qmd", encoding = "UTF-8")
starts <- which(grepl("^```\\{r\\}", lines))
chunks <- lapply(starts, function(start) {
  end <- start + which(lines[(start + 1):length(lines)] == "```")[1]
  text <- lines[(start + 1):(end - 1)]
  label <- sub("#\\| label: ", "", text[grepl("^#\\| label:", text)])
  stopifnot(length(label) == 1L)
  list(label = label, code = text[!grepl("^#\\|", text)],
       skip = any(text == "#| eval: false"))
})
names(chunks) <- vapply(chunks, function(x) x$label, character(1))
stopifnot(!anyDuplicated(names(chunks)))
stopifnot(setequal(names(chunks)[vapply(chunks, function(x) x$skip, logical(1))],
                  c("l05-instalace", "l05-url-csv", "l05-url-download")))
for (chunk in chunks) {
  if (chunk$skip) next
  cat("\nCHUNK:", chunk$label, "\n")
  seen_warnings <- character()
  withCallingHandlers({
    for (expression in parse(text = chunk$code)) {
      value <- withVisible(eval(expression, envir = .GlobalEnv))
      if (value$visible) print(value$value)
    }
  }, warning = function(w) {
    seen_warnings <<- c(seen_warnings, conditionMessage(w))
  })
  relevant <- if (chunk$label == "l05-balicky") {
    seen_warnings[!grepl("was built under R version", seen_warnings, fixed = TRUE)]
  } else seen_warnings
  if (chunk$label == "l05-chyba-parser") {
    stopifnot(length(relevant) == 1L, grepl("parsing issues", relevant))
  } else if (length(relevant)) {
    stop("Unexpected warning in ", chunk$label, ": ", paste(relevant, collapse = "; "))
  }
  if (chunk$label == "l05-nazvy-rucne") {
    stopifnot(identical(names(students), names(students_raw)))
    manual <- students |> rename(student_id = `Student ID`, full_name = `Full Name`,
                                  favourite_food = favourite.food, meal_plan = mealPlan, age = AGE)
    stopifnot(identical(manual, janitor::clean_names(students)))
  }
  if (chunk$label == "l05-hs-shoda-pred") {
    stopifnot(setequal(names(hs), codebook$name), "finantial_situation" %in% names(hs))
  }
  if (chunk$label == "l05-hs-nazvy") {
    stopifnot(identical(setdiff(names(hs), codebook$name), "financial_situation"),
              identical(setdiff(codebook$name, names(hs)), "finantial_situation"))
  }
}

# The fixture must demonstrate a real decoding error, then preserve correct Czech and IDs.
stopifnot(identical(dim(odpovedi), c(6L, 2L)),
          identical(odpovedi$id, sprintf("%03d", 1:6)),
          identical(odpovedi$odpoved[1], "Při zkoušce se často cítím napjatě."),
          all(validUTF8(odpovedi$odpoved)), !all(validUTF8(odpovedi_chybne$odpoved)),
          "windows-1250" %in% tolower(odhad_kodovani$encoding))

# Original input remains available and the cleaning conserves rows and values.
stopifnot(identical(dim(students), c(6L, 5L)),
          identical(students$age, c(4L, 5L, 7L, NA_integer_, 5L, 6L)),
          sum(is.na(students$favourite_food)) == 1L,
          identical(as.integer(table(students$meal_plan)), c(2L, 4L)),
          identical(kratka_data$id, c("001", "002")),
          nrow(problems(skore_problem)) == 1L, nrow(problems(skore_ok)) == 0L,
          identical(skore_problem$skore, skore_ok$skore),
          identical(reakce$cas_s, c(0.45, NA, 0.62)), nrow(problems(reakce)) == 0L)
stopifnot(identical(dim(international), c(20L, 7L)),
          identical(as.integer(table(international$contint)), c(9L, 5L, 3L, 3L)),
          identical(haven::as_factor(international_raw$contint), international$contint))
stopifnot(identical(dim(hs), c(172L, 34L)),
          sum(is.na(hs$age)) == 5L, sum(is.na(hs$help_01)) == 7L,
          setequal(names(hs), codebook$name), !anyDuplicated(codebook$name),
          all(!is.na(codebook$label)),
          is.factor(hs$gender), is.factor(hs$partner),
          is.factor(hs$college_title), is.factor(hs$college_student),
          all(is.na(hs$help_01) | as.numeric(hs$help_01) %in% 1:4),
          identical(val_labels(hs$help_01), help_labels),
          identical(val_labels(hs$emo_17), emo_labels),
          identical(as.integer(table(hs$gender)), c(129L, 35L, 3L)),
          identical(as.integer(table(hs$financial_situation)), c(13L, 114L, 40L)),
          identical(as.integer(table(help_01_kategorie)), c(25L, 58L, 54L, 28L)),
          is.numeric(help_01_cisla), !haven::is.labelled(help_01_cisla),
          identical(as.numeric(hs$help_01), as.numeric(help_01_cisla)),
          identical(as.numeric(hs_cv$vek), as.numeric(hs$age)),
          identical(is.na(odpoved_na), c(FALSE, FALSE, TRUE, TRUE)),
          identical(as.numeric(mean(odpoved_spss, na.rm = TRUE)), 4),
          identical(as.numeric(mean(odpoved_na, na.rm = TRUE)), 1.5),
          identical(is.na(x), c(FALSE, FALSE, TRUE)))
# Across matches the explicit one-column conversions, including NA positions.
for (name in c("partner", "college_title", "college_student")) {
  raw <- hs_raw[[name]]
  raw[raw == -99] <- NA
  expected <- factor(raw, levels = 1:2, labels = c("Ne", "Ano"))
  stopifnot(identical(as.character(hs[[name]]), as.character(expected)))
}
for (name in grep("^(help_|emo_)", names(hs), value = TRUE)) {
  raw <- hs_raw[[name]]
  raw[raw == -99] <- NA
  stopifnot(identical(as.numeric(hs[[name]]), raw))
}
stopifnot(identical(dim(four), c(1084L, 21L)), nrow(four_wrong) == 1085L,
          is.numeric(four$q1_prop_1), is.character(four_wrong$q1_prop_1),
          length(four_names) == length(four_labels), nrow(four_dictionary) == 21L,
          identical(as.integer(table(four$country)), c(361L, 258L, 216L, 249L)),
          identical(as.character(excel_numeric_to_date(c(45345, 45346))), c("2024-02-23", "2024-02-24")),
          inherits(kalendarni_data, "Date"),
          identical(as.character(kalendarni_data), c("2024-02-23", "2024-02-24")),
          identical(hs, hs_znovu), is.character(hs_z_csv$gender),
          is.null(val_labels(hs_z_csv$help_01)),
          identical(sort(obnovena_jmena), c("international", "students")),
          identical(dotaznik, dotaznik_znovu), n_distinct(dotaznik$id) == 172L,
          !anyNA(dotaznik$id))

# Check the approved public subset and, when available locally, every retained source cell.
expected_names <- c(paste0("q", 1:6, "_prop_1"), paste0("q", 1:8, "_anx_1"),
                    paste0("q", 1:3, "_p_ai_1"), paste0("q", 4:6, "_ado_ai_1"), "country")
stopifnot(identical(names(four), expected_names), all(vapply(four[1:20], is.numeric, logical(1))))
if (file.exists("data/raw/four_countries_data.xlsx")) {
  original_names <- read_excel("data/raw/four_countries_data.xlsx", n_max = 0) |>
    janitor::clean_names() |> names()
  original <- read_excel("data/raw/four_countries_data.xlsx", skip = 3, col_names = original_names)
  for (name in expected_names) {
    stopifnot(identical(as.vector(four[[name]]), original[[name]]))
  }
  original_labels <- read_excel("data/raw/four_countries_data.xlsx", skip = 1, n_max = 0) |> names()
  stopifnot(identical(four_labels, original_labels[match(expected_names, original_names)]))
  cat("PASS: public subset retains every selected source value and row.\n")
}

# The final solution must run without chapter state in a second clean process.
standalone <- "quarto/_verification/standalone-solution.R"
writeLines(enc2utf8(chunks[["l05-reseni-samostatne"]]$code), standalone, useBytes = TRUE)
status <- system2(file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"),
                  c("--vanilla", standalone), stdout = "quarto/_verification/lesson05-standalone.log",
                  stderr = "quarto/_verification/lesson05-standalone-errors.log")
stopifnot(status == 0L)
cat("PASS: every executable lesson 05 block and solution, expected parser warning, interpretations, labels, factors and exports.\n")
