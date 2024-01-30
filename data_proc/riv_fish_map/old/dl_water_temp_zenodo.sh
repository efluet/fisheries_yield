#!/bin/bash 
#SBATCH --job-name=dl_wat_temp
#SBATCH --time=2:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G
#SBATCH --output=dl_wat_temp.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=$efluet@stanford.edu


# Change directory
cd /home/groups/robertj2

# Download the file from zenodo
# https://zenodo.org/record/<record number>/files/<filename>?download=1
wget https://zenodo.org/record/3337659/files/waterTemperature_monthly_1981-2014.nc
