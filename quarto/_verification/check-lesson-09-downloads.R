# Optional network check, separate from the offline book render and CI.
lines <- readLines("quarto/lekce_09.qmd", encoding = "UTF-8")
chunk_code <- function(label) {
  start <- grep(paste0("^#\\| label: ", label, "$"), lines)
  end <- start + which(lines[(start + 1):length(lines)] == "```")[1]
  code <- lines[(start + 1):(end - 1)]
  code[!grepl("^#\\|", code)]
}
suppressPackageStartupMessages(library(readr))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(dplyr))
local_data <- read_rds("data/clean/vztahy_zavazek.rds")

# Run the exact direct-URL example from the chapter.
eval(parse(text = chunk_code("l09-url-rds")))
stopifnot(grepl("/[0-9a-f]{40}/data/clean/vztahy_zavazek\\.rds$", data_url),
          identical(vztahy, local_data))

# Run the exact download example in a disposable student-project directory.
project_root <- getwd()
dir.create("output/lesson09/student-download", recursive = TRUE, showWarnings = FALSE)
setwd("output/lesson09/student-download")
eval(parse(text = chunk_code("l09-url-download")))
stopifnot(unname(tools::md5sum("data/clean/vztahy_zavazek.rds")) ==
            unname(tools::md5sum(file.path(project_root, "data/clean/vztahy_zavazek.rds"))),
          identical(vztahy, local_data))
setwd(project_root)
cat("PASS: both lesson 09 online examples executed; download matches the local input byte-for-byte.\n")
