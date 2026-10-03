# Vectors ----------------------------------------------------------------------

# NOTE:
# Vectors are the most fundamental data structure in R.
# Almost everything we will do later (data frames, models,
# statistical operations) ultimately builds on vectors.

# * Properties of vectors --------------------------------------------------

# In R there are two fundamental types of vectors:
# 1) Atomic vectors
# 2) Lists

# Atomic vectors can be further divided into:
# logical, integer, double (real numbers), and character (text)
#
# logical
# integer
# double
# character

# Integers and doubles are jointly referred to as "numeric".
# Integers represent whole numbers, doubles can contain decimals.

# Lists

# Lists are also vectors, but they can contain elements of
# different types.

# Key idea:
# Atomic vectors -> same type
# Lists -> can mix types

# Data frames
# Data frames are actually lists of atomic vectors (columns).


# ** Core properties of vectors --------------------------------------------

# 1) Type
# We can check the type using typeof()

letters
typeof(letters)

1:10
typeof(1:10)

typeof(c(TRUE, FALSE, TRUE))


# 2) Length (number of elements)

x <- list("a", "b", 1:10)
length(x)

length(1:10)

# NOTE:
# Attributes are additional metadata attached to objects.
# Many important R objects are actually vectors with attributes.

# Examples:
# factor -> integer vector + levels
# data frame -> list + dimensions
# date -> numeric vector + date class


# * Basic types of atomic vectors ----------------------------------------------

# ** Logical vectors (boolean) --------------------------

# Logical vectors contain only:
# TRUE, FALSE, or NA (missing value)

x <- c(TRUE, TRUE, FALSE, NA)
x

# Exercise:
# Create a logical vector with five elements
# containing both TRUE and FALSE.

# ** Numeric vectors ------------------------------------

# Numeric vectors include two internal types:
# integer and double

# R creates doubles by default
typeof(1)

# Integers must be specified with L
typeof(1L)
typeof(c(1L, 2L, 3L))
typeof(c(1, 2, 3))

# These functions also produce integers
typeof(1:10)
typeof(seq(1, 10))

# NOTE:
# For most data analysis tasks we do not need
# to distinguish integer vs double.

# However, doubles represent approximate numbers.
# Computers cannot store infinite precision.
x <- sqrt(2) ^ 2
x

x - 2

# Strict comparison may fail
x == 2


# dplyr provides near() to compare numbers
# with numerical tolerance
near(x, 2)

# Exercise:
# Calculate sqrt(3)^2 and test whether it equals 3.

# ** Character vectors (text) --------------------------

# Character vectors store text strings
x <- "This is a reasonably long string."
x


# Exercise:
# Create a character vector containing the names
# of three countries.


# * Type conversion --------------------------
# There are two types of type conversion in R:

# 1) Explicit conversion
# 2) Implicit conversion


# ** Explicit conversion --------------------------

# Functions start with "as." and specify target type
as.integer(c(TRUE, FALSE, TRUE))
as.character(c(1, 2, 3, 4))
as.logical(c(0, 1, 0, 1))


# Check resulting type
as.integer(c(TRUE, FALSE, TRUE)) |> typeof()
as.character(c(1, 2, 3, 4)) |> typeof()
as.logical(c(0, 1, 0, 1)) |> typeof()


# ** Implicit conversion --------------------------

# Some functions automatically convert input types
x <- sample(1:20, 100, replace = TRUE)
x

# Logical vector
y <- x > 10
y

# Logical TRUE becomes 1
# Logical FALSE becomes 0
sum(y)
mean(y)


# When combining elements using c(),
# the most complex type dominates.
c(TRUE, 0L)
typeof(c(TRUE, 0L))

c(TRUE, 0L, 2.5)
typeof(c(TRUE, 0L, 2.5))

c(TRUE, 0L, 2.5, "one")
typeof(c(TRUE, 0L, 2.5, "one"))


# NOTE:
# Type hierarchy we should remember:
# logical -> integer -> double -> character


# * Checking vector type --------------------------

# typeof() returns the type as text
typeof(c(TRUE, FALSE))


# Predicate functions return TRUE/FALSE
is_logical(c(TRUE, FALSE))
is_logical(c(0, 1))

is_integer(c(1L, 2L))
is_integer(c(1, 2))

is_double(c(1.2, 2.4))
is_double(c(1L, 2L))

