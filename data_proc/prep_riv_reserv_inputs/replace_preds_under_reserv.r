

# /----------------------------------------------------------------------------#
#/  Get predictors to fix                                           -----------

# Get mamax area % and km2
mamax_perc <- rast('../data/giemsd15/giems_d15_v10_mamax_1km.tif')/4
mamax_km2 <- mamax_perc * cellSize(mamax_perc, mask=TRUE)

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
#/  Make reservoir buffer mask                                      -----------

# Mask of reservoirs at 1km
grand_mask_1km <- rast('../data/fromGG/FishYieldsExport/grandid_mask_1km.tif')

# Get reservoir polygons with attributes
grand_poly <- st_read('../data/fromGG/FishYieldsExport/grand_poly.shp')


# Make buffer around reservoirs; Convert from km to arc degree 
grand_poly_buff <- st_buffer(grand_poly, grand_poly$RES_LEN_KM / 120 / 10)

# Make circular buffer around reservoirs
grand_poly_buff <- 
    grand_poly_buff %>% filter(
        st_geometry_type(.)
        %in% c("POLYGON")) # "MULTIPOLYGON"


# Convert buffer to raster


# convert pop to raster; to use as template to the fasterize function
pop_r <- raster(pop)

grand_poly_buff_r <- fasterize(sf=grand_poly_buff, 
                               raster=pop_r, # use pop as template raster
                               field = 'GRAND_ID', 
                               fun="first") %>% 
                      rast()


# Mask rasterized buffer by the river pixels
grand_poly_buff_r_m <- mask(grand_poly_buff_r, q_cls, inverse=FALSE, maskvalues=NA)
# Exclude area within reservoirs
grand_poly_buff_r_m <- mask(grand_poly_buff_r_m, grand_mask_1km, inverse=T, maskvalues=NA)

writeRaster(grand_poly_buff_r_m, '../output/results/grand_poly_buff_r_m.tif', overwrite=T)



# Get median population and mamax over this mask
pop_pergrand_df        <- terra::zonal(pop,        grand_poly_buff_r_m, fun=mean)
mamax_km2_pergrand_df  <- terra::zonal(mamax_km2,  grand_poly_buff_r_m, fun=mean)
mamax_perc_pergrand_df <- terra::zonal(mamax_perc, grand_poly_buff_r_m, fun=mean)



# /----------------------------------------------------------------------------#
#/  REPLACE POP VALUES INSIDE RESERVOIRS

# Assign median value
buffer_pop_val <- subst(grand_poly_buff_r,
                        from=pop_pergrand_df$layer,
                        to  =pop_pergrand_df$gpw_v4_population_count_rev11_2015_30_sec)

# Mask by rivers
buffer_pop_val_m <- mask(buffer_pop_val,   q_cls, inverse=FALSE, maskvalues=NA)

# Mask by reservoir
buffer_pop_val_m <- mask(buffer_pop_val_m, grand_mask_1km, inverse=FALSE, maskvalues=NA)

# Replace values
pop_replaced <- mosaic(pop, buffer_pop_val_m, fun="max")

# Save to file
writeRaster(pop_replaced, '../output/results/pop_1km_replaced.tif', overwrite=T)


# /----------------------------------------------------------------------------#
#/  REPLACE MAMAX KM2  VALUES INSIDE RESERVOIRS


buffer_mamax_km2_val <- subst(grand_poly_buff_r,
                            from=mamax_km2_pergrand_df$layer,
                            to  =mamax_km2_pergrand_df$Count)

# Mask by rivers
buffer_mamax_km2_val_m <- mask(buffer_mamax_km2_val,   q_cls, inverse=FALSE, maskvalues=NA)

# Mask by reservoir
buffer_mamax_km2_val_m <- mask(buffer_mamax_km2_val_m, grand_mask_1km, inverse=FALSE, maskvalues=NA)

# Replace values
mamax_km2_replaced <- mosaic(mamax_km2, buffer_mamax_km2_val_m, fun="max")

# Save to file
writeRaster(mamax_km2_replaced, '../output/results/mamax_km2_1km_replaced.tif', overwrite=T)



# /----------------------------------------------------------------------------#
#/  REPLACE MAMAX PERC  VALUES INSIDE RESERVOIRS


buffer_mamax_perc_val <- subst(grand_poly_buff_r,
                                from=mamax_perc_pergrand_df$layer,
                                to  =mamax_perc_pergrand_df$Count)

# Mask by rivers
buffer_mamax_perc_val_m <- mask(buffer_mamax_perc_val,   q_cls, inverse=FALSE, maskvalues=NA)

# Mask by reservoir
buffer_mamax_perc_val_m <- mask(buffer_mamax_perc_val_m, grand_mask_1km, inverse=FALSE, maskvalues=NA)

mamax_perc_replaced <- mosaic(mamax_perc, buffer_mamax_perc_val_m, fun="max")

writeRaster(mamax_perc_replaced, '../output/results/mamax_perc_1km_replaced.tif', overwrite=T)

