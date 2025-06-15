################################################################################
# title
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# jc_villasenor@miami.edu
# date
#
# Description
#
################################################################################

## SET UP ######################################################################

# Load packages ----------------------------------------------------------------
pacman::p_load(
  here,
  tidyverse
)

# Load data --------------------------------------------------------------------
effort <- readRDS(file = here("data", "processed", "annual_effort_by_vessel.rds"))
landings <- readRDS(file = here("data", "processed", "annual_landings_by_vessel.rds"))

## PROCESSING ##################################################################

# X ----------------------------------------------------------------------------
data <- inner_join(effort, landings, by = join_by(year, vessel_rnpa)) |> 
  mutate(period = ifelse(year <= 2019, "subsidies", "no subsidies")) |> 
  select(period, year, vessel_id = vessel_rnpa, effort_hours = h, catch_kg = live_weight) |> 
  mutate(cpue = catch_kg / effort_hours)

## VISUALIZE ###################################################################

# X ----------------------------------------------------------------------------
ggplot(data, aes(x = period, y = effort_hours)) +
  stat_summary(geom = "col", fun = "mean")

ggplot(data, aes(x = period, y = catch_kg)) +
  stat_summary(geom = "col", fun = "mean")

ggplot(data, aes(x = period, y = cpue)) +
  stat_summary(geom = "col", fun = "mean")

## EXPORT ######################################################################

# X ----------------------------------------------------------------------------
saveRDS(object = data,
        file = here("data", "estimation", "annual_effort_and_catch_by_vessel.rds"))
write_csv(x = data,
          file = here("data", "estimation", "annual_effort_and_catch_by_vessel.csv"))
