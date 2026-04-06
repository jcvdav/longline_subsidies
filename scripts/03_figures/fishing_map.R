################################################################################
# Map of VMS fishing positions for GoM longline vessels
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# jc_villasenor@miami.edu
# 2026-04-03
#
# Queries BigQuery for VMS positions of longline vessels in the Gulf of Mexico
# and plots all fishing coordinates on a map.
#
################################################################################

## SET UP ######################################################################

# Load packages ----------------------------------------------------------------
pacman::p_load(
  bigrquery,
  DBI,
  tidyverse,
  sf,
  rnaturalearth,
  rnaturalearthdata
)

bq_auth("juancarlos.villader@gmail.com")

# Connect to BigQuery ----------------------------------------------------------
con <- dbConnect(drv = bigquery(),
                 project = "mex-fisheries",
                 dataset = "mex_vms",
                 allowLargeResults = T)

vms <- tbl(con, "mex_vms_processed_v_20250623")
vi <- tbl(con, "vessel_info_v_20250815")

## PROCESSING ##################################################################

# Identify longline vessels ----------------------------------------------------
ll <- vi |>
  mutate(across(starts_with("gear_"), as.character)) |>
  filter(if_any(starts_with("gear_"), ~ str_detect(.x, "PALANGRE"))) |>
  select(vessel_rnpa, eu_rnpa)

# Query VMS positions (same filters as 1_sub_GoM_vms.R) -----------------------
positions <- vms |>
  inner_join(ll, by = join_by(vessel_rnpa)) |>
  filter(between(year, 2016, 2024),
         fishing_region %in% c(5, 6),
         depth_m < -50,
         hours < 1.5,
         distance_from_shore_m > 5e2) |>
  select(lon, lat) |>
  collect()

## VISUALIZE ###################################################################

# Get coastline for the Gulf of Mexico -----------------------------------------
world <- ne_countries(scale = "medium", returnclass = "sf")

# Build map --------------------------------------------------------------------
fishing_map <- ggplot() +
  geom_point(data = positions,
             aes(x = lon, y = lat),
             size = 0.1,
             alpha = 0.05,
             color = "steelblue") +
  geom_sf(data = world, fill = "gray90", color = "gray40", linewidth = 0.2) +
  coord_sf(xlim = c(-98, -82), ylim = c(18, 31)) +
  labs(x = "Longitude",
       y = "Latitude") +
  theme_linedraw()

## EXPORT ######################################################################

ggsave("plots/fishing_map.png",
       fishing_map,
       width = 8,
       height = 6,
       dpi = 300)
