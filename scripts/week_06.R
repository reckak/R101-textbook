# * Required packages --------------------------------------------------
# (some are not part of core tidyverse)
library(psych)    # For reliability estimates 
library(tidyverse)
library(readr)    # For CSV and TSV files import
library(janitor)  # For clean_names(), remove_empty(), etc.
library(readxl)   # For Excel files
library(haven)    # For SPSS, Stata, and similar formats
library(labelled) # For variable and value labels (similar to SPSS/JASP)
library(rstatix)

# Data Preparation ----------------------------------------------------------
#  * Import data ------------------------------------------------------------

hs <- read_rds("data/help_seeking_data.rds")
codebook <- read_rds("data/help_seeking_codebook.rds")

# When working with psychological scales, it is often useful to compute
# a reliability estimate, such as Cronbach's alpha.
hs %>% 
  select(starts_with("help_")) %>% 
  psych::alpha()

# However, first we need to recode reversed items.
# For the Attitudes Toward Seeking Professional Psychological Help scale,
# the reversed items are help_02, help_04, help_08, help_09, and help_10.
codebook %>% 
  filter(
    instrument == "Attitudes Toward Seeking Professional Psychological Help",
    reversed
  )


#  * RECODING REVERSED ITEMS ------------------------------------------------
#  ** Manual recoding -------------------------------------------------------

# Again, recoding each item separately would be inefficient and prone to
# errors, because we would have to reference each column individually and
# repeat the same line of code several times.
hs %>% 
  mutate(
    help_02 = 5 - help_02,
    help_04 = 5 - help_04,
    help_08 = 5 - help_08,
    help_09 = 5 - help_09,
    help_10 = 5 - help_10
  )

#  ** Create a vector of reversed item names --------------------------------

# Therefore, we can first create a character vector with the names of
# the reversed items using str_c().

# This is almost correct:
str_c(
  "help_",
  c(2, 4, 8, 9, 10)
)

# However, we need leading zeros to match the column names exactly.

# This can be done with str_pad().
str_pad(
  c(2, 4, 8, 9, 10),   # Vector
  width = 2,           # Extend each element to a length of two characters
  pad = "0",           # By adding zeros
  side = "left"        # On the left side
)

# Now we can combine this with str_c().
rev_help <- str_c(
  "help_",
  str_pad(
    c(2, 4, 8, 9, 10),
    pad = "0",
    width = 2
  )
)

# Now we have the names of the reversed items.
rev_help

# And we can use them inside across().
hs %>% 
  mutate(
    across(
      all_of(rev_help), # Select the reversed columns
      ~ 5 - .x          # Apply reverse scoring
    )
  )

# A 1-4 response scale is reversed with 5 - x:
# 5 - 1 = 4, 5 - 2 = 3, 5 - 3 = 2, and 5 - 4 = 1.

# By default, the original columns are overwritten because the newly created
# columns keep the same names.
# If we want to keep the original data frame unchanged, we should save the
# result into a different object, for example hs_rec.
hs_rec <- hs %>% 
  mutate(
    across(
      all_of(rev_help),
      ~ 5 - .x
    )
  )

# Now that the reversed items have been recoded, the reliability estimate
# is valid.
hs_rec %>% 
  select(starts_with("help_")) %>% 
  psych::alpha()

# Alpha around 0.82 can usually be considered good.

# Alternatively, if we want to store the recoded columns in the original
# data frame but still keep the original versions, we can create new names
# with the .names argument.
# For example, we can add the suffix "_r" to the names of the recoded items.
hs %>% 
  mutate(
    across(
      all_of(rev_help),
      ~ 5 - .x,
      .names = "{.col}_r" # {.col} is a placeholder for the original column name
    )
  )


#  * Compute a total score --------------------------------------------------

# If we have the recoded data, we can compute a total score reflecting
# a general attitude toward seeking professional psychological help.
# This is usually done by computing a row-wise mean across relevant items.

# This will not work, because mean() from base R does not support dplyr-style
# column selection directly, unlike select().
hs_rec %>% 
  mutate(
    tot_help = mean(help_01:help_10)
  )

