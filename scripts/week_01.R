#   ____________________________________________________________________________
#   Introduction to R                                                       ####

# * Overview -------------------------------------------------------------------
#
# 🧠 1. What is R?
# R: a programming language and environment for statistical
# computing and data analysis
# Origin: created by statisticians (Ross Ihaka & Robert Gentleman);
# built for data analysis from the ground up
# Open-source: free to use, transparent,
# continuously improved by a global community
# Community-driven development: thousands of contributors
# develop packages and tools
# Widely used in:
#   - Academia (research & teaching)
#   - Data science
#   - Psychology & social sciences
#   - Economics & finance
#   - Bioinformatics
#   - Industry analytics
# Key idea: R is not just software – it is a language for thinking about data.
#
# 💻 2. What is RStudio?
# RStudio: an IDE (Integrated Development Environment)
# for R
# Purpose: makes working with R more organized,
# user-friendly, and efficient
# Main panels:
#   - Script editor: where you write and save your code (.R files)
#   - Console: where R executes commands immediately;
#     direct communication with the R engine
#   - Environment: shows objects currently stored in memory
#     (datasets, variables, models)
#   - Files: browse project folders
#   - Plots: displays generated graphs
#   - Packages: manage installed and loaded packages
#   - Help: documentation for functions and packages
# Important distinction:
#   - R = engine (does the computation)
#   - RStudio = interface (helps you work with R)
#
# 📊 3. Why use R instead of SPSS / Excel / JASP?
# - Reproducibility: analyses are saved as code
# - Script-based workflow: every step is explicit and documented
# - Transparency: no hidden clicks or black-box procedures
# - Version control compatibility: works well with Git
# - Extensibility: thousands of packages available
# - Industry standard: highly valued skill in research and industry
# - Publication-quality graphics: flexible and customizable
# - Automation & scalability: suitable for large datasets
#   and repeated analyses
# Emphasize for students: If you can click it, you cannot fully reproduce it.
#
# 🔁 4. Reproducibility as a Core Principle
# - Code as documentation: your analysis is fully traceable
# - Re-runability: anyone (including future you) can reproduce results
# - No hidden steps: everything is written explicitly
# Supports:
#   - Open science
#   - Pre-registration
#   - Collaboration
#   - Long-term research projects
# Introduce briefly:
#   - .R scripts: plain text files with code
#   - R Markdown / Quarto: combine code, output, and text in one document
#
# 📦 5. Packages: The tidyverse Ecosystem
# Base R: core functionality included in R
# Packages: extensions that add new tools and workflows
# CRAN: official repository of R packages
# For this course, we will mainly use tidyverse.
# Installing vs loading packages:
#   - Installing (install.packages("package_name")):
#     downloads the package from CRAN to your computer
#     (done once per machine)
#   - Loading (library(package_name)):
#     attaches the package to the current R session
#     (must be done each time you start a new session)
# Example:
#   install.packages("tidyverse")   # run once
#   library(tidyverse)               # run in every new session
# tidyverse: an umbrella package (meta-package)
# that loads a collection of packages designed
# for data science
# Installing tidyverse automatically installs its core components
# Loading library(tidyverse) attaches multiple packages at once
# Core tidyverse packages and their main roles:
#   - ggplot2: data visualization (grammar of graphics)
#   - dplyr: data manipulation (filtering, selecting, mutating, summarizing)
#   - tidyr: data reshaping (pivoting, handling wide/long formats)
#   - readr: fast and consistent data import
#   - tibble: modern data frame format
#   - stringr: string/text manipulation
#   - forcats: working with categorical variables (factors)
#   - purrr: functional programming tools for iteration
# Key idea: The tidyverse provides a coherent,
# consistent grammar for working with data.
# Later in the course, we may introduce additional
# specialized packages, but tidyverse will be
# our main toolkit.
#
# 🧮 6. R as a Calculator (First Demo Section)
# - Arithmetic: basic mathematical operations
# - Objects (<-): assign values to names
# - Vectors: basic data container in R
# - Functions: operations applied to objects
# - Basic operations: mean(), sd(), summary(), etc.
# Core concepts:
#   - Everything is an object
#   - Everything is a function
#   - R is vectorized (operations apply to entire vectors at once)
#
# 📁 7. RStudio Projects
# - Automatic working directory: each project has
#   its own root folder; no need to use setwd()
# - Relative paths: enables portable file referencing
#   (e.g., data/myfile.csv) that works across computers
# - Reproducibility: ensures that analyses run
#   consistently regardless of machine
# - Isolation: each project keeps its own scripts,
#   files, and workflow separate from other projects
# - Session continuity: RStudio can reopen
#   previously open scripts and restore context
# - Git integration: built-in version control
#   support (commit, push, pull, branching)
# - Project-specific settings: allows configuration
#   of build tools, R Markdown / Quarto options,
#   and other environment settings
# Recommended structure inside a project:
#   project/
#     data/
#     scripts/
#     output/
# Key message: One research project = one RStudio project.
#
# 📈 8. R for Data Analysis Workflow
# Typical pipeline:
#   - Import data (read.csv(), readr, etc.)
#   - Clean data (filtering, recoding, handling missing values)
#   - Explore data (descriptive statistics, visualization)
#   - Model data (regression, ANOVA, SEM, etc.)
#   - Visualize results (ggplot2)
#   - Report results (R Markdown / Quarto)
# Key idea: Analysis is not just running a model.
# It is a structured process.
#
# 🎨 9. Visualization in R
# - Base plotting: built-in plotting system
# - ggplot2: grammar of graphics approach
# - Reproducible figures: plots generated directly from data & code
# - Publication-ready customization: themes, colors, labels
# Message for students: In R, figures are analytical tools, not decorations.


