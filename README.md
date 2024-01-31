# US Sum Road Lenth Calculation by Census Tract

# Project Overview:
This repository includes code for the derivation sum road length at the census tract-level using TIGER/Line roads data. Total road length is measured, as well as road length within each of several MTFCC classes.

# Usage:
The three code files include processing to 1) Download roads data, 2) Calculate sum road length within census tracts by county, 3) Combine road length measures from multiple counties into a nationwide dataset.

# Data Sources: 
Accessed 11 Jan. 2024
**TIGER/Line Roads Data Description**: 	https://assets.nhgis.org/original-data/gis/TGRSHP2020_TechDoc.pdf
- See page 130 for road class definitions
- See page 152 for additional variable information
For more information about querying roads data through the tigris package, see: https://rdrr.io/cran/tigris/man/roads.html
	
# Workflow: 
The R code provided includes steps for 
  1) Downloading TIGER/Line shapefiles for a county or series of counties using the R tigris package.
  2) Using the sf package to cut road shapes to fit into the census tracts where they fall, then calculating the length of the road within each tract.
  3) Adding the road length by class wihtin each tract.
  4) Combining data from multiple counties in separate R files into one nationwide shapefile.

# Dependencies: 
The processing in this code to produce the Harvard Dataverse file was done using bash scripting. More information about bash scripting can be found here: . This allows for processing that would take a large amount of time and memory to be cut into smaller pieces. In this case, each county is processed separately. The biggest 'roadblock' in processing these data in an efficient way is the st_intersection (from library sf) function which cuts road shapes to the census tract. For a single large county, this process can take over 12 hours. 

# Contact Information: 
For correspondence about this processing, contact Zach Popp (zpopp@bu.edu)