# However, we can use the helper function c_across().
# Still, this result is not correct because missing values are contagious.
hs_rec %>% 
  mutate(
    tot_help = mean(c_across(help_01:help_10)),
    .before = help_01
  )

# We need to set na.rm = TRUE to remove missing values before computation.
hs_rec %>% 
  mutate(
    tot_help = mean(c_across(help_01:help_10), na.rm = TRUE),
    .before = help_01
  )

# Something is still wrong, because only one mean is computed for all rows.
hs_rec %>% 
  mutate(
    tot_help = mean(c_across(help_01:help_10), na.rm = TRUE),
    .before = help_01
  )

# We need rowwise() to compute the mean one respondent at a time.
hs_rec <- hs_rec %>% 
  rowwise() %>% 
  mutate(
    tot_help = mean(c_across(help_01:help_10), na.rm = TRUE),
    .before = help_01
  )

# We should also inspect the number of missing values per respondent.
hs_rec <- hs_rec %>% 
  rowwise() %>% 
  mutate(
    tot_help = mean(c_across(help_01:help_10), na.rm = TRUE),
    n_miss_help = sum(is.na(c_across(help_01:help_10))),
    .before = help_01
  ) %>% 
  ungroup()

# Then we can see how many respondents have how many missing values.
hs_rec %>% 
  count(n_miss_help)

# We can also set a missing-data cut-off.
# For example, if a respondent has more than two missing values,
# we may replace their total score with NA.
hs_rec <- hs_rec %>% 
  mutate(
    tot_help = if_else(
      n_miss_help > 2,
      true = NA_real_,
      false = tot_help
    )
  )


#  * Summarize the total score ----------------------------------------------
hs_rec %>%
  summarise(
    n = n(),
    n_valid = sum(!is.na(tot_help)),
    mean = mean(tot_help, na.rm = TRUE),
    sd = sd(tot_help, na.rm = TRUE)
  )

# Exercises ----------------------------------------------------------------
# Practice: Repeat the workflow for a second psychological scale -----------

# Your task is to repeat the same sequence of steps for the Emotional
# Expressiveness Scale. The items of this scale start with the prefix "emo_".
#
# Specifically, try to:
# 1. Identify the reversed items using the codebook.
# 2. Create a vector with the names of the reversed items.
# 3. Recode the reversed items using across().
# 4. Compute a total score (e.g., tot_emo) as a row-wise mean across items.
# 5. Inspect the number of missing values and decide on a reasonable cut-off.
# 6. Compute a reliability estimate (Cronbach's alpha).
#
# IMPORTANT:
# Pay close attention to the response scale.
# Emotional Expressiveness items use a 1-6 scale, not a 1-4 scale.
# Therefore, the reverse-scoring formula is different:
#
# For a 1-4 scale: new_value = 5 - x
# For a 1-6 scale: new_value = 7 - x
#
# This is a very common source of errors in real data analysis.


# Identify reversed items for the Emotional Expressiveness Scale ----------
# The codebook contains information about which items are reverse-worded.
# Here we keep only those items that:
#   (a) belong to the Emotional Expressiveness Scale
#   (b) are marked as reversed
# and extract their variable names into a character vector.
rev_emo <- codebook %>% 
  filter(
    reversed,
    instrument == "Emotional Expressiveness Scale"
  ) %>% 
  pull(name)

rev_emo


# Reverse-score the identified items
# Emotional Expressiveness items use a 1-6 response scale.
# Therefore, the correct reverse-scoring formula is:
#
#   new_value = (max + 1) - old_value
#   new_value = 7 - x
#
# We use across() to apply the same transformation to all reversed items.
hs_rec <- hs_rec %>% 
  mutate(
    across(
      all_of(rev_emo),
      ~ 7 - .x
    )
  )


# Compute reliability (Cronbach's alpha)
# This step evaluates the internal consistency of the Emotional
# Expressiveness Scale.
hs_rec %>% 
  select(starts_with("emo_")) %>% 
  psych::alpha()


