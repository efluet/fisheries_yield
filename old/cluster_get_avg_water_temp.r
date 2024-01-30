

# /-------------------------------------------------
#/    Load modules
ml R             # Load R (default 3.5)
ml load physics  # load category: for gdal and geos
ml load proj     # needs to be loaded before geos
ml load gdal/2.2.1
ml load geos
ml load netcdf

ml system
ml imagemagick   # for animated GIF




# In R now
# library(netcdf4)
library(ncdf4)
library(raster)


# filename
f <- 'waterTemperature_monthly_1981-2014.nc'

# open & get the variable name
wt <- nc_open(f)
print(wt)

# read as raster stack
wt_stack <- brick(f, var='waterTemp')

# Filter to years
#wt_stack <- wt_stack[[(1997-1981)*12+12 : (2014-1981)*12+12]]
wt_stack <- wt_stack[[204 : 408]]

# 192 - 296

# Get mean of raster stack
wt_avg <- calc(wt_stack, fun=mean, na.rm=T)

# Save raster
writeRaster(wt_avg, 
            filename='./waterTemperature_average_1998_2014.tif', 
            format="GTiff", overwrite=TRUE)

