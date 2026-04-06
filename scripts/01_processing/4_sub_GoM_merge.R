################################################################################
# Merge datasets and create estimation sample
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# jc_villasenor@miami.edu
#
# Joins effort, landings, and subsidy data. Defines subsidy/no-subsidy periods,
# restricts to continuously-treated vessels, removes outlier observations, and
# calculates CPUE. Outputs the estimation dataset.
#
################################################################################

## SET UP ######################################################################

# Load packages ----------------------------------------------------------------
pacman::p_load(
  here,
  tidyverse
)

# Load data --------------------------------------------------------------------
effort <- readRDS("data/processed/annual_effort_by_vessel.rds")
landings <- readRDS("data/processed/annual_landings_by_vessel.rds")
subsidies <- readRDS("data/processed/annual_subsidies_by_economic_unit.rds")

## PROCESSING ##################################################################

# Merge effort, landings, and subsidies ----------------------------------------
data <- inner_join(effort, landings, by = join_by(year, vessel_rnpa)) |> 
  left_join(subsidies, by = join_by(year, eu_rnpa)) |> 
  mutate(period = ifelse(year <= 2019, "subsidies", "no subsidies")) |> 
  replace_na(list(subsidy_pesos = 0, treated = 0)) |> 
  group_by(vessel_rnpa, period) |>
  mutate(n_times_subsidized = sum(treated, na.rm = TRUE)) |>
  ungroup() |>
  select(period, year, eu_id = eu_rnpa, vessel_id = vessel_rnpa, n_times_subsidized, effort_hours = h, catch_kg = live_weight) |> # Select the appropriate columns here
  mutate(cpue = catch_kg / effort_hours) |> 
  filter(period == "no subsidies" | n_times_subsidized == 9 & period == "subsidies") 

data_clean <- data|>
  filter(!(year == 2018 & vessel_id %in% c("00074500", "00034389")), !(year == 2016 & vessel_id == "00034389"))


## EXPORT ######################################################################
# Save estimation dataset -------------------------------------------------------
saveRDS(object = data_clean,
        file = here("data", "estimation", "annual_effort_and_catch_by_vessel.rds"))
