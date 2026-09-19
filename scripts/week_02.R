#   ____________________________________________________________________________
#   Basics of Data Visualization                                           ####
# install.packages("palmerpenguins")
# install.packages("ggthemes")
# install.packages("tidyverse")

library(tidyverse)
library(palmerpenguins)
library(ggthemes)

penguins
?penguins
# glimpse() comes from the dplyr package (loaded via tidyverse).
# It provides a compact, structured overview of a dataset:
# number of rows, number of columns, variable names, types, and example values.
glimpse(penguins)

view(penguins)
summary(penguins)

print(penguins, n = Inf)


# Goal: create a scatterplot showing the relationship between
# flipper length (X-axis) and body mass (Y-axis).
# We will distinguish penguin species using BOTH color and shape,
# and add ONE overall linear trend line for the full dataset.

# Step 1: choose the dataset using the data argument.
ggplot(data = penguins)

# Step 2: specify which variables go on the X and Y axes.
# We do this via the mapping argument and the aes() function ("aesthetics").
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g))

# Step 3: choose the geometric object ("geom") that represents observations.
# In ggplot2, geoms are added with functions starting with geom_.
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g)) +
  geom_point()
# Note: you will likely see a warning/error here because some rows contain missing values
# in flipper_length_mm or body_mass_g. We'll come back to missing data later.

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

# Next, add a trend line as another layer using geom_smooth().
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g,
                     color = species)) +
  geom_point() +
  geom_smooth()

# By default, geom_smooth() uses a nonparametric smoother (loess) for small datasets.
# Here we want a linear model, so we set method = "lm".
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g,
                     color = species)) +
  geom_point() +
  geom_smooth(method = "lm")


# This creates separate trend lines for each species because color is mapped globally.
# If we want ONE overall line, we keep the global mapping "clean" and map species
# only inside geom_point() (i.e., only for the points).
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g)) +
  geom_point(mapping = aes(color = species)) +
  geom_smooth(method = "lm")

# IMPORTANT: Global vs local mapping in ggplot2
# Mapping defined inside ggplot() is GLOBAL — it is inherited by all geoms.
# Mapping defined inside a specific geom_*() is LOCAL — it applies only to that layer.

# Compare:
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,  # Mapping set globally
                     y = body_mass_g)) +
  geom_point() +  # Inherits x and y
  geom_smooth(method = "lm")  # Also inherits x and y

# And:
ggplot(data = penguins) +  # No global mapping defined here
  geom_point(mapping = aes(x = flipper_length_mm,  # Must be specified
                           y = body_mass_g)) +    # separately in each geom
  geom_smooth(mapping = aes(x = flipper_length_mm,
                            y = body_mass_g),
              method = "lm")

# Both plots produce the same result, but the structure is different.
# The first version is usually cleaner and more concise when layers share aesthetics.


# Accessibility: because some viewers may be color-blind, we also map species to shape
# (in addition to color).
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


# We can also use a color-blind-friendly palette via ggthemes::scale_color_colorblind().
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g)) +
  geom_point(mapping = aes(color = species,
                           shape = species),
             size = 3) +
  geom_smooth(method = "lm") +
  scale_color_colorblind()



# Finally, add labels (title, axis labels, legend titles) using labs().
?labs

ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g)) +
  geom_point(mapping = aes(color = species,
                           shape = species),
             size = 3) +
  geom_smooth(method = "lm") +
  scale_color_colorblind() +
  labs(title = "Flipper Length and Body Mass of Penguins", # Plot title
       x = "Flipper Length (mm)", # X-asix title
       y = "Body Mass (g)", # Y-asix title
       color = "Species", # Color legend title
       shape = "Species") # Shape legend title. 
      # Because legend titles for color and shape are same, only one legend
      # (combining color and shape) is created

# So far we have written argument names explicitly (data = ..., mapping = ...).
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point()

# To save typing, we can omit argument names.
# ggplot() expects: (1) data, then (2) mapping (aes).
ggplot(
  penguins,
  aes(x = flipper_length_mm, 
      y = body_mass_g)
) +
  geom_point()

ggplot(
  penguins,
  aes(flipper_length_mm, 
      body_mass_g)
) +
  geom_point()