is_character(c("1", "2"))
is_character(c(1, 2))

is_atomic(c(1, 2))
is_atomic(list(1, c(1, 2)))

is_list(c(1, 2))
is_list(list(1, c(1, 2)))

is_vector(c(1, 2))
is_vector(NULL)


# * Vector recycling --------------------------

# When vectors have equal length
c(1, 2, 3) + c(4, 5, 6)
c(1, 2, 3) * c(4, 5, 6)


# When lengths differ
# R recycles the shorter vector
c(1, 2, 3) + 10
c(1, 2, 3) + c(10, 10, 10)


# Recycling also works with longer patterns
1:10 + 1:2
1:10 + 1:3


# NOTE:
# R gives a warning only if lengths are not multiples.

# Exercise:
# What happens if you compute:
# 1:10 + 1:4 ?


# * Naming vector elements --------------------------
x <- c(x = 1, y = 2, z = 4)
x

names(x)

attributes(x)


# Assign names later
x <- c(1, 2, 4)

names(x) <- c("x", "y", "z")
x


# Using tidyverse helper
x <- c(1, 2, 4)

x <- x |>
  set_names(c("x", "y", "z"))


# --- (1) Subsetting -------------------------------------------------------
# Subsetting can be done in three ways, always using [] with different vectors:
# 1) Integer indices (positive OR negative)
x <- c("one", "two", "three", "four", "five")
x
x[c(3, 2, 5)]
# Repeating indices creates a longer output:
x[c(1, 1, 1, 5, 5, 5, 2)]
# Negative indices exclude elements:
x[c(-1, -3, -5)]
x[-c(1, 3, 5)]
# Positive and negative indices cannot be mixed:
# x[c(1, -1)]

# 2) Logical vector (elements with TRUE are kept)
x <- c(10, 3, NA, 5, 8, 1, NA)
length(x)

x[c(TRUE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE)]
x[c(TRUE, FALSE)]
x[c(FALSE, TRUE)]

# All non-missing values
is.na(x)
!is.na(x)

x[!is.na(x)]

# Values > 5 (NA remain)
x[x > 5]
# Without NA
y <- x[x > 5 & !is.na(x)]
y

# Even numbers (NA remain)
x[x %% 2 == 0]

# 3) Names (if elements are named)
x <- c(abc = 1, def = 2, xyz = 5)
x
x[c("xyz", "def")]
x[c("xyz", "xyz", "xyz")]

# Double brackets [[]] always return a single element and drop the name:
x["def"]
x[["def"]]
# x[[c("xyz", "def")]]  # invalid – [[]] always returns a single element

# --- (2) Factors -----------------------------------------------------------
# Factors represent categorical variables – integers with a levels attribute.
x <- factor(
  c("a1", "a1", "b2", "c3"), 
  levels = c("a1", "b2", "c3")
)

class(x)
as.integer(x)
typeof(x)      # underlying type is integer
attributes(x)  # contains levels
levels(x)

# The "factor" class tells R to treat the object specially (e.g., mean does not make sense):
# mean(x)
# sum(x)

# Example: ordering of levels
temps <- c("cold", "hot", "hot", "warm", "cold", "cold", "warm")
factor(temps)  # default alphabetical order

temps_fct <- factor(temps, levels = c("cold", "warm", "hot"))
temps_fct

# If categories are coded as numbers, labels can be added:
temps <- c(1, 3, 3, 2, 1, 1, 2)
temps_fct <- factor(temps, 
                    levels = c(2, 1, 3), 
                    labels = c("warm", "cold", "hot"))
temps_fct

# --- (3) Lists -------------------------------------------------------------
# Lists can contain a mix of objects and have hierarchical structure.
x <- list(1, c(2, 3), c("A", "B", "C"))
x

# str() is the fastest way to inspect list structure
str(x)

x[3]

# Named list elements
x_named <- list(a = 1, b = 2, c = 3)
str(x_named)

x_named[c("a", "b")]

x_named[["a"]] %>% typeof()
x_named["a"] %>% typeof()

# Lists can mix types and contain other lists
y <- list("a", 1L, 1.5, TRUE)
str(y)

z <- list(list(1, 2), list(3, 4))
str(z)

# ** Subsetting lists -------------------------------------------------------
# [] returns a list; [[]] returns the element; $ is shorthand for [["name"]]
my_list <- list(
  a = 1:3, 
  b = "a string", 
  c = pi, 
  d = list(-1, -5)
) 