# * Keyboard Shortcuts ---------------------------------------------------------
# Typing special characters on a Czech keyboard using the right Alt:
# RAlt + x = # (hashtag)
# RAlt + F = [] (square brackets)
# RAlt + B = {} (curly braces)
# RAlt + , = < (less-than sign)
# RAlt + . = > (greater-than sign)
# RAlt + ů = $ (dollar sign)
# RAlt + C = & (ampersand)
# RAlt + š, then any character = ^ (caret)
# RAlt + ý, then any character = `` (backtick)

# Typing the same characters on an English keyboard (using Shift):
# Shift + 3  = # (hashtag)
# Shift + [  = { (left curly brace)
# Shift + ]  = } (right curly brace)
# [ and ]     = square brackets
# Shift + ,  = < (less-than sign)
# Shift + .  = > (greater-than sign)
# Shift + 4  = $ (dollar sign)
# Shift + 7  = & (ampersand)
# Shift + 6  = ^ (caret)
# ` (key left of 1) = backtick

### Customizable RStudio Keyboard Shortcuts
# Alt + Shift + K   for the list of RStudio keyboard shortcuts
# Alt + -           inserts the assignment operator <- for creating objects
# Ctrl + Enter      to run the current code on the selected line
# Ctrl + Alt + P    re-runs the code that was run last

# Ctrl + Alt + R    runs all the code
# Alt + L           collapses the current code block
# Alt + Shift + L   expands the current code block
# Alt + O           collapses all the code
# Alt + Shift + 0   expands all the code
# Ctrl + Shift + R  inserts a new section header
# Ctrl + Shift + M  inserts the pipe operator %>% 

# * Basic Operations -----------------------------------------------------------
# Mathematical operations
# Addition
5 + 5 

# Subtraction
5 - 5 

# Multiplication
3 * 5

# Division
(5 + 5) / 2 

# Exponentiation
2^5

# Square root
sqrt(9)
9^(1/2)

# Integer division
16 %/% 6

# Remainder after integer division
16 %% 6

# Creating objects
# The assignment operator <- is used to create new objects:
# object_name <- its_value
x <- 3 * 4

# To combine multiple values into a single object (vector), use
# the function c()
primes <-  c(2, 3, 5, 7, 11, 13)
primes

# Various operations, for example mathematical ones, can be applied to a vector
primes * 2 # each element is multiplied by two
primes - 1 # one is subtracted from each element

