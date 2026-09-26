#   ____________________________________________________________________________
#   Data Transformation                                                     ####

# Loading packages we are going to use
library(tidyverse)
library(nycflights13)

# In this section, we switch from visualization to data manipulation.
# We will use the `flights` dataset from the nycflights13 package.
# Note: `flights` is NOT loaded by tidyverse itself; it becomes available after
# `library(nycflights13)` above.
#
# The dataset contains information about flights departing from
# New York City in 2013, including departure delays, arrival delays,
# destinations, distance, air time, and more.
#
# For data transformation, we will mainly use functions from the
# dplyr package (also part of tidyverse), such as:
# filter(), arrange(), select(), mutate(), summarise()/summarize(), and group_by().
# (Both spellings of summarise are accepted in dplyr.)

flights
?flights
glimpse(flights)
summary(flights)

# Core idea (dplyr):
# - First argument is the data frame.
# - Remaining arguments describe the operation (often using column names).
# - The result is a NEW data frame (dplyr does not modify the original).

# We often want to perform several operations in sequence.
# The pipe operator |> helps us "chain" steps in a readable way.
# (This is the base R pipe, available since R 4.1. The older tidyverse pipe is %>%. )
flights  |> 
  filter(dest == "IAH") |> 
  group_by(year, month, day) |> 
  summarize(
    arr_delay = mean(arr_delay, na.rm = TRUE)
  )

# * Selecting and ordering rows ------------------------------------------------

# filter() keeps rows that satisfy given conditions.
dep_delay_above_2h <- flights |> 
  filter(dep_delay > 120)

dep_delay_above_2h

# Logical operators commonly used in filter() conditions
#
# Comparison operators:
# ==        equal to
# !=        not equal to
# >         greater than
# <         less than
# >=        greater than or equal to
# <=        less than or equal to
# %in%      element is contained in a vector (membership test)
# is.na(x)  is a value missing  
#
# Logical operators:
# &    AND  (both conditions must be TRUE)
# |    OR   (at least one condition must be TRUE)
# !    NOT  (negates a logical condition)
#
# These operators allow us to build more complex filtering rules.

# Example: flights that departed on January 1, 2013.
flights |>  
  filter(month == 1 & day == 1)

flights |>  
  filter(month == 1, day == 1)

# Example: flights that departed in January OR February OR March.
flights |>  
  filter(month == 1 | month == 2 | month == 3)

# A shorter way: use %in% for membership (here: selected months).
flights |>  
  filter(month %in% c(1, 2, 3)) # January to March

flights |>  
  filter(between(month, 1, 6)) # January to June

# Reminder: dplyr functions never modify the original dataset in place.
flights |>  
  filter(month == 1 & day == 1)

# If we want to keep the result, we assign it to an object using <-.
jan1 <- flights |>  
  filter(month == 1 & day == 1)

# Common mistakes to watch for:
flights |>  
  filter(month = 1) # typing a single "=" instead of "=="

flights |>  
  filter(month == 1 | 2) 
# ⚠ Common pitfall: `month == 1 | 2` is interpreted as `(month == 1) | (2)`.
# Because `2` is treated as TRUE, this returns *all* rows.
# Use `month %in% c(1, 2)` or `month == 1 | month == 2` instead. 

# arrange() sorts rows by one or more variables.
# Unlike filter(), it does not remove rows.
flights |>  
  arrange(year, month, day, dep_time)

flights |>  
  arrange(dep_time)

# For descending order, wrap a variable in desc().
flights |>  
  arrange(desc(dep_delay))

# distinct() keeps unique rows (optionally with respect to selected columns).

# Remove any duplicate rows
flights |>  
  distinct()

# Select all unique rows for the columns origin and dest
flights |>  
  distinct(origin, dest) |> 
  arrange(origin, dest)

# count() is a convenient shortcut for computing frequencies. 
flights |> 
  count(origin, dest, sort = TRUE)

