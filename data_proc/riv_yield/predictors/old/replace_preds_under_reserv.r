

# /----------------------------------------------------------------------------#
#/  Get predictors to fix                                           -----------

# Get mamax area % and km2
# mamax_perc <- rast('../data/giemsd15/giems_d15_v10_mamax_1km.tif')/4
# mamax_km2 <- mamax_perc * terra::cellSize(mamax_perc, mask=TRUE)


# Get mamax area % and km2
glwdv2_areakm2_1km_nopeat<- rast('../output/results/riv_yield_predictors/grids/aggregated/glwdv2_areakm2_1km_nopeat.tif')
glwdv2_perc_1km_nopeat <- rast('../output/results/riv_yield_predictors/grids/aggregated/glwdv2_perc_1km_nopeat.tif')


# Get population
pop <- rast('../data/pop/gpw_v4_population_count_rev11_2015_30_sec.tif')
pop <- crop(pop, ext(mamax_perc))


# /----------------------------------------------------------------------------#
#/ Make river mask                                    -----------

# Get discharge
q_cls <- rast('../data/discharge/dis_dls/q_cls_1km.tif')

# Convert to binary mask
q_cls[q_cls <  1] <- NA
q_cls[q_cls >= 1] <- 1

# /----------------------------------------------------------------------------#
#/  Make reservoir buffer mask                                       -----------

# Mask of reservoirs at 1km
# grand_mask_1km <- rast('../data/fromGG/FishYieldsExport/grandid_mask_1km.tif')
gdw_1km_ids <- rast('../output/results/res_yield_gdw/GDW_reservoirs_v0_2_GDWIDs.tif')
gdw_1km_ids <- extend(gdw_1km_ids, com_ext, snap="near")

# Get reservoir polygons with attributes
# grand_poly <- st_read('../data/fromGG/FishYieldsExport/grand_poly.shp')
res_poly <- st_read('../data/GDW/GDW_v0_2_beta/GDW_v0_2_beta_shp/GDW_reservoirs_v0_2.shp')

# Make buffer around reservoirs; Convert from km to arc degree 
res_buff_poly <- st_buffer(res_poly, res_poly$AREA_SKM / 10000)

# Make circular buffer around reservoirs
res_poly_buff <- 
  res_poly_buff %>% filter(
        st_geometry_type(.)
        %in% c("POLYGON")) 
        # "MULTIPOLYGON"


# /----------------------------------------------------------------------------#
#/  Convert reservoir buffer to raster

# convert polygon buffer to raster; to use as template to the fasterize function
res_poly_buff_r <- fasterize(sf=res_poly_buff, 
                               raster=raster(pop), # use pop as template raster
                               field = 'GRAND_ID', 
                               fun="first") %>% 
                      rast()


# Mask rasterized polygon buffer by the river pixels; to remove the rivers from averaging suface
res_poly_buff_r_m <- mask(res_poly_buff_r, q_cls, inverse=FALSE, maskvalues=NA)

# Exclude area within reservoirs
res_poly_buff_r_m <- mask(res_poly_buff_r_m, gdw_1km_ids, inverse=T, maskvalues=NA)

# Save buffer to raster
writeRaster(res_poly_buff_r_m, '../output/results/res_yield_gdw/gdw_poly_buff_r_m.tif', overwrite=T)


# /----------------------------------------------------------------------------#
#/. Function imputing values


impute_inside_res <- function(var_rast, varname, res_r, res_buff_r_m){

  # Summarize per buffer; mean of value over buffer
  var_mean_perres_df        <- terra::zonal(var_rast, res_buff_r_m, fun=mean)

  # Assign median value
  var_val_overbuffer_r <- subst(res_buff_r,
                          from=var_mean_perres_df$layer,
                          to  =var_mean_perres_df[names(var_mean_perres_df)[2]]) #$gpw_v4_population_count_rev11_2015_30_sec)
  
  # Mask by rivers; to only keep over river channels
  buffer_val_m <- mask(var_val_overbuffer_r,   q_cls, inverse=FALSE, maskvalues=NA)
  
  # Mask by reservoir
  buffer_val_m <- mask(buffer_val_m, res_r, inverse=FALSE, maskvalues=NA)
  
  # Replace values
  var_rast_replaced <- mosaic(var_rast, buffer_val_m, fun="max")
  
  # Save to file
  writeRaster(var_rast_replaced, 
              paste0('../output/results/', varname, '_1km_replaced.tif', overwrite=T))
  
  
}


