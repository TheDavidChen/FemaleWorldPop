
# Female WorldPop Processing - Downloading by Age, Year, and Administrative Level

The WorldPop provides [global mosaics of the world population broken down by age and sex at a ~1km resolution from 2000-2020](https://www.worldpop.org/geodata/listing?id=65). The code provided in this repo will allow the user to automatically download and then process all the data into a simple `R` dataframe that is easy to apply. 

The final output is an `.RDS` file containing the data year, the country name, administrative level name, and the sum of the female population living in that area. Users can specify the age range (e.g. 15-49) and the years desired. 

Note: 4_ageAggregation.R aggregates the age brackets together with a tidyverse solution. Since it may not be compatible with the cluster, it is provided separately. 

## Technologies

This makes use of `R` v3.5.2 and the following packages:

+ `sp` v1.4.1.      
+ `raster` v3.0.12.    

The code is designed to be run on the [Penn State ACI-b cluster](https://www.icds.psu.edu/computing-services/icds-aci-user-guide/), although it can be run on any local computer. 

4_ageAggregation makes use of the following:

+ `tidyverse` v1.3.0

## How to Run

### On the cluster

**Note:** If this is your first time running the `raster` package on the cluster, please refer to the "Getting Raster Working" section first. 

1. Download the three `R` files and corresponding PBS files.    
2. Use WinSCP or another SCP Client (e.g. Cyberduck for Mac, FileZilla for all OS) to move the files into a new scratch folder on the ACI-b.  
3. Edit line 21 of 2_SSA_district_processing.PBS to match the version current available on the cluster.  

    + This can be checked by using PuTTY and running: "module spider" and locating the line similar to "ml gdal-3.0.4-gcc-7.3.1-ztomvd7 proj-6.2.0-gcc-7.3.1-3dqejei".   
    
4. Enter PuTTY (Terminal for Mac), and use `cd` to get to the location of the transferred R files.  
5. Run the 3 PBS files through the `qsub` command in numerical order (e.g. `qsub 1SSA_download.PBS` in PuTTY to commence processing. 
6. Transfer the .RDS output out of the cluster through your SCP client if desired. 
7. Run 4_ageAggregation.R to aggregate the age brackets together.

## Files

There are 3 `R` files and 3 corresponding `PBS` files. The first `R` file downloads the data, the second extracts the data, and then the third aggregates and outputs the results. 

A fourth `R` file (4_ageAggregation.R) is provided as a tidyverse solution to joining all the age brackets together. No corresponding `.PBS` file is provided due to the amount of dependencies required. 

A sample output (2000-2020 female 15-49 population sizes in sub-Saharan Africa at the administrative level one unit) is provided in the Sample_Output folder. 

### 1_SSA_download.R

**Purpose:** Specifies the functions to download the age/sex structure WorldPop data (1km) automatically. The user can specify the years and ages desired, and the functions will proceed to download the .tif files into a folder.

**Input:** The User has to specify: output folder name, starting year, ending year (inclusive), starting age (interval of 5), ending year (ideally should end in a 4 or 9), and desired sex. 

**Output:** All the desired WorldPop data downloaded with the following name: <year>_<age>.tif

**Notes:** 

+ The output folder will be set at the specified location. If it does not already exist, it will automatically create it. If it does exist, it will use that folder. 

### 2_PopExtraction.R

**Purpose:** Extract the population data at the specified administrative level for all the .tif files previously downloaded. 

**Input:** ISO3 codes for all the desired countries, the path to the folder where all the .tif files are located, name the desired output folder, and the desired administrative level (defaults to 1).

**Output:** .RDS file containing the country name, admin level name, sum of the female population in that area, year, and age (if 45, then data is for 45-49). 

**Changes user may make:** 

+ The data is extracted through `raster::extract()`. Consider exploring the documentation and deciding how the parameters should be set, specifically `weights`, `small`, and `fun`.  
+ This program defaults to `sum` as the aggregation function. If a different function is desired, change the `fun` argument in `raster::extract()`. 
+ The output can be saved in any other format, besides `.RDS`. For example, if a `.csv` file is desired, simply change `saveRDS()` to `write.csv()`. 

**Notes:** 

+ If some countries need to be specified at a different administrative level (e.g. Malawi level 2 instead of level 1), it should be significantly easier to simply run the code twice but with different arguments. 
+ This program sums the designated regions. If one wants all the individual points, please explore the `raster::extract()` argument `df`. 

### 3_joinFiles.R

**Purpose:** Combine all the previously downloaded population data into one dataframe. 

**Input:** Specify the folder with the previous output and label the output name.

**Output:** All the individual years combined into one dataframe, a .RDS file.

**Notes:** 

+ The user should specify the output name to ensure it is an accurate description.

### 4_ageAggregation.R

**Purpose:** Combine all the age brackets into one value for each country/year/region combination.

**Input:** The .RDS dataframe created from 3_joinFiles.R

**Output:** An .RDS dataframe containing the aggregated female population data.

**Notes:** 

+ A sample is provided in the Sample_Output folder.
+ Users should ensure that the file names match the previously created files. 

### PBS Files

**REQUIRED CHANGE FOR ALL USERS:** For 2PopExtraction.PBS, on line 21, the user will have to change to the appropriate version of gdal and proj. These additional lines are required to get the `raster` package working on the cluster. See the "Getting Raster Working" section for more information. 

No changes are required for 1SSA_download.PBS.

To understand the PBS files, please read the documentation on the [ICDS_ACI](https://www.icds.psu.edu/computing-services/icds-aci-user-guide/#07-02-interactive-compute-sessions-aci-b) and/or the [Quick Reference guide](https://www.icds.psu.edu/wp-content/uploads/2017/09/ICS-ACI-Documentation_Reference-Sheet.pdf).

## Getting Raster Working

To get the raster package running on the server, there are a bit more technicalities. If you just attempt to install and call `raster`, you will find that it doesn’t work. Instead, you will need to do the following at least once first:

In order to install `rgdal` (required for `raster`) properly, use the following code in PuTTY (or terminal or any other related system) after logging into the ACI-b server: 

$ cd work  
$ module purge  
$ module use /gpfs/group/dml129/default/sw/modules  
$ ml gcc  
$ ml r/3.4  
$ ml openmpi  
$ mkdir sw  
$ cd sw  
$ mkdir gdal  
$ cd gdal  
$ git clone https://github.com/spack/spack.git  
$ . spack/share/spack/setup-env.sh  
$ spack install gdal  
$ cd spack  
$ source ./share/spack/setup-env.sh  
$ ml gdal-3.0.1-gcc-7.3.1-uxpvawq proj-6.1.0-gcc-7.3.1-odxlwcd  
$ R  
\> install.packages(“rgdal”)  

**NOTE:** The ml gdal-3.0.1 part gets updated, so you need to check both the packages and update them. You can use `module spider` to look at all the modules and update it accordingly. For example, I used:

ml gdal-3.0.4-gcc-7.3.1-ztomvd7 proj-6.2.0-gcc-7.3.1-3dqejei

When I installed packages, I stored them all temporarily here: 
The downloaded source packages are in
        ‘/tmp/RtmpBMKWUB/downloaded_packages’

Now, every time you want to use the raster package, you will still need to call the gdal part of the code. This is done for you in the `PBS` file. 
