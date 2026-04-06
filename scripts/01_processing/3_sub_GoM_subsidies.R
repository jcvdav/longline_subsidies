################################################################################
# Fuel subsidy data processing
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# jc_villasenor@miami.edu
#
# Loads subsidy panel from the mexican_subsidies sibling repository and filters
# to the economic units present in the study fleet.
# Requires: ../mexican_subsidies/data/processed/economic_unit_subsidy_panel.rds
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
subsidy_roster <- readRDS(file = here("../mexican_subsidies/data/processed/economic_unit_subsidy_panel.rds"))

## PROCESSING ##################################################################

# Filter to study economic units ------------------------------------------------
rnpa <- unique(effort$eu_rnpa)

ll_subsidies <- filter(subsidy_roster,
                       year >= 2011,
                       eu_rnpa %in% rnpa) |> 
  select(year, eu_rnpa, subsidy_pesos, treated)


## VISUALIZE ###################################################################

# Quick visual checks -----------------------------------------------------------
ggplot(ll_subsidies,
       aes(x = year,
           y = subsidy_pesos)) +
  stat_summary(geom = "col", fun = "sum")

ggplot(ll_subsidies,
       aes(x = year,
           y = treated)) +
  stat_summary(geom = "col", fun = "sum")


## EXPORT ######################################################################

# Save processed subsidies data -------------------------------------------------
saveRDS(object = ll_subsidies,
        file = here("data", "processed", "annual_subsidies_by_economic_unit.rds"))