# We can already start getting acquainted with the pipe operator |>
# (read it as: "and then"). 
ggplot(
  penguins,
  aes(x = flipper_length_mm, 
      y = body_mass_g)
) +
  geom_point()

penguins |> 
  ggplot(aes(x = flipper_length_mm, 
             y = body_mass_g)) +
  geom_point()

# ADVANCED: Mapping aesthetics to values NOT stored in the dataset

# Sometimes we want to display multiple model fits (or reference lines)
# and distinguish them in the legend — even though the distinguishing
# labels (e.g., "Linear", "Loess") are not variables in the dataset.

# Example 1: Setting colors manually (no legend is created)
# Here, color and fill are FIXED values, not mapped aesthetics.
# Because they are set outside aes(), ggplot treats them as constants
# and therefore does NOT generate a legend.

ggplot(
  penguins,
  aes(x = flipper_length_mm, 
      y = body_mass_g)
) +
  geom_point() +
  geom_smooth(method = "lm", # Linear fit
              color = "blue",
              fill = "blue",
              alpha = 0.2) +
  geom_smooth(method = "loess", # Nonparametric loess curve
              color = "red",
              fill = "red",
              alpha = 0.2)

# Example 2: Creating a legend for model types
# To generate a legend, we must MAP aesthetics inside aes().
# Here, we map color and fill to character strings.
# These strings behave like artificial factor levels,
# which allows ggplot to create a legend.

ggplot(
  penguins,
  aes(x = flipper_length_mm, 
      y = body_mass_g)
) +
  geom_point() +
  geom_smooth(mapping = aes(color = "Linear",
                            fill = "Linear"),
              method = "lm",
              alpha = 0.2) +
  geom_smooth(mapping = aes(color = "Loess",
                            fill = "Loess"),
              method = "loess",
              alpha = 0.2) +
  labs(color = "Fit",
       fill = "Fit") +
  scale_fill_manual(values = c("red", "blue")) +
  scale_color_manual(values = c("red", "blue"))

# Key principle:
# - Setting aesthetics outside aes() = fixed value (no legend).
# - Mapping inside aes() = variable (real or artificial) → legend.
#
# This is a powerful technique when adding model comparisons,
# reference lines, thresholds, or theoretical expectations.

# * Visualizing the distribution of a single variable --------------------------

# For a categorical variable, a bar chart is usually the default choice.
ggplot(penguins, 
       aes(x = species)) +
  geom_bar()

# Often we want to order categories by frequency.
# We can do that with forcats::fct_infreq().
?fct_inorder 

ggplot(penguins, aes(x = fct_infreq(species))) +
  geom_bar()

# Here we combine two forcats functions using the pipe:
# 1) fct_infreq() orders factor levels by their frequency (most frequent first).
#    This means the most common species would appear on the left.
# 2) fct_rev() reverses the order of factor levels.
#    Because bar plots in ggplot display factor levels from left to right
#    in the order stored in the factor, reversing the levels
#    moves the most frequent category to the right instead.
#
# In short:
# fct_infreq()  → order by frequency
# fct_rev()     → flip that order
#
# This is often useful when we want bars ordered from smallest to largest
# (or vice versa) without manually recoding factor levels.
ggplot(penguins, aes(x = species |>
                       fct_infreq() |>
                       fct_rev())) +
  geom_bar()

# For a numerical variable, we often start with a histogram.
ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram()

# We can control the "resolution" of the histogram.
# Option A: set binwidth (width of each bin) and choose a sensible value.
ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram(binwidth = 200)

ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram(binwidth = 2000)

ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram(binwidth = 20)

# Option B: set the number of bins via bins = ...
ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram(bins = 30)

ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram(bins = 300)

ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram(bins = 10)

# Alternatively, we can display a smoothed density estimate (a continuous analogue of a histogram).
ggplot(penguins, aes(x = body_mass_g)) +
  geom_density() +
  scale_y_continuous(labels = scales::comma)

# * Visualizing relationships between variables --------------------------------

# Categorical + numerical: a box plot is a common starting point.
ggplot(penguins, aes(x = species, y = body_mass_g)) +
  geom_boxplot()

ggplot(penguins, aes(y = species, x = body_mass_g)) +
  geom_boxplot()

# Alternatively, we can overlay density curves and distinguish groups by color.
ggplot(penguins, aes(x = body_mass_g, color = species)) +
  geom_density(linewidth = 0.75)

