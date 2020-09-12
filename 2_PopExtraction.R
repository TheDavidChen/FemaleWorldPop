#############################################################################
# Date: August 19th, 2020
# Author: David Chen 


# Purpose: 
#   First, we create all the necessary folders to store the shapefiles and output.
#   Next, we loop through all the .tif files created from the previous file.
#   We then use raster::extract() to get the pop. sum at the admin level 1.
#   This output is then returned. 

# Input: N/A, just have the .tif files all stored in a folder

# Output: 
#   .RDS file containing the country name, admin level name, and sum of the 
#     pop sum of that area, year, age (if 45, then data is for 45-49). 


# Notes:
# We use raster::extract(). Consider changing the weights and other arguments
#   for situations like if a country border doesn't align exactly. 

# Additionally, if you find that for some countries you need to change
#  the administrative level (e.g. to 2 instead of 1 for some country), 
#  consider re-running the function and joining the tables later. 

#############################################################################

# Load packages
library(sp)
library(raster)

############################################################


extractPop <- function(data_folder, ISO3_codes, admin_level = 1) {

  # Purpose: Extract pop data at requested admin_level and aggregated with 
  #            specified function. 
  # Inputs:
  #   data_folder: Folder where all the .tif files are stored.
  #   ISO3_codes: Vector of all the ISO3 codes desired.
  #   admin_level: integer of admin level desired. 
  # Output:
  #   output_table: df containing country, admin level name, pop sum of that area,
  #                   year, age (if 45, then data is for 45-49). 
  
  # This locates where all the worldPop data (.tif files) are stored
  files <- list.files(data_folder)[85:105]
  
  # Create file to store shapefiles
  if (file.exists("./Shapefiles") == FALSE) {
    dir.create("./Shapefiles")
  }

  ############################################################################
  
  # Get shapefiles for all of SSA
  country_shape <- do.call("bind", lapply(ISO3_codes,
                                      function(x) raster::getData('GADM', path = "./Shapefiles", country = x, level = admin_level)))
  
  print("Let's start the process!")
  
  # Create the final output table, set empty for now. 
  output_table <- data.frame(country = character(), admin_level_one = character(), 
                             pop_sum = double(), year = integer(), age = integer())
  
  
  # Loop through all the .tif files and add to the output_table
  for (image in files) {
    
    # Read in the population data
    pop_image <- raster(paste0(data_folder,image))
    
    
    print(paste0("We're working on: ", image)) # for debugging
    
    
    # Identify the year and age we are working on (for naming purposes)
    year <- as.numeric(substr(image, 1, 4))
    age <- substr(image, 6, 7)
    
    print(paste0("Starting the processing for: ", image)) # for debugging
    
    # Get the sum of the population values at the district level
    # Return as a spatialpolygonsdataframe, we can extract values there.
    # Note: 
    #   We use na.rm since sum() would break otherwise. There are a lot of NA
    #     values in the .tif file.
    #   Additionally, consider changing the different arguments in extract,
    #     such as weight. 
    final_sp <- raster::extract(pop_image, country_shape, 
                                na.rm = T, fun = sum, sp=T)
    
    # Extract the country name, district, and the last row (pop values)
    # Note that technically we could specify @data for the first two parameters
    #   too, not sure why it technically doesn't need it. 
    # Then add the year and age. 
    output <- 
      cbind(final_sp$NAME_0, final_sp$NAME_1, 
            final_sp@data[,ncol(final_sp@data)], year, age)
    
    
    print(paste0("We finished processing: ", image)) # debugging
    
    # Add to the output table
    # This is really really inefficient, fix if too slow to data tables
    output_table <- rbind(output_table, output)
    
    
    # All of this is just for debugging
    ## print("Added to the final output table. Printing last row: ")
    ## print(tail(output_table, 1))
    
    ## print("Length of the output_table right now: ")
    ## print(nrow(output_table))
    
  }
  
  print("Done!") # for debugging
  
  return(output_table)
}


# ISO3 codes of all the countries we want to extract
ISO3_codes_SSA <- 
  c("AGO", "BEN", "BWA", "BFA", "BDI", "CMR", "CAF", "COG", "CIV", "COD", 
    "ETH", "GMB", "GHA", "GIN", "KEN", "LSO", "LBR", "MDG", "MWI", "MLI", 
    "MRT", "MOZ", "NAM", "NER", "NGA", "RWA", "SEN", "SLE", "SOM", "ZAF", 
    "SSD", "SDN", "SWZ" ,"TZA", "TGO", "UGA", "ZMB", "ZWE")


Female1549_WorldPop <- extractPop(data_folder = "./Raw_Data/", ISO3_codes = ISO3_codes_SSA)

# Output the final data set
saveRDS(Female1549_WorldPop, "./Output/Female1549_WorldPop_12_14.RDS")

