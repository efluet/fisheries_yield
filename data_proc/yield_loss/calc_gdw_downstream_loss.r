
# Get DOR computed from GDW dams; between 0-1 range
gdw_dor <- rast('../output/dor/gdw_dor_v8.tif')

# Get riverine catch in tons
catch_distrib_1km <- rast("../output/results/distrib_catch/distrib_catch_lm2c_catch.c2_1km_2023_rep.tif" ) * 10^6


# /---------------------------------------------------------------------------#
#/    Mask reservoir footprings from DOR losses to avoid counting 

# Prep the GDW mask
gdw_frac_1km <- rast('../output/gdw/GDW_frac_1km.tif')
# gdw_frac_1km <- extend(gdw_frac_1km, com_ext, snap="near")
gdw_frac_1km <- extend(gdw_frac_1km, gdw_dor, snap="near")
# ext(gdw_frac_1km) <- ext(com_ext)

# gdw_mask <- gdw_frac_1km
# gdw_mask[gdw_mask >= 0] <- 0
# gdw_mask[is.na(gdw_mask)] <- 1

# Make inverse fraction of reservoir; to partially mask fish outside footprint
# This primarily affects pixels immediately downstream of reservoir
gdw_frac_1km[is.na(gdw_frac_1km)] <- 0
non_gdw_frac <- 1 - gdw_frac_1km


# /---------------------------------------------------------------------------#
#/   Loop and test different DOR thresholds

# Make list of lower DOR threshold
# dor_thresh <- seq(0, 1, .1)
dor_thresh <- c(0, 0.02, 0.05, seq(0.1, .5, .1))
# dor_thresh <- c(0.2)

dor_thresh_df <- data.frame()

# loop through thresholds 
for (t in dor_thresh){
  
  print(t)
  
  # rename/temp layer
  gdw_dor_capped <- gdw_dor

  # Apply lower threshold
  gdw_dor_capped[gdw_dor_capped < t] <- NA

  # compute downstream riverine loss
  downstream_loss <- catch_distrib_1km * gdw_dor_capped * non_gdw_frac
  downstream_loss[downstream_loss==0] <- NA
  
  # Append sum to df
  dor_thresh_df <- bind_rows(dor_thresh_df,
                             data.frame(t, global(downstream_loss, sum, na.rm=T)))
  
  
  # /---------------------------------------------------------------------------#
  #/    Save raster for threshold of 2%
  if(t==0.02){
    print('saved')
    writeRaster(downstream_loss, 
                paste0('../output/results/catch_losses/gdw_dor_2p_loss.tif'), 
                overwrite=TRUE)}
  }


# /---------------------------------------------------------------------------#
#/   Save table of all thresholds

# Rename df columns
names(dor_thresh_df) <- c('thresh', 'dor_loss')
# Save df
write.csv(dor_thresh_df, '../output/dor/gdw_dor_thresholds.csv', row.names=F)





