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
library(dplyr)
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

# Subsidy counts ---------------------------------------------------------------
subsidy_counts <- cpue |>
  filter(period == "subsidies") |>
  group_by(vessel_id) |>
  summarise(years_subsidized = n_distinct(year))

count(subsidy_counts, years_subsidized)

# EU counts --------------------------------------------------------------------
eu_counts <- count(cpue, eu_id)

# Set reference level ----------------------------------------------------------
cpue$period <- factor(cpue$period, levels = c("subsidies", "no subsidies"))

# Models in levels -------------------------------------------------------------
m_effort <- feols(effort_hours ~ period | vessel_id,
                  data = cpue, vcov = "NW",
                  panel.id = ~ vessel_id + year)

m_catch  <- feols(catch_kg ~ period | vessel_id,
                  data = cpue, vcov = "NW",
                  panel.id = ~ vessel_id + year)

m_cpue   <- feols(cpue ~ period | vessel_id,
                  data = cpue, vcov = "NW",
                  panel.id = ~ vessel_id + year)

# Log-transformed models -------------------------------------------------------
cpue <- cpue |>
  mutate(
    log_effort = log(effort_hours + 1),
    log_catch  = log(catch_kg + 1),
    log_cpue   = log(cpue + 1)
  )

m_log_effort <- feols(log_effort ~ period | vessel_id,
                      data = cpue, vcov = "NW",
                      panel.id = ~ vessel_id + year)

m_log_catch  <- feols(log_catch ~ period | vessel_id,
                      data = cpue, vcov = "NW",
                      panel.id = ~ vessel_id + year)

m_log_cpue   <- feols(log_cpue ~ period | vessel_id,
                      data = cpue, vcov = "NW",
                      panel.id = ~ vessel_id + year)

# Pre-subsidy means ------------------------------------------------------------
pre_means <- cpue |>
  filter(period == "subsidies") |>
  summarize(
    effort_hours = mean(effort_hours, na.rm = TRUE),
    catch_kg     = mean(catch_kg, na.rm = TRUE),
    cpue         = mean(cpue, na.rm = TRUE)
  )

# Main regression table --------------------------------------------------------
models <- list(
  list("Effort (levels)" = m_effort,
       "Catch (levels)"  = m_catch,
       "CPUE (levels)"   = m_cpue),
  list("Effort (log)"    = m_log_effort,
       "Catch (log)"     = m_log_catch,
       "CPUE (log)"      = m_log_cpue)
)

modelsummary(
  models,
  shape = "rbind",
  coef_map = c("periodno subsidies" = "Reform"),
  add_rows = data.frame(
    term = "Pre‑reform mean",
    `Effort (levels)` = pre_means$effort_hours,
    `Catch (levels)`  = pre_means$catch_kg,
    `CPUE (levels)`   = pre_means$cpue
  ),
  title = "Fixed-effects regression results for effort, catch, and CPUE before and after the 2020 fuel subsidy reform. Newey-West (L=1) standard errors in parentheses.",
  output = "tables/cpue_regression.tex",
  stars = panelsummary:::econ_stars(),
  gof_omit = "IC|Log|Adj"
)
add_label("tables/cpue_regression.tex", "tab:table")

# Robustness: drop 2020 (COVID confound) --------------------------------------
m_effort_no2020     <- feols(effort_hours ~ period | vessel_id,
                             data = cpue, subset = ~ year != 2020,
                             vcov = "NW", panel.id = ~ vessel_id + year)

m_catch_no2020      <- feols(catch_kg ~ period | vessel_id,
                             data = cpue, subset = ~ year != 2020,
                             vcov = "NW", panel.id = ~ vessel_id + year)

m_cpue_no2020       <- feols(cpue ~ period | vessel_id,
                             data = cpue, subset = ~ year != 2020,
                             vcov = "NW", panel.id = ~ vessel_id + year)

