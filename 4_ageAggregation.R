#############################################################################
# Date: September 12th, 2020
# Author: David Chen 

# Purpose: 
#   Combine all the age brackets into one value for each country/year/region 
#     combination.

# Input:
#   The dataframe created from 3_joinFiles.R

# Output:
#   .RDS dataframe containing the aggregated female population data

#############################################################################


# Load in libraries
library(tidyverse)

# Read in data (from 3_joinFiles.R)
FemalePop_raw <- readRDS("./Female1549_00_20.RDS")

# Ensure names match what we expect
names(FemalePop_raw) <- c("country", "admin_level_name", "fpop_sum", "year", "age")

# First, convert fpop_sum from a factor to a numeric
# Then sum accordingly. 
FemalePop_combined <- 
  FemalePop_raw %>%
  mutate(fpop_sum = as.numeric(levels(fpop_sum))[fpop_sum]) %>%
  group_by(country, admin_level_name, year) %>%
  summarize(fpop_sum_ages = sum(fpop_sum))

saveRDS(FemalePop_combined, "./FemalePop_00_20.RDS")
