#!/bin/bash -l

#$ -N roads_join ## Name the job
#$ -j y         ## Merge error & output files
#$ -pe omp 16

module load R/4.3.1
Rscript 3A_Nationwide_Roads_Join_v01.R

## In Terminal, cd to the directory in which this bash script is located. 
## qsub -P climlab 3B_Nationwide_Roads_Join_v01.sh
##
## This bash script will run the aggregation of county files. 