m_log_effort_no2020 <- feols(log_effort ~ period | vessel_id,
                             data = cpue, subset = ~ year != 2020,
                             vcov = "NW", panel.id = ~ vessel_id + year)

m_log_catch_no2020  <- feols(log_catch ~ period | vessel_id,
                             data = cpue, subset = ~ year != 2020,
                             vcov = "NW", panel.id = ~ vessel_id + year)

m_log_cpue_no2020   <- feols(log_cpue ~ period | vessel_id,
                             data = cpue, subset = ~ year != 2020,
                             vcov = "NW", panel.id = ~ vessel_id + year)

pre_means_no2020 <- cpue |>
  filter(period == "subsidies", year != 2020) |>
  summarize(
    effort_hours = mean(effort_hours, na.rm = TRUE),
    catch_kg     = mean(catch_kg, na.rm = TRUE),
    cpue         = mean(cpue, na.rm = TRUE)
  )

models_no2020 <- list(
  list("Effort (levels)" = m_effort_no2020,
       "Catch (levels)"  = m_catch_no2020,
       "CPUE (levels)"   = m_cpue_no2020),
  list("Effort (log)"    = m_log_effort_no2020,
       "Catch (log)"     = m_log_catch_no2020,
       "CPUE (log)"      = m_log_cpue_no2020)
)

modelsummary(
  models_no2020,
  shape = "rbind",
  coef_map = c("periodno subsidies" = "Reform"),
  add_rows = data.frame(
    term = "Pre‑reform mean",
    `Effort (levels)` = pre_means_no2020$effort_hours,
    `Catch (levels)`  = pre_means_no2020$catch_kg,
    `CPUE (levels)`   = pre_means_no2020$cpue
  ),
  title = "Robustness: regression results excluding 2020. Newey-West (L=1) standard errors in parentheses.",
  output = "tables/cpue_regression_no2020.tex",
  stars = panelsummary:::econ_stars(),
  gof_omit = "IC|Log|Adj"
)
add_label("tables/cpue_regression_no2020.tex", "tab:no2020")

# Robustness: SE clustered at the economic-unit level --------------------------
m_effort_eu     <- feols(effort_hours ~ period | vessel_id,
                         data = cpue, cluster = ~ eu_id)

m_catch_eu      <- feols(catch_kg ~ period | vessel_id,
                         data = cpue, cluster = ~ eu_id)

m_cpue_eu       <- feols(cpue ~ period | vessel_id,
                         data = cpue, cluster = ~ eu_id)

m_log_effort_eu <- feols(log_effort ~ period | vessel_id,
                         data = cpue, cluster = ~ eu_id)

m_log_catch_eu  <- feols(log_catch ~ period | vessel_id,
                         data = cpue, cluster = ~ eu_id)

m_log_cpue_eu   <- feols(log_cpue ~ period | vessel_id,
                         data = cpue, cluster = ~ eu_id)

models_eu <- list(
  list("Effort (levels)" = m_effort_eu,
       "Catch (levels)"  = m_catch_eu,
       "CPUE (levels)"   = m_cpue_eu),
  list("Effort (log)"    = m_log_effort_eu,
       "Catch (log)"     = m_log_catch_eu,
       "CPUE (log)"      = m_log_cpue_eu)
)

modelsummary(
  models_eu,
  shape = "rbind",
  coef_map = c("periodno subsidies" = "Reform"),
  add_rows = data.frame(
    term = "Pre‑reform mean",
    `Effort (levels)` = pre_means$effort_hours,
    `Catch (levels)`  = pre_means$catch_kg,
    `CPUE (levels)`   = pre_means$cpue
  ),
  title = "Robustness: regression results with standard errors clustered at the economic-unit level (9 clusters).",
  output = "tables/cpue_regression_eucluster.tex",
  stars = panelsummary:::econ_stars(),
  gof_omit = "IC|Log|Adj"
)
add_label("tables/cpue_regression_eucluster.tex", "tab:eucluster")