# * Creating, selecting, renaming, and repositioning columns -------------------

# mutate() creates new columns (or overwrites existing ones).
flights |>  
  mutate(
    air_delay = arr_delay - dep_delay,
    speed = distance / (air_time / 60)
  )

# With .before / .after we can control where new columns appear
# (otherwise they are added at the end).
flights |>  
  mutate(
    air_delay = arr_delay - dep_delay,
    speed = distance / (air_time / 60),
    .before = 1
  )

# With .keep we can control how many of the original columns are kept
# (useful when you want a compact output for demonstration).
?mutate
flights |>  
  mutate(
    air_delay = arr_delay - dep_delay,
    speed = (distance*1.609344) / (air_time / 60),
    .keep = "none"
  )

# select() chooses columns we want to keep (and can also drop columns).
# By using the name:
flights |>  
  select(year, month, day)

# All columns in the range:
flights |>  
  select(year:day)

# All columns except for the range:
flights |>  
  select(!year:day)

# Selecting columns by data type:
flights |>  
  select(where(is.character))

flights |>  
  select(where(is.numeric))

# Helper functions: starts_with(), ends_with(), contains(), matches(), etc.
flights |>  
  select(starts_with("dep"))

flights |>  
  select(ends_with("time"))

flights |>  
  select(contains("arr"))

# select() can also rename while selecting: new_name = old_name.
flights |>  
  select(tail_num = tailnum)

# rename() only renames specified columns and keeps all other columns.
flights |>  
  rename(tail_num = tailnum)

# relocate() changes column order (useful for readability).
flights |>  
  relocate(distance:time_hour, .after = day)

flights  |>  
  relocate(starts_with("arr"), .before = dep_time)

# * Splitting the dataset into groups ------------------------------------------

# The group_by() function splits the dataset into groups for further analysis
# Notice the output groups
flights |> 
  group_by(month)

# In combination with the summarise() function, 
# we can calculate various statistics
# For example, the average departure delay
# Missing values (NA) are "contagious":
# e.g., mean(c(1, NA)) returns NA unless you set na.rm = TRUE.

flights |> 
  group_by(month) |> 
  summarise(
    avg_delay = mean(dep_delay)
  )

# With the argument na.rm, we will ignore them
flights |> 
  group_by(month) |> 
  summarise(
    avg_delay = mean(dep_delay, na.rm = TRUE)
  )

flights |> 
  summarise(
    avg_delay = mean(dep_delay, na.rm = TRUE)
  )

# The n() function provides information about the number of rows
flights |> 
  group_by(month) |> 
  summarise(
    avg_delay = mean(dep_delay, na.rm = TRUE), 
    n = n()
  )

# The slice_*() functions (on grouped data):
# pick rows *within each group* based on position, min/max, or random sampling.
# Tip: many of them have `with_ties = TRUE/FALSE` to control how ties are handled.
grouped <- flights |> 
  group_by(month)

# slice_head() selects the first row(s) from each group
grouped |> 
  slice_head(n = 1)

# slice_tail() selects the last row(s) from each group
grouped |> 
  slice_tail(n = 1)

# slice_min() selects the row(s) with the smallest values in the chosen column
grouped |> 
  slice_min(dep_delay, n = 1)

# slice_max() selects the row(s) with the largest values in the chosen column
grouped |> 
  slice_max(arr_delay, n = 1)

# slice_sample() selects random rows
grouped |> 
  slice_sample(n = 1)

# We can provide multiple variables to the group_by function
daily <- flights |>  
  group_by(year, month, day)

daily

daily |> 
  summarise(
    avg_daily_delay = mean(dep_delay, na.rm = TRUE)
  )

# Notice that the summarise() function by default "peels off" the grouping 
# by the last variable (in the resulting dataset)
# This behavior can be changed using the .groups argument
?summarise

# The grouping can be removed using the ungroup function
daily |> 
  ungroup() |> 
  summarise(
    avg_total_delay = mean(dep_delay, na.rm = TRUE)
  )

