
# GRanD projects (shapefiles and raster):
# On the top of my head, I do not remember exactly why some projects were unselected, probably when they a combination of: 
# a) had no reservoir shape; 
# b) had no volume attribute; 
# c) were lake controlled, or 
# d) when there was no FAO yield data available (quite a few countries). You can use the field INC in the shapefile ‘grand_dams’ to identify the ones that were used (1) versus the one’s not used (0) for producing the DOR raster.


# grand_dams: contains the grand dams used for calculating losses and gain (use field INC to distinguish projects that were used)
# grand_poly: GRanD polygons. Contains the attribute ‘res_len_km’ which was my best attempt to calculate the length of a reservoir in kilometers. 
#             This was quite tricky because of the irregular shape of reservoirs. 
#             The length of the reservoir was then used to calculate losses downstream for three different tiers: 
#                     i) 2 times length of reservoir; 
#                     ii) 5 times length of reservoir; and 
#                     iii) all the way down to ocean or sink. See layers that start with ‘distance_’ below.
# grand_poly_raster: GRanD polygons converted to 500m raster, then vectorized (see also res_mask1.tif). 
#                     This also includes the field ‘Trop1Temp2’ which indicates if it was a tropical or temperate zone reservoir.
# res_mask_percent1.tif: reservoir footprint (500m pixels; res_mask1.tif) with values representing the proportion of each pixels covered by reservoir (0 = 0%; 1 = 100%). 
#                        This was used to calculate losses and gains more precisely. 
#                        For example, if – in reality - a 500m reservoir pixel was only covered by a reservoir partially, 
#                        the losses and gains were also only partially counted. 
#                        It was produced by first converting the reservoir vectors to a 50m grid, then upscaling to 500m, 
#                        while counting the number of 50mpixels that were contained in each 500m pixel.

# From draft: We estimate that catch from large tropical reservoirs totals 192,377 T/yr globally, while temperate reservoirs yield just 118,512 T/yr 

# Etienne's updated total reserv: 204,583
# Etienne's updated total reserv: 354,617


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
#/    GET GRAND MASK WITH IDs 

# Get reservoir percent ;  'res_mask.tif' is alternative without percentage covereage
res_mask_percent <- rast('../data/fromGG/FishYieldsExport/res_mask_percent1_1km.tif')

grand_mask_1km <- rast('../data/fromGG/FishYieldsExport/grandid_mask_1km.tif')

# /----------------------------------------------------------------------------#
#/    Scale riv fish per percentage coverage; then aggregate to get GRaND IDs

# Multiply riverine catch with percentage coverage of each reservoir of 500m pixel (0-1)
riv_catch_onres <- riv_catch * res_mask_percent


# Sum grid per reservoir
riv_perreserv <- as.data.frame(zonal(riv_catch_onres, grand_mask_1km, 'sum', na.rm=T)) %>%
                 rename(GRAND_ID = 1, riv_catch = 2) 



# /----------------------------------------------------------------------------#
#/    Attach riv and reserv yield to points for summarizing per basin and mapping

# Start with 6862 grand points 
# Filtering reservoirs by LAKE_CTRL or LAKE_CONTR reduces number to 6757

# Get grand points and polys
grand_poly <- vect('../data/fromGG/FishYieldsExport/grand_poly.shp')
grand_pts  <- vect('../data/fromGG/FishYieldsExport/grand_dams.shp')


# Attach other attributes
riv_perreserv_df <- left_join(riv_perreserv, data.frame(grand_poly), by='GRAND_ID')

# Attach the attributes to points
grand_pts_dat <- merge(grand_pts, riv_perreserv, by='GRAND_ID', all.x=FALSE)


# /----------------------------------------------------------------------------#
#/    Save to sums to table
write.csv(riv_perreserv_df, paste0('../output/results/catch_losses/riv_catch_perreserv_', m, '_', c, '_rep.csv'),
          row.names = FALSE)


writeVector(grand_pts_dat,  paste0('../output/results/catch_losses/riv_catch_perreserv_pts_', m, '_', c, '_rep.shp'), overwrite=T)



