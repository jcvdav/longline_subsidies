#load packages------------------------------------------------------
library(bigrquery)
library(DBI)
library(sf)
library(dplyr)
library(leaflet)
library(lubridate)

#authenticate with Google Cloud ------------------------------------
bq_auth("laubri42@gmail.com")

#outlier 1- vessel RNPA 00034389, year 2018------------------------------------------------------
#load data------------------------------------------------------
project_id <- "mex-fisheries"
dataset <- "mex_vms"
table <- "mex_vms_processed_v_20250623"

full_table <- bq_table(project_id, dataset, table)
spatial_df <- bq_table_download(full_table)

con <- dbConnect(
  bigrquery::bigquery(),
  project = project_id,
  dataset = dataset,
  billing = project_id
)

vms_tbl <- tbl(con, table)

#function to isolate outliers------------------------------------------------------
get_vms_data <- function(rnpa, year) {
  vms_tbl %>%
    filter(
      vessel_rnpa == rnpa,
      sql(paste0("EXTRACT(YEAR FROM datetime) = ", year))
    ) %>%
    arrange(datetime) %>%
    collect()
}

#Vessel 0034389, year 2018 DEF REMOVE ------------------------------------------------------
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
#Vessel 00034389, year 2016 ANALYZE RAW LANDINGS DATA ------------------------------------------------------
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
#Vessel 00074500, year 2018 DEF REMOVE ------------------------------------------------------
#filter ------------------------------------------------------
vessel_rnpa <- "00074500"
year <- 2018

spatial_df <- get_vms_data(vessel_rnpa, year)

#export data------------------------------------------------------
write.csv(spatial_df, "data/estimation/vms_00074500_2018.csv", row.names = FALSE)

#convert to sf object------------------------------------------------------

spatial_sf <- st_as_sf(spatial_df, coords = c("lon", "lat"), crs = 4326)
st_write(spatial_sf, "data/estimation/vms_00074500_2018.gpkg", driver = "GPKG", delete_dsn = TRUE)

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
