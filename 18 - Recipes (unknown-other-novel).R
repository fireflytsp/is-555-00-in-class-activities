library(tidyverse)
library(tidymodels)

# ── Load & split ──────────────────────────────────────────
cars <- read_csv('https://www.dropbox.com/scl/fi/xavej23qpauvx3xfdq7zh/car_sales.csv?rlkey=4mfp6tpia0uqkcoiqf9jleau3&dl=1')

set.seed(42)
cars_split <- initial_split(cars, prop = 0.8)
cars_training <- training(cars_split)
cars_testing  <- testing(cars_split)

# ── Quick look at why this matters ────────────────────────
# How many NAs in make?
cars_training |> summarize(
  na_make = sum(is.na(make)), 
  na_model = sum(is.na(model))
  )

# How many unique makes, and how many are rare (< 5%)?
cars_training |>
  count(make, sort = TRUE) |>
  mutate(pct = n / sum(n)) |>
  summarize(
    total_makes   = n(),
    below_5_pct   = sum(pct < 0.05),
    singletons    = sum(n <= 2)
  )

# Which makes appear in test but NOT in training?
test_makes  <- unique(cars_testing$make)
train_makes <- unique(cars_training$make)
setdiff( train_makes, test_makes)  # these are the "unseen" levels

# ═══════════════════════════════════════════════════════════
# DEMO 1: step_unknown() — handling NAs in categorical cols
# ═══════════════════════════════════════════════════════════

# What happens if we just try step_dummy() on data with NAs?
bad_rec <- recipe(sellingprice_log ~ make, data = cars_training) |>
  step_dummy(make)

# This will create weird dummy codes because make has NAs
bad_rec |> prep() |> 
  bake(cars_training) |> 
  select(starts_with("make_")) |>
  glimpse()

# Fix: convert NAs to an explicit factor level first
rec_unknown <- recipe(sellingprice_log ~ make, data = cars_training) |>
  step_unknown(make, new_level = "missing") |>
  step_dummy(make)


# Look at the training result — NAs are now "missing"
rec_unknown |> prep() |>
  bake(cars_training) |>
  select(starts_with("make_")) |>
  glimpse()

# Confirm: is there a make_missing column?
rec_unknown_prepped |>
  bake(cars_training) |>
  select(make_missing) |>
  summarize(has_missing = sum(make_missing))

# ═══════════════════════════════════════════════════════════
# DEMO 2: step_other() — collapsing rare categories
# ═══════════════════════════════════════════════════════════

rec_other <- recipe(sellingprice_log ~ make, data = cars_training) |>
  step_unknown(make, new_level = "missing") |>
  step_other(make, threshold = 0.05) |>
  step_dummy(make)

rec_other_prepped <- rec_other |> prep()

# How many dummy columns now? Much fewer than 86!
rec_other_prepped |>
  bake(cars_training) |>
  select(starts_with("make_"))

# ═══════════════════════════════════════════════════════════
# DEMO 3: step_novel() — catching unseen levels at bake time
# ═══════════════════════════════════════════════════════════

# Without step_novel(), baking test data with unseen makes fails
rec_no_novel <- recipe(sellingprice_log ~ make, data = cars_training) |>
  step_unknown(make, new_level = "missing") |>
  # step_other(make, threshold = 0.05) |>
  step_dummy(make)

rec_no_novel_prepped <- rec_no_novel |> prep()

# This will warn or error because test has makes not in training
rec_no_novel_prepped |> bake(cars_testing)  # uncomment to see

# Fix: add step_novel() between unknown and other
rec_novel <- recipe(sellingprice_log ~ make, data = cars_training) |>
  step_unknown(make, new_level = "missing") |>
  step_novel(make, new_level = "brand_new") |>
  step_other(make, threshold = 0.05) |>
  step_dummy(make)

rec_novel_prepped <- rec_novel |> prep()

# Now baking test data works — unseen makes become "brand_new"
rec_novel_prepped |>
  bake(cars_testing) |>
  select(starts_with("make_")) |>
  glimpse()

# Check: any rows mapped to brand_new?
rec_novel_prepped |>
  bake(cars_testing) |>
  select(make_brand.new) |>
  summarize(n_brand_new = sum(make_brand.new))

# ═══════════════════════════════════════════════════════════
# DEMO 4: The full recommended recipe
# ═══════════════════════════════════════════════════════════

cars_rec <- recipe(sellingprice_log ~ ., data = cars_training) |>
  step_impute_median(all_numeric_predictors()) |>
  step_YeoJohnson(all_numeric_predictors()) |>
  step_unknown(c(make, model), new_level = "missing") |>    # 1. NA → level
  step_novel(c(make, model), new_level = "brand_new") |>    # 2. safety net
  step_other(c(make, model), threshold = 0.05) |>           # 3. rare → other
  step_normalize(all_numeric_predictors()) |>
  step_dummy(all_nominal_predictors())                        # 4. encode

cars_prepped <- cars_rec |> prep()

# Bake training — should work cleanly
cars_prepped |>
  bake(cars_training) |>
  glimpse()

# Bake testing — works even with unseen makes/models
cars_prepped |>
  bake(cars_testing) |>
  glimpse()