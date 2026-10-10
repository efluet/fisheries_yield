

# /----------------------------------------------------------------------------#
#/  Get predictors to fix                                           -----------

# Get wetlands area % and km2
glwdv2_areakm2_1km_nopeat<- rast('../output/results/riv_yield_predictors/grids/aggregated/glwdv2_areakm2_1km_nopeat.tif')
glwdv2_perc_1km_nopeat <- rast('../output/results/riv_yield_predictors/grids/aggregated/glwdv2_perc_1km_nopeat.tif')

# Get population
pop <- rast('../data/pop/gpw_v4_population_count_rev11_2015_30_sec.tif')
pop <- crop(pop, ext(glwdv2_perc_1km_nopeat))


# /----------------------------------------------------------------------------#
#/ Make river mask                                    -----------

# Get discharge
q_cms <- rast('../data/discharge/dis_dls/q_cms_1km.tif')

# Convert to binary mask
q_cms[q_cms <  1] <- NA
q_cms[q_cms >= 1] <- 1
# q_cms[q_cms <  0.1] <- NA
# q_cms[q_cms >= 0.1] <- 1


# /----------------------------------------------------------------------------#
#/  Make reservoir buffer mask                                       -----------

# Mask of reservoirs at 1km
gdw_1km_ids <- rast('../output/results/res_yield_gdw/GDW_reservoirs_v0_2_GDWIDs.tif')
gdw_1km_ids_ext <- align(ext(glwdv2_perc_1km_nopeat), gdw_1km_ids, snap="near")
gdw_1km_ids <- extend(gdw_1km_ids, gdw_1km_ids_ext, snap="near")
gdw_1km_ids[gdw_1km_ids==0] <- NA

# Get reservoir polygons with attributes
res_poly <- st_read('../data/GDW/GDW_v0_2_beta/GDW_v0_2_beta_shp/GDW_reservoirs_v0_2.shp') %>% 
  filter(AREA_SKM >= 0.1,
         is.na(LAKE_CTRL),
         is.na(TIMELINE) | TIMELINE == 'Modified')



# Set buffer distance around reservoirs; Convert from km to arc degree 
buf_dist <- sqrt(res_poly$AREA_SKM) / 100   # Calculate distance relative to size
buf_dist[buf_dist > 0.1] <- 0.1  #  Set ceiling of buffer
buf_dist[buf_dist < 0.01] <- 0.01  # Set minimum buffer; a bit over one pixel == 0.00833333
# buf_dist[buf_dist < 0.00833333] <- 

# Create buffer
res_buff_poly <- st_buffer(res_poly, buf_dist)

# Filter buffers to single part polygons
res_buff_poly <- 
  res_buff_poly %>% filter(
        st_geometry_type(.)
        %in% c("POLYGON")) 
        # "MULTIPOLYGON"


# /----------------------------------------------------------------------------#
#/  Convert reservoir buffer to raster

# convert polygon buffer to raster; to use as template to the fasterize function
res_buff_r <- fasterize(sf=res_buff_poly, 
                               raster=raster(pop), # use pop as template raster
                               field = 'GDW_ID', 
                               fun="first") %>% 
                      rast()


### NOTE: THESE TWO INTERMEDIARY LAYERS NEED TO BE NAMES DIFFERENTLY
# res_buff_r_m2 <- res_buff_r_m1  * q_cms

# Exclude river pixels from the rasterized buffer; to remove the rivers from averaging surface
res_buff_r_m1 <- mask(res_buff_r, q_cms, inverse=F, maskvalues=NA)

# Exclude area within reservoirs, to keep only area in buffer
# inverse	= If TRUE, areas on mask that are _not_ the maskvalue are masked
res_buff_r_m2 <- mask(res_buff_r_m1, gdw_1km_ids, inverse=T, maskvalues=NA)

# Save buffer to raster
writeRaster(res_buff_r_m2, 
            '../output/results/riv_yield_predictors/grids/buffer/gdw_buff_r_m_newbuf_wmin_2024.tif', 
            overwrite=T)



# /----------------------------------------------------------------------------#
#/. Function imputing values
#. #NOTE: Running the function as a whole makes R session crash

# res_buff_r_m2 <- rast('../output/results/res_yield_gdw/gdw_buff_r_m_newbuf_wmin.tif')

# impute_inside_res <- function(var_rast, varname){
var_rast <- pop
varname <- 'pop'
res_r <<- gdw_1km_ids
res_buff_r <<- res_buff_r
res_buff_r_m <<- res_buff_r_m2

