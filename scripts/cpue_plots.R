#load original data
cpue_by_vessel <- read.csv("data/estimation/annual_effort_and_catch_by_vessel.csv")

#removing outliers
Q1 <- quantile(cpue_by_vessel$cpue, 0.25)
Q3 <- quantile(cpue_by_vessel$cpue, 0.75)
IQR = Q3 - Q1

lower_bound <- Q1 - 1.5 * IQR
upper_bound <- Q3 + 1.5 * IQR

cpue_clean <- cpue_by_vessel[cpue_by_vessel$cpue >= lower_bound & cpue_by_vessel$cpue <= upper_bound,  ]


#identifying outliers
cpue_outliers <- cpue_by_vessel[cpue_by_vessel$cpue <= lower_bound | cpue_by_vessel$cpue >= upper_bound, ]

#two sample t test for cpue, effort, and catch, before and after subsidy removal

#significance test for difference in cpue before and after subsidies
t.test(cpue ~ period, data = cpue_clean)
#16.58% increase in cpue, p = 0.005034

#significance test for difference in effort
t.test(effort_hours ~ period, data = cpue_clean)
#14.03% decrease in effort, p = 0.00315

#significance test for difference in catch
t.test(catch_kg ~ period, data = cpue_clean)
#3.68% decrease in catch, p = 0.5637 NO SIGNIFICANCE

#plots

#boxplot, before outlier removal   
cpue_by_vessel |> 
  ggplot(aes(x = fct_infreq(period), y = cpue)) +
  geom_boxplot() +
  labs(
    title = "Catch efficiency of Mexican tuna longlining",
    subtitle = "Before and after subsidy reform",
    x = "Subsidy status",
    y = "Catch-per-unit-effort (kg/hr)",
    caption = "Before outlier removal"
  ) 
ggsave("catch_efficiency_box.png")

#scatterplot, after outlier removal
cpue_clean |> 
  ggplot(aes(x = year, y = cpue, color = period)) +
  geom_point() + 
  geom_smooth(method = "lm") + 
  labs(
    title = "Catch efficiency of Mexican tuna longlining",
    x = "Year",
    y = "Catch-per-unit-effort (kg/hr)"
  ) 
ggsave("catch_efficiency_plot.png")

#boxplot, after outlier removal
cpue_clean |> 
  ggplot(aes(x = fct_infreq(period), y = cpue)) +
  geom_boxplot() +
  labs(
    title = "Catch efficiency of Mexican tuna longlining",
    subtitle = "Before and after subsidy reform",
    x = "Subsidy status",
    y = "Catch-per-unit-effort (kg/hr)",
    caption = "After outlier removal"
  ) 
ggsave("catch_efficiency_box_clean.png")