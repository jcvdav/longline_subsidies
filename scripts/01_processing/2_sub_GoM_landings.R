################################################################################
# Tuna landings processing for longline vessels
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# jc_villasenor@miami.edu
#
# Downloads vessel-level landings from the mex_fisheries GitHub repository,
# filters to tuna (ATUN) species for study vessels, 2011-2024.
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
landings <-  readRDS(file = url("https://github.com/jcvdav/mex_fisheries/raw/refs/heads/main/data/mex_landings/clean/mex_annual_landings_by_vessel.rds"))
## PROCESSING ##################################################################

# Filter to study vessels and tuna species --------------------------------------
rnpa <- unique(effort$vessel_rnpa)
ll_landings <- filter(landings,
                      between(year, 2011, 2024),
                      vessel_rnpa %in% rnpa,
                      main_species_group %in% c("ATUN")) |> 
  select(year, vessel_rnpa, live_weight) |> 
  group_by(year, vessel_rnpa) |>
  summarize(live_weight = sum(live_weight), .groups = "drop")


## VISUALIZE ###################################################################

# Quick visual check ------------------------------------------------------------
ggplot(ll_landings, aes(x = year, y = live_weight)) +
  stat_summary(geom = "point", fun = "mean")

## EXPORT ######################################################################

# Save processed landings data --------------------------------------------------
saveRDS(object = ll_landings,
        file = here("data", "processed", "annual_landings_by_vessel.rds"))
