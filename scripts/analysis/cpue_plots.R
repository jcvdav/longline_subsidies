#load original data------------------------------------------------------
cpue_by_vessel <- readRDS("data/estimation/annual_effort_and_catch_by_vessel.rds")

#filtering data- removing vessels not subsidized all years of subsidy period-----------------------
cpue_by_vessel_clean <- cpue_by_vessel |> 
  filter(period == "no subsidies" | n_times_subsidized == 4 & period == "subsidies") 

#removing outliers-------------------------------------------------------
#Q1 <- quantile(cpue_by_vessel_clean$cpue, 0.25)
#Q3 <- quantile(cpue_by_vessel_clean$cpue, 0.75)
#IQR = Q3 - Q1

#lower_bound <- Q1 - 1.5 * IQR
#upper_bound <- Q3 + 1.5 * IQR

#cpue_clean <- cpue_by_vessel_clean[cpue_by_vessel_clean$cpue >= lower_bound & cpue_by_vessel_clean$cpue <= upper_bound,  ]

#plots---------------------------------------------------------------------

#boxplot
cpue_by_vessel_clean |> 
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

#scatterplot
cpue_by_vessel_clean |> 
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
#cpue_clean |> 
 # ggplot(aes(x = fct_infreq(period), y = cpue)) +
  #geom_boxplot() +
  #labs(
    #title = "Catch efficiency of Mexican tuna longlining",
    #subtitle = "Before and after subsidy reform",
    #x = "Subsidy status",
    #y = "Catch-per-unit-effort (kg/hr)",
    #caption = "After outlier removal"
  #) 
#ggsave("catch_efficiency_box_clean.png")
