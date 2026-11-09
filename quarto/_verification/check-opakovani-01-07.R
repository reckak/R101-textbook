# Checks the standalone quiz review opakovani/opakovani_testy_01-07.qmd
# against the IS MUNI quizzes tests/test_01.txt ... tests/test_07.txt.
#
# For every quiz question the review must contain a heading "### N.k <title>",
# the question text and options A-D identical to the quiz (inline-code
# backticks are ignored), and a collapsed solution stating the keyed answer.
# Run from the repository root:
#   Rscript --vanilla quarto/_verification/check-opakovani-01-07.R

read_utf8 <- function(path) {
  x <- readLines(path, encoding = "UTF-8", warn = FALSE)
  sub("\r$", "", x)
}

fail <- character()
check <- function(ok, msg) if (!isTRUE(ok)) fail <<- c(fail, msg)
strip_code <- function(x) gsub("`", "", x, fixed = TRUE)

# Quizzes ------------------------------------------------------------------
parse_quiz <- function(path) {
  lines <- read_utf8(path)
  blocks <- split(lines[lines != "--"], cumsum(lines[lines != "--"] |> grepl(pattern = "^::")))
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

# Review document ----------------------------------------------------------
qmd <- read_utf8("opakovani/opakovani_testy_01-07.qmd")
heading_rx <- "^### ([1-7])\\.([0-9]+) (.+) \\{#sec-t([1-7])-q([0-9]+)\\}$"
extra_rx <- "^### Úloha navíc ([1-7])\\.[AB]: .+ \\{#sec-t([1-7])-extra-[ab]\\}$"
callout <- '::: {.callout-note collapse="true" title="Ukázat řešení"}'

h3 <- which(grepl("^### ", qmd))
section_end <- function(i) {
  nxt <- h3[h3 > i]
  nxt_h2 <- which(grepl("^## ", qmd) & seq_along(qmd) > i)
  min(c(nxt, nxt_h2, length(qmd) + 1)) - 1
}

n_questions <- 0
for (n in 1:7) {
  quiz <- parse_quiz(sprintf("tests/test_%02d.txt", n))
  check(length(quiz) == 10, sprintf("test %d: expected 10 quiz questions", n))
  for (k in seq_along(quiz)) {
    q <- quiz[[k]]
    i <- which(grepl(sprintf("^### %d\\.%d ", n, k), qmd))
    if (length(i) != 1) {
      fail <- c(fail, sprintf("%d.%d: heading missing or duplicated", n, k))
      next
    }
    n_questions <- n_questions + 1
    check(grepl(heading_rx, qmd[i]), sprintf("%d.%d: heading/id format", n, k))
    check(sub(heading_rx, "\\3", qmd[i]) == strip_code(q$title) ||
            strip_code(sub(heading_rx, "\\3", qmd[i])) == q$title,
          sprintf("%d.%d: title differs from quiz", n, k))
    check(identical(sub(heading_rx, "\\4.\\5", qmd[i]), sprintf("%d.%d", n, k)),
          sprintf("%d.%d: section id does not match the number", n, k))
    body <- qmd[(i + 1):section_end(i)]
    text <- body[nzchar(body)][1]
    check(strip_code(text) == q$text, sprintf("%d.%d: question text differs from quiz", n, k))
    opts <- body[grepl("^- \\*\\*[A-D]\\*\\* ", body)][1:4]
    check(all(sub("^- \\*\\*([A-D])\\*\\* .*$", "\\1", opts) == LETTERS[1:4]),
          sprintf("%d.%d: options are not A-D in order", n, k))
    check(identical(strip_code(sub("^- \\*\\*[A-D]\\*\\* ", "", opts)), q$options),
          sprintf("%d.%d: options differ from quiz", n, k))
    check(sum(body == callout) == 1, sprintf("%d.%d: expected one collapsed solution", n, k))
    first_after <- body[which(body == callout)[1] + 1]
    check(identical(first_after, sprintf("**Správná odpověď: %s.**", LETTERS[q$key])) ||
            startsWith(first_after, sprintf("**Správná odpověď: %s.** ", LETTERS[q$key])),
          sprintf("%d.%d: stated answer differs from key %s", n, k, LETTERS[q$key]))
  }
  extras <- which(grepl(sprintf("^### Úloha navíc %d\\.", n), qmd))
  check(length(extras) %in% 1:2, sprintf("test %d: expected 1-2 extra tasks", n))
  for (i in extras) {
    check(grepl(extra_rx, qmd[i]), sprintf("extra task heading/id format: %s", qmd[i]))
    check(sum(qmd[(i + 1):section_end(i)] == callout) == 1,
          sprintf("extra task without one collapsed solution: %s", qmd[i]))
  }
}

# Every solution callout is collapsed; ids are unique.
solutions <- grepl("Ukázat řešení", qmd, fixed = TRUE) & grepl("^:::", qmd)
check(all(qmd[solutions] == callout), "a solution callout is not collapsed or differs in format")
ids <- regmatches(qmd, regexpr("\\{#[^}]+\\}", qmd))
check(!anyDuplicated(ids), "duplicated section ids")
labels <- sub("^#\\| label: ", "", qmd[grepl("^#\\| label: ", qmd)])
check(!anyDuplicated(labels), "duplicated chunk labels")

n_extra <- sum(grepl("^### Úloha navíc ", qmd))
cat(sprintf("Questions checked: %d, extra tasks: %d, collapsed solutions: %d\n",
            n_questions, n_extra, sum(qmd == callout)))
check(n_questions == 70, "expected 70 quiz questions")
check(sum(qmd == callout) == 70 + n_extra, "number of solutions differs from questions + extra tasks")

if (length(fail)) {
  cat("FAILED:\n", paste0(" - ", fail, collapse = "\n"), "\n", sep = "")
  quit(status = 1)
}
cat("OK\n")
