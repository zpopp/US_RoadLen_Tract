##Author:   Zach Popp
##Contrib:  Dennis Milechin
##Date Created:     01/29/2024
##Date Modified:    02/21/2024
##Overview: The goal of these scripts is to query and process roads data from 
##          tigris to a census tract level road length measure by road class. 
##          Processing is done by county.
##          The roads are intersected with census tracts using st_intersection (this file),
##          the length in each tract is calculated with st_length, and then sum
##          road lengths are calculated for each of the unique road classifications.
##          Finally, a nationwide road lenght dataset is developed
##
##Purpose:  Intersect roads data with census tracts and calculate length of road 
##          by class in each tract.
##          

# Reading in packages
#
library(sf)
library(dplyr)
library(data.table)
library(tidycensus)
library(tigris)

# Script to allow bash scripting by county index (b)
# We use bash scripting here to read in each county separately and conduct the
# intersection operation. For details about bash scripting, see script 1.
# 
args <- commandArgs(trailingOnly = TRUE)
b <- as.numeric(args[1]) # county FIPS index

# Set directories where you want to read in and output data
#
fips_dir <- "" # directory where FIPS file is stored, only needed if using bash scripts
               # This should be COUNTY-fips data. For county level fips codes, this resource can be used: https://transition.fcc.gov/oet/info/maps/census/fips/fips.txt
               # Alternatively nationwide counties can be queried with the tigris counties(year = 2020) function, and subset to the FIPS column
indir <- "" # this directory is where the UTM projection zones are to be stored
            # We use a projected coordinate system to ensure we process lengths in meters and to expedite the processing time.
            # UTM zones are region-specific projected coordinate systems that can ensure the projection is specific to the region being processed.
            # UTM zones with requisite coordinate data for subsetting are available from: 
            # https://crs-explorer.proj.org/?searchText=NAD83(HARN)%20%2F%20UTM%20zone&ignoreWorld=false&allowDeprecated=false&authorities=EPSG&activeTypes=PROJECTED_CRS&map=osm
roads_interdir <- "" # directory where your previously generated roads data is stored
roads_outdir <- "" # directory where you want to output your tract data after tract aggregation

# Specify county to be used based on bash input
#
countyFIPS <- read.csv(paste0(fips_dir, "US_Counties_FIPS_Codes_2020.csv"),
                       colClasses = "character", check.names = F)
colnames(countyFIPS)[1] <- "GEOID"
countyFIPS <- countyFIPS$GEOID[b]

# If you are not using a bash script than you can use the line below.
# If you are not using a bash script, lines 26-27 and 37-38 are not needed.
# countyFIPS <- "25001"  # Example here for Barnstable County, MA

# Grab stateFIPS for use in identifying outputs
#
stateFIPS <- substr(countyFIPS, 1, 2)

# Loading in road and state tract datasets
#
tigris_roads <- readRDS(paste0(roads_interdir, "tigris_roads_", stateFIPS, "_2020.rds"))

# Read in tract data for county using tigris
#
tl_2020_county <- tracts(
  state = stateFIPS,
  county = substr(countyFIPS, 3, 5),
  year = 2020
)

# The process below is conducted to determine the appropriate projected coordinate
# system for both the roads and census tract data. Projected coordinate systems
# allow faster spatial analysis This faster computation
# has the drawback of producing a distortion of the features which can, 
# in this case, lead to a lengthening or shortening of road lenghts. Distortion
# can be minimized by selecting a projection that is specific to a given region.
# Here, we use Universal Travel Mercator (UTM) zones to project the data. For 
# more information, see: https://www.geographyrealm.com/universal-transverse-mercator/
#
# First, we determine in which UTM zone the county is in.  The formula is based 
# on the post linked below, and added here by Dennis Milechin
# https://gis.stackexchange.com/questions/209267/r-return-the-utm-zone-that-a-wgs84-point-belongs-to
#
# Get the bounding box of the county
#
county_bbox <- st_bbox(tl_2020_county)

