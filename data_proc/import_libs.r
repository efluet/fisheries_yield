

### import libraries -----------------------------------------------------------
library(dplyr)
library(tidyr)
library(countrycode)
library(rgdal)
library(rgeos)
library(raster)
library(ggplot2)
library(ggrepel)
library(sf)
library(terra)
library(fasterize)
library(scales)
library(countrycode)
library(ggnewscale)
library(colorspace)
library(RColorBrewer)

# /----------------------------------------------------------------------------#
#/   Set options
options("scipen"=100, digits = 6, stringsAsFactors = FALSE)

rasterOptions(chunksize=2e+07)



# Function summing raster
sum_raster <- function(raster){sum(cellStats(raster, stat="sum"))}

# Common geographic extent of analysis
com_ext <- ext(-180, 180, -56, 84)

com_extent <- extent(-180, 180, -56, 84)



# /----------------------------------------------------------------------------#
#/  Function that converts raster to df
WGSraster2dfROBIN <- function(r){
  library(terra)
  # crs(r) <- CRS('+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0')
  # r <- terra::rast(r)
  r_robin <- terra::project(r, '+proj=robin', method='near')#, mask=T)
  r_robin_df <- as.data.frame(r_robin, xy=TRUE, na.rm=TRUE) 
  return(r_robin_df) }
