# Data import ------------------------------------------------------
# This section introduces importing data from different sources using tidyverse
# and related packages.

# * Required packages --------------------------------------------------
# (some are not part of core tidyverse)
library(psych)    # For reliability estimates 
library(tidyverse)
library(readr)    # For CSV and TSV files import
library(janitor)  # For clean_names(), remove_empty(), etc.
library(readxl)   # For Excel files
library(haven)    # For SPSS, Stata, and similar formats
library(labelled) # For variable and value labels (similar to SPSS/JASP)

# * Flat files ---------------------------------------------------------
# Functions from readr (part of tidyverse):
# read_csv()  -> comma-separated values
# read_csv2() -> semicolon-separated values
# read_tsv()  -> tab-separated values
# read_delim() -> general function with custom delimiter

# Create data directory if it does not exist (used later for saving files)
if (!dir.exists("data")) dir.create("data")

# Load directly from URL
students <- read_csv("https://is.muni.cz/go/3zuzvn")
students

# Download file and then load it locally
download.file(url = "https://is.muni.cz/go/3zuzvn",
              destfile = "data/students.txt")

students <- read_csv("data/students.txt")
students

# The dataset may not look clean initially
students

# Define missing values explicitly
students <- read_csv("https://pos.it/r4ds-students-csv",
                     na = c("", "NA", "N/A"))
students

# Rename columns for consistency
students %>% 
  rename(
    student_id = `Student ID`,
    full_name = `Full Name`
  )

# Or automatically clean names (recommended)
students <- students %>% 
  clean_names()
students

# Fix incorrect values (e.g., age stored as text)
students %>% 
  mutate(age = if_else(age == "five", "5", age))

students %>% 
  mutate(age = if_else(age == "five", "5", age) %>% 
           as.integer())

students <- students %>% 
  mutate(age = if_else(age == "five", "5", age) %>% 
           as.integer())

students

# Convert variable to factor (categorical)
glimpse(students)

students <- students %>% 
  mutate(meal_plan = factor(meal_plan))

glimpse(students)

# readr usually guesses column types correctly

# Example dataset
example <- "
  logical,numeric,date,string
  TRUE,1,2021-01-15,abc
  false,4.5,2021-02-15,def
  T,Inf,2021-02-16,ghi
"

read_csv(example)

# Handling custom missing values
simple_csv <- "
  x
  10
  .
  20
  30"

read_csv(simple_csv)
read_csv(simple_csv, na = ".")

# Manually specifying column types
simple_csv <- "
  x
  10
  .
  20
  30"

df <- read_csv(
  simple_csv, 
  col_types = list(x = col_double())
)

df

# Inspect parsing problems
problems(df)

# Common column type functions:
# col_logical(), col_integer(), col_double(), col_character()
# col_factor(), col_date(), col_datetime(), col_number(), col_skip()

# Another example
another_csv <- "
x,y,z
1,2,3
4,5,6"

read_csv(another_csv,
         col_types = list(x = col_character(),
                          y = col_integer(),
                          z = col_factor()))

# Set default column type (e.g., everything as character)
read_csv(
  another_csv, 
  col_types = cols(.default = col_character())
)

# Import only selected columns
read_csv(
  another_csv,
  col_types = cols_only(x = col_character())
) 

# * SPSS ---------------------------------------------------------------
# Using haven package

# Load directly from URL
international <- read_sav("https://is.muni.cz/go/yhuc1g")

# Download and load locally
download.file(url = "https://is.muni.cz/go/yhuc1g",
              destfile = "data/international.sav")

international <- read_sav("data/international.sav")

# SPSS labelled variables are imported as numeric with labels
# Convert to factor if needed
international %>% 
  mutate(contint = as_factor(contint))

# * Excel --------------------------------------------------------------
# Example workflow for messy Excel file

# Downloading a binary file (Excel)
# Note: For non-text files (like .xlsx), it is important 
# to set additional arguments.
# - method = "libcurl": ensures a stable download method across platforms
# - mode = "wb" (write binary): prevents corruption of binary files 
#           (especially on Windows)
# Without mode = "wb", the file may be saved incorrectly and cannot be opened.
download.file(url = "https://is.muni.cz/go/qv1bbo",
              method   = "libcurl",
              mode     = "wb",
              destfile = "data/four_countries_data.xlsx")

four <- read_excel("data/four_countries_data.xlsx")

# This is not ideal structure
four

# 1. Extract clean variable names
var_names <- read_excel("data/four_countries_data.xlsx",
                        n_max = 0) %>% 
  clean_names() %>% 
  colnames()

# 2. Extract variable labels
var_labels <- read_excel("data/four_countries_data.xlsx",
                         skip = 1,
                         n_max = 0) %>% 
  colnames()

