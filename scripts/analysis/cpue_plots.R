#load packages------------------------------------------------

pacman::p_load(
  here,
  tidyverse,
  ggplot2,
  dplyr
)

#load data---------------------------------------------------------
effort <- readRDS("data/processed/annual_effort_by_vessel.rds")
landings <- readRDS("data/processed/annual_landings_by_vessel.rds")
subsidies <- readRDS("data/processed/annual_subsidies_by_economic_unit.rds")

#clean data w/o outlier removal---------------------------------------------

data <- inner_join(effort, landings, by = join_by(year, vessel_rnpa)) |> 
  left_join(subsidies, by = join_by(year, eu_rnpa)) |> 
  mutate(period = ifelse(year <= 2019, "subsidies", "no subsidies")) |> 
  replace_na(list(subsidy_pesos = 0, treated = 0)) |> 
  group_by(vessel_rnpa, period) |>
  mutate(n_times_subsidized = sum(treated, na.rm = TRUE)) |>
  ungroup() |>
  select(period, year, eu_id = eu_rnpa, vessel_id = vessel_rnpa, n_times_subsidized, effort_hours = h, catch_kg = live_weight) |> # Select the appropriate columns here
  mutate(cpue = catch_kg / effort_hours)

#load clean data------------------------------------------------------
cpue_by_vessel <- readRDS("data/estimation/annual_effort_and_catch_by_vessel.rds")

#removing outliers-------------------------------------------------------
#Q1 <- quantile(cpue_by_vessel$cpue, 0.25)
#Q3 <- quantile(cpue_by_vessel$cpue, 0.75)
#IQR = Q3 - Q1

#lower_bound <- Q1 - 1.5 * IQR
#upper_bound <- Q3 + 1.5 * IQR

#cpue_clean <- cpue_by_vessel[cpue_by_vessel$cpue >= lower_bound & cpue_by_vessel$cpue <= upper_bound]


#plots---------------------------------------------------------------------
#bar charts--------------------------------------------------

# bar chart - cpue clean


cpue_by_vessel |> 
  group_by(period) |> 
  summarise(
    mean_cpue = mean(cpue, na.rm = TRUE),
    se_cpue = sd(cpue, na.rm = TRUE) / sqrt(n())
    ) |> 
  ggplot(aes(x = period, y = mean_cpue, fill = period)) +
  geom_col() +
  geom_errorbar(aes(ymin = mean_cpue - se_cpue, ymax = mean_cpue + se_cpue),
                width = 0.2, color = "black") +
  labs(
    title = "Catch efficiency",
    y = "Mean Catch-per-unit-effort (kg/hr)"
  ) +
  theme(legend.position = "none")
ggsave("plots/cpue_bar_clean.png")

# bar chart - cpue original data
data |> 
  mutate(period = factor(period, levels = c("subsidies", "no subsidies"))) |> 
  group_by(period) |> 
  summarise(
    mean_cpue = mean(cpue, na.rm = TRUE),
    se_cpue = sd(cpue, na.rm = TRUE) / sqrt(n())
  ) |> 
  ggplot(aes(x = period, y = mean_cpue, fill = period)) +
  geom_col() +
  geom_errorbar(aes(ymin = mean_cpue - se_cpue, ymax = mean_cpue + se_cpue),
                width = 0.2, color = "black") +
  labs(
    title = "Catch efficiency",
    x = "Subsidy Status",
    y = "Mean Catch-per-unit-effort (kg/hr)"
  ) +
  theme(legend.position = "none")
ggsave("plots/cpue_bar.png")



# bar chart - effort clean
cpue_by_vessel |> 
  group_by(period) |> 
  summarise(
    mean_effort = mean(effort_hours, na.rm = TRUE),
    se_effort = sd(effort_hours, na.rm = TRUE) / sqrt(n())
  ) |> 
  ggplot(aes(x = period, y = mean_effort, fill = period)) +
  geom_col() +
  geom_errorbar(aes(ymin = mean_effort - se_effort, ymax = mean_effort + se_effort),
                width = 0.2, color = "black") +
  labs(
    title = "Fishing effort",
    y = "Mean Effort (hours)",
    fill = "Subsidy Status"
  ) +
  theme(legend.position = "left")