writeRaster(mamax_perc_replaced, '../output/results/mamax_perc_1km_replaced.tif', overwrite=T)

# 
# # Get median population and mamax over this mask
# pop_pergrand_df        <- terra::zonal(pop,        grand_poly_buff_r_m, fun=mean)
# mamax_km2_pergrand_df  <- terra::zonal(mamax_km2,  grand_poly_buff_r_m, fun=mean)
# mamax_perc_pergrand_df <- terra::zonal(mamax_perc, grand_poly_buff_r_m, fun=mean)
# 
# 
# 
# # /----------------------------------------------------------------------------#
# #/  REPLACE POP VALUES INSIDE RESERVOIRS
# 
# 
# 
# 
# # Assign median value
# buffer_pop_val <- subst(grand_poly_buff_r,
#                         from=pop_pergrand_df$layer,
#                         to  =pop_pergrand_df$gpw_v4_population_count_rev11_2015_30_sec)
# 
# # Mask by rivers
# buffer_pop_val_m <- mask(buffer_pop_val,   q_cls, inverse=FALSE, maskvalues=NA)
# 
# # Mask by reservoir
# buffer_pop_val_m <- mask(buffer_pop_val_m, grand_mask_1km, inverse=FALSE, maskvalues=NA)
# 
# # Replace values
# pop_replaced <- mosaic(pop, buffer_pop_val_m, fun="max")
# 
# # Save to file
# writeRaster(pop_replaced, '../output/results/pop_1km_replaced.tif', overwrite=T)
# 
# 
# # /----------------------------------------------------------------------------#
# #/  REPLACE MAMAX KM2  VALUES INSIDE RESERVOIRS
# 
# 
# buffer_mamax_km2_val <- subst(grand_poly_buff_r,
#                             from=mamax_km2_pergrand_df$layer,
#                             to  =mamax_km2_pergrand_df$Count)
# 
# # Mask by rivers
# buffer_mamax_km2_val_m <- mask(buffer_mamax_km2_val,   q_cls, inverse=FALSE, maskvalues=NA)
# 
# # Mask by reservoir
# buffer_mamax_km2_val_m <- mask(buffer_mamax_km2_val_m, grand_mask_1km, inverse=FALSE, maskvalues=NA)
# 
# # Replace values
# mamax_km2_replaced <- mosaic(mamax_km2, buffer_mamax_km2_val_m, fun="max")
# 
# # Save to file
# writeRaster(mamax_km2_replaced, '../output/results/mamax_km2_1km_replaced.tif', overwrite=T)
# 
# 
# 
# # /----------------------------------------------------------------------------#
# #/  REPLACE MAMAX PERC  VALUES INSIDE RESERVOIRS
# 
# 
# buffer_mamax_perc_val <- subst(grand_poly_buff_r,
#                                 from=mamax_perc_pergrand_df$layer,
#                                 to  =mamax_perc_pergrand_df$Count)
# 
# # Mask by rivers
# buffer_mamax_perc_val_m <- mask(buffer_mamax_perc_val,   q_cls, inverse=FALSE, maskvalues=NA)
# 
# # Mask by reservoir
# buffer_mamax_perc_val_m <- mask(buffer_mamax_perc_val_m, grand_mask_1km, inverse=FALSE, maskvalues=NA)
# 
# mamax_perc_replaced <- mosaic(mamax_perc, buffer_mamax_perc_val_m, fun="max")
# 
# writeRaster(mamax_perc_replaced, '../output/results/mamax_perc_1km_replaced.tif', overwrite=T)

