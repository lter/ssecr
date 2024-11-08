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
librarian::shelf(tidyverse, RColorBrewer)

# Make a folder for storing this data
dir.create(path = file.path("data"), showWarnings = FALSE)

# Clear environment
rm(list = ls())

## ------------------------------------ ##
# Simulate Data ----
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

# Generate synthetic random walk counts for each combination of plot and taxon
datafile <- expand_grid(
  year = years,
  plot = plots,
  taxon = taxa
) %>%
  # Random walk series
  dplyr::group_by(plot, taxon) %>%
  dplyr::mutate(count = random_walk(n = length(year), start = 10, sd = 3)) %>%  
  dplyr::ungroup() %>%
  # make pseudoturnover
  dplyr::mutate(taxon = ifelse(test = (taxon == "Taxon_1" & year == 2014),
                               yes = "Taxon_2", no = taxon)) %>%
  # Change into a typical "presence only" survey
  dplyr::filter(count != 0) 

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
  expand(nesting(taxon, plot), year) 

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

# Export locally
# write.csv(x = withzeros, row.names = F, na = '', file = file.path("data", "spp_abun.csv"))

## ------------------------------------ ##
# Graph Code ----
## ------------------------------------ ##

# NOTE:
## Once we can get the above code to work/produce a data file we should move this to the end of the visualization module
## Until then, leaving code here for posterity/version control purposes
## Should be easier to run/debug in script format

# # 4. Create the plot of species counts over time with zeros filled in
# pdf("counts_by_taxon_with_zeros.pdf", width = 9, height = 5) # Start a PDF output
# 
# # Loop over groups of taxa, plotting up to 6 taxa at a time
# for (i in seq(1, length(unique(withzeros$taxon)), 6)) {
#   
#   df <- withzeros %>%
#     # Select up to 6 taxa at a time
#     dplyr::filter(taxon %in% unique(withzeros$taxon)[i:(i + 5)]) %>% 
#     # Convert 'plot' to a factor for coloring
#     dplyr::mutate(plot = factor(plot)) 
#   
#   # Determine the number of unique plots (colors)
#   colourCount <- length(unique(df$plot)) 
#   
#   # Define a color palette
#   getPalette <- grDevices::colorRampPalette(RColorBrewer::brewer.pal(n = 9, name = "Set1")) 
#   
#   # Generate the plot using ggplot
#   print(
#     ggplot(df, aes(x = year, y = n, group = plot, color = plot)) +
#       geom_line() +
#       # Facet by 'taxon', 2 rows of plots
#       facet_wrap(~ taxon, nrow = 2) +
#       # Apply custom color palette
#       scale_color_manual(values = getPalette(colourCount)) 
#   )
# }
# 
# dev.off() # Close the PDF output
# 
# # 5. View your plots! Can you spot instance of pseudoturnover where certain taxa
# # "disappear" in the same years that another taxon with similar morphology
# # "appears"? Are levels of interannual fluctuations realistic for your system?
# 

# End ----
