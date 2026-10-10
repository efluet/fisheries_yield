# DOR raster (dor1.tif):
# Regarding the DOR raster, there is no official global raster that one can use. I created my own, which was based on a selections of projects from GRanD, 
# my flow accumulation and Bernhards discharge data from 2017. Not all GRanD projects were used in producing the DOR raster that I sent.
# see my further explanation below.

# Regarding the processing, I found a couple of “rules” in my code: 
# a) we decided that a DOR of below 2% should not reduce fish yield, it will be set to zero; 
# b) similarly a DOR at or above 100 will be set to 100%. 
# The units of the DOR raster are fractional DOR value, so if you wanted the percentages, you need to multiply the values by 100.


# Distance downstream (shapefiles and rasters)
# distance_2_1 (shapefile) and distance_2 (raster): points and raster representing the (centroid of) pixels downstream of reservoirs 
#                                                   until 2 times the length of reservoir.
# distance_5_1 (shapefile) and distance_5 (raster): points and raster representing the (centroid of) pixels downstream of reservoirs 
#                                                   until 5 times the length of reservoir.
# distance_all_1 (shapefile) and distance_all (raster): points and raster representing the (centroid of) pixels downstream of reservoirs 
#                                                       until ocean or sink.

#-- Aggregate distance DOR rasters to 1km;  using max or mean?
#   Apply the floor/ceiling 
#   Multiply the distance DOR to the riverine cathc


# /----------------------------------------------------------------------------#
#/   Scale riverine catch by fractional reservoir cover

m='lm2c'
c='catch.c2'
# Read raster
riv_catch <- rast(paste0('../output/results/distrib_catch/distrib_catch_', m, '_', c, '_1km_2023_rep.tif')) * 10^6
# Replace Inf by 0
riv_catch[!is.finite(riv_catch)] <- 0

# Get total
global(riv_catch, sum, na.rm=T)


# /----------------------------------------------------------------------------#
#/   Loss from Regulation  (DOR)                                      ----------

# ranges between 0-1
dor           <- rast('../data/fromGG/FishYieldsExport/dor1_1km.tif')

# Mask values following Gunther's scheme
dor[dor < 0.02] <- 0
dor[dor > 1] <- 1
dor[dor==0] <- NA

dor_dist_all  <- rast('../data/fromGG/FishYieldsExport/distance_all_1km.tif')
dor_dist_5    <- rast('../data/fromGG/FishYieldsExport/distance_5_1km.tif')
dor_dist_2    <- rast('../data/fromGG/FishYieldsExport/distance_2_1km.tif')


# /----------------------------------------------------------------------------#
#/    Apply the DOR grids to river catch

riv_catch_dor <- riv_catch * dor

riv_catch_dist_all <- riv_catch * dor_dist_all
riv_catch_dist_5  <- riv_catch * dor_dist_5
riv_catch_dist_2  <- riv_catch * dor_dist_2


# /----------------------------------------------------------------------------#
#/    Mask DOR losses by RESERVOIR FOOTPRINTS (AND LAKES TOO???)

grand_mask_1km <- rast('../data/fromGG/FishYieldsExport/grandid_mask_1km.tif')

riv_catch_dor <- mask(riv_catch_dor, grand_mask_1km, inverse=TRUE)


# /----------------------------------------------------------------------------#
#/    Save to file
writeRaster(riv_catch_dor,     paste0('../output/results/catch_losses/riv_catch_dor_', m, '_', c, '_rep.tif'), overwrite=TRUE)
writeRaster(riv_catch_dist_all, paste0('../output/results/catch_losses/riv_catch_dist_all_', m, '_', c, '_rep.tif'), overwrite=TRUE)
writeRaster(riv_catch_dist_5,  paste0('../output/results/catch_losses/riv_catch_dist_5_', m, '_', c, '_rep.tif'), overwrite=TRUE)
writeRaster(riv_catch_dist_2,  paste0('../output/results/catch_losses/riv_catch_dist_2_', m, '_', c, '_rep.tif'), overwrite=TRUE)







# # Sum grid per country
# riv_perreserv <- 
#   as.data.frame(zonal(riv_catch_onres, grand_mask_1km, 'sum', na.rm=T)) %>%
#   rename(GRAND_ID = 1, riv_catch = 2) 
# 
# 
# # Join GRaND attributes
# grand_poly <- vect('../data/fromGG/FishYieldsExport/grand_poly.shp')
# grand_poly <- data.frame(grand_poly)
# 
# 
# # Attach other attributes
# riv_perreserv <- left_join(riv_perreserv, grand_poly, by='GRAND_ID')
# 
