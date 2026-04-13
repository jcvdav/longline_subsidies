################################################################################
# Summary statistics table (Table 1)
################################################################################
#
# Produces a pre-reform vs post-reform summary statistics table for the
# manuscript. Exports to draft/tabs/summary_stats.tex.
#
################################################################################

# Load packages ----------------------------------------------------------------
library(dplyr)
library(tidyr)
library(kableExtra)

# Load data --------------------------------------------------------------------
cpue <- readRDS("data/estimation/annual_effort_and_catch_by_vessel.rds")

# Build summary table ----------------------------------------------------------
summary_stats <- cpue |>
  mutate(period = factor(period,
                         levels = c("subsidies", "no subsidies"),
                         labels = c("Pre-reform (2016--2019)", "Post-reform (2020--2024)"))) |>
  group_by(period) |>
  summarise(
    `Mean effort (hours)`   = mean(effort_hours, na.rm = TRUE),
    `SD effort (hours)`     = sd(effort_hours, na.rm = TRUE),
    `Mean catch (kg)`       = mean(catch_kg, na.rm = TRUE),
    `SD catch (kg)`         = sd(catch_kg, na.rm = TRUE),
    `Mean CPUE (kg/hr)`     = mean(cpue, na.rm = TRUE),
    `SD CPUE (kg/hr)`       = sd(cpue, na.rm = TRUE),
    `Vessel-years`          = n(),
    `Vessels`               = n_distinct(vessel_id),
    `Economic units`        = n_distinct(eu_id),
    .groups = "drop"
  ) |>
  pivot_longer(-period, names_to = "Statistic", values_to = "value") |>
  pivot_wider(names_from = period, values_from = value)

# Format numeric values --------------------------------------------------------
summary_stats <- summary_stats |>
  mutate(across(where(is.numeric), ~ ifelse(
    Statistic %in% c("Vessel-years", "Vessels", "Economic units"),
    formatC(.x, format = "d", big.mark = ","),
    formatC(.x, format = "f", digits = 1, big.mark = ",")
  )))

# Export as LaTeX table --------------------------------------------------------
kbl(summary_stats,
    format = "latex",
    booktabs = TRUE,
    align = c("l", "r", "r"),
    caption = "Summary statistics by reform period.",
    label = "summary_stats") |>
  kable_styling(latex_options = "hold_position") |>
  save_kable("draft/tabs/summary_stats.tex")