# Compute total score and count missing values
# tot_emo: mean score across all Emotional Expressiveness items
# n_miss_emo: number of missing item responses for each participant
#
# rowwise() allows us to compute statistics across columns within each row.
hs_rec <- hs_rec %>% 
  rowwise() %>% 
  mutate(
    tot_emo = mean(c_across(emo_01:emo_17), na.rm = TRUE),
    n_miss_emo = sum(is.na(c_across(emo_01:emo_17))),
    .before = help_01
  ) %>% 
  ungroup()


# Inspect the distribution of missing values
# This helps us decide on a reasonable threshold for excluding participants
# from the total-score computation.
hs_rec %>% 
  count(n_miss_emo)


# Apply a missing-data rule
# Here we set the total score to NA if more than 2 items are missing.
# Such a rule should ideally be decided in advance (e.g., in an analysis
# plan or preregistration).
hs_rec <- hs_rec %>% 
  mutate(
    tot_emo = if_else(
      n_miss_emo > 2,
      true = NA_real_,
      false = tot_emo
    )
  )


# Emotional Openness and attitudes toward seeking professional help -------

# * Scatterplots -------------------------------------------------------------
# Goal: Visualize the association between two continuous variables:
#   tot_emo  = Emotional Openness
#   tot_help = Attitudes toward Seeking Professional Psychological Help
#
# A scatterplot is the standard graph for showing the relationship between
# two continuous variables.
hs_rec %>% 
  ggplot(aes(tot_emo, tot_help)) +
  geom_point()


# Add jitter to reduce overplotting
# Jitter slightly shifts the points so that overlapping observations become
# visible. This does NOT change the actual data values, only their position
# in the plot.
hs_rec %>% 
  ggplot(aes(tot_emo, tot_help)) +
  geom_point(
    position = position_jitter(
      width = .05,
      height = .05,
      seed = 123
    )
  )


# Shortcut for jitter: geom_jitter()
hs_rec %>% 
  ggplot(aes(tot_emo, tot_help)) +
  geom_jitter(height = .05, width = .05)


# Use a cleaner visual theme
# theme_classic() removes the grey background and improves readability.
# base_size controls the default font size.
hs_rec %>% 
  ggplot(aes(tot_emo, tot_help)) +
  geom_jitter(height = .1, width = .3) +
  theme_classic(base_size = 15)


# Set a global default theme for subsequent plots
# After this call, all following plots will use theme_classic(base_size = 15)
# unless specified otherwise.
theme_set(
  theme_classic(base_size = 15)
)


# Scatterplot with jitter using the global theme 
hs_rec %>% 
  ggplot(aes(tot_emo, tot_help)) +
  geom_jitter(height = .05, width = .05)


# Add a smooth trend line
# By default, geom_smooth() uses loess for smaller datasets.
# This provides a flexible summary of the general trend in the data.
hs_rec %>% 
  ggplot(aes(tot_emo, tot_help)) +
  geom_jitter(height = .05, width = .05) +
  geom_smooth()


# Add a linear regression line
# method = "lm" fits a standard linear regression line.
# level = .99 requests a 99% confidence interval around the estimated mean.
# The shaded area reflects uncertainty around the estimated regression line,
# not around individual observations.
hs_rec %>% 
  ggplot(aes(tot_emo, tot_help)) +
  geom_jitter(height = .05, width = .05) +
  geom_smooth(
    method = "lm",
    level = .99,
    color = "red",
    fill = "red",
    alpha = .2
  )


# Compare a linear fit and a loess smooth
# Blue dashed line: linear regression without confidence interval
# Red solid line: loess smooth with a 95% confidence interval
hs_rec %>% 
  ggplot(aes(tot_emo, tot_help)) +
  geom_jitter(height = .05, width = .05) +
  geom_smooth(
    method = "lm",
    color = "blue",
    se = FALSE,
    linetype = "11"
  ) +
  geom_smooth(
    level = .95,
    color = "red",
    fill = "red",
    alpha = .2
  )