# We store variable labels as a named list:
# - as.list() converts the vector of labels into a list
# - set_names(var_names) assigns column names as names of list elements
# This way, each label is linked to the corresponding variable
description <- var_labels %>% 
  as.list() %>% 
  set_names(var_names)

# 3. Import actual data (skip metadata rows)
four <- read_excel("data/four_countries_data.xlsx",
                   skip = 3,
                   col_names = FALSE)

# 4. Assign column names and labels
four <- four %>% 
  set_names(var_names)

# We can now assign these labels to variables 
# (similar to SPSS or JASP variable labels)
# Labels are stored as attributes of each column and will be visible in View()
four <- four %>% 
  set_variable_labels(.labels = description, .strict = FALSE)

# Inspect result
view(four)

# Remove unnecessary columns
# (janitor functions)
four <- four %>% 
  remove_constant() %>% 
  remove_empty(which = "cols")

four

# Fix Excel date columns (numeric -> Date)
four <- four %>% 
  mutate(start_date = excel_numeric_to_date(start_date),
         end_date = excel_numeric_to_date(end_date),
         recorded_date = excel_numeric_to_date(recorded_date))

# Dictionary / codebook
generate_dictionary(four, details = "full")

look_for(four, "prop", details = "full")

# * Saving data --------------------------------------------------------

# save() / load() (binary workspace file)
save(four, students, international,
     file = "data/my_data.Rdata")

load("data/my_data.Rdata")

# write_rds() / read_rds() (single object)
write_rds(four,
          file = "data/four.rds")

any_name <- read_rds("data/four.rds")

# Export to CSV
write_csv(four,
          file = "data/four.csv")

# ** Note on saving functions --------------------------------------------
# There are two common approaches in R:

# (1) save() / load()
# - Can store multiple objects in a single file (.RData)
# - When loading, objects are restored with their original names
# - You CANNOT easily rename them during loading

# Example:
# save(four, students, file = "data/my_data.Rdata")
# load("data/my_data.Rdata")  # objects appear in environment

# (2) write_rds() / read_rds()
# - Stores a single object in a file (.rds)
# - When loading, YOU assign the name manually
# - More flexible and safer in many workflows

# Example:
# write_rds(four, "data/four.rds")
# my_data <- read_rds("data/four.rds")  # custom name

# Rule of thumb:
# - Use save()/load() for quick workspace saving
# - Use RDS for reproducible workflows and scripts


# Packages -----------------------------------------------------------------
#  * Load required packages -------------------------------------------------

library(psych)
library(tidyverse)
library(readr)    # For CSV and TSV files
library(janitor)  # For clean_names(), remove_empty(), etc.
library(readxl)   # For Excel files
library(haven)    # For SPSS, Stata, and similar formats
library(labelled) # For variable and value labels (similar to SPSS/JASP)


# Data Preparation ----------------------------------------------------------
#  * Import data ------------------------------------------------------------
#  ** Read the main dataset -------------------------------------------------

# Import data from Excel (sheet = 1 by default)
hs <- read_xlsx("data/help_seeking.xlsx")
hs

glimpse(hs)

# Read the data again and define user-coded missing values
hs <- read_xlsx(
  "data/help_seeking.xlsx",
  na = c("", "-99")
)
hs

# Display a quick overview of the data
glimpse(hs)

#  ** Read the codebook -----------------------------------------------------

codebook <- read_xlsx(
  "data/help_seeking.xlsx",
  sheet = 2
) %>% 
  mutate(reversed = as.logical(reversed))

codebook


#  * Convert selected variables to factors ---------------------------------
#  ** Variables with different response categories --------------------------

# Convert gender and financial_situation to factors
hs <- hs %>% 
  mutate(
    gender = factor(
      gender,
      levels = 1:3,
      labels = c("Female", "Male", "Other")
    ),
    financial_situation = factor(
      financial_situation,
      levels = 1:3,
      labels = c("Bad", "Acceptable", "Good")
    )
  )

#  ** Variables with the same response categories ---------------------------

# Convert partner, college_title, and college_student to factors
# Notice that this approach involves a lot of repetition
hs %>% 
  mutate(
    partner = factor(
      partner,
      levels = 1:2,
      labels = c("No", "Yes")
    ),
    college_title = factor(
      college_title,
      levels = 1:2,
      labels = c("No", "Yes")
    ),
    college_student = factor(
      college_student,
      levels = 1:2,
      labels = c("No", "Yes")
    )
  )

# A more efficient solution is to use across() to apply the same operation
# to multiple columns at once.
# This works because these variables share the same coding scheme:
# 1 = No, 2 = Yes.
hs <- hs %>% 
  mutate(
    across(
      c(partner, college_title, college_student),
      ~ factor(
        .x,
        levels = 1:2,
        labels = c("No", "Yes")
      )
    )
  )


#  * Assign value labels to numeric items ----------------------------------

