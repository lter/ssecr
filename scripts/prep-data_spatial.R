## ------------------------------------------------ ##
            # Data Prep - Spatial Data
## ------------------------------------------------ ##
# Script author(s): Nick J Lyon

## Purpose:
# Prepare raster/vector data for course

## ------------------------------------ ##
            # Housekeeping ----
## ------------------------------------ ##
# Load needed libraries
## install.packages("librarian")
librarian::shelf(tidyverse, sf, terra, googledrive)

# Make a folder for storing this data
dir.create(path = file.path("data"), showWarnings = FALSE)

# Authorize R to work with Google Drive
googledrive::drive_auth()

# Clear environment
rm(list = ls())

## ------------------------------------ ##
          # Vector Data Prep ----
## ------------------------------------ ##

# Identify path to `sf` North Carolina vector data
sf_file <- system.file(file.path("shape", "nc.shp"), package = "sf")

# Read it in
sf_obj <- sf::st_read(dsn = sf_file)

# Transform CRS
sf_wgs84 <- sf::st_transform(x = sf_obj, crs = 4326)

# Exploratory plot
plot(sf_wgs84["AREA"], axes = T)

# Export locally to a more easily accessible directory
sf::st_write(obj = sf_wgs84, dsn = file.path("data", "nc_borders.shp"), delete_layer = T)

## ------------------------------------ ##
          # Raster Data Prep ----
## ------------------------------------ ##

# Data source info:
## NASA Shuttle Radar Topography Mission Global 3 arc second
## https://lpdaac.usgs.gov/products/srtmgl3v003/

# Identify folder in SSECR Shared Drive
raster_drive <- googledrive::as_id("https://drive.google.com/drive/u/0/folders/1CBC-nFVVJoydMjnd88_sJU2D92HIZ31V")

# Find and download the data
googledrive::drive_ls(path = raster_drive) %>% 
  dplyr::filter(name == "SRTMGL3_NC.003_SRTMGL3_DEM_doy2000042_aid0001.tif") %>% 
  googledrive::drive_download(file = .$id, overwrite = T,
                              path = file.path("data", .$name))

# Load data
rast_raw <- terra::rast(x = file.path("data", "SRTMGL3_NC.003_SRTMGL3_DEM_doy2000042_aid0001.tif"))

# Crop raster to polygon above
rast_crop <- terra::crop(x = rast_raw, y = terra::vect(sf_wgs84["AREA"]), mask = T)

# Test plot
terra::plot(rast_crop)

# Export locally
terra::writeRaster(x = rast_crop, overwrite = T,
                   filename = file.path("data", "nc_elevation.tif"))

# End ----