# Add axis labels
# Clear labels make the plot easier to understand and more suitable for
# reports or presentations.
hs_rec %>% 
  ggplot(aes(tot_emo, tot_help)) +
  geom_jitter(height = .05, width = .05) +
  geom_smooth(
    method = "lm",
    color = "blue",
    fill = "blue",
    alpha = .2
  ) +
  labs(
    x = "Emotional Openness",
    y = "Attitudes toward Seeking Professional Psychological Help"
  )

# Customize axis breaks
# Emotional Openness uses a 1-6 response metric.
# The help scale total score is expected to vary roughly on a 1-4 metric.
# coord_cartesian() zooms the visible x-range without removing data.
hs_rec %>% 
  ggplot(aes(tot_emo, tot_help)) +
  geom_jitter(height = .05, width = .05) +
  geom_smooth(
    method = "lm",
    color = "blue",
    fill = "blue",
    alpha = .2
  ) +
  labs(
    x = "Emotional Openness",
    y = "Attitudes toward Seeking Professional Psychological Help"
  ) +
  scale_x_continuous(breaks = seq(1, 6, by = 1)) +
  scale_y_continuous(breaks = seq(1, 4, by = 1)) +
  coord_cartesian(xlim = c(1, 6))


# * Basic correlation tests in base R ---------------------------------------
# cor.test() tests the null hypothesis that the population correlation is 0.
# By default, it computes Pearson's correlation.
# Pearson correlation is most appropriate when the relationship is roughly
# linear and there are no extreme outliers.
cor.test(hs_rec$tot_emo, hs_rec$tot_help)


# The same correlation test using formula syntax
cor.test(
  ~ tot_emo + tot_help,
  data = hs_rec
)


# Spearman correlation
# A non-parametric alternative that is more robust to outliers, skewed
# distributions, and monotonic but non-linear relationships.
cor.test(
  hs_rec$tot_emo,
  hs_rec$tot_help,
  method = "spearman"
)

# Change the confidence level
# conf.level = .99 requests a 99% confidence interval.
cor.test(
  hs_rec$tot_emo,
  hs_rec$tot_help,
  conf.level = .99
)


# Correlation matrix
# Compute correlations among all help-related variables.
# Be careful with missing data: by default, cor() uses complete cases only.
hs_rec %>% 
  select(starts_with("help")) %>% 
  cor()


# Pairwise handling of missing values
# use = "pairwise" means that each correlation is computed from all cases
# that have data on that particular pair of variables.
hs_rec %>% 
  select(starts_with("help")) %>% 
  cor(use = "pairwise")


# Round the correlation matrix for readability
hs_rec %>% 
  select(starts_with("help")) %>% 
  cor(use = "pairwise") %>% 
  round(digits = 2)


# * Q-Q plots and histograms -------------------------------------------------
# Goal: Examine whether variables are approximately normally distributed.
# This can be useful before using Pearson correlation or linear regression.


# Histogram of standardized Emotional Openness
# scale() converts the variable to z-scores (mean = 0, SD = 1).
# The red curve shows the theoretical normal distribution.
hs_rec %>% 
  ggplot(aes(x = scale(tot_emo))) +
  geom_histogram(
    aes(y = after_stat(density)),
    binwidth = .25,
    color = "black",
    fill = "grey"
  ) +
  stat_function(
    fun = dnorm,
    color = "red",
    linewidth = 1
  )

# Q-Q plot for attitudes toward seeking professional help
# If the points lie roughly on the line, the distribution is approximately
# normal.
hs_rec %>% 
  ggplot(aes(sample = tot_help)) +
  geom_qq_line() +
  geom_qq()


# Histogram of standardized help attitudes
ggplot(aes(x = scale(tot_help))) +
  geom_histogram(
    aes(y = after_stat(density)),
    binwidth = .5,
    color = "black",
    fill = "grey"
  ) +
  stat_function(
    fun = dnorm,
    color = "red",
    linewidth = 1
  )

# Another Q-Q plot for the same variable
hs_rec %>% 
  ggplot(aes(sample = tot_help)) +
  geom_qq_line() +
  geom_qq()


