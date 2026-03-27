#load packages------------------------------------------------------
library(bigrquery)
library(DBI)
library(sf)
library(dplyr)
library(leaflet)
library(lubridate)

#authenticate with Google Cloud ------------------------------------
bq_auth("laubri42@gmail.com")

# Identify outliers ------------------------------------------------------

cpue <- data 

# subsidies period--- 1 outlier in 2011 to look at 
cpue_sub <- cpue %>%  filter(period == "subsidies")

Q1_sub <- quantile(cpue_sub$cpue, 0.25)
Q3_sub <- quantile(cpue_sub$cpue, 0.75)
IQR_sub <- Q3_sub - Q1_sub

lower_sub <- Q1_sub - 1.5 * IQR_sub
upper_sub <- Q3_sub + 1.5 * IQR_sub

outliers_sub <- cpue_sub %>%  
  filter(cpue <= lower_sub | cpue >= upper_sub)

# no subisidies period--- 4 outliers in 2023 to look at 
cpue_no_sub <- cpue %>%  filter(period == "no subsidies")

Q1_no_sub <- quantile(cpue_no_sub$cpue, 0.25)
Q3_no_sub <- quantile(cpue_no_sub$cpue, 0.75)
IQR_no_sub <- Q3_no_sub - Q1_no_sub

lower_no_sub <- Q1_no_sub - 1.5 * IQR_no_sub
upper_no_sub <- Q3_no_sub + 1.5 * IQR_no_sub

outliers_no_sub <- cpue_no_sub %>% 
  filter(cpue <= lower_no_sub | cpue >= upper_no_sub)


sub_ids <- outliers_sub %>%
  select(vessel_id, year) %>%
  distinct()

no_sub_ids <- outliers_no_sub %>%
  select(vessel_id, year) %>%
  distinct()

# Connect to BigQuery and access data ------------------------------------------------------

project_id <- "mex-fisheries"
dataset <- "mex_vms"
table <- "mex_vms_processed_v_20250623"

con <- dbConnect(
  bigrquery::bigquery(),
  project = project_id,
  dataset = dataset,
  billing = project_id
)

vms_tbl <- tbl(con, table)

#function to isolate outliers------------------------------------------------------
get_vms_data <- function(rnpa, year) {
  rnpa <- as.character(rnpa)
  year <- as.integer(year)
  
  vms_tbl %>%
    filter(
      vessel_rnpa == rnpa,
      year(datetime) == year
    ) %>%
    arrange(datetime) %>%
    collect()
}
vms_subsidized_list <- list()

#subsidized outliers ----------------------------------------------------------
for (i in seq_len(nrow(sub_ids))) {
  rnpa <- sub_ids$vessel_id[i]
  yr   <- sub_ids$year[i]
  
  message("Downloading subsidized outlier: ", rnpa, " (", yr, ")")
  
  vms_subsidized_list[[paste0(rnpa, "_", yr)]] <- get_vms_data(rnpa, yr)
}

vms_unsubsidized_list <- list()

#unsubsidized outliers ----------------------------------------------------------

for (i in seq_len(nrow(no_sub_ids))) {
  rnpa <- no_sub_ids$vessel_id[i]
  yr   <- no_sub_ids$year[i]
  
  message("Downloading unsubsidized outlier: ", rnpa, " (", yr, ")")
  
  vms_unsubsidized_list[[paste0(rnpa, "_", yr)]] <- get_vms_data(rnpa, yr)
}

# Save VMS data for each outlier------------------------------------------------------
for (name in names(vms_subsidized_list)) {
  df <- vms_subsidized_list[[name]]
  write.csv(df, paste0("data/estimation/vms_subsidized_", name, ".csv"), row.names = FALSE)
}

for (name in names(vms_unsubsidized_list)) {
  df <- vms_unsubsidized_list[[name]]
  write.csv(df, paste0("data/estimation/vms_unsubsidized_", name, ".csv"), row.names = FALSE)
}


