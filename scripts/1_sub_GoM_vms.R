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
                 billing = "mex-fisheries",
                 allowLargeResults = T)

vms <- tbl(con, "mex_vms_processed_v_20250613")
vi <- tbl(con, "vessel_info_v_20230803")

## PROCESSING ##################################################################

# X ----------------------------------------------------------------------------
ll <- vi |> 
  filter(str_detect(gear_type, "PALANGRE")) |> 
  select(vessel_rnpa)

effort <- vms |> 
  inner_join(ll, by = join_by(vessel_rnpa)) |> 
  filter(between(year, 2016, 2024),
         fishing_region %in% c(5, 6),
         depth_m < -50,
         hours < 1.5,
         distance_from_shore_m > 5e2) |> 
  group_by(year, vessel_rnpa) |> 
  summarize(h = sum(hours, na.rm = T),
            .groups = "drop")

effort_local <- collect(effort)

effort_local |> 
  arrange(vessel_rnpa, year)

## VISUALIZE ###################################################################

# X ----------------------------------------------------------------------------
ggplot(effort_local, aes(x = year, y = h)) +
  stat_summary(geom = "point", fun = "mean")

## EXPORT ######################################################################

# X ----------------------------------------------------------------------------
saveRDS(object = effort_local,
        file = here("data", "processed", "annual_effort_by_vessel.rds"))