# * Simple linear regression -------------------------------------------------
# We first visualize the fitted linear trend again using a publication-ready
# scatterplot with labels and axis breaks.
hs_rec %>% 
  ggplot(aes(tot_emo, tot_help)) +
  geom_jitter(height = .05, width = .05) +
  geom_smooth(
    method = "lm",
    color = "blue",
    fill = "blue",
    alpha = .2
  ) +
  labs(
    x = "Emotional Openness",
    y = "Attitudes toward Seeking Professional Psychological Help"
  ) +
  scale_x_continuous(breaks = seq(1, 6, by = 1)) +
  scale_y_continuous(breaks = seq(1, 4, by = 1)) +
  coord_cartesian(xlim = c(1, 6))


# Fit the linear regression model
# Here we predict attitudes toward seeking professional help from emotional
# openness.
# na.action = "na.exclude" keeps the alignment of residuals/predictions with
# the original dataset.
fit <- lm(
  tot_help ~ tot_emo,
  data = hs_rec,
  na.action = "na.exclude"
)

summary(fit)

# Create new predictor values for plotting model predictions
# We generate a fine grid covering the whole observed scale of tot_emo.
new_data <- tibble(
  tot_emo = seq(1, 6, by = 0.01)
)


# Confidence intervals for the expected mean
# Confidence intervals express uncertainty around the estimated mean outcome
# at each value of the predictor.
ci <- predict(
  fit,
  newdata = new_data,
  interval = "confidence"
) %>% 
  as_tibble() %>% 
  rename(
    ci_lwr = lwr,
    ci_upr = upr
  )

ci


# Prediction intervals for individual observations
# Prediction intervals are wider than confidence intervals because they
# include both uncertainty in the estimated mean and individual variability.
pi <- predict(
  fit,
  newdata = new_data,
  interval = "prediction"
) %>% 
  as_tibble() %>% 
  rename(
    pi_lwr = lwr,
    pi_upr = upr
  )

pi


# Combine confidence and prediction intervals
# Both objects contain the fitted values, so we join them by the common
# column "fit".

ci_pi <- left_join(ci, pi, by = "fit")
ci_pi

# Bind intervals back to the predictor grid
new_data <- bind_cols(new_data, ci_pi)
new_data


# Plot only the fitted regression line
new_data %>% 
  ggplot(aes(tot_emo)) +
  geom_line(aes(y = fit))


# Add the confidence interval
new_data %>% 
  ggplot(aes(tot_emo)) +
  geom_ribbon(
    aes(ymin = ci_lwr, ymax = ci_upr),
    fill = "blue",
    alpha = 0.2
  ) +
  geom_line(aes(y = fit))


# Add both prediction and confidence intervals
# Pink ribbon: prediction interval
# Blue ribbon: confidence interval
new_data %>% 
  ggplot(aes(tot_emo)) +
  geom_ribbon(
    aes(ymin = pi_lwr, ymax = pi_upr),
    fill = "pink",
    alpha = 0.2
  ) +
  geom_ribbon(
    aes(ymin = ci_lwr, ymax = ci_upr),
    fill = "blue",
    alpha = 0.2
  ) +
  geom_line(aes(y = fit))


# Add observed data points
# This final plot overlays the fitted line and both interval types on top of
# the raw data.
new_data %>% 
  ggplot(aes(tot_emo)) +
  geom_ribbon(
    aes(ymin = pi_lwr, ymax = pi_upr),
    fill = "pink",
    alpha = 0.2
  ) +
  geom_ribbon(
    aes(ymin = ci_lwr, ymax = ci_upr),
    fill = "blue",
    alpha = 0.2
  ) +
  geom_line(aes(y = fit)) +
  geom_point(
    data = hs_rec,
    aes(y = tot_help),
    alpha = .5
  )


# Comparing men and women --------------------------------------------------
# Keep only participants coded as Female or Male.
# This avoids accidental inclusion of other values or missing labels.
hs_clean <- hs_rec %>% 
  filter(gender %in% c("Female", "Male"))


# Boxplot with mean and confidence interval
# stat_summary(fun.data = mean_cl_normal) adds the group mean and a normal-
# theory confidence interval.
hs_clean %>% 
  ggplot(aes(gender, tot_help)) +
  geom_boxplot() +
  stat_summary(
    fun.data = mean_cl_normal,
    color = "red"
  )


