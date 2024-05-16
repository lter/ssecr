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
  
  # Make a list of allowable ranges
  rng_list <- list(15:22, 24:31, 1:6)
  
  # Randomize range order
  rng_ord <- sample(x = 1:3, size = 3, replace = F)
  
  # Generate annual data
  for(yr in 2022:2024){
    
    # Generate plot level data
    for(plt in 1:3){
      
      # Pick plot letter
      plt_id <- letters[plt]
      
      # Grab range of responses at this plot
      rng <- rng_list[[rng_ord[plt]]]
      
      # Modify the range by this site's modifier
      rng_mod <- ceiling(rng * site_mod)
      
      # Simulate response data 
      resp <- sample(x = rng_mod, size = reps, replace = T)
      
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

# Wrangle simulated data
spider_df <- sim_list %>% 
  # Unlist to a dataframe
  purrr::list_rbind(x = .) %>% 
  # Put year in front of everything else
  dplyr::relocate(year, .before = dplyr::everything())

# Check structure
dplyr::glimpse(spider_df)

# Exploratory visuals
## Site means work as desired
ggplot(spider_df, aes(y = tarantula_count, x = reorder(site, -road_dist_km), 
                      fill = road_dist_km)) +
  geom_violin(alpha = 0.5) +
  theme_bw()

## Plot-level random effect
ggplot(spider_df, aes(y = tarantula_count, x = plot, fill = plot)) +
  geom_violin(alpha = 0.5) +
  facet_wrap(site ~ .) +
  theme_bw()

# Export locally
# write.csv(x = spider_df, row.names = F, na = '', file = file.path("data", "tarantulas.csv"))

# End ----