#Vessel 0034389, year 2018 REMOVE ------------------------------------------------------
#This outlier was removed as the VMS data shows extremely limited data points for location, likely an error causing the values to be inaccurate
#filter ------------------------------------------------------
vessel_rnpa <- "00034389"
year <- 2018

spatial_df <- get_vms_data(vessel_rnpa, year)

#export data------------------------------------------------------
write.csv(spatial_df, "data/estimation/vms_00034389_2018.csv", row.names = FALSE)

#convert to sf object------------------------------------------------------

spatial_sf <- st_as_sf(spatial_df, coords = c("lon", "lat"), crs = 4326)
st_write(spatial_sf, "data/estimation/vms_00034389_2018.gpkg", driver = "GPKG", delete_dsn = TRUE)

#create a leaflet map------------------------------------------------------

track_line <- spatial_sf %>%
  summarise(do_union = FALSE) %>%
  st_cast("LINESTRING")


leaflet() %>%
  addTiles() %>%
  addCircleMarkers(
    data = spatial_sf,
    radius = 3,
    popup = ~paste("Time:", datetime),
    color = "blue"
  ) %>%
  addPolylines(
    data = track_line,
    color = "red",
    weight = 2,
    opacity = 0.8
  )

#Vessel 00034389, year 2016 ANALYZE RAW LANDINGS DATA------------------------------------------------------
#This outlier was removed as the raw landings data for this vessel and year shows extremely limited catch, which is likely an error in the data. 
#filter ------------------------------------------------------
vessel_rnpa <- "00034389"
year <- 2016

spatial_df <- get_vms_data(vessel_rnpa, year)

#export data------------------------------------------------------
write.csv(spatial_df, "data/estimation/vms_00034389_2016.csv", row.names = FALSE)

#convert to sf object------------------------------------------------------

spatial_sf <- st_as_sf(spatial_df, coords = c("lon", "lat"), crs = 4326)
st_write(spatial_sf, "data/estimation/vms_00034389_2016.gpkg", driver = "GPKG", delete_dsn = TRUE)



#create a leaflet map------------------------------------------------------

track_line <- spatial_sf %>%
  summarise(do_union = FALSE) %>%
  st_cast("LINESTRING")


leaflet() %>%
  addTiles() %>%
  addCircleMarkers(
    data = spatial_sf,
    radius = 3,
    popup = ~paste("Time:", datetime),
    color = "blue"
  ) %>%
  addPolylines(
    data = track_line,
    color = "red",
    weight = 2,
    opacity = 0.8
  )
#Vessel 00074500, year 2018  ------------------------------------------------------
#This outlier was removed there is limited effort data. Latitude and longitude shows fishing activity, so it is assumed that there is an error in the data causing the effort hours to be uncharacteristically low.
#load data ------------------------------------------------------

spatial_df <- read.csv("data/estimation/vms_subsidized_00074500_2018.csv")

#convert to sf object------------------------------------------------------

spatial_sf <- st_as_sf(
  spatial_df,
  coords = c("lon", "lat"),
  crs = 4326
)

#create a leaflet map------------------------------------------------------

track_line <- spatial_sf %>%
  summarise(do_union = FALSE) %>%
  st_cast("LINESTRING")


library(leaflet)

leaflet() %>%
  addTiles() %>%
  addCircleMarkers(
    data = spatial_sf,
    radius = 3,
    popup = ~paste("Time:", datetime),
    color = "blue"
  ) %>%
  addPolylines(
    data = track_line,
    color = "red",
    weight = 2,
    opacity = 0.8
  )


#Vessel 00066001, year 2011
# This outlier was not removed as VMS data and maps show this vessel was active in 2011.
#load data ------------------------------------------------------

spatial_df <- read.csv("data/estimation/vms_subsidized_00066001_2011.csv")

#convert to sf object------------------------------------------------------

spatial_sf <- st_as_sf(
  spatial_df,
  coords = c("lon", "lat"),
  crs = 4326
)

#create a leaflet map------------------------------------------------------

track_line <- spatial_sf %>%
  summarise(do_union = FALSE) %>%
  st_cast("LINESTRING")


