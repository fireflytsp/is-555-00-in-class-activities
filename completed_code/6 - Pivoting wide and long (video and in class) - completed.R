# Function Summary --------------------------------------------------------------------------------------

# JUST TWO FUNCTIONS:
# 
# I'm going to narrate the two functions with their parameters as a new way to help...?
# 
# Pay special attention to the parameters with the ** as they are the most important.
# 
# pivot_longer(
#   data,                             <-- The incoming tibble, usually comes in via a pipe
#   **cols,                           <-- This is where you say which columns you're pulling down to long format
#                                           (any that you don't name here are assumed to be "id columns" that 
#                                           will repeat with each of the variables being converted to long format)
#   **names_to = "name",              <-- This is the column name that will "house" the column names that you have 
#                                           specified in the `cols` parameter. Often you can just leave this as the 
#                                           default and it will name it "name", but you can also be more descriptive
#   names_prefix = NULL,              <-- You can (optionally) indicate a text-based prefix to auto-remove as the
#                                           function is pulling the columns down. So for columns like `year1`, `year2`,
#                                           you could specify "year" as the prefix and the function would remove it.
#   names_sep = NULL,                 <-- beyond our scope - explore this on your own if you want. 
#   names_pattern = NULL,             <-- beyond our scope - explore this on your own if you want.
#   names_ptypes = NULL,              <-- beyond our scope - explore this on your own if you want.
#   names_transform = NULL,           <-- beyond our scope - explore this on your own if you want.
#   names_repair = "check_unique",    <-- beyond our scope - explore this on your own if you want.
#   **values_to = "value",              <-- this is the column that will "house" the values corresponding to each of 
#                                           the column name labels in the `names_to` column that you specified above.
#   values_drop_na = FALSE,           <-- wider data is often "sparse", meaning that it has lots of nulls when not all
#                                           rows have a value for each wide column. It's usually efficient to filter 
#                                           those out when pivoting longer, so this is an option for convenience.
#   values_ptypes = NULL,             <-- beyond our scope - explore this on your own if you want.
#   values_transform = NULL,          <-- beyond our scope - explore this on your own if you want.
# )
# 
# 
# pivot_wider(                        
#   data,                             <-- The incoming tibble, usually comes in via a pipe
#   id_cols = NULL,                   <-- "id columns" are the ones that you DON'T want to spread out as wide
#                                           columns, but you can usually ignore this parameter because you will
#                                           be explicitly specifying the `names_from` and `values_from` parameters
#   id_expand = FALSE,                <-- beyond our scope - explore this on your own if you want.
#   **names_from = name,                <-- Here you specify the column that contains the value names or "labels"
#                                           (it defaults to `name` because that's the default from `pivot_longer()`)
#   names_prefix = "",                <-- beyond our scope - explore this on your own if you want.
#   names_sep = "_",                  <-- beyond our scope - explore this on your own if you want.
#   names_glue = NULL,                <-- beyond our scope - explore this on your own if you want.
#   names_sort = FALSE,               <-- beyond our scope - explore this on your own if you want.
#   names_vary = "fastest",           <-- beyond our scope - explore this on your own if you want.
#   names_expand = FALSE,             <-- beyond our scope - explore this on your own if you want.
#   names_repair = "check_unique",    <-- beyond our scope - explore this on your own if you want.
#   **values_from = value,              <-- Here you specify the column that contains the values corresponding to the
#                                           names specified in the `names_from` parameter.
#                                           (it defaults to `value` because that's the default from `pivot_longer()`)
#   values_fill = NULL,               <-- This option allows you to provide the "default value" for any rows in the
#                                           wider data that don't have a value in the longer format list. (Leaving
#                                           this out will result in NAs in the wider data, which is usually fine.)
#   values_fn = NULL,                 <-- beyond our scope - explore this on your own if you want.
#   unused_fn = NULL,                 <-- beyond our scope - explore this on your own if you want.
# )

# Sample Code -------------------------------------------------------------------------------------------

library(tidyverse)


drinks <- tribble(
  ~country,  ~soda, ~tea,  ~sparkling_water,
  'China',      79,    192,     8,
  'Italy',         85,     42,   237,
  'USA',          249,     58,    84
)

drinks_2 <- tribble(
  ~country, ~population, ~soda, ~tea,  ~sparkling_water,  ~cat_count, ~dog_count,                      
  'China',   786578,   79,    192,     8,                   3456,         3,     
  'Italy',   125,      85,     42,   237,                   20,         123,     
  'USA',     2355,     249,     58,    84,                   3,         84728     
)

drinks
drinks_2 



# Let's make it more tidy. pivot_longer
drinks_longer <- drinks %>% 
  pivot_longer(
    cols = c(soda, tea, sparkling_water),
    names_to = 'drink_type',
    values_to = 'liters_per_capita'
  ) 

drinks_2 %>% 
  pivot_longer(
    cols = c(soda, tea, sparkling_water),
    names_to = 'drink_type',
    values_to = 'liters_per_capita'
  ) 

drinks_longer |> 
  pivot_wider(
    names_from = drink_type,
    values_from = liters_per_capita
  )



