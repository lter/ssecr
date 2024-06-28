## -------------------------------------- ##
        # Spatial Module Prep Work
## -------------------------------------- ##
# Author(s): Nick J Lyon

# Purpose:
## Prepare data for the spatial modules

## ----------------------- ##
    # Housekeeping ----
## ----------------------- ##

# Load needed libraries
librarian::shelf(sf, terra)

# Create the 'data' folder if it doesn't exist
dir.create(path = file.path("data"), showWarnings = F)

# Clear environment
rm(list = ls())

## ----------------------- ##
  # Vector Data Prep ----
## ----------------------- ##

# Identify path to `sf` North Carolina vector data
sf_file <- system.file(file.path("shape", "nc.shp"), package = "sf")

# Read it in
sf_obj <- sf::st_read(dsn = sf_file)

# Transform CRS
sf_wgs84 <- sf::st_transform(x = sf_obj, crs = 4326)

# Exploratory plot
plot(sf_wgs84["AREA"], axes = T)

# Export locally to a more easily accessible directory
sf::st_write(obj = sf_wgs84, dsn = file.path("data", "nc.shp"), delete_layer = T)

## ----------------------- ##
  # Raster Data Prep ----
## ----------------------- ##

# Data source info:
## NASA Shuttle Radar Topography Mission Global 3 arc second
## https://lpdaac.usgs.gov/products/srtmgl3v003/

# Download note:
## Downloaded and placed in "data" folder manually
## Used NASA's AppEEARS portal for doing the downloading

# Load data
rast_raw <- terra::rast(x = file.path("data", "SRTMGL3_NC.003_SRTMGL3_DEM_doy2000042_aid0001.tif"))

# Crop raster to polygon above
rast_crop <- terra::crop(x = rast_raw, y = terra::vect(sf_wgs84["AREA"]), mask = T)

# Test plot
terra::plot(rast_crop)

# Export locally
terra::writeRaster(x = rast_crop, overwrite = T,
                   filename = file.path("data", "elevation.tif"))

# End ----
