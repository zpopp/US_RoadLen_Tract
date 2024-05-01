#!/bin/bash -l

#$ -N roads_nat_t ## Name the job
#$ -j y         ## Merge error & output files
#$ -pe omp 8

##
## See https://www.bu.edu/tech/support/research/system-usage/running-jobs/batch-script-examples/#MEMORY
##     for details on how to request the appropriate amount of RAM for your job
## Use #$ -l mem_per_core=8G for 32-64 GB.

module load R/4.3.1
Rscript /projectnb/anchor/Data_Hub/Data_Requests/ZachP/Nationwide_TIGRIS/Code/2_Nationwide_Roads_Tract_Length_v02.R $SGE_TASK_ID

## In Terminal, cd to the directory in which this bash script is located. 
## qsub -P climlab -t 1-3143 2B_Nationwide_Roads_Tract_Length_v02.sh
##
## Alternatively, you can create a single "submit" script that includes the 
## bash syntax for every single day needed in your dates of interest