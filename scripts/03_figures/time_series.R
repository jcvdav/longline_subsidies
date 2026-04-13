################################################################################
# Time series of subsidies, effort, catch, and CPUE
################################################################################
#
# Produces a 4-panel time series figure (A: subsidies, B: effort, C: catch,
# D: CPUE) showing fleet-level annual totals/averages with a vertical reference
# line at the 2020 subsidy reform.
# Output: plots/time_series.png
#
################################################################################

# Load packages ----------------------------------------------------------------
library(tidyverse)
library(patchwork)

# Load data --------------------------------------------------------------------
cpue <- readRDS("data/estimation/annual_effort_and_catch_by_vessel.rds")
subsidies <- readRDS("data/processed/annual_subsidies_by_economic_unit.rds")

# Join subsidy amounts for Panel A ---------------------------------------------
cpue_timeseries <- cpue |>
  left_join(subsidies, by = join_by(year, eu_id == eu_rnpa)) |>
  replace_na(list(subsidy_pesos = 0))

# Annual totals ----------------------------------------------------------------
yearly_totals <- cpue_timeseries |>
  filter(year >= 2016) |>
  group_by(year) |>
  summarise(
    total_catch = sum(catch_kg, na.rm = TRUE),
    total_hours = sum(effort_hours, na.rm = TRUE),
    total_subsidy = sum(subsidy_pesos, na.rm = TRUE),
    n_vessels = n_distinct(vessel_id)
  ) |>
  mutate(
    avg_cpue = total_catch / total_hours
  )

# Panel A: Subsidies-----------------------------------------------------------------
panel_a <-
  ggplot(data = yearly_totals, aes(x = year, y = total_subsidy)) +
  geom_vline(xintercept = 2020, linetype = "dashed", color = "red", linewidth = 0.8) +
  geom_line(color = "steelblue", linewidth = 1) +
  labs(
    y = "Subsidies (MXN)",
    x = "Year"
  ) +
  theme_linedraw()

# Panel B: Fishing Hours-----------------------------------------------------------------
panel_b <-
  ggplot(data = yearly_totals, aes(x = year, y = total_hours)) +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_vline(xintercept = 2020, linetype = "dashed", color = "red", linewidth = 0.8) +
  labs(
    y = "Hours",
    x = "Year"
  ) +
  theme_linedraw()

# Panel C: Total Catch-----------------------------------------------------------------
panel_c <-
  ggplot(data = yearly_totals, aes(x = year, y = total_catch)) +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_vline(xintercept = 2020, linetype = "dashed", color = "red", linewidth = 0.8) +
  labs(
    y = "Catch (kg)",
    x = "Year"
  ) +
  theme_linedraw()

# Panel D: Fleet-wide CPUE-----------------------------------------------------------------
panel_d <-
  ggplot(data = yearly_totals, aes(x = year, y = avg_cpue)) +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_vline(xintercept = 2020, linetype = "dashed", color = "red", linewidth = 0.8) +
  labs(
    y = "CPUE (kg/hr)",
    x = "Year"
  ) +
  theme_linedraw()

# Combine into a 1-column figure
combined <- panel_a / panel_b / panel_c / panel_d +
  plot_annotation(tag_levels = "A")

# Export figure ----------------------------------------------------------------
ggsave("plots/time_series.png",
  combined,
  width = 8,
  height = 12,
  dpi = 300
)
