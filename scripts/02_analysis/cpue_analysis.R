################################################################################
# Fixed-effects regressions for effort, catch, and CPUE
################################################################################
#
# Tests for changes in fishing effort, catch, and catch-per-unit-effort before
# and after Mexico's fuel subsidy reform using vessel fixed-effects models.
# Outputs a LaTeX regression table for the manuscript.
#
################################################################################

# Load packages ----------------------------------------------------------------
library(dplyr)
library(fixest)
library(modelsummary)

#load original data
cpue <- readRDS("data/estimation/annual_effort_and_catch_by_vessel.rds")

#subsidy counts-----------------------------------------------------
subsidy_counts <- cpue |>
  filter(period == "subsidies") |> 
  group_by(vessel_id) |> 
  summarise(years_subsidized = n_distinct(year))

count(subsidy_counts, years_subsidized) 

#eu counts -----------------------------------------------------

eu_counts <- count(cpue, eu_id)


#Linear regressions------------------------------------------------- 

#Adjusting reference level
cpue$period <- factor(cpue$period, levels = c("subsidies", "no subsidies"))

#Models in levels
m_effort  <- feols(effort_hours ~ period | vessel_id,
                   data = cpue,
                   vcov = "NW",
                   panel.id = ~ vessel_id + year)

m_catch   <- feols(catch_kg ~ period | vessel_id,
                   data = cpue,
                   vcov = "NW",
                   panel.id = ~ vessel_id + year)

m_cpue    <- feols(cpue ~ period | vessel_id,
                   data = cpue,
                   vcov = "NW",
                   panel.id = ~ vessel_id + year)

#Log transformed models 
cpue <- cpue |> 
  mutate(
    log_effort = log(effort_hours + 1),
    log_catch  = log(catch_kg + 1),
    log_cpue   = log(cpue + 1)
  )

m_log_effort <- feols(log_effort ~ period | vessel_id,
                      data = cpue,
                      vcov = "NW",
                      panel.id = ~ vessel_id + year)

m_log_catch  <- feols(log_catch ~ period | vessel_id,
                      data = cpue,
                      vcov = "NW",
                      panel.id = ~ vessel_id + year)

m_log_cpue   <- feols(log_cpue ~ period | vessel_id,
                      data = cpue,
                      vcov = "NW",
                      panel.id = ~ vessel_id + year)
#Pre-subsidy means 
pre_means <- cpue |> 
  filter(period == "subsidies") |> 
  summarize(
    effort_hours = mean(effort_hours, na.rm = TRUE),
    catch_kg     = mean(catch_kg, na.rm = TRUE),
    cpue         = mean(cpue, na.rm = TRUE)
  )


#Summary table
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
    term = "Pre‑subsidy mean",
    `Effort (levels)` = pre_means$effort_hours,
    `Catch (levels)`  = pre_means$catch_kg,
    `CPUE (levels)`   = pre_means$cpue
  ),
  output = "data/processed/cpue_regression.tex",
  stars = TRUE,
  gof_omit = "IC|Log|Adj"
)