library(leaflet)

leaflet() %>%
  addTiles() %>%
  addCircleMarkers(
    data = spatial_sf,
    radius = 3,
    popup = ~paste("Time:", datetime),
    color = "blue"
  ) %>%
  addPolylines(
    data = track_line,
    color = "red",
    weight = 2,
    opacity = 0.8
  )

#Vessel 00039180, year 2023
#This outlier was not removed as VMS data and maps show this vessel was active in 2023. 
#load data ------------------------------------------------------

spatial_df <- read.csv("data/estimation/vms_unsubsidized_00039180_2023.csv")

#convert to sf object------------------------------------------------------

spatial_sf <- st_as_sf(
  spatial_df,
  coords = c("lon", "lat"),
  crs = 4326
)

#create a leaflet map------------------------------------------------------

track_line <- spatial_sf %>%
  summarise(do_union = FALSE) %>%
  st_cast("LINESTRING")


library(leaflet)

leaflet() %>%
  addTiles() %>%
  addCircleMarkers(
    data = spatial_sf,
    radius = 3,
    popup = ~paste("Time:", datetime),
    color = "blue"
  ) %>%
  addPolylines(
    data = track_line,
    color = "red",
    weight = 2,
    opacity = 0.8
  )

#Vessel 00008656, year 2023
#This outlier was not removed as VMS data and maps show this vessel was active in 2023.
#load data ------------------------------------------------------

spatial_df <- read.csv("data/estimation/vms_unsubsidized_00008656_2023.csv")

#convert to sf object------------------------------------------------------

spatial_sf <- st_as_sf(
  spatial_df,
  coords = c("lon", "lat"),
  crs = 4326
)

#create a leaflet map------------------------------------------------------

track_line <- spatial_sf %>%
  summarise(do_union = FALSE) %>%
  st_cast("LINESTRING")


library(leaflet)

leaflet() %>%
  addTiles() %>%
  addCircleMarkers(
    data = spatial_sf,
    radius = 3,
    popup = ~paste("Time:", datetime),
    color = "blue"
  ) %>%
  addPolylines(
    data = track_line,
    color = "red",
    weight = 2,
    opacity = 0.8
  )

#Vessel 00066035, year 2023
#This outlier was not removed as VMS data and maps show this vessel was active in 2023.
#load data ------------------------------------------------------

spatial_df <- read.csv("data/estimation/vms_unsubsidized_00066035_2023.csv")

#convert to sf object------------------------------------------------------

spatial_sf <- st_as_sf(
  spatial_df,
  coords = c("lon", "lat"),
  crs = 4326
)

#create a leaflet map------------------------------------------------------

track_line <- spatial_sf %>%
  summarise(do_union = FALSE) %>%
  st_cast("LINESTRING")


library(leaflet)

leaflet() %>%
  addTiles() %>%
  addCircleMarkers(
    data = spatial_sf,
    radius = 3,
    popup = ~paste("Time:", datetime),
    color = "blue"
  ) %>%
  addPolylines(
    data = track_line,
    color = "red",
    weight = 2,
    opacity = 0.8
  )

#Vessel 00066217, year 2023
#This outlier was not removed as VMS data and maps show this vessel was active in 2023.
#load data ------------------------------------------------------

spatial_df <- read.csv("data/estimation/vms_unsubsidized_00066217_2023.csv")

#convert to sf object------------------------------------------------------

spatial_sf <- st_as_sf(
  spatial_df,
  coords = c("lon", "lat"),
  crs = 4326
)

#create a leaflet map------------------------------------------------------

track_line <- spatial_sf %>%
  summarise(do_union = FALSE) %>%
  st_cast("LINESTRING")


library(leaflet)

leaflet() %>%
  addTiles() %>%
  addCircleMarkers(
    data = spatial_sf,
    radius = 3,
    popup = ~paste("Time:", datetime),
    color = "blue"
  ) %>%
  addPolylines(
    data = track_line,
    color = "red",
    weight = 2,
    opacity = 0.8
  )