# Some variables are technically categorical, but we may want to keep them
# numeric instead of converting them to factors.
# This is common for Likert-type items when we plan to compute a total score
# representing a construct of interest, such as Attitudes Toward Seeking
# Professional Psychological Help or Emotional Expressiveness.
# We cannot perform numerical operations with factors, only with numeric
# vectors. However, we can still assign value labels to numeric columns
# using the labelled package.

?val_label()

# Doing this for each column separately would be cumbersome
hs %>% 
  mutate(
    help_01 = labelled(
      help_01,
      labels = c(
        "Disagree" = 1,
        "Rather disagree" = 2,
        "Rather agree" = 3,
        "Agree" = 4
      )
    ),
    help_02 = labelled(
      help_02,
      labels = c(
        "Disagree" = 1,
        "Rather disagree" = 2,
        "Rather agree" = 3,
        "Agree" = 4
      )
    )
  )

# We can do this for multiple columns at once with across().
# First, for the Attitudes Toward Seeking Professional Psychological Help items.
hs <- hs %>% 
  mutate(
    across(
      starts_with("help_"),
      ~ labelled(
        .x,
        labels = c(
          "Disagree" = 1,
          "Rather disagree" = 2,
          "Rather agree" = 3,
          "Agree" = 4
        )
      )
    )
  )

# Second, for the Emotional Expressiveness Scale items.
hs <- hs %>% 
  mutate(
    across(
      starts_with("emo_"),
      ~ labelled(
        .x,
        labels = c(
          "Never" = 1,
          "Rarely" = 2,
          "Sometimes" = 3,
          "Often" = 4,
          "Almost always" = 5,
          "Always" = 6
        )
      )
    )
  )


#  * Assign variable labels -------------------------------------------------
#  ** Create labels from the codebook --------------------------------------

# First, extract variable names from the codebook
variable_names <- codebook$name

# Then extract variable labels
variable_labels <- codebook$label

# Next, create a named list where each element is a variable label
# and the element name corresponds to a column name in the dataset
variable_labels_list <- variable_labels %>% 
  as.list() %>% 
  set_names(variable_names)

variable_labels_list

#  ** Example of a manually created label list ------------------------------

# This is how the full list would look if we created it by hand
variable_labels_list <- list(
  # variable name = variable label
  id = "Respondent ID",
  gender = "Gender",
  partner = "Romantic partner / relationship status",
  age = "Age (years)",
  college_title = "University degree",
  college_student = "Currently a university student",
  financial_situation = "Financial situation assessment",
  help_01 = "If I felt I was having a mental breakdown, the first thing I would think of would be to seek professional help.",
  help_02 = "Talking about problems with a psychologist seems like a poor way to get rid of mental health issues.",
  help_03 = "If I were experiencing a serious emotional crisis, I am sure that psychotherapy would help me.",
  help_04 = "I admire people who are willing to handle their problems and worries without seeking professional help.",
  help_05 = "If I were troubled by long-term anxiety and distress, I would want to seek psychological help.",
  help_06 = "In the future, I might want to use psychological counseling.",
  help_07 = "A person with mental health problems will likely not solve them alone; they have a better chance of solving them with professional help.",
  help_08 = "Given the amount of time and money psychotherapy requires, I am not sure it would benefit someone like me.",
  help_09 = "People should solve their own problems; psychological counseling should be a last resort.",
  help_10 = "Personal and psychological difficulties, like most things in life, tend to resolve themselves.",
  emo_01 = "I do not share my emotions with other people.",
  emo_02 = "Even when I experience strong feelings, I do not show them outwardly.",
  emo_03 = "Other people think I am a very emotional person.",
  emo_04 = "People can easily \"read\" my emotions.",
  emo_05 = "I keep my feelings to myself.",
  emo_06 = "Other people are not able to easily recognize what I am feeling.",
  emo_07 = "I express my emotions in front of other people.",
  emo_08 = "People think of me as an emotionless person.",
  emo_09 = "I dislike letting others know how I feel.",
  emo_10 = "I cannot hide how I feel.",
  emo_11 = "I do not express my emotions much outwardly.",
  emo_12 = "I often seem indifferent to others.",
  emo_13 = "I have no problem crying in front of others.",
  emo_14 = "Even when I feel very emotionally distressed, I do not let others notice.",
  emo_15 = "I consider myself a person who gives vent to their feelings.",
  emo_16 = "How I feel often differs from how others think I feel.",
  emo_17 = "I keep my feelings inside."
)

# Finally, assign the labels using set_variable_labels()
hs <- hs %>% 
  set_variable_labels(.labels = variable_labels_list)

# We can inspect the variable dictionary with look_for()
look_for(hs)
look_for(hs, details = TRUE)

# Or search only for specific variables
look_for(hs, "help_")