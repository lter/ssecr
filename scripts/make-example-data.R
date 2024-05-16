## ------------------------------------------------ ##
                  # Make Example Data
## ------------------------------------------------ ##
# Script author(s): Nick J Lyon

## Purpose:
# Create example datasets that exactly meet our needs in a given module/topic

## ------------------------------------ ##
# Housekeeping ----
## ------------------------------------ ##
# Load needed libraries
## install.packages("librarian")
librarian::shelf(tidyverse)

# Make a folder for storing this data
dir.create(path = file.path("data"), showWarnings = FALSE)

# Clear environment
rm(list = ls())

## ------------------------------------ ##
  # Stats - Mixed-Effect Case Study ----
## ------------------------------------ ##
# Simulate a tarantula dataset with nested structure

# Let's imagine we are researching tarantula populations for several years in the Chihuahuan Desert. Our hypothesis is that the number of tarantulas (response variable) will be greater in sites further from the nearest road (explanatory variable). We select ten study sites of varying distances from the nearest road and intensively count our furry friends for several months at three plots within each site. We return to our sites--and their associated plots--and repeat this process each year for three years. After entering our data in MS Excel here's what we walk away with.

# Generate site-level information
( site_df <- data.frame("site" = paste0("site_", LETTERS[1:10]),
                        "dist" = round(rnorm(n = 10, mean = 50, sd = 20), digits = 2)) )

# Define plot-level replicate counts
reps <- 5

# Make an empty list
sim_list <- list()

# Loop across sites
for(k in 1:nrow(site_df)){
  
  # Define a site-specific modifier to change responses by
  site_mod <- site_df[k, ]$dist / 10
  
  # Generate annual data
  for(yr in 2022:2024){
    
    # Generate plot level data
    for(plt in letters[1:3]){
      
      # Pick range of responses per site
      if(plt == "a"){ rng <- 15:22 }
      if(plt == "b"){ rng <- 24:31 }
      if(plt == "c"){ rng <- 1:6 }
      
      # Modify the range by this site's modifier
      rng_mod <- ceiling(rng * site_mod)
      
      # Simulate response data 
      resp <- sample(x = rng, size = reps, replace = T)
      
      # Generate a more involved data frame
      sim_df <- data.frame("site" = rep(x = site_df[k, ]$site, times = reps),
                           "road_dist_km" = rep(x = site_df[k, ]$dist, times = reps),
                           # "plot" = rep(x = paste0(site_df[k, ]$site, "-", plt), 
                           #              times = reps),
                           "plot" = rep(x = paste0("plot_", plt), times = reps),
                           "year" = rep(x = yr, times = reps),
                           "tarantula_count" = resp)
      
      # Add to list
      sim_list[[paste(site_df[k, ]$site, yr, plt, sep = "-")]] <- sim_df
      
    } # Close plot loop
  } # Close year loop
} # Close site loop

# Unlist and wrangle simulated data
spider_df <- sim_list %>% 
  purrr::list_rbind(x = .)

# Check structure
dplyr::glimpse(spider_df)

# Exploratory visuals
ggplot(spider_df, aes(y = tarantula_count, x = reorder(site, -road_dist_km),
                      fill = road_dist_km, color = plot)) +
  geom_violin(alpha = 0.5) +
  theme_bw()

# Export locally

# End ----