# Violin plot + boxplot + raw data
# This combines several layers:
#   - violin: approximate distribution shape
#   - boxplot: median and quartiles
#   - jittered points: individual observations
#   - red summary: mean with confidence interval
hs_clean %>% 
  ggplot(aes(gender, tot_help)) +
  geom_violin() +
  geom_boxplot(width = .3) +
  geom_jitter(width = 0.1, alpha = .25) +
  stat_summary(
    fun.data = mean_cl_normal,
    color = "red"
  )


# * Independent-samples t-test ----------------------------------------------
# This test compares the mean level of attitudes toward seeking professional
# psychological help between women and men.
#
# By default, t.test() uses Welch's t-test, which does not assume equal
# variances across groups.

t.test(
  tot_help ~ gender,
  data = hs_clean
)


# Student's t-test with equal variances assumed
# Setting var.equal = TRUE requests the classical pooled-variance t-test.
# In practice, Welch's test is often preferred unless equal variances are
# well justified.
t.test(
  tot_help ~ gender,
  data = hs_clean,
  var.equal = TRUE
)


# The same test using rstatix
# detailed = TRUE returns a more complete output, including descriptive
# information and test statistics in a tidy format.
hs_clean %>% 
  drop_na(gender) %>%  
  rstatix::t_test(
    tot_help ~ gender,
    detailed = TRUE
  )


# rstatix version with equal variances assumed
hs_clean %>% 
  drop_na(gender) %>%  
  rstatix::t_test(
    tot_help ~ gender,
    detailed = TRUE,
    var.equal = TRUE
  )


# Effect size: Cohen's d
# Cohen's d expresses the mean difference in standard deviation units.
# The confidence interval helps quantify uncertainty around the effect-size
# estimate.
hs_clean %>% 
  drop_na(gender) %>%  
  rstatix::cohens_d(
    tot_help ~ gender,
    ci = TRUE,
    ci.type = "norm"
  )


# * Group-wise descriptive statistics ---------------------------------------
# These summaries help us understand the group means, variability, sample
# sizes, and the approximate shape of the distributions.
#
# m      = mean
# s      = standard deviation
# skew   = skewness
# kurt   = kurtosis
# n      = total number of rows in the group
# n_valid= number of non-missing values on tot_help
hs_clean %>% 
  group_by(gender) %>% 
  summarise(
    m = mean(tot_help, na.rm = TRUE),
    s = sd(tot_help, na.rm = TRUE),
    skew = psych::skew(tot_help),
    kurt = psych::kurtosi(tot_help),
    n = n(),
    n_valid = sum(!is.na(tot_help))
  )


# * Checking assumptions ----------------------------------------------------
# It is good practice to inspect assumptions, but keep in mind that the
# independent-samples t-test is fairly robust, especially in larger samples.
# We typically focus on:
#   - approximate normality within groups
#   - homogeneity of variances across groups
#
# These checks should be interpreted together with visual inspection and
# substantive judgment, not mechanically.


# Q-Q plots by gender
# If the points lie roughly along the reference line, the group distribution
# is approximately normal.
hs_clean %>% 
  ggplot(aes(sample = tot_help)) +
  geom_qq() +
  geom_qq_line() +
  facet_wrap(~ gender)


# Histograms by gender
# Histograms provide a complementary visual check of distribution shape,
# skewness, and potential outliers.
hs_clean %>% 
  ggplot(aes(x = tot_help)) +
  geom_histogram(
    aes(y = after_stat(density)),
    binwidth = .25
  ) +
  facet_wrap(~ gender)


# Levene's test for homogeneity of variances
# This test evaluates whether group variances are similar.
# If the test is significant, Welch's t-test is usually the safer choice.
hs_clean %>% 
  rstatix::levene_test(tot_help ~ gender)


# Shapiro-Wilk tests within groups
# This formally tests normality in each group.
# In practice, these tests can be overly sensitive in large samples and
# underpowered in small samples, so they should not be used in isolation.
hs_clean %>% 
  group_by(gender) %>% 
  rstatix::shapiro_test(tot_help)