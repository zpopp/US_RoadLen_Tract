##Author:   Zach Popp
##Date Created:     01/29/2024
##Date Modified:    02/21/2024
##Overview: The goal of these scripts is to query and process roads data from 
##          tigris to a census tract level road length measure by road class. 
##          This script is used to download TIGER/Line road data for all US counties.
##          The roads are then intersected with census tracts using st_intersection (next file),
##          the length in each tract is calculated with st_length, and then sum
##          road lengths are calculated for each of the unique road classifications.
##          Finally, a nationwide road lenght dataset is constructed.
##
##Purpose:  Use tigris to download all roads for a state.
##          
library(dplyr)
library(tigris)

# Set directories where you want to read in and output data
#
fips_dir <-  # directory where FIPS file is stored, only needed if using bash scripts
             # a list of FIPS codes can be found at https://transition.fcc.gov/oet/info/maps/census/fips/fips.txt 
roads_dir <- # directory where you want your roads data to be placed

# The following variables come from the command line when running as bash. Bash
# scripting is a method for expediting processing using a computing cluster.
# To use this code, you would need to separately write a bash script (such as file 1B in the repository)
# that specifies a series of indices which will be used to process multiple states simultaneously
#
# If you are only processing a single state, this is not necessary. The bash script
# language below can be removed, and you can 
# add a line to specify the stateFIPS you would like to process.
#
args <- commandArgs(trailingOnly = TRUE)
b <- as.numeric(args[1]) # state FIPS index; b=8 for DC

# %%%%%%%%%%%%%%%%%%%% IDENTIFY STATE FIPS OF INTEREST %%%%%%%%%%%%%%%%%%%%%%% #
# Reading in stateFIPS to allow for filtering by state in bash script. If you
# are not using a bash script just use line 43 below.
#
stateFIPS <- read.csv(paste0(fips_dir, "US_States_FIPS_Codes.csv"), stringsAsFactors = FALSE)
stateFIPS <- stateFIPS$StFIPS     #integer; does not contain leading zeroes
stateFIPS <- formatC(stateFIPS[b], width = 2, format = "fg", flag = "0")

# If you are not using a bash script than you can use the line below
# stateFIPS <- "25"  # Example here for Massachusetts state FIPS code

# Develop list of all counties for the state specified using tigris package.
#
counties <- tigris::counties(state = stateFIPS, year = 2020, cb = TRUE)
counties <- unique(counties[[grep("^COUNTYFP", names(counties), ignore.case = TRUE)]])

# Download statewide roads using the TIGRIS package
#
state_roads <- roads(state = stateFIPS, county = c(counties), year = 2020)

# Output state road file for use in next script
saveRDS(state_roads, paste0(roads_dir, "tigris_roads_", stateFIPS, "_2020.rds"))


