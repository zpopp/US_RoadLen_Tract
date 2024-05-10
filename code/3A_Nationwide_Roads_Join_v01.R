##    Author: Zach Popp
##      Date: 01/11/2024
##Overview: The goal of these scripts is to query and process roads data from 
##          tigris to a census tract level road length measure by road class. 
##          Processing is done by county.
##          The roads are intersected with census tracts using st_intersection (this file),
##          the length in each tract is calculated with st_length, and then sum
##          road lengths are calculated for each of the unique road classifications.
##          Finally, a nationwide road lenght dataset is developed (this file)
##
##  Purpose:  Join output files from county-specific processing into nationwide
##            output data
##        

library(sf)

# Set directories for input and output
#
roads_county_dir <- # this is the directory where the tract sum road length measures for each county has been stored
roads_combined_dir <- # this is the directory where you want your final nationwide output

# Create list of all county-wide tract-level road measures data
#
roads_files <- dir(roads_county_dir, full.names=TRUE, pattern="tigris_roadlen.*.rds")

# Looping through files to merge into one file with all years included
#
for (i in 1:length(roads_files)) {
  
  # Indicate progress
  #
  cat("Processing", i, "of", length(roads_files), "files \n")
  
  # Read in roads at county level
  #
  input <- readRDS(roads_files[i])
  
  # The tract road length was calculated with distinct projected coordinate 
  # systems based on the region within the US. We cannot create a nationwide
  # shapefile from components with distinct coordinate systems. To create 
  # the nationwide file, we will convert each county shapefile to a consistent 
  # coordinate system. We use NAD 1983 as it is the coordinate system which the 
  # tracts were initially read in as. 
  #
  input <- st_transform(input, 4269)
  
  if (i == 1) { final <- input; next }
  
  # Bind each new county to a nationwide dataset
  #
  final <- rbind(final, input)
}

#Export rds file
#
saveRDS(final, paste0(roads_combined_dir, "Nationwide_2020_TIGER_Roads_Sum_Length_Tract.rds"))