ggsave("plots/effort_bar_clean.png")

#bar chart - effort original data 

data |> 
  mutate(period = factor(period, levels = c("subsidies", "no subsidies"))) |> 
  group_by(period) |> 
  summarise(
    mean_effort = mean(effort_hours, na.rm = TRUE),
    se_effort = sd(effort_hours, na.rm = TRUE) / sqrt(n())) |> 
  ggplot(aes(x = period, y = mean_effort, fill = period)) +
  geom_col() +
  geom_errorbar(aes(ymin = mean_effort - se_effort, ymax = mean_effort + se_effort),
                width = 0.2, color = "black") +
  labs(
    title = "Fishing effort of Mexican tuna longlining",
    x = "Subsidy status",
    y = "Mean Effort (hours)",
    fill = "Subsidy Status"
  ) +
  theme(legend.position = "left")
ggsave("plots/effort_bar.png")


# bar chart- catch clean
cpue_by_vessel |> 
  mutate(period = factor(period, levels = c("subsidies", "no subsidies"))) |> 
  group_by(period) |> 
  summarise(
    mean_catch = mean(catch_kg, na.rm = TRUE),
    se_catch = sd(catch_kg, na.rm = TRUE) / sqrt(n())
    ) |>
  ggplot(aes(x = period, y = mean_catch, fill = period)) +
  geom_col() +
  geom_errorbar(aes(ymin = mean_catch - se_catch, ymax = mean_catch + se_catch),
                width = 0.2, color = "black") +
  labs(
    title = "Catch",
    y = "Mean Catch (kg)"
  ) +
  theme(legend.position = "none")
ggsave("plots/catch_bar_clean.png")

# bar chart - catch original data

data |> 
  mutate(period = factor(period, levels = c("subsidies", "no subsidies"))) |> 
  group_by(period) |> 
  summarise(
    mean_catch = mean(catch_kg, na.rm = TRUE),
    se_catch = sd(catch_kg, na.rm = TRUE) / sqrt(n())
    )|> 
  ggplot(aes(x = period, y = mean_catch, fill = period)) +
  geom_col() + 
  geom_errorbar(aes(ymin = mean_catch - se_catch, ymax = mean_catch + se_catch),
                width = 0.2, color = "black") +
  labs(
    title = "Catch of Mexican tuna longlining",
    x = "Subsidy status",
    y = "Mean Catch (kg)"
  ) +
  theme(legend.position = "none")
ggsave("plots/catch_bar.png")

#box plots---------------------------------------------------

#box plot- cpue clean
cpue_by_vessel |> 
  ggplot(aes(x = period, y = cpue)) +
  geom_boxplot() +
  labs(
    title = "Catch efficiency of Mexican tuna longlining",
    x = "Subsidy status",
    y = "Catch-per-unit-effort (kg/hr)"
  ) 
ggsave("plots/cpue_box_clean.png")

#box plot- cpue original data
data |> 
  mutate(period = factor(period, levels = c("subsidies", "no subsidies"))) |> 
  ggplot(aes(x = period, y = cpue)) +
  geom_boxplot() +
  labs(
    title = "Catch efficiency of Mexican tuna longlining",
    x = "Subsidy status",
    y = "Catch-per-unit-effort (kg/hr)"
  )
ggsave("plots/cpue_box.png")

#box plot - effort clean

cpue_by_vessel |> 
  mutate(period = factor(period, levels = c("subsidies", "no subsidies"))) |> 
  ggplot(aes(x = period, y = effort_hours)) +
  geom_boxplot() +
  labs(
    title = "Fishing effort of Mexican tuna longlining",
    x = "Subsidy status",
    y = "Effort (hours)"
  )
