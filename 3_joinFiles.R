

# Join all the data from our output dataset
folder <- './Output'
filenames <- list.files(folder)

# Join all the datasets together
all_files <- Reduce(rbind, lapply(paste0(folder, "/" ,filenames), readRDS))

# Save the output, manually specify the name. 
saveRDS(all_files, "./Female1549_00_20.RDS")