# More recently, it is also possible to work without the group_by() function 
# and specify the dataset grouping directly in the summarise() function
# using the .by argument
flights  |>  
  summarise(
    delay = mean(dep_delay, na.rm = TRUE), 
    n = n(),
    .by = c(origin, dest)
  )

# Exercises --------------------------------------------------------------------
# In a single pipeline for each condition, find all flights 
# that meet the condition:

# Had an arrival delay of two or more hours
flights |> 
  filter(arr_delay >= 120)

# Flew to Houston (IAH or HOU)
flights |> 
  filter(dest %in% c("IAH", "HOU"))

flights |> 
  filter(dest == "IAH" | dest == "HOU")

# Were operated by United, American, or Delta
airlines

flights |> 
  filter(carrier %in% c("DL", "AA", "UA"))

# Departed in summer (July, August, and September)
flights |> 
  filter(month %in% c(7, 8, 9))

flights |> 
  filter(between(month, 7, 9))

flights |> 
  filter(month >= 7 & month <= 9)

# Arrived more than two hours late but didn't leave late
flights |> 
  filter(arr_delay > 120,
         dep_delay <= 0)

# Were delayed by at least an hour, but made up over 30 minutes in flight
flights |> 
  filter(dep_delay > 60,
         dep_delay - arr_delay > 30)

# Sort flights to find the flights with the longest departure delays. 
flights |> 
  arrange(desc(dep_delay))

flights |> 
  arrange(-dep_delay)

# Find the flights that left earliest in the morning.
flights |> 
  filter(hour > 4) |> 
  arrange(time_hour) |> 
  relocate(time_hour)

# Sort flights to find the fastest flights. 
# (Hint: Try including a math calculation inside of your function.)
flights |> 
  arrange(
    desc(distance / air_time)
  )

flights |> 
  mutate(speed_mph = distance / (air_time / 60)) |> 
  arrange(desc(speed_mph)) |> 
  relocate(speed_mph)

# Was there a flight on every day of 2013?
flights |> 
  distinct(month, day)

flights |> 
  distinct(month, day) |> 
  nrow()

# Which flights traveled the farthest distance? 
flights |> 
  arrange(desc(distance)) |> 
  relocate(distance)

# Which traveled the least distance?
flights |> 
  arrange(distance) |> 
  relocate(distance)

# Compare dep_time, sched_dep_time, and dep_delay. 
# How would you expect those three numbers to be related?

# First, we need to transform the departure times to minutes (since midnight)
# sched_dep_time %/% 100 extracts the hundreds (ie. hours)
# and sched_dep_time %% 100 extracts the remainder (ie. minutes)

df <- flights |> 
  mutate(
    # Converting HHMM-style times into minutes since midnight:
    # - x %/% 100 gives hours (integer division)
    # - x %% 100 gives minutes (remainder)
    # ⚠ Note: this chunk will ERROR because of the trailing comma after dep_time.
    # Keep it here as a teaching moment, but remove the trailing comma when running.
    sched_dep_time = (sched_dep_time %/% 100) * 60 + sched_dep_time %% 100,
    dep_time = (dep_time %/% 100) * 60 + dep_time %% 100,
  )

# There are some flights that do not meet the expected condition.
# These are mostly flights where dep_time crossed midnight.
# Example: scheduled at 11:50 PM but actually departed at 00:30 AM the next day.
df |> 
  filter(
    dep_delay != dep_time - sched_dep_time
  )

# Accounting for these flights, we now expect the remaining cases to match
# dep_delay == dep_time - sched_dep_time (up to the midnight adjustment).
df |> 
  filter(dep_delay != dep_time - sched_dep_time) |> 
  filter(dep_delay != (dep_time + 24*60) - sched_dep_time)


# Brainstorm as many ways as possible to select 
# dep_time, dep_delay, arr_time, and arr_delay from flights.
flights |> 
  select(dep_time, dep_delay, arr_time, arr_delay)

