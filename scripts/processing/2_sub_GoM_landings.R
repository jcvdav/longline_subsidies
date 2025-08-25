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
landings <- readRDS(file = url("https://github.com/jcvdav/mex_fisheries/raw/refs/heads/main/data/mex_landings/clean/mex_annual_landings_by_vessel.rds"))

## PROCESSING ##################################################################

# X ----------------------------------------------------------------------------
rnpa <- unique(effort$vessel_rnpa)
ll_landings <- filter(landings,
                      between(year, 2016, 2024),
                      vessel_rnpa %in% rnpa,
                      main_species_group %in% c("ATUN")) |> 
  select(year, vessel_rnpa, live_weight) |> 
  group_by(year, vessel_rnpa) |>
  summarize_all(sum)


## VISUALIZE ###################################################################

# X ----------------------------------------------------------------------------
ggplot(ll_landings, aes(x = year, y = live_weight)) +
  stat_summary(geom = "point", fun = "mean")

## EXPORT ######################################################################

# X ----------------------------------------------------------------------------
saveRDS(object = ll_landings,
        file = here("data", "processed", "annual_landings_by_vessel.rds"))
