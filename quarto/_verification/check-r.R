lines <- readLines("quarto/lekce_01.qmd", encoding = "UTF-8")
starts <- which(grepl("^```\\{r\\}", lines))
chunks <- lapply(starts, function(start) {
  end <- start + which(lines[(start + 1):length(lines)] == "```")[1]
  text <- lines[(start + 1):(end - 1)]
  label <- sub("#\\| label: ", "", text[grepl("^#\\| label:", text)])
  list(label = label, code = text[!grepl("^#\\|", text)])
})
names(chunks) <- vapply(chunks, function(chunk) chunk$label, character(1))

# A separate R process verifies that the final answer has no lesson-state dependency.
standalone <- "quarto/_verification/standalone-solution.R"
writeLines(enc2utf8(c("grDevices::pdf(file = NULL)",
                     chunks[["fig-reseni-samostatne"]]$code,
                     "grDevices::dev.off()")), standalone, useBytes = TRUE)
status <- system2(file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"),
                  c("--vanilla", standalone),
                  stdout = "quarto/_verification/standalone.log",
                  stderr = "quarto/_verification/standalone-errors.log")
stopifnot(status == 0L)

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(palmerpenguins))
suppressPackageStartupMessages(library(ggthemes))
stopifnot(nrow(penguins) == 344L, ncol(penguins) == 8L)
usable <- complete.cases(penguins[c("flipper_length_mm", "body_mass_g")])
stopifnot(sum(usable) == 342L)
stopifnot(mean(c(480, 520, 610, 550, 490)) == 530)
stopifnot(round(sd(c(480, 520, 610, 550, 490)), 2) == 52.44)
stopifnot(mean(c(8, 11, 15, 10, 16)) == 12)
stopifnot(round(sd(c(8, 11, 15, 10, 16)), 2) == 3.39)
stopifnot(identical(seq(from = 1, to = 10, by = 2), c(1, 3, 5, 7, 9)))

# Compare data and model layer with the last (complete) graph in the source script.
source_lines <- readLines("scripts/week_01.R", encoding = "UTF-8")
last_plot <- tail(which(grepl("^ggplot\\(data = penguins", source_lines)), 1)
original_plot <- eval(parse(text = source_lines[last_plot:length(source_lines)]))
grDevices::pdf(file = NULL)
eval(parse(text = chunks[["fig-tucnaci-final"]]$code))
grDevices::dev.off()
old_layers <- suppressWarnings(ggplot_build(original_plot)$data)
new_layers <- suppressWarnings(ggplot_build(graf_tucnaci)$data)
stopifnot(isTRUE(all.equal(old_layers[[1]][c("x", "y", "colour", "shape", "size")],
                           new_layers[[1]][c("x", "y", "colour", "shape", "size")],
                           check.attributes = FALSE)))
stopifnot(isTRUE(all.equal(old_layers[[2]][c("x", "y", "ymin", "ymax")],
                           new_layers[[2]][c("x", "y", "ymin", "ymax")],
                           tolerance = 1e-10, check.attributes = FALSE)))
stopifnot(length(unique(new_layers[[2]]$group)) == 1L)
stopifnot(file.exists("output/figures/tucnaci.png"),
          file.exists("output/figures/tucnaci_samostatne.png"))
for (label in c("pracovni-adresar", "napoveda-seq", "napoveda-penguins")) {
  eval(parse(text = chunks[[label]]$code))
}
cat("PASS: numerical interpretations, 342 usable rows, unchanged final plot data and model,\n")
cat("standalone final solution in Rscript --vanilla, interactive help and working directory.\n")
print(sessionInfo())
