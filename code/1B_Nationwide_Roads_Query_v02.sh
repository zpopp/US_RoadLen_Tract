#!/bin/bash -l

#$ -N roads_nat_t ## Name the job
#$ -j y         ## Merge error & output files
#$ -pe omp 16

module load R/4.3.1
Rscript code_dir/1_Nationwide_Roads_Query_v02.R $SGE_TASK_ID

## In Terminal, cd to the directory in which this bash script is located. 
## qsub -P project -t 1-51 1B_Nationwide_Roads_Query_v02.sh
##
## This bash script will run an array of jobs for each index 1 to 51. This index
## will be read into the R scripts to specify specific U.S. States. Alternatively,
## the processing could be run for each state.
