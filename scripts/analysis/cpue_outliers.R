#load packages------------------------------------------------------
library(bigrquery)
library(DBI)
library(sf)
library(dplyr)
library(leaflet)

#authenticate with Google Cloud ------------------------------------
bq_auth("laubri42@gmail.com")

#outlier 1- vessel RNPA 00034389, year 2018------------------------------------------------------
#load data------------------------------------------------------
project_id <- "mex-fisheries"
dataset <- "mex_vms"
table <- "mex_vms_processed_v_20250623"

vessel_rnpa <- "00034389"
year <- 2018

query <- sprintf("
  SELECT vessel_rnpa, datetime, lat, lon
  FROM `%s.%s.%s`
  WHERE vessel_rnpa = '%s' 
    AND EXTRACT(YEAR FROM datetime) = %d
  ORDER BY datetime ASC
", project_id, dataset, table, vessel_rnpa, year)
      

#run query------------------------------------------------------

spatial_data <- bq_project_query(project_id, query)
spatial_df <- bq_table_download(spatial_data)

#export data------------------------------------------------------
write.csv(spatial_df, "data/estimation/vms_00034389_2018.csv", row.names = FALSE)

#convert to sf object------------------------------------------------------

spatial_sf <- st_as_sf(spatial_df, coords = c("lon", "lat"), crs = 4326)
st_write(spatial_sf, "data/estimation/vms_00034389_2018.geojson", driver = "GeoJSON", delete_dsn = TRUE)

#create a leaflet map------------------------------------------------------
spatial_sf <- spatial_sf %>% arrange(datetime)

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

