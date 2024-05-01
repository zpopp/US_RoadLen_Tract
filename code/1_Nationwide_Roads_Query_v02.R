##Author:   Zach Popp
##Date Created:     01/29/2024
##Date Modified:    02/21/2024
##Overview: The goal of these scripts is to query and process roads data from 
##          tigris to a census tract level road length measure by road class. 
##          This script is used to download raw road data for all US counties.
##          The roads are then intersected with census tracts using st_intersection (next file),
##          the length in each tract is calculated with st_length, and then sum
##          road lengths are calculated for each of the unique road classifications.
##          Finally, a nationwide road lenght dataset is developed
##
##Purpose:  Use tigris to download all roads for a state.
##          
library(dplyr)
library(tigris)

# Set directories where you want to read in and output data
#
fips_dir <- "/projectnb/acres/Census/RawData/" # directory where FIPS file is stored, only needed if using bash scripts
roads_dir <- "/projectnb/anchor/Data_Hub/Data_Requests/ZachP/Nationwide_TIGRIS/IntermediateData/" # directory where you want your roads data to be placed

# The following variables come from the command line when running as bash. Bash
# scripting is a method for expediting processing using a computing cluster.
# To use this code, you would need to separately write a bash script that specifies
# a series of indices that will be used to process multiple states simultaneously
#
# If you are only processing a single state, this is not necessary. The bash script
# language below including lines 22 through 31 can be removed, and you can 
# add a line to specify the stateFIPS you would like to process.
#
args <- commandArgs(trailingOnly = TRUE)
b <- as.numeric(args[1]) # state FIPS index; b=8 for DC

# %%%%%%%%%%%%%%%%%%%% IDENTIFY STATE FIPS OF INTEREST %%%%%%%%%%%%%%%%%%%%%%% #
# Reading in stateFIPS to allow for filtering by state in bash script. If you
# are using a bash script
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

# Output state road file
saveRDS(state_roads, paste0(roads_dir, "tigris_roads_", stateFIPS, "_2020.rds"))