ggsave("plots/effort_box_clean.png")

#box plot - effort original data

data |> 
  mutate(period = factor(period, levels = c("subsidies", "no subsidies"))) |> 
  ggplot(aes(x = period, y = effort_hours)) +
  geom_boxplot() +
  labs(
    title = "Fishing effort of Mexican tuna longlining",
    x = "Subsidy status",
    y = "Effort (hours)"
  )
ggsave("plots/effort_box.png")

#box plot - catch clean

cpue_by_vessel |> 
  mutate(period = factor(period, levels = c("subsidies", "no subsidies"))) |> 
  ggplot(aes(x = period, y = catch_kg)) +
  geom_boxplot() +
  labs(
    title = "Catch of Mexican tuna longlining",
    x = "Subsidy status",
    y = "Catch (kg)"
  )
ggsave("plots/catch_box_clean.png")

#box plot - catch original data

data |> 
  mutate(period = factor(period, levels = c("subsidies", "no subsidies"))) |> 
  ggplot(aes(x = period, y = catch_kg)) +
  geom_boxplot() +
  labs(
    title = "Catch of Mexican tuna longlining",
    x = "Subsidy status",
    y = "Catch (kg)"
  )
ggsave("plots/catch_box.png")


#scatterplots---------------------------------------------------

#scatterplot - cpue clean
cpue_by_vessel |> 
  ggplot(aes(x = year, y = cpue, color = period)) +
  geom_point() + 
  geom_smooth(method = "lm") + 
  labs(
    title = "Catch efficiency of Mexican tuna longlining",
    x = "Year",
    y = "Catch-per-unit-effort (kg/hr)"
  ) 
ggsave("plots/cpue_plot_clean.png")

#scatterplot - cpue original data

data |> 
  mutate(period = factor(period, levels = c("subsidies", "no subsidies"))) |> 
  ggplot(aes(x = year, y = cpue, color = period)) +
  geom_point() + 
  geom_smooth(method = "lm") + 
  labs(
    title = "Catch efficiency of Mexican tuna longlining",
    x = "Year",
    y = "Catch-per-unit-effort (kg/hr)"
  )
ggsave("plots/cpue_plot.png")

#scatterplot - effort clean

cpue_by_vessel |> 
  ggplot(aes(x = year, y = effort_hours, color = period)) +
  geom_vline(xintercept = 2019.5, linetype = "dashed") +
  geom_smooth(method = "lm") + 
  geom_point() + 
  labs(
    title = "Fishing effort of Mexican tuna longlining",
    x = "Year",
    y = "Effort (hours)"
  ) +
  theme_minimal(base_size = 14)
ggsave("plots/effort_plot_clean.png")

#scatterplot - effort original data

data |> 
  mutate(period = factor(period, levels = c("subsidies", "no subsidies"))) |> 
  ggplot(aes(x = year, y = effort_hours, color = period)) +
  geom_point() + 
  geom_smooth(method = "lm") + 
  labs(
    title = "Fishing effort of Mexican tuna longlining",
    x = "Year",
    y = "Effort (hours)"
  )
ggsave("plots/effort_plot.png")

#scatterplot - catch clean  

cpue_by_vessel |> 
  ggplot(aes(x = year, y = catch_kg, color = period)) +
  geom_point() + 
  geom_smooth(method = "lm") + 
  labs(
    title = "Catch of Mexican tuna longlining",
    x = "Year",
    y = "Catch (kg)"
  )
ggsave("plots/catch_plot_clean.png")

#scatterplot - catch original data

data |> 
  mutate(period = factor(period, levels = c("subsidies", "no subsidies"))) |> 
  ggplot(aes(x = year, y = catch_kg, color = period)) +
  geom_point() + 
  geom_smooth(method = "lm") + 
  labs(
    title = "Catch of Mexican tuna longlining",
    x = "Year",
    y = "Catch (kg)"
  )
ggsave("plots/catch_plot.png")