flights |> 
  select(starts_with("dep_"), starts_with("arr_"))

x <- c("dep_time", "dep_delay", "arr_time", "arr_delay")

flights |> 
  select(all_of(x))

# What happens if you specify the name of the same variable 
# multiple times in a select() call?
flights |> 
  select(dep_time, dep_time, dep_time,
         dep_delay, arr_time, arr_delay)

# What does the any_of() function do? Why might it be helpful 
# in conjunction with this vector?
variables <- c("year", "month", "day", "dep_delay", "arr_delay")

flights |> 
  select(all_of(variables))

# Does the result of running the following code surprise you? 
# How do the select helpers deal with upper and lower case 
# by default? How can you change that default?
flights |>  
  select(contains("TIME"))

flights |>  
  select(contains("TIME", ignore.case = FALSE))

flights |>  
  select(contains("time", ignore.case = FALSE))

# Rename air_time to air_time_min to indicate units of measurement 
# and move it to the beginning of the data frame.
flights |> 
  relocate(air_time_min = air_time)

# Why doesn’t the following work, and what does the error mean?
flights |>  
  select(tailnum) |>  # we selected only this column 
  arrange(arr_delay) # so arr_delay is no longer one of the columns

flights |>  
  arrange(arr_delay) |> 
  select(tailnum)  

# Which carrier has the worst average delays? 
flights |> 
  group_by(carrier) |> 
  summarise(
    mean_arr_delay = mean(arr_delay, na.rm = TRUE)
  )|> 
  arrange(desc(mean_arr_delay))

# Find the flights that are most delayed upon departure from each destination.
flights |> 
  group_by(origin) |> 
  slice_max(dep_delay)

# How do delays vary over the course of the day? 
# Illustrate your answer with a plot.
flights |> 
  ggplot(aes(x = factor(hour), # converting hour of departure to a categorical
             y = dep_delay)) + # putting departure delay on a logarithmic 
  geom_point(stat = "summary",
             fun = mean,
             size = 3) +
  geom_line(stat = "summary",
            fun = mean,
            aes(group = 1))


# What happens if you supply a negative n to slice_min() and friends?
# It removes n rows from each group

# Explain what count() does in terms of the dplyr verbs you just learned. 
# What does the sort argument to count() do?
# count() lets you quickly count the unique values of one or more variables,
# and the sort argument, if set to TRUE, will show the largest groups 
# at the top.
# otherwise the groups are sorted alphabetically 
# or in ascending order of values.
flights |> 
  count(carrier, dest, sort = TRUE)

# Suppose we have the following tiny data frame:
df <- tibble(
  x = 1:5,
  y = c("a", "b", "a", "a", "b"),
  z = c("K", "K", "L", "L", "K")
)

# Write down what you think the output will look like, 
# then check if you were correct, and describe what group_by() does.
df  |> 
  group_by(y) # groups the dataset into two groups according to y

df |> 
  arrange(y) # sorts the dataset according to y (alphabetically)

df |> 
  group_by(y)  |> 
  summarize(mean_x = mean(x)) 
# computes the mean of x for each y-group

df |> 
  group_by(y, z) |> 
  summarize(mean_x = mean(x))
# computes the mean of x for each combination of y and z

df |> 
  group_by(y, z) |> 
  summarize(mean_x = mean(x), .groups = "drop")
# computes the mean of x for each combination of y and z
# but also ungroups the output

df |> 
  group_by(y, z) |> 
  summarize(mean_x = mean(x))
# computes the mean of x for each combination of y and z
# keeps the grouping according to y but peels of the last grouping 
# (according to z)

df |> 
  group_by(y, z) |> 
  mutate(mean_x = mean(x))
# computes the mean of x for each combination of y and z
# because we used mutate() instead of summarise(), the output has the same
# number of rows as the original dataset and both groupings are retained
# as this is the default behavior of mutate().