drinks_2 |> 
  pivot_longer(
    cols = c(soda, tea, sparkling_water, cat_count, dog_count),
    names_to = 'key',
    values_to = 'value'
    ) |> 
  mutate(attribute_type = if_else(key %in% c('cat_count', 'dog_count'), 'animal_info','drink_info'))



# New data:
gap <- read_csv('https://www.dropbox.com/s/dv1a1ldkuyoftn2/gap_smaller.csv?dl=1')

# Start with just country, year, lifeExp, pivot wider
gap %>% 
  select(country, year, lifeExp) %>% 
  pivot_wider(
    names_from = year,
    values_from = lifeExp
  )




# Now let's go the other way: pivot all three measures longer
gap %>% 
  pivot_longer(
    cols = lifeExp:gdpPercap, # c(lifeExp, pop, gdpPercap)
    names_to = 'measure',
    values_to = 'value'
  )





# Pivot all three measures wider. Gets messy, but 
# sometimes data comes to you in this format
gap_wide <- gap %>% 
  pivot_wider(
    names_from = year,
    values_from = lifeExp:gdpPercap
  )

gap_wide %>% 
  pivot_longer(
    cols = lifeExp_1952:gdpPercap_2007,
    names_to = 'convert_me',
    values_to = 'value'
  ) %>% 
  separate_wider_delim(convert_me, delim = '_', names = c('measure','year'))




gap_wide %>% 
  pivot_longer(lifeExp_1952:gdpPercap_2007,
               names_sep = '_',
               names_to = c('year','name'))



# New data:
ri <- read_csv('https://www.dropbox.com/s/dfjgfytyek44u61/rel_inc.csv?dl=1')
bnames <- read_csv('https://www.dropbox.com/s/6bck5fy4aag76kw/baby_names.csv?dl=1')
bob <- read_csv('https://www.dropbox.com/s/mozqpceit51hia7/bob_ross.csv?dl=1')

# see if you can pivot the religious income data into a tidier format
# what is the most common income bracket for each religion?





# IMPORTANT: Notice how EASY it is to find the top income for each religion because
# of the tidying of the data we've done. It's a simple filter, rather than a 
# group_by(), which is what we used to have to do when the data was wider.

ri %>% 
  pivot_longer(
    cols = !religion,
    names_to = 'income_bracket',
    values_to = 'household_count'
  ) %>% 
  group_by(religion) %>% 
  slice_max(household_count, with_ties = F)


# Okay now let's look at this bob dataset
bob %>% 
  glimpse

# which objects occur most frequently?
bob |> 
  pivot_longer(
    cols = apple_frame:last_col(),
    names_to = 'feature',
    values_to = 'is_in_frame'
  ) |> 
  group_by(feature) |> 
  summarise(count_instances = sum(is_in_frame)) |> 
  arrange(desc(count_instances))


# What was the season when Bob painted the most mountains?

bob |> 
  pivot_longer(
    cols = apple_frame:last_col(),
    names_to = 'feature',
    values_to = 'is_in_frame'
  ) |> 
  filter(is_in_frame == 1) |> 
  group_by(season) |> 
  summarise(num_paintings_with_mtns = sum(feature %in% c('mountain', 'mountains'))) |> 
  arrange(desc(num_paintings_with_mtns))

#  How do the episodes compare in terms of the variety of objects included?
bob |> 
  pivot_longer(
    cols = apple_frame:last_col(),
    names_to = 'feature',
    values_to = 'is_in_frame'
  ) |> 
  filter(is_in_frame == 1) |> 
  group_by(episode) |> 
  summarise(distinct_feature_count = n_distinct(feature)) |> 
  arrange(desc(distinct_feature_count))

# Has the variety of objects changed over the 30 seasons?
bob |> 
  pivot_longer(
    cols = apple_frame:last_col(),
    names_to = 'feature',
    values_to = 'is_in_frame'
  ) |> 
  filter(is_in_frame == 1) |> 
  group_by(season, episode_num) |> 
  summarise(distinct_feature_count = n_distinct(feature)) |> 
  group_by(season) |> 
  summarize(mean_diversity = mean(distinct_feature_count)) |> 
  print(n=31)

# Create a table that displays one line per object with a count of times that 
# object was used in each season (one column per season)

bob |> 
  pivot_longer(
    cols = apple_frame:last_col(),
    names_to = 'feature',
    values_to = 'is_in_frame'
  ) |> 
  filter(is_in_frame == 1) |> 
  group_by(season, feature) |> 
  summarize(feature_count = n()) |> 
  mutate(season = str_c('season_',season)) |> 
  pivot_wider(names_from = season,
              values_from = feature_count,
              values_fill = 0)


# Assume we want to look at name trends over time, regardless of sex.

# First, look at it with years as columns, and look at, for example, Ashley
bnames |> 
  pivot_wider(
    names_from = year,
    values_from = n
    ) |> 
  filter(name == 'Brittany')

# Now, with names as columns
bnames |> 
  pivot_wider(
    names_from = name,
    values_from = n
  )
  


bnames |> 
  filter(name == 'Brittany') |> 
  pivot_wider(
    names_from = sex,
    values_from = n
  ) |> 
  mutate(total = M + F) |> print(n=30)
  select(-c(M, F)) |> 
  pivot_wider(
    names_from = year,
    values_from = total
  ) 





