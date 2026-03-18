#load packages------------------------------------------------

pacman::p_load(
  here,
  tidyverse,
  ggplot2,
  dplyr
)

#load data _---------------------------------------------------------
cpue <-readRDS("data/estimation/annual_effort_and_catch_by_vessel.rds")

#Effort -----------------------------------------------------------------------------

cpue |> 
  mutate(period = factor(period, levels = c("subsidies", "no subsidies"))) |> 
  group_by(period) |> 
  summarise(
    mean_effort = mean(effort_hours, na.rm = TRUE),
    se_effort = sd(effort_hours, na.rm = TRUE) / sqrt(n())
  ) |> 
  ggplot(aes(x = period, y = mean_effort, fill = period)) +
  geom_col(color = "black", fill = "steelblue", width = .5) +
  geom_errorbar(
    aes(ymin = mean_effort - se_effort, ymax = mean_effort + se_effort),
    width = 0.2,
    color = "black"
  ) +
  labs(
    x = "Period",
    y = "Mean Effort (hours)"
  ) +
  theme_linedraw() +
  theme(legend.position = "none")


ggsave("plots/effort_barchart.png")

#Catch -----------------------------------------------------------------------------

cpue |> 
  mutate(period = factor(period, levels = c("subsidies", "no subsidies"))) |> 
  group_by(period) |> 
  summarise(
    mean_catch = mean(catch_kg, na.rm = TRUE),
    se_catch = sd(catch_kg, na.rm = TRUE) / sqrt(n())
  ) |> 
  ggplot(aes(x = period, y = mean_catch, fill = period)) +
  geom_col(color = "black", fill = "steelblue", width = .5) +
  geom_errorbar(
    aes(ymin = mean_catch - se_catch, ymax = mean_catch + se_catch),
    width = 0.2,
    color = "black"
  ) +
  labs(
    x = "Period",
    y = "Mean Catch (kg)"
  ) +
  theme_linedraw() +
  theme(legend.position = "none")


ggsave("plots/catch_barchart.png")


#CPUE -----------------------------------------------------------------------------

cpue |> 
  mutate(period = factor(period, levels = c("subsidies", "no subsidies"))) |> 
  group_by(period) |> 
  summarise(
    mean_cpue = mean(cpue, na.rm = TRUE),
    se_cpue = sd(cpue, na.rm = TRUE) / sqrt(n())
  ) |> 
  ggplot(aes(x = period, y = mean_cpue, fill = period)) +
  geom_col(color = "black", fill = "steelblue", width = .5) +
  geom_errorbar(
    aes(ymin = mean_cpue - se_cpue, ymax = mean_cpue + se_cpue),
    width = 0.2,
    color = "black"
  ) +
  labs(
    y = "Mean Catch-per-unit-effort (kg/hr)",
    x = "Period"
  ) +
  theme_linedraw() +
  theme(legend.position = "none")


ggsave("plots/cpue_barchart.png")

