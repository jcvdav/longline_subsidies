################################################################################
# Fixed-effects regressions for effort, catch, and CPUE
################################################################################
#
# Tests for changes in fishing effort, catch, and catch-per-unit-effort before
# and after Mexico's fuel subsidy reform using vessel fixed-effects models.
# Outputs LaTeX regression tables for the manuscript.
#
################################################################################

# Load packages ----------------------------------------------------------------
library(tidyverse)
library(fixest)
library(modelsummary)
library(panelsummary)

# Helper: post-process modelsummary .tex to inject \label into \caption --------
add_label <- function(file, label) {
  lines <- readLines(file)
  lines <- gsub("(\\\\caption\\{)", paste0("\\1\\\\label{", label, "}"), lines)
  writeLines(lines, file)
}

# Load data --------------------------------------------------------------------
cpue <- readRDS("data/estimation/annual_effort_and_catch_by_vessel.rds")

# Create post-reform indicator -------------------------------------------------
cpue$post <- 1 * (cpue$period == "no subsidies")

# Subsidy counts ---------------------------------------------------------------
subsidy_counts <- cpue |>
  filter(period == "subsidies") |>
  group_by(vessel_id) |>
  summarise(years_subsidized = n_distinct(year))

count(subsidy_counts, years_subsidized)

# EU counts --------------------------------------------------------------------
eu_counts <- count(cpue, eu_id)

# Dictionary for readable labels -----------------------------------------------
setFixest_dict(c(
  post = "Post reform",
  vessel_id = "Vessel",
  eu_id = "Economic unit"
))

gof_omit_regex <- "IC|Log|R2$|R2 W|RMSE|Std"

model_names <- c("Effort (hr)", "Catch (kg)", "CPUE (kg/hr)")

# Main models ------------------------------------------------------------------
m_main <- feols(c(effort_hours, catch_kg, cpue) ~ post | vessel_id,
                data = cpue, 
                vcov = "NW",
                panel.id = ~ vessel_id + year) |> 
  set_names(model_names)

# Main regression table --------------------------------------------------------
modelsummary(
  m_main,
  coef_map = c("post" = "Post reform"),
  title = "Fixed-effects regression results for effort, catch, and CPUE before and after the 2020 fuel subsidy reform. Newey-West (L=1) standard errors in parentheses.",
  output = "tables/cpue_regression.tex",
  stars = panelsummary:::econ_stars(),
  gof_omit = gof_omit_regex
)
add_label("tables/cpue_regression.tex", "tab:table")

# Robustness: drop 2020 (COVID confound) --------------------------------------
m_no2020 <- feols(c(effort_hours, catch_kg, cpue) ~ post | vessel_id,
                  data = cpue, 
                  subset = ~ year != 2020,
                  vcov = "NW", 
                  panel.id = ~ vessel_id + year) |> 
  set_names(model_names)

modelsummary(
  m_no2020,
  coef_map = c("post" = "Post reform"),
  title = "Robustness: regression results excluding 2020. Newey-West (L=1) standard errors in parentheses.",
  output = "tables/cpue_regression_no2020.tex",
  stars = panelsummary:::econ_stars(),
  gof_omit = gof_omit_regex
)
add_label("tables/cpue_regression_no2020.tex", "tab:no2020")

# Robustness: SE clustered at the economic-unit level --------------------------
modelsummary(
  models_main,
  vcov = ~ eu_id,
  coef_map = c("post" = "Post reform"),
  title = "Robustness: regression results with standard errors clustered at the economic-unit level.",
  output = "tables/cpue_regression_eucluster.tex",
  stars = panelsummary:::econ_stars(),
  gof_omit = gof_omit_regex
)
add_label("tables/cpue_regression_eucluster.tex", "tab:eucluster")
