#############################################################################
# Date: August 19th, 2020
# Author: David Chen 

# Purpose: 
#   Combine all the previously downloaded population data into one dataframe. 

# Input:
#   Specify the folder with the previous output and label the output name.

# Output:
#   All the individual years combined into one dataframe. 

#############################################################################

# Join all the data from our output dataset
folder <- './Output'
filenames <- list.files(folder)

# Join all the datasets together
all_files <- Reduce(rbind, lapply(paste0(folder, "/" ,filenames), readRDS))
names(all_files) <- c("country", "admin_level_name", "fpop_sum", "year", "age")

# Save the output, manually specify the name. 
saveRDS(all_files, "./Female1549_00_20.RDS")