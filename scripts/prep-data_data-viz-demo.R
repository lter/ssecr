## ------------------------------------------------ ##
   # Data Prep - Data Visualisation "Bonus" Demo
## ------------------------------------------------ ##
# Script author(s): Sarah Elmendorf

## Purpose:
# Create example dataset(s) for the 'bonus' code demo at the end of the data viz module

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
# Download Green Lakes Chem/Zooplankton Data ----
## ------------------------------------ ##

# This code demo uses the following dataset:
## Citation: Johnson, P. and K. Loria. 2019. Lake water quality, chemistry and zooplankton composition for 16 lakes surrounding the Green Lakes Valley, 2016 ver 1. Environmental Data Initiative. https://doi.org/10.6073/pasta/cd8b0f9e4d985a945135c60773c94fea
## Link: https://portal.edirepository.org/nis/mapbrowse?packageid=knb-lter-nwt.12.1

# Read it in directly from EDI
water_df <- read.csv("https://pasta.lternet.edu/package/data/eml/knb-lter-nwt/12/1/2619d9d5c07fa2822883df2ea17ffd52")

# Export it locally for easier subsequent access
write.csv(x = water_df, na = '', row.names = F,
          file = file.path("data", "green-lakes_water-chem-zooplank.csv"))

## ------------------------------------ ##
# Simulate Taxon Data ----
## ------------------------------------ ##

# Set random seed for reproducibility
set.seed(123)

# Function to generate a random walk time series
random_walk <- function(n, start = 10, sd = 2) {
  
  # Random increments (positive/negative)
  steps <- rnorm(n, mean = 0, sd = sd)
  
  # Cumulative sum for the random walk
  walk <- cumsum(steps) + start
  
  # Ensure counts are non-negative and integers
  walk <- pmax(0, round(walk))
  
  # Return the result
  return(walk) }

# Define what will become some columns
years <- seq(2010, 2020)
plots <- seq(1, 10)
taxa <- paste0("Taxon_", toupper(letters[1:10]))

# Generate synthetic random walk counts for each combination of plot and taxon
datafile <- tidyr::expand_grid(
  year = years,
  plot = plots,
  taxon = taxa ) %>%
  # Random walk series
  dplyr::group_by(plot, taxon) %>%
  dplyr::mutate(count = random_walk(n = length(year), start = 10, sd = 3)) %>%  
  dplyr::ungroup() %>%
  # make pseudoturnover
  dplyr::mutate(taxon = ifelse(test = (taxon == "Taxon_A" & year == 2014),
                               yes = "Taxon_B", no = taxon)) %>%
  # Change into a typical "presence only" survey
  dplyr::filter(count != 0) 

# Export this file locally
write.csv(x = datafile, na = '', row.names = F,
          file.path("data", "simulated-taxa-df.csv"))

# Define the primary key over which taxa counts should be summed
pKey <- c("year", "plot", "taxon")

# 1. Summing up taxa counts by 'year', 'plot', and 'taxon'
totals <- datafile %>%
  dplyr::group_by(dplyr::across(dplyr::all_of(pKey))) %>% # Group by primary key
  dplyr::summarise(n = sum(count, na.rm = T), .groups = "drop") %>% 
  dplyr::ungroup()

# 2. Expand the data to include zero counts for taxa not hit in a particular year but otherwise present
zeros <- totals %>%
  # Create all combinations of 'taxon', 'plot', and 'year'
  tidyr::expand(tidyr::nesting(taxon, plot), year) 

withzeros <- totals %>%
  dplyr::select(plot, taxon) %>%
  # Get distinct combinations of 'plot' and 'taxon'
  dplyr::distinct() %>% 
  # Cross-join to include all 'year' combinations
  dplyr::full_join(totals %>% dplyr::select(plot, year) %>% dplyr::distinct(),
                   by = "plot", relationship = "many-to-many") %>% 
  # Find rows that don't exist in 'totals'
  dplyr::anti_join(totals, by = c("plot", "taxon", "year")) %>% 
  # Assign zero count for missing combinations
  dplyr::mutate(n = 0) %>% 
  # Bind the zero rows with the original 'totals'
  dplyr::bind_rows(totals)

# 3. Arrange the final data by 'taxon' for so that taxa are sorted alphabetically
# in the plotting step
withzeros <- withzeros %>%
  dplyr::arrange(taxon)

# Export this file locally
write.csv(x = withzeros, na = '', row.names = F,
          file.path("data", "simulated-taxa-df_with-zeros.csv"))

## ------------------------------------ ##
# Download Green Lakes Streamflow Data ----
## ------------------------------------ ##

# This code demo uses the following dataset:
## Caine, N., J. Morse, and Niwot Ridge LTER. 2024. Streamflow for Green Lake 4, 1981 - ongoing. ver 18. Environmental Data Initiative. https://doi.org/10.6073/pasta/d9a922df7747ce82ee1dd5c22026c07a
## Link: https://portal.edirepository.org/nis/mapbrowse?packageid=knb-lter-nwt.105.18

# Read it in directly from EDI
streamflow_df <- read.csv("https://portal.edirepository.org/nis/dataviewer?packageid=knb-lter-nwt.105.18&entityid=3f04604569c43a28142630c784abd99d")

# Export it locally for easier subsequent access
write.csv(x = streamflow_df, na = '', row.names = F,
          file = file.path("data", "green-lakes_streamflow.csv"))

# End ----
