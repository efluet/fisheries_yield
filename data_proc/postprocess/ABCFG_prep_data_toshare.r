# Prep outputs


share_dir <- '../output/results/data_toshare/'


# /----------------------------------------------------------------------------#
#/    A: Data table of fish yield for 66 training river basins, including predictors and predicted yield. 

basins_wpreds_df_wdistrib <- 
  read.csv('../output/results/riv_yield_distrib/basins_wpreds_df_wdistrib.csv') %>% 
  dplyr::select(-c(glwdv2_area_km2_nopeat, Pop, glwdv2_area_Mkm2_nopeat, 
                   logcatch, logpopdens, logq_km3yr, wetperc, lm_pred_yield, lwr, upr, ID,distrib_lwr,distrib_upr)) 


# Rename
names(basins_wpreds_df_wdistrib) <- 
  c("name", "longname", "area_Mkm2", "pop_M", "q_km3yr",
    "temp_degC", "glwdv2_perc_nopeat", "lit_catch_tonnesyr", "pop_dens", 
    "pred_catch_tonnesyr", "pred_catch_range_tonnesyr",
    "distrib_yield_tonnesyr","distrib_yield_range_tonnesyr")


# Reorder
basins_wpreds_df_wdistrib <- 
  basins_wpreds_df_wdistrib[,
  c("name", "longname", "area_Mkm2", "pop_M", "q_km3yr",
  "temp_degC", "glwdv2_perc_nopeat", "pop_dens", 
  "lit_catch_tonnesyr",
  "pred_catch_tonnesyr", "pred_catch_range_tonnesyr",
  "distrib_yield_tonnesyr","distrib_yield_range_tonnesyr")]


write.csv(basins_wpreds_df_wdistrib,
          '../output/results/data_toshare/A_training_river_basins.csv',
          row.names = F)


# /----------------------------------------------------------------------------#
#/  B: Data table of fish yield for 350 reservoirs (incl. coordinates), 
#   including predictors and predicted reservoir yield and uncertainty.


train_res <-
  # read.csv('../output/results/res_train_yield/cs_reserv_catch_2024_wpreds_v10.csv')
  st_read('../output/results/res_train_yield/cs_reserv_catch_2024_wpreds_v10.gpkg') %>% 
  st_drop_geometry() %>% 
  mutate(predCATCH_range_tonnesyr = predCATCH_tonnesyr_upr - predCATCH_tonnesyr_lwr) %>% 
  dplyr::select(-c(LAT_GROUP, log10AREA_km2, log10CATCH_tonnesyr, log10pop_buf, 
                   log10predCATCH_tonnesyr, predCATCH_tonnesyr_upr, predCATCH_tonnesyr_lwr))

glimpse(train_res)

write.csv(train_res,
          '../output/results/data_toshare/B_training_reservoirs.csv',
          row.names = F)



# /----------------------------------------------------------------------------#
#/    C: Data table of GDW 30k reservoirs, including predicted reservoir yield, river yield inside footprint, local losses and uncertainty, and local yield change. 


gdw_barriers_localloss <- 
  st_read(paste0('../output/results/yield_losses/localloss_gdw_barrier_', m, '_', c, '_rep_cap_2024_v10.gpkg')) %>% 
  # st_read('../output/results/res_yield_gdw/GDW_barriers_v0_2_resyield_102024.gpkg') %>% 
  st_drop_geometry() %>% 
  dplyr::select(-c(l10AREA, lg10pp_)) %>%
  rename(RES_NAME = RES_NAM,
         DAM_NAME = DAM_NAM,
         TIMELINE = TIMELIN,
         AREA_km2 = AREA_k2,
         predicted_reservoir_yield_tonnesyr = res_yield,
         predicted_reservoir_yield_range_tonnesyr = res_yield_range,
         river_yield_inreservoir_tonnesyr = riv_yield,
         river_yield_inreservoir_range_tonnesyr = riv_yield_range,
         localloss_tonnesyr = localloss,
         localloss_range_tonnesyr = localloss_range)


glimpse(gdw_barriers_localloss)

write.csv(gdw_barriers_localloss,
          '../output/results/data_toshare/C_predicted_GDW_reservoirs.csv',
          row.names = F)





# /----------------------------------------------------------------------------#
#/    E: Gridded 1km maps of globally distributed riverine yield and uncertainty.


catch_distrib <- 
  rast('../output/results/riv_yield_distrib/riv_yield_distrib_', m, '_', c, '_1km_2024_rep_cap_v10.tif') *10^6


catch_distrib_range <- 
  rast('../output/results/riv_yield_distrib/riv_yield_distrib_range_', m, '_', c, '_1km_2024_rep_cap.tif') *10^6

# Stack
catch_distrib_toshare <- c(catch_distrib, catch_distrib_range)
# Rename
names(catch_distrib_toshare) <- c('catch_distrib_tonnesyr', 'catch_distrib_range_tonnesyr')


# Save to file
writeRaster(catch_distrib_toshare, 
            '../output/results/data_toshare/E_river_yield_uncert_1km_tonnesyr.tif', 
            overwrite=TRUE)


# /----------------------------------------------------------------------------#
#/    F: Gridded 1km map of downstream flow regulation yield loss.

#    Get DOR LOSS raster to file
gdw_dor <- rast('../output/results/dor/gdw_dor_v8.tif')

gdw_dor_loss <- 
  rast('../output/results/dor_yield_losses/gdw_dor_2p_loss_102024.tif')

# Stack
gdw_dor_toshare <- c(gdw_dor, gdw_dor_loss)

# Rename
names(gdw_dor_toshare) <- c('dor', 'dor_yield_loss_tonnesyr')

# Save to file
writeRaster(gdw_dor_toshare, 
            '../output/results/data_toshare/F_downstream_dor_yield_loss.tif', 
            overwrite=TRUE)