str(my_list)

# Selection by position (still a list)
my_list[1:2]
str(my_list[1:2])
str(my_list[4])

# Extracting a single element
str(my_list[[1]])
my_list[[1]]

my_list[1] %>% typeof()
my_list[[1]] %>% typeof()

# Access by name
my_list[[1]]
my_list$a
my_list[["a"]]

# --- (4) Data frames -------------------------------------------------------
# Data frame = 2D structure: columns = variables, rows = observations.

# (4.1) Creating an example data frame -------------------------------------
df <- data.frame(
  name = c("Mercury", "Venus", "Earth", "Mars", 
           "Jupiter", "Saturn", "Uranus", "Neptune"),
  type = c("Terrestrial", "Terrestrial", "Terrestrial","Terrestrial", 
           "Gas giant", "Gas giant", "Gas giant", "Gas giant"),
  diameter = c(0.382, 0.949, 1, 0.532, 11.209, 9.449, 4.007, 3.883),
  rotation = c(58.64, -243.02, 1, 1.03, 0.41, 0.43, -0.72, 0.67),
  rings = c(FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, TRUE, TRUE)
)

# (4.2) Quick inspection ----------------------------------------------------
df
is_list(df)
length(df)
dimnames(df)

# (4.3) Subsetting in base R -----------------------------------------------
# (a) By position (row, column)
df[1, 2]
df[, c(2, 3)]
# Exercise: How would you select these columns using dplyr?

# (b) By column names
df[c("name", "diameter")]
df[, c("name", "diameter")]
# Exercise: How would you do this using select()?

# (c) Logical row filtering
df$diameter > 1
df[df$diameter > 1, ]
# Exercise: How would you do this using filter()?

# Selecting specific columns after filtering (base R)
df[df$diameter > 1, names(df) %in% c("name", "type")]
# Exercise: How to do the same with dplyr?

# (4.4) subset() function ---------------------------------------------------
subset(df, subset = diameter > 1, select = name)
subset(df, subset = diameter > 1, select = c(name, type))
# Exercise: Write the dplyr equivalent

# (4.5) Tibble --------------------------------------------------------------
# Tibble is a more user-friendly version of data frame
as_tibble(df)

# (4.6) Creating tibble `planets` ------------------------------------------
planets <- tibble(
  name = c("Mercury", "Venus", "Earth", "Mars", 
           "Jupiter", "Saturn", "Uranus", "Neptune"),
  type = c("Terrestrial", "Terrestrial", "Terrestrial","Terrestrial", 
           "Gas giant", "Gas giant", "Gas giant", "Gas giant"),
  diameter = c(0.382, 0.949, 1, 0.532, 11.209, 9.449, 4.007, 3.883),
  rotation = c(58.64, -243.02, 1, 1.03, 0.41, 0.43, -0.72, 0.67),
  rings = c(FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, TRUE, TRUE)
)

# (4.7) Large tibble example ----------------------------------------------
long_tibble <- tibble(
  x = runif(10000)
)

long_tibble

# --- (5) Exercises --------------------------------------------------------
# The following tasks are for practicing vectors, factors, lists, and data frames.

# (5.1) Vector tasks --------------------------------------------------------
# 1) Create a numeric vector from 5 to 15 and check its length.
# 2) Convert this vector to character.
# 3) Create a logical vector identifying values > 10.
# 4) Use it to subset the original vector.

# (5.2) Factor tasks --------------------------------------------------------
# 1) Create a factor describing weather ("sunny", "cloudy", "rainy").
# 2) Reorder levels by pleasantness.
# 3) Inspect levels() and underlying integers.

# (5.3) List tasks ----------------------------------------------------------
# 1) Create a list with:
#    - numeric vector 1:5
#    - names of weekdays
#    - logical vector indicating weekend
# 2) Extract the second element using [[]].
# 3) Add a new element: mean of numeric vector.

# (5.4) Data frame tasks ----------------------------------------------------
# 1) Create a data frame with name, age, and favorite_food.
# 2) Select only people older than 25.
# 3) Use dplyr to select name and favorite_food.
# 4) Convert to tibble and inspect.

# (5.5) Bonus ---------------------------------------------------------------
# Using `planets`:
# 1) Find planets with rings.
# 2) Compute mean diameter of gas giants.
# 3) Sort planets by diameter (descending).

