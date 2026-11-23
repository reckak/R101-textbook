# Checks the teaching handout podklady/podklady_11.qmd against lesson 11 and quiz 11.
#
# Handout part (everything before "## Test k lekci 11"):
# - Every visible (eval: false) code block is identical to a code block of
#   quarto/lekce_11.qmd, so the handout cannot drift from the chapter.
# - Every such block except the installation has exactly one output block
#   (ref.label, no code of its own) directly inside a fixed green box
#   '::: {.callout-tip title="Výstup"}'; every ref.label points to a visible block.
# - Labels are unique; this part has no exercises or solutions.
# - Time budget: at most 20 output blocks before "Pokud zbude čas" and at most
#   40 minutes in the schedule table of the introduction; no times in headings.
# Quiz part ("## Test k lekci 11"):
# - Each of the 10 questions of tests/test_11.txt has a heading "### 11.k <title>",
#   the same question text and options A-D (inline-code backticks are ignored)
#   and a collapsed solution starting with the keyed answer.
# Rendered HTML (if it exists): 29 output boxes that cannot be collapsed and
# 10 quiz solutions that are collapsed by default.
# Run from the repository root:
#   Rscript --vanilla quarto/_verification/check-podklady-11.R

read_utf8 <- function(path) {
  x <- readLines(path, encoding = "UTF-8", warn = FALSE)
  sub("\r$", "", x)
}

fail <- character()
check <- function(ok, msg) if (!isTRUE(ok)) fail <<- c(fail, msg)
strip_code <- function(x) gsub("`", "", x, fixed = TRUE)

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
lesson_code <- vapply(parse_chunks(lesson), `[[`, "", "code")

test_start <- which(grepl("^## Test k lekci 11", qmd))
check(length(test_start) == 1, "section 'Test k lekci 11' missing")
handout <- qmd[seq_len(test_start - 1)]
quiz_part <- qmd[test_start:length(qmd)]

chunks <- parse_chunks(qmd)
labels <- vapply(chunks, `[[`, "", "label")
check(!anyNA(labels), "every code block needs a label")
check(!anyDuplicated(labels), sprintf("duplicated labels: %s", paste(labels[duplicated(labels)], collapse = ", ")))
check(all(grepl("^pk11-", labels)), "labels must start with pk11-")

# Handout part ----------------------------------------------------------------
main_chunks <- Filter(function(ch) ch$start < test_start, chunks)
visible <- Filter(function(ch) identical(ch$eval, "false"), main_chunks)
outputs <- Filter(function(ch) !is.na(ch$ref), main_chunks)
check(length(visible) + length(outputs) == length(main_chunks),
      "every handout block is either visible (eval: false) or an output block (ref.label)")

for (ch in visible) {
  check(ch$code %in% lesson_code, sprintf("%s: code differs from every block of lekce_11.qmd", ch$label))
}

vis_labels <- vapply(visible, `[[`, "", "label")
ref_labels <- vapply(outputs, `[[`, "", "ref")
box <- '::: {.callout-tip title="Výstup"}'
for (ch in outputs) {
  check(ch$ref %in% vis_labels, sprintf("%s: ref.label %s is not a visible block", ch$label, ch$ref))
  check(ch$code == "", sprintf("%s: output block must not contain code", ch$label))
  check(qmd[ch$start - 1] == box, sprintf("%s: not directly inside an output box", ch$label))
}
for (l in setdiff(vis_labels, "pk11-instalace")) {
  check(sum(ref_labels == l) == 1, sprintf("%s: expected exactly one output block", l))
}
check(!"pk11-instalace" %in% ref_labels, "installation must not be run")
check(sum(handout == box) == length(outputs), "every output box holds one output block")
check(!any(grepl("Ukázat řešení|\\.exercise|collapse=", handout)),
      "handout part must not contain exercises, solutions or collapsed blocks")

extra_start <- which(grepl("^## Pokud zbude čas", qmd))
check(length(extra_start) == 1 && extra_start < test_start, "section 'Pokud zbude čas' missing or after the quiz")
main_outputs <- sum(vapply(outputs, `[[`, 0, "start") < extra_start)
rows <- grep("^\\| [^-:].*\\| *[0-9]+ \\| *[0-9]+ \\|$", handout, value = TRUE)
minutes <- as.integer(vapply(strsplit(rows, "\\|"), function(x) trimws(x[3]), ""))
cumulative <- as.integer(vapply(strsplit(rows, "\\|"), function(x) trimws(x[4]), ""))
check(length(minutes) > 0, "schedule table missing")
check(identical(cumsum(minutes), cumulative), "cumulative minutes do not add up")
check(sum(minutes) <= 40, sprintf("schedule has %d minutes (max 40)", sum(minutes)))
check(main_outputs <= 20, sprintf("%d output blocks in the main part (max 20)", main_outputs))
check(!any(grepl("^#{2,3} .*\\bmin\\b", qmd)), "headings must not contain times")

