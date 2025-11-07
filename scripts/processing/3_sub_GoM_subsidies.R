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
subsidy_roster <- readRDS(file = here("../mexican_subsidies/data/processed/economic_unit_subsidy_panel.rds"))

## PROCESSING ##################################################################

# X ----------------------------------------------------------------------------
rnpa <- unique(effort$eu_rnpa)

ll_subsidies <- filter(subsidy_roster,
                       year >= 2011,
                       eu_rnpa %in% rnpa) |> 
  select(year, eu_rnpa, subsidy_pesos, treated)


## VISUALIZE ###################################################################

# X ----------------------------------------------------------------------------
ggplot(ll_subsidies,
       aes(x = year,
           y = subsidy_pesos)) +
  stat_summary(geom = "col", fun = "sum")

ggplot(ll_subsidies,
       aes(x = year,
           y = treated)) +
  stat_summary(geom = "col", fun = "sum")


## EXPORT ######################################################################

# X ----------------------------------------------------------------------------
saveRDS(object = ll_subsidies,
        file = here("data", "processed", "annual_subsidies_by_economic_unit.rds"))