# The geom_density() function allows you to specify both the 
# color of the curves and the fills
ggplot(penguins, aes(x = body_mass_g, 
                     color = species,
                     fill = species)) +
  geom_density()

ggplot(penguins, aes(x = body_mass_g, 
                     color = species,
                     fill = species)) +
  geom_density(alpha = .5)

# Two categorical variables: use a bar chart (stacked or side-by-side).

# By default, geom_bar() shows absolute counts and stacks the bars.
ggplot(penguins, aes(x = island, fill = species)) +
  geom_bar()

# If we set position = "fill", bars are scaled to proportions within each x-category.
ggplot(penguins, aes(x = island, fill = species)) +
  geom_bar(position = "fill")

# Two numerical variables: a scatter plot visualizes their relationship.
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point()

ggplot(penguins, aes(x = body_mass_g, y = flipper_length_mm)) +
  geom_point()

# We can add more information by mapping other variables to aesthetics
# (e.g., color, shape, size, alpha).
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(color = species, shape = island),
             size = 3)

ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g,
                     color = species, shape = island)) +
  geom_point(size = 3)

ggplot(penguins) +
  geom_point(size = 3, aes(x = flipper_length_mm, y = body_mass_g,
                           color = species, shape = island))

# Caution: too many aesthetics can make a plot cluttered and hard to read.

# A clean alternative is faceting: split the plot into panels by a grouping variable
# using facet_wrap().
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(color = species, shape = species)) +
  facet_wrap(~island, ncol = 2)

# * Saving and managing ggplot objects ----------------------------------------

# A good practice is to first store the plot in an object.
# A ggplot object is just a regular R object that we can:
# - print to the console
# - modify further
# - pass to functions such as ggsave()

p <- ggplot(penguins, aes(x = flipper_length_mm,
                          y = body_mass_g)) +
  geom_point()

# Typing the object name prints the plot:
p

# We can add more layers later and reassign it:
p <- p +
  geom_smooth(method = "lm", color = "blue")

p

# Saving plots with ggsave()

# If no plot argument is supplied, ggsave() saves the LAST displayed plot.
?ggsave
ggsave(filename = "plots/penguin-plot-1.png")

# However, it is often safer and clearer to explicitly specify the plot object.
ggsave(filename = "plots/penguin-plot-2.png",
       plot = p)

# We can also control output size and units.
ggsave(filename = "plots/penguin-plot-3.png",
       plot = p,
       units = "cm",
       width = 16,
       height = 10)

# We can also control resolution using the dpi argument (dots per inch).
# Lower dpi → smaller file size, lower detail (suitable for slides).
# Higher dpi → larger file size, higher detail (suitable for print).

# Low resolution (e.g., for PowerPoint)
ggsave(filename = "plots/penguin-plot-low-dpi.png",
       plot = p,
       width = 16,
       height = 10,
       units = "cm",
       dpi = 72)

# High resolution (e.g., for publication or printing)
ggsave(filename = "plots/penguin-plot-high-dpi.png",
       plot = p,
       width = 16,
       height = 10,
       units = "cm",
       dpi = 300)

# In summary:
# - Create plot → store in object (e.g., p)
# - Print it by typing its name
# - Save it with ggsave(plot = p, ...)

#   ____________________________________________________________________________
#   Data Transformation                                                     ####

# In this section, we switch from visualization to data manipulation.
# We will use the `flights` dataset from the nycflights13 package
# (loaded automatically via tidyverse).
#
# The dataset contains information about flights departing from
# New York City in 2013, including departure delays, arrival delays,
# destinations, distance, air time, and more.
#
# For data transformation, we will mainly use functions from the
# dplyr package (also part of tidyverse), such as:
# filter(), arrange(), select(), mutate(), summarize(), and group_by().

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

mutate(flights,
       air_delay = arr_delay - dep_delay,
       speed = distance / (air_time / 60))

# With .before / .after we can control where new columns appear
# (otherwise they are added at the end).
flights |>  
  mutate(
    air_delay = arr_delay - dep_delay,
    speed = distance / (air_time / 60),
    .before = 1
  )

flights |>  
  mutate(
    air_delay = arr_delay - dep_delay,
    speed = distance / (air_time / 60),
    .after = day
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
