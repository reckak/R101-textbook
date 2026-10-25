# Optional network check, separate from the offline book render and CI.
lines <- readLines("quarto/lekce_07.qmd", encoding = "UTF-8")
chunk_code <- function(label) {
  start <- grep(paste0("^#\\| label: ", label, "$"), lines)
  end <- start + which(lines[(start + 1):length(lines)] == "```")[1]
  code <- lines[(start + 1):(end - 1)]
  code[!grepl("^#\\|", code)]
}
suppressPackageStartupMessages(library(haven))
suppressPackageStartupMessages(library(stringr))
local_file <- "data/raw/monitoring_teaching.sav"
local_data <- read_sav(local_file)

# Run the exact direct-URL example from the chapter.
eval(parse(text = chunk_code("l07-url-sav")))
stopifnot(grepl("/[0-9a-f]{40}/data/raw/monitoring_teaching\\.sav$", data_url),
          identical(adolescenti, local_data))

# Run the exact download example in a disposable student-project directory.
project_root <- getwd()
dir.create("output/lesson07/student-download", recursive = TRUE, showWarnings = FALSE)
setwd("output/lesson07/student-download")
eval(parse(text = chunk_code("l07-url-download")))
stopifnot(unname(tools::md5sum(local_file)) ==
            unname(tools::md5sum(file.path(project_root, local_file))),
          identical(adolescenti, local_data))
setwd(project_root)
cat("PASS: both lesson 07 online examples executed; download matches the local input byte-for-byte.\n")