# Summarize per buffer; mean of value over buffer
var_mean_perres_df        <- terra::zonal(var_rast, res_buff_r_m, fun=mean)

# Assign mean value 
var_val_overbuffer_r <- subst(res_buff_r,
                        from=var_mean_perres_df$layer,
                        to  =var_mean_perres_df[names(var_mean_perres_df)[2]])

# Mask by rivers; to only keep over river channels
buffer_val_m1 <- mask(var_val_overbuffer_r,   q_cms, inverse=FALSE, maskvalues=NA)

# Mask by reservoir
buffer_val_m2 <- mask(buffer_val_m1, res_r, inverse=FALSE, maskvalues=NA)

# Replace values with higher infilled ones
var_rast_replaced <- mosaic(var_rast, buffer_val_m2, fun="max")

# Save to file
writeRaster(var_rast_replaced, 
            paste0('../output/results/riv_yield_predictors/grids/replaced/', varname, '_1km_replaced2024.tif'), 
            overwrite=T)


# }
##################################
# impute_inside_res <- function(var_rast, varname){
var_rast <- glwdv2_perc_1km_nopeat
varname <- 'glwdv2_perc_1km_nopeat'
res_r <<- gdw_1km_ids
res_buff_r <<- res_buff_r
res_buff_r_m <<- res_buff_r_m2

# Summarize per buffer; mean of value over buffer
var_mean_perres_df        <- terra::zonal(var_rast, res_buff_r_m, fun=mean)

# Assign mean value
var_val_overbuffer_r <- subst(res_buff_r,
                              from=var_mean_perres_df$layer,
                              to  =var_mean_perres_df[names(var_mean_perres_df)[2]])

# Mask by rivers; to only keep over river channels
buffer_val_m1 <- mask(var_val_overbuffer_r,   q_cms, inverse=FALSE, maskvalues=NA)

# Mask by reservoir
buffer_val_m2 <- mask(buffer_val_m1, res_r, inverse=FALSE, maskvalues=NA)

# Replace values with higher infilled ones
var_rast_replaced <- mosaic(var_rast, buffer_val_m2, fun="max")

# Save to file
writeRaster(var_rast_replaced, 
            paste0('../output/results/riv_yield_predictors/grids/replaced/', varname, '_1km_replaced2024.tif'), overwrite=T)




# pop_replaced <- impute_inside_res(pop, 'pop')# , gdw_1km_ids, res_buff_r, res_poly_buff_r_m)
# glwdv2_perc_replaced <- impute_inside_res(glwdv2_perc_1km_nopeat, 'glwdv2_perc_1km_nopeat')#, gdw_1km_ids, res_poly_buff_r_m)
# glwdv2_areakm2_replaced <- impute_inside_res(glwdv2_areakm2_1km_nopeat, 'glwdv2_areakm2_1km_nopeat')#, gdw_1km_ids, res_poly_buff_r_m)
# 
# 
# writeRaster(pop_replaced, '../output/results/pop_1km_replaced.tif', overwrite=T)
# writeRaster(mamax_perc_replaced, '../output/results/glwdv2_perc_1km_replaced.tif', overwrite=T)
# writeRaster(glwdv2_areakm2_replaced, '../output/results/glwdv2_areakm2_1km_replaced.tif', overwrite=T)


# # Get median population and mamax over this mask
# pop_pergrand_df        <- terra::zonal(pop,        grand_poly_buff_r_m, fun=mean)
# mamax_km2_pergrand_df  <- terra::zonal(mamax_km2,  grand_poly_buff_r_m, fun=mean)
# mamax_perc_pergrand_df <- terra::zonal(mamax_perc, grand_poly_buff_r_m, fun=mean)
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
# buffer_pop_val_m <- mask(buffer_pop_val,   q_cms, inverse=FALSE, maskvalues=NA)
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
# buffer_mamax_km2_val_m <- mask(buffer_mamax_km2_val,   q_cms, inverse=FALSE, maskvalues=NA)
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
# buffer_mamax_perc_val_m <- mask(buffer_mamax_perc_val,   q_cms, inverse=FALSE, maskvalues=NA)
# 
# # Mask by reservoir
# buffer_mamax_perc_val_m <- mask(buffer_mamax_perc_val_m, grand_mask_1km, inverse=FALSE, maskvalues=NA)
# 
# mamax_perc_replaced <- mosaic(mamax_perc, buffer_mamax_perc_val_m, fun="max")
# 
# writeRaster(mamax_perc_replaced, '../output/results/mamax_perc_1km_replaced.tif', overwrite=T)