# Determine the center longitude
#
long_center <- (county_bbox$xmax + county_bbox$xmin)/2

# Determine the UTM Zone for the longitude center
#
utm_zone <- floor((long_center+180)/6)+1

# Read in a CSV file that maps the zone number to EPSG Code
#
utm_zones_ref <- read.csv(paste0(indir, "utm_zone_epsgs.csv"))

# Extract the EPSG code
#
epsg_code <- utm_zones_ref[utm_zones_ref$index == utm_zone,]$epsg_code

# Transform both GIS data layers to UTM
#
tl_2020_county <- st_transform(tl_2020_county,epsg_code)
tigris_roads <- st_transform(tigris_roads, epsg_code)

# Subset column names
#
tl_2020_county <- tl_2020_county[c("GEOID", "geometry")]
tigris_roads <- tigris_roads[c("MTFCC", "geometry")]

# Apply the intersection
#
rd_tract_full_tr <- st_intersection(tl_2020_county, tigris_roads) 

# The intersection results in points being generated at intersection, which is not
# relevant for length calculations. The code below will remove the point data
#
rd_tract_full_tr <- rd_tract_full_tr[st_geometry_type(rd_tract_full_tr$geometry) %in% c("LINESTRING", "MULTILINESTRING"),]

# Calculate length after cropping to polygon fit
#
rd_tract_full_tr$len_m <- st_length(rd_tract_full_tr$geometry) 

# Set as data.table
#
rd_tract_full_tr <- setDT(rd_tract_full_tr)

# Summation of length measures 
#
rd_tract_sum <- rd_tract_full_tr[, .(length = (sum(len_m))), by=.(GEOID, MTFCC)]

# Estimate of total length by class
# See page 130-131 for definition https://assets.nhgis.org/original-data/gis/TGRSHP2020_TechDoc.pdf
#
rd_tract_primary <- rd_tract_sum[MTFCC=="S1100", .(GEOID=GEOID, prim_len = length)]
rd_tract_secondary <- rd_tract_sum[MTFCC=="S1200", .(GEOID=GEOID, sec_len = length)]
rd_tract_local <- rd_tract_sum[MTFCC=="S1400", .(GEOID=GEOID, loc_len = length)]
rd_tract_vehic <- rd_tract_sum[MTFCC=="S1500", .(GEOID=GEOID, vehic_len = length)]
rd_tract_ramp <- rd_tract_sum[MTFCC=="S1630", .(GEOID=GEOID, ramp_len = length)]

# Other list includes: service drive usually along limited access highway
# walkway/pedestrian trail, stairway, alley, private road for service vehicles
# internal census bureau use, parking lot road, bike path/trail, bridle path
# See data dictionary listed above for more details
#
other_list <- c("S1640", "S1710", "S1720", "S1730", "S1740",
                "S1750", "S1780", "S1820", "S1830")

rd_tract_other_filt <- rd_tract_sum[MTFCC %in% other_list]
rd_tract_other <- rd_tract_other_filt[, .(other_len = sum(length)), by =  GEOID]

# Calculate total road length
#
rd_tract_total <- rd_tract_sum[, .(total_len = sum(length)), by =  GEOID]

# Rejoin class level lengths to census tracts (now not buffered)
#
county_rdlen <- left_join(tl_2020_county, rd_tract_primary, by="GEOID")
county_rdlen <- left_join(county_rdlen, rd_tract_secondary, by="GEOID")
county_rdlen <- left_join(county_rdlen, rd_tract_local, by="GEOID")
county_rdlen <- left_join(county_rdlen, rd_tract_vehic, by="GEOID")
county_rdlen <- left_join(county_rdlen, rd_tract_ramp, by="GEOID")
county_rdlen <- left_join(county_rdlen, rd_tract_other, by="GEOID")
county_rdlen <- left_join(county_rdlen, rd_tract_total, by="GEOID")

# Save joined dataset
#
saveRDS(county_rdlen, paste0(roads_outdir, "tigris_roadlen_by_MTFCC_", countyFIPS, "_2020.rds"))

