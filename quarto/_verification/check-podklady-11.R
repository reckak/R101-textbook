# Checks the teaching handout podklady/podklady_11.qmd against lesson 11.
#
# - Every visible (eval: false) code block of the handout is identical to a code
#   block of quarto/lekce_11.qmd, so the handout cannot drift from the chapter.
# - Every such block except the installation has exactly one hidden output block
#   (ref.label) inside a collapsed "Ukázat výstup" callout, and every ref.label
#   points to a visible block; output blocks carry no code of their own.
# - Labels are unique; the handout has no exercises or solutions.
# - Time budget: at most 20 output blocks before "Pokud zbude čas" and at most
#   40 minutes in the schedule table of the introduction.
# - If the rendered HTML exists, it has one collapsed "Ukázat výstup" callout per
#   output block and none of them is open by default.
# Run from the repository root:
#   Rscript --vanilla quarto/_verification/check-podklady-11.R

read_utf8 <- function(path) {
  x <- readLines(path, encoding = "UTF-8", warn = FALSE)
  sub("\r$", "", x)
}

fail <- character()
check <- function(ok, msg) if (!isTRUE(ok)) fail <<- c(fail, msg)

parse_chunks <- function(lines) {
  starts <- which(grepl("^```\\{r", lines))
  lapply(starts, function(s) {
    e <- s + which(lines[(s + 1):length(lines)] == "```")[1]
    body <- if (e > s + 1) lines[(s + 1):(e - 1)] else character()
    opt_lines <- grep("^#\\| ", body, value = TRUE)
    code <- body[!grepl("^#\\| ", body)]
    while (length(code) && code[length(code)] == "") code <- code[-length(code)]
    opt <- function(name) {
      v <- sub(sprintf("^#\\| %s: ", name), "", grep(sprintf("^#\\| %s: ", name), opt_lines, value = TRUE))
      if (length(v)) v else NA_character_
    }
    list(start = s, label = opt("label"), eval = opt("eval"), ref = opt("ref.label"),
         code = paste(code, collapse = "\n"))
  })
}

qmd <- read_utf8("podklady/podklady_11.qmd")
lesson <- read_utf8("quarto/lekce_11.qmd")
chunks <- parse_chunks(qmd)
lesson_code <- vapply(parse_chunks(lesson), `[[`, "", "code")

labels <- vapply(chunks, `[[`, "", "label")
check(!anyNA(labels), "every code block needs a label")
check(!anyDuplicated(labels), sprintf("duplicated labels: %s", paste(labels[duplicated(labels)], collapse = ", ")))
check(all(grepl("^pk11-", labels)), "labels must start with pk11-")

visible <- Filter(function(ch) identical(ch$eval, "false"), chunks)
outputs <- Filter(function(ch) !is.na(ch$ref), chunks)
check(length(visible) + length(outputs) == length(chunks),
      "every block is either visible (eval: false) or an output block (ref.label)")

for (ch in visible) {
  check(ch$code %in% lesson_code, sprintf("%s: code differs from every block of lekce_11.qmd", ch$label))
}

vis_labels <- vapply(visible, `[[`, "", "label")
ref_labels <- vapply(outputs, `[[`, "", "ref")
callout <- '::: {.callout-tip collapse="true" title="Ukázat výstup"}'
for (ch in outputs) {
  check(ch$ref %in% vis_labels, sprintf("%s: ref.label %s is not a visible block", ch$label, ch$ref))
  check(ch$code == "", sprintf("%s: output block must not contain code", ch$label))
  check(qmd[ch$start - 1] == callout, sprintf("%s: not directly inside a collapsed output callout", ch$label))
}
for (l in setdiff(vis_labels, "pk11-instalace")) {
  check(sum(ref_labels == l) == 1, sprintf("%s: expected exactly one output block", l))
}
check(!"pk11-instalace" %in% ref_labels, "installation must not be run")
check(sum(qmd == callout) == length(outputs), "every output callout holds one output block")

check(!any(grepl("Ukázat řešení|\\.exercise", qmd)), "handout must not contain exercises or solutions")

# Time budget ---------------------------------------------------------------
extra_start <- which(grepl("^## Pokud zbude čas", qmd))
check(length(extra_start) == 1, "section 'Pokud zbude čas' missing")
main_outputs <- sum(vapply(outputs, `[[`, 0, "start") < extra_start)
rows <- grep("^\\| [^-:].*\\| *[0-9]+ \\| *[0-9]+ \\|$", qmd, value = TRUE)
minutes <- as.integer(vapply(strsplit(rows, "\\|"), function(x) trimws(x[3]), ""))
cumulative <- as.integer(vapply(strsplit(rows, "\\|"), function(x) trimws(x[4]), ""))
check(length(minutes) > 0, "schedule table missing")
check(identical(cumsum(minutes), cumulative), "cumulative minutes do not add up")
check(sum(minutes) <= 40, sprintf("schedule has %d minutes (max 40)", sum(minutes)))
check(main_outputs <= 20, sprintf("%d output blocks in the main part (max 20)", main_outputs))
check(!any(grepl("^#{2,3} .*\\bmin\\b", qmd)), "headings must not contain times")

# Rendered HTML ---------------------------------------------------------------
html_path <- "podklady/podklady_11.html"
if (file.exists(html_path)) {
  html <- paste(read_utf8(html_path), collapse = "\n")
  count <- function(rx) lengths(regmatches(html, gregexpr(rx, html)))
  n_titles <- count('title="Ukázat výstup"')
  n_open <- count('callout-[0-9]+-contents callout-collapse collapse show"')
  n_closed <- count('callout-[0-9]+-contents callout-collapse collapse"')
  check(n_titles == length(outputs), sprintf("HTML: %d output callouts, expected %d", n_titles, length(outputs)))
  check(n_open == 0, "HTML: some output callouts are open by default")
  check(n_closed == length(outputs), sprintf("HTML: %d collapsed callouts, expected %d", n_closed, length(outputs)))
  check(!grepl("Error in|Chyba v", html), "HTML: an R error appears in the output")
} else {
  message("HTML not found; render podklady/podklady_11.qmd to check it as well.")
}

cat(sprintf("Visible code blocks: %d; output blocks: %d (main part %d, extra %d); schedule %d min\n",
            length(visible), length(outputs), main_outputs, length(outputs) - main_outputs, sum(minutes)))
if (length(fail)) {
  cat("FAILED:\n", paste0("- ", fail, collapse = "\n"), "\n")
  quit(status = 1)
}
cat("OK\n")