# * Comments -------------------------------------------------------------------
# Comments are inserted using the hashtag #
# Anything to the right of the hashtag will not be executed as code by R
# A special type of comment is a section header, which can be inserted using 
# CTRL + Shift + R or by adding ---

# create a vector of prime numbers
primes <- c(2, 3, 5, 7, 11, 13)

# multiply the prime numbers by two
primes * 2


# * Naming Objects -------------------------------------------------------------
# Object names must start with a letter and may only contain
# letters, numbers, underscores (_) and periods (.)

# It is recommended to use snake case for creating longer object names
i_use_snake_case
otherPeopleUseCamelCase
some.people.dot.case
And_aFew.People_RENOUNCEconvention

# To display an object in the console, simply type its name
x
r_rocks <- 2^3
r_rocks

# The object name must be written exactly, otherwise R will not find it
r_rock # here the ending "s" is missing
R_rocks # R is case sensitive

# * Using Functions ------------------------------------------------------------
# R contains a large number of functions
# To call them, you only need to know the function's name and its arguments
# function_name(argument1 = value1, argument2 = value2, ...)

# You can get help for the function seq() like this
help(seq)
?seq

# Try generating a sequence of integers from 1 to 10 using the seq() function
seq()

seq(from = 1,
    to = 10,
    by = 2)

#   ____________________________________________________________________________
#   Basics of Data Visualization                                           ####
# install.packages("palmerpenguins")
# install.packages("ggthemes")
# install.packages("tidyverse")

library(tidyverse)
library(palmerpenguins)
library(ggthemes)

penguins
glimpse(penguins)

?penguins

# Our goal is to create a scatterplot showing the relationship between 
# flipper length (on the X-axis) and body mass (on the Y-axis) of penguins
# The points in the plot should be distinguished by penguin species
# using both color and shape
# and also display a linear trend for all data

# The first step is to choose the dataset using the data argument
ggplot(data = penguins)

# Next, we need to specify which variables from the dataset we want 
# on the X and Y axes
# using the mapping argument and the aes() function
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g))

# Then we need to decide which type of plot (geom) to use
# in other words, which geometric object should represent each observation
# For this, various functions starting with geom_ are used
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g)) +
  geom_point()
# notice the error message

# Now we want to add information about the penguin species and 
# represent it with point color
# For example, it is possible that the relationship between flipper length 
# and body mass varies
# depending on the penguin species
# Thus, we map the variable species to color
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g,
                     color = species)) +
  geom_point()

# Then we add a regression curve as a new geom using the geom_smooth function
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g,
                     color = species)) +
  geom_point() +
  geom_smooth()

# By default, ggplot uses a nonparametric regression (loess curve)
# that does not assume a linear relationship
# But we want to use a linear model
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g,
                     color = species)) +
  geom_point() +
  geom_smooth(method = "lm")


# This produced regression lines for each species separately,
# but we want one line for the entire dataset together
# Therefore, we need to apply the mapping of species to color 
# only within geom_point()
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g)) +
  geom_point(mapping = aes(color = species)) +
  geom_smooth(method = "lm")


# Because some people may be colorblind, we can represent the species not only 
# by the color 
# of the points, but also by their shape
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g)) +
  geom_point(mapping = aes(color = species,
                           shape = species)) +
  geom_smooth(method = "lm")


# To make the point shapes more distinguishable, we increase their size using
# the size argument
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g)) +
  geom_point(mapping = aes(color = species,
                           shape = species),
             size = 3) +
  geom_smooth(method = "lm")


# We can also choose a different color palette that is more color-blind friendly
# using the scale_color_colorblind() function from the ggthemes package
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g)) +
  geom_point(mapping = aes(color = species,
                           shape = species),
             size = 3) +
  geom_smooth(method = "lm") +
  scale_color_colorblind()



# And finally, we add various labels to the graph using the labs() function
?labs

ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g)) +
  geom_point(mapping = aes(color = species,
                           shape = species),
             size = 3) +
  geom_smooth(method = "lm") +
  scale_color_colorblind() +
  labs(title = "Flipper Length and Body Mass of Penguins",
       x = "Flipper Length (mm)",
       y = "Body Mass (g)",
       color = "Species",
       shape = "Species")
























