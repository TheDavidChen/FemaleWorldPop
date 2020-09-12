#############################################################################
# Date: August 19th, 2020
# Author: David Chen 


# Purpose: 
#   Functions to download age/sex structure WorldPop data (1km) is provided.
#   The user can specify the years, ages, and the gender desired. 
#   The functions will proceed to download the .tif files into a folder.

# Input:
#   User has to specify output folder name, starting year, ending year (inclusive),
#     starting age (interval of 5), ending year (ideally should end in a 4 or 9),
#     and desired sex. 

# Output:
#   All the desired WorldPop data downloaded with the following name:
#     <year>_<age>.tif

#############################################################################

# We can make a function to pick the years and the age range
extract_global_links <- function(year_start, year_end, 
                                 age_start, age_end, sex = "f") {
  
  # Purpose: Store all the download links for the desired years, ages, and sex
  # Inputs:
  ### year_start: numeric value of first year desired 
  ### year_end: numeric value of last year desired (inclusive)
  ### age_start: numeric start of age desired (must be interval of 5)
  ### age_end: last age desired (inclusive)
  ### sex: Sex dataset desired ("m" or "f")
  # Output:
  ### download_links: data frame containing the year, starting age, and then 
  ###                 the download link. 
  
  # All the parts of the download link that are universal
  link_start <- "ftp://ftp.worldpop.org.uk/GIS/AgeSex_structures/Global_2000_2020/"
  link_mid <- "/0_Mosaicked/global_mosaic_1km/global_"
  link_end <- "_1km.tif"
  
  # Create a data frame that will store our download links (long format)
  # It is unclear why we need to enter a row of data. 
  # Without this, the variables get renamed and everything breaks
  download_links <- data.frame(year = 1, age = 1, 
                               link = "fill", stringsAsFactors=FALSE)
  
  # If the starting year is after the end year, throw an error and quit
  stopifnot(year_start <= year_end)
  
  # If the starting age is after the ending age, throw an error and quit
  stopifnot(age_start <= age_end)
  
  # Loop through each desired year and create the link for each age subgroup
  # Store in a data frame for output
  for (year in year_start:year_end) {
    
    # Reset the age to start at the specified age
    age <- age_start
    
    # Stop when the age exceeds the specified age_end
    while (age <= age_end) {

      # Create the link
      age_link <- paste0(link_start, year, link_mid, sex, "_", age, "_", year, link_end)

      # Add the link (and year/age) to our data frame
      download_links <- rbind(download_links, c(year, age, age_link))
      
      # Index the age by 5 since data is only available in intervals of 5
      age <- age + 5
    }
    
    #print(year) # Debugging
  }
  
  # Return data frame containing the download links
  # Remove the first row (our filler)
  return(download_links[2:nrow(download_links),])
  
}

download_global_links <- function(output_folder, 
                                  year_start, year_end, 
                                  age_start, age_end, sex = "f") {
  
  # Purpose: Download all the desired data to specified folder
  # Inputs:
  ### output_folder: name of folder to store all the .tif files
  ### <everything else>: see extract_global_links()
  # Output: 
  ### All the files are downloaded into the specified folder with the following
  ###   structure: <year>_<age>.tif
  
  
  # Use previously defined function to create df of download links
  links_df <- extract_global_links(year_start, year_end, age_start, age_end, sex)

  # Create the output folder if it doesn't already exist
  if (file.exists(output_folder) == FALSE) {
    dir.create(output_folder)
  }
  
  # Download all the links 
  for (row in 1:nrow(links_df)) {
    
    # Print confirmation to keep track of progress
    print(paste0("Downloading row: ", row))
    
    # Set the name of the downloaded file
    file_name <- paste0(links_df[row, 1], "_",links_df[row, 2], ".tif")
    
    print(file_name)
    
    # Download the data to the designated folder
    #   and set the name to what we previously decided
    download.file(links_df[row, 3], paste0(output_folder, "/", file_name))
  }
}


download_global_links("Raw_Data", 2000, 2020, 15, 49)
