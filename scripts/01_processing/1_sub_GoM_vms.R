################################################################################
# VMS effort processing for GoM longline vessels
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# jc_villasenor@miami.edu
#
# Queries BigQuery for VMS data, filters to longline (PALANGRE) vessels in
# fishing regions 5-6 (Gulf of Mexico), and calculates annual effort hours
# by vessel. Applies spatial filters: depth > 50 m, distance from shore > 500 m.
#
################################################################################

## SET UP ######################################################################

# Load packages ----------------------------------------------------------------
pacman::p_load(
  bigrquery,
  DBI,
  here,
  readxl,
  tidyverse
)

bq_auth("juancarlos.villader@gmail.com")

# Load data --------------------------------------------------------------------
con <- dbConnect(drv = bigquery(),
                 project = "mex-fisheries",
                 dataset = "mex_vms",
                 allowLargeResults = T)

vms <- tbl(con, "mex_vms_processed_v_20260409")
vi <- tbl(con, "vessel_info_v_20250815")

## PROCESSING ##################################################################

# Filter to longline vessels ----------------------------------------------------
ll <- vi |> 
  mutate(across(starts_with("gear_"), as.character)) |>
  filter(if_any(starts_with("gear_"), ~ str_detect(.x, "PALANGRE"))) |>
  select(vessel_rnpa, eu_rnpa)

effort <- vms |> 
  inner_join(ll, by = join_by(vessel_rnpa)) |> 
  filter(between(year, 2011, 2024),
         fishing_region %in% c(5, 6),
         depth_m < -50,
         hours < 1.5,
         distance_from_shore_m > 5e2) |> 
  group_by(year, eu_rnpa, vessel_rnpa) |> 
  summarize(h = sum(hours, na.rm = T),
            .groups = "drop")

effort_local <- collect(effort)

effort_local |> 
  arrange(vessel_rnpa, year)

## VISUALIZE ###################################################################

# Quick visual check ------------------------------------------------------------
ggplot(effort_local, aes(x = year, y = h)) +
  stat_summary(geom = "point", fun = "mean")

## EXPORT ######################################################################

# Save processed effort data ----------------------------------------------------
saveRDS(object = effort_local,
        file = here("data", "processed", "annual_effort_by_vessel.rds"))