# Quiz part -------------------------------------------------------------------
parse_quiz <- function(path) {
  lines <- read_utf8(path)
  lines <- lines[lines != "--"]
  blocks <- split(lines, cumsum(grepl("^::", lines)))
  lapply(blocks, function(b) {
    stopifnot(length(b) == 9)
    list(
      title = sub("^::([^:]+)::.*$", "\\1", b[1]),
      text = sub("^::[^:]+::", "", b[1]),
      options = sub("^ :r[1-4] ", "", b[2:5]),
      key = which(grepl("^:r[1-4] ok ", b[6:9]))
    )
  })
}

quiz <- parse_quiz("tests/test_11.txt")
check(length(quiz) == 10, "tests/test_11.txt: expected 10 questions")
solution <- '::: {.callout-note collapse="true" title="Ukázat řešení"}'
h3 <- which(grepl("^### ", quiz_part))
for (k in seq_along(quiz)) {
  q <- quiz[[k]]
  i <- which(grepl(sprintf("^### 11\\.%d ", k), quiz_part))
  if (length(i) != 1) {
    fail <- c(fail, sprintf("11.%d: heading missing or duplicated", k))
    next
  }
  heading_rx <- sprintf("^### 11\\.%d (.+) \\{#pk11-t-q%d\\}$", k, k)
  check(grepl(heading_rx, quiz_part[i]), sprintf("11.%d: heading/id format", k))
  check(strip_code(sub(heading_rx, "\\1", quiz_part[i])) == q$title, sprintf("11.%d: title differs from the quiz", k))
  end <- min(c(h3[h3 > i], length(quiz_part) + 1)) - 1
  sec <- quiz_part[i:end]
  nonempty <- sec[sec != ""]
  check(strip_code(nonempty[2]) == q$text, sprintf("11.%d: question text differs from the quiz", k))
  for (j in 1:4) {
    opt <- sprintf("- **%s** %s", LETTERS[j], q$options[j])
    check(strip_code(nonempty[2 + j]) == opt, sprintf("11.%d: option %s differs from the quiz", k, LETTERS[j]))
  }
  s <- which(sec == solution)
  check(length(s) == 1, sprintf("11.%d: expected one collapsed solution", k))
  if (length(s) == 1) {
    check(startsWith(sec[s + 1], sprintf("**Správná odpověď: %s.**", LETTERS[q$key])),
          sprintf("11.%d: solution must start with the keyed answer %s", k, LETTERS[q$key]))
    wrong <- LETTERS[setdiff(1:4, q$key)]
    for (w in wrong) {
      check(any(startsWith(sec[(s + 1):length(sec)], sprintf("- **%s** ", w))),
            sprintf("11.%d: solution does not explain option %s", k, w))
    }
  }
}
check(sum(quiz_part == solution) == length(quiz), "quiz: one solution per question")

# Rendered HTML ---------------------------------------------------------------
html_path <- "podklady/podklady_11.html"
if (file.exists(html_path)) {
  html <- paste(read_utf8(html_path), collapse = "\n")
  count <- function(rx) lengths(regmatches(html, gregexpr(rx, html)))
  check(count('title="Výstup"') == length(outputs),
        sprintf("HTML: %d output boxes, expected %d", count('title="Výstup"'), length(outputs)))
  check(count('title="Ukázat řešení"') == length(quiz), "HTML: expected one solution per quiz question")
  check(count('callout-[0-9]+-contents callout-collapse collapse"') == length(quiz),
        "HTML: only the quiz solutions may be collapsible, and they must start collapsed")
  check(count("callout-collapse collapse show") == 0, "HTML: a collapsible block is open by default")
  check(!grepl("Error in|Chyba v", html), "HTML: an R error appears in the output")
} else {
  message("HTML not found; render podklady/podklady_11.qmd to check it as well.")
}

cat(sprintf("Visible code blocks: %d; output boxes: %d (main part %d, extra %d); schedule %d min; quiz questions: %d\n",
            length(visible), length(outputs), main_outputs, length(outputs) - main_outputs,
            sum(minutes), length(quiz)))
if (length(fail)) {
  cat("FAILED:\n", paste0("- ", fail, collapse = "\n"), "\n")
  quit(status = 1)
}
cat("OK\n")
