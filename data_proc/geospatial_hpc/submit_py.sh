#!/bin/bash 
#SBATCH --job-name=rast_reserv
#SBATCH --time=36:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=16G
#SBATCH --output=rast_reserv.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=$efluet@stanford.edu

# whole thing runs for t=216 in 42hrs
# sdev -m 16GB -t 2:00:00

# /-------------------------------------------------------------#
#/    Load modules for lacustrine - uses rioxarray
#     3.9.0 - does not have latest geopandas

ml python/3.9.0
ml load physics
ml load sqlite/3.37.2
ml load proj/9.1.0
ml load  gdal/3.4.1 # gdal/3.5.2
ml load geos
ml system
ml load devel
ml py-numpy # /1.20.3_py39
ml py-scikit-image/0.19.3_py39
ml python/3.9.0

# set wd
cd /home/groups/robertj2/reserv_fish

# python3   # Start python


# /---------------------------------------------------------------#
#/  Submit python script

python3 -u scripts/rasterize_reservoirs.py
