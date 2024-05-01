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
roads_county_dir <- "/projectnb/anchor/Data_Hub/Data_Requests/ZachP/Nationwide_TIGRIS/OutputData/"
roads_combined_dir <- "/projectnb/anchor/Data_Hub/Data_Requests/ZachP/Nationwide_TIGRIS/OutputData/Combined/"

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
  
  # Convert to data.frame and remove geometry. The county files are 
  # each projected to a different UTM, and cannot be joined together
  # as spatial objects. Because the UTM system divides the world into equal
  # zones, the length outputs are expacted to be comparable across zones.
  #
  input <- as.data.frame(input)
  input$geometry <- NULL
  
  if (i == 1) { final <- input; next }
  
  # Bind each new county to a nationwide dataset
  #
  final <- rbind(final, input)
}

#Export rds file
#
saveRDS(final, paste0(roads_combined_dir, "Nationwide_TIGER_Roads_Length_Tract_Projected.rds"))

