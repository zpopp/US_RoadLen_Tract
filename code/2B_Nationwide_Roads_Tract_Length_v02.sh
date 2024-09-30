#!/bin/bash -l

#$ -N roads_nat_t ## Name the job
#$ -j y         ## Merge error & output files
#$ -pe omp 8

module load R/4.3.1
Rscript 2A_Nationwide_Roads_Tract_Length_v02.R $SGE_TASK_ID

## In Terminal, cd to the directory in which this bash script is located. 
## qsub -P project -t 1-3143 2B_Nationwide_Roads_Tract_Length_v02.sh
##
## This bash script will run as an array with an index for every US county. The index will be
## read in by the R script 2 to identify the county to process. By processing only by county,
## we reduce the computation time needed. Alternatively, a series of counties or states could
## be specified directly in your R script.
