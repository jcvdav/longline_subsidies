#load packages
library(dplyr)

#load original data
cpue_by_vessel <- readRDS("data/estimation/annual_effort_and_catch_by_vessel.rds")

#subsidy counts-----------------------------------------------------

subsidy_counts <- cpue_by_vessel |> 
  filter(period == "subsidies") |> 
  group_by(vessel_id) |> 
  summarise(years_subsidized = n_distinct(year))

count(subsidy_counts, years_subsidized) 

#filtering data- removing vessels not subsidized all years of subsidy period-----------------------
cpue_by_vessel_clean <- cpue_by_vessel |> 
  filter(period == "no subsidies" | n_times_subsidized == 4 & period == "subsidies") 


#removing outliers----------------------------------------------------
#Q1 <- quantile(cpue_by_vessel$cpue, 0.25)
#Q3 <- quantile(cpue_by_vessel$cpue, 0.75)
#IQR = Q3 - Q1

#lower_bound <- Q1 - 1.5 * IQR
#upper_bound <- Q3 + 1.5 * IQR

#cpue_clean <- cpue_by_vessel[cpue_by_vessel$cpue >= lower_bound & cpue_by_vessel$cpue <= upper_bound,  ]


#identifying outliers
#cpue_outliers <- cpue_by_vessel[cpue_by_vessel$cpue <= lower_bound | cpue_by_vessel$cpue >= upper_bound, ]


#significance tests-------------------------------------------------

#cpue before and after subsidies

t.test(cpue ~ period, data = cpue_by_vessel_clean)
#50.6% decrease in cpue, p = 0.2877

#t.test(cpue ~ period, data = cpue_clean)
#12.3% increase in cpue, p = 0.03804

#effort before and after subsidies

t.test(effort_hours ~ period, data = cpue_by_vessel_clean)
#16.5% decrease in effort, p = 0.000252

#t.test(effort_hours ~ period, data = cpue_clean)
#23.7% decrease in effort, p = 0.00000026

#catch before and after subsidies

t.test(catch_kg ~ period, data = cpue_by_vessel_clean)
#10.1% decrease in catch, p = 0.1314

#t.test(catch_kg ~ period, data = cpue_clean)
#13.6% decrease in catch, p = 0.03917 NO SIGNIFICANCE



