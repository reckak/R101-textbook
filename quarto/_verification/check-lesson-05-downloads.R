# Optional network check, separate from the offline book render and CI.
lines <- readLines("quarto/lekce_05.qmd", encoding = "UTF-8")

# Run the exact optional direct-URL CSV example from the chapter.
start <- grep("^#\\| label: l05-url-csv$", lines)
end <- start + which(lines[(start + 1):length(lines)] == "```")[1]
suppressPackageStartupMessages(library(readr))
suppressPackageStartupMessages(library(stringr))
eval(parse(text = lines[(start + 1):(end - 1)]))
local <- read_csv("data/raw/students.txt", show_col_types = FALSE)
stopifnot(identical(as.data.frame(students_online), as.data.frame(local)))

# The table now has one local download link per file. Check the original four
# GitHub inputs using the pinned directory actually constructed by the example.
stopifnot(grepl("/[0-9a-f]{40}/data/raw/students.txt$", students_url))
files <- c("students.txt", "international.sav", "help_seeking.xlsx", "four_countries_teaching.xlsx")
urls <- str_c(dirname(students_url), "/", files)
dir.create("output/lesson05/downloads", recursive = TRUE, showWarnings = FALSE)
for (url in urls) {
  destination <- file.path("output/lesson05/downloads", basename(url))
  download.file(url, destination, mode = "wb", quiet = TRUE)
  original <- file.path("data/raw", basename(url))
  stopifnot(unname(tools::md5sum(destination)) == unname(tools::md5sum(original)))
}

# Run the exact download example in a disposable student-project directory.
start <- grep("^#\\| label: l05-url-download$", lines)
end <- start + which(lines[(start + 1):length(lines)] == "```")[1]
project_root <- getwd()
dir.create("output/lesson05/student-download", recursive = TRUE, showWarnings = FALSE)
setwd("output/lesson05/student-download")
eval(parse(text = lines[(start + 1):(end - 1)]))
stopifnot(unname(tools::md5sum("data/raw/help_seeking.xlsx")) ==
            unname(tools::md5sum(file.path(project_root, "data/raw/help_seeking.xlsx"))))
setwd(project_root)
cat("PASS: four public GitHub downloads match local inputs byte-for-byte; both optional online examples executed.\n")
