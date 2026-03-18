#load packages------------------------------------------------

pacman::p_load(
  here,
  tidyverse,
  ggplot2,
  dplyr
)

#load data _---------------------------------------------------------
cpue <-readRDS("data/estimation/annual_effort_and_catch_by_vessel.rds")
