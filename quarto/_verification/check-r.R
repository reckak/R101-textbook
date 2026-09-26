lines <- c(readLines("quarto/lekce_01.qmd", encoding = "UTF-8"),
           readLines("quarto/lekce_02.qmd", encoding = "UTF-8"))
starts <- which(grepl("^```\\{r\\}", lines))
chunks <- lapply(starts, function(start) {
  end <- start + which(lines[(start + 1):length(lines)] == "```")[1]
  text <- lines[(start + 1):(end - 1)]
  label <- sub("#\\| label: ", "", text[grepl("^#\\| label:", text)])
  list(label = label, code = text[!grepl("^#\\|", text)])
})
names(chunks) <- vapply(chunks, function(chunk) chunk$label, character(1))

# A separate R process verifies that the final answer has no lesson-state dependency.
for (solution_label in c("reseni-samostatny-skript", "fig-reseni-samostatne")) {
  standalone <- "quarto/_verification/standalone-solution.R"
  writeLines(enc2utf8(c("grDevices::pdf(file = NULL)",
                       chunks[[solution_label]]$code,
                       "grDevices::dev.off()")), standalone, useBytes = TRUE)
  status <- system2(file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"),
                    c("--vanilla", standalone),
                    stdout = "quarto/_verification/standalone.log",
                    stderr = "quarto/_verification/standalone-errors.log")
  stopifnot(status == 0L)
}

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
cat("both standalone final solutions in Rscript --vanilla, interactive help and working directory.\n")
# Check the numbers described in the new chapter against the actual dataset.
stopifnot(identical(as.integer(table(penguins$species)), c(152L, 68L, 124L)))
stopifnot(identical(as.integer(table(penguins$island)), c(168L, 124L, 52L)))
stopifnot(sum(is.na(penguins$sex)) == 11L)
stopifnot(identical(range(penguins$body_mass_g, na.rm = TRUE), c(2700L, 6300L)))
medians <- tapply(penguins$body_mass_g, penguins$species, median, na.rm = TRUE)
stopifnot(identical(as.numeric(medians), c(3700, 3700, 5000)))
print(table(penguins$island, penguins$species))
print(medians)
# Validate computed graphical summaries, not only source syntax.
plot_from <- function(label) eval(parse(text = chunks[[label]]$code))
histogram <- ggplot_build(plot_from("fig-histogram"))$data[[1]]
stopifnot(sum(histogram$count) == 342L)
box <- ggplot_build(plot_from("fig-boxplot"))$data[[1]]
stopifnot(isTRUE(all.equal(box$middle, as.numeric(medians))))
counts <- ggplot_build(plot_from("fig-ostrovy-pocty"))$data[[1]]
stopifnot(sum(counts$count) == 344L)
proportions <- ggplot_build(plot_from("fig-ostrovy-podily"))$data[[1]]
stopifnot(all(tapply(proportions$ymax, proportions$x, max) == 1))
separate <- ggplot_build(plot_from("fig-primky-druhy"))$data[[2]]
stopifnot(length(unique(separate$group)) == 3L)
panels <- ggplot_build(plot_from("fig-panely"))$layout$layout
stopifnot(nrow(panels) == 3L)
# Every within-species fitted slope is positive, as described in the panel solution.
slopes <- sapply(split(penguins, penguins$species), function(d) coef(lm(body_mass_g ~ flipper_length_mm, data = d))[2])
stopifnot(all(slopes > 0))
cat("PASS: new chapter counts, medians, histogram total, proportions, grouped trends and facets.\n")
print(slopes)
print(sessionInfo())

# Execute lesson 03 in its own clean process, including every executable solution.
status_l03 <- system2(
  file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"),
  c("--vanilla", "quarto/_verification/check-lesson-03.R")
)
stopifnot(status_l03 == 0L)
