

# /----------------------------------------------------------------------------#
#/    Get riverine catch per DOR losses threshold
riv_catch         <- rast("../output/results/riv_yield_distrib/riv_yield_distrib_lm2c_catch.c2_1km_2024_rep_cap_v10.tif") * 10^6


# GET DOR LOSSES  ----------------------------

dor_loss_0p  <- rast('../output/results/dor_yield_losses/gdw_dor_0p_loss_102026.tif')
dor_loss_2p  <- rast('../output/results/dor_yield_losses/gdw_dor_2p_loss_102026.tif')
dor_loss_4p  <- rast('../output/results/dor_yield_losses/gdw_dor_4p_loss_102026.tif')


# Stack 
riv_catch_dor_stack <- c(riv_catch, dor_loss_0p, dor_loss_2p, dor_loss_4p)

names(riv_catch_dor_stack) <- c('riv_catch', 'dor_loss_0p', 'dor_loss_2p','dor_loss_4p')


# /----------------------------------------------------------------------------#
#/    get reservoir points with river and reservoir catch              ---------

gdw_pts_res_riv <- 
  st_read(paste0('../output/results/yield_losses/localloss_gdw_barrier_lm2c_catch.c2_rep_cap_2024_v10.gpkg')) %>% 
  dplyr::select(GDW_ID, res_yield, res_yield_range, riv_yield, riv_yield_range, localloss, localloss_range) %>%
  rename(#res_yield = 2,
    riv_yield_infootprint = riv_yield) #3


# /----------------------------------------------------------------------------#
#/     GET TRAINING BASINS                                ---------

# Get training river basins
training_rivbasins <- 
  st_read('../data/riv_yield_train_basins/river_basins/catch_bas_all_dissolved_v3.shp') %>% 
  tibble::rownames_to_column() %>% 
  mutate(id = rowname) %>% 
  mutate(id = as.numeric(id))


# /----------------------------------------------------------------------------#
#/     EXTRACT DOR LOSSES BY BASIN


#DOR Extract riverine catch and DOR loss per country
c_dor_df <- 
  exact_extract(riv_catch_dor_stack, training_rivbasins, fun='sum', max_cells_in_memory= 1447891200) %>% # 723816000
  data.frame() %>% 
  tibble::rownames_to_column()

names(c_dor_df) <- c('id', 'riv_catch', 'dor_loss_0p', 'dor_loss_2p', 'dor_loss_4p')
c_dor_df$id = as.numeric(c_dor_df$id)

# Join DOR losses back to country polygon 
c_poly_dor <- 
  merge(training_rivbasins, c_dor_df, by='id', all.x=T) %>% 
  # Compute DOR range
  mutate(dor_loss_range = dor_loss_0p - dor_loss_4p) %>% 
  rename(dor_loss = dor_loss_2p) %>% 
  dplyr::select(id, NAME, dor_loss, dor_loss_range) %>% 
  st_drop_geometry()


# Clean up space
rm(riv_catch, dor_loss_0p, dor_loss_2p,dor_loss_4p)


#/  SUMMARIZE RESERVOIRS. ------------------------------------------
# join the country polygon to the GDW points, then sum per country  

# 57 rows
c_res_df <- 
  st_join(gdw_pts_res_riv, training_rivbasins, join = st_intersects, left=F) %>%
  st_drop_geometry() %>% 
  # Summarize all reservoirs by basins
  group_by(id, NAME) %>% 
  summarize(n_reservoir= n(), 
            # 
            riv_yield_infootprint = sum(riv_yield_infootprint, na.rm=T),
            riv_yield_range=sqrt(sum(riv_yield_range^2, na.rm=T)),
            #
            res_yield=sum(res_yield, na.rm=T), 
            res_yield_range=sqrt(sum(res_yield_range^2, na.rm=T)),
            #
            local_change = sum(localloss, na.rm=T),
            local_change_range=sqrt(sum(localloss_range^2, na.rm=T))) %>% 
  ungroup() %>% 
  st_drop_geometry()



# /----------------------------------------------------------------------------#
#/     Rejoin the summed point values to the country polygons 
c_poly_dor_res <- 
  merge(c_res_df, c_poly_dor, by=c('id','NAME'),  all.x=T, all.y=T) %>%
  rename(Basin_name = NAME) %>% 
  # Replace NAs
  mutate(across(everything(), ~replace_na(.x, 0))) %>% 
  #  Remove basins without reservoirs
  filter(n_reservoir > 0) %>% 

  # Compute net losses
  mutate(net_change = local_change - dor_loss,
         net_change_range = sqrt(local_change_range^2 + dor_loss_range^2)) %>% 
  
  mutate(riv_yield_infootprint = round(riv_yield_infootprint/1000, 2),
         riv_yield_range = round(riv_yield_range/1000, 2),
         res_yield = round(res_yield/1000, 2),
         res_yield_range = round(res_yield_range/1000,2),
         local_change = round(local_change/1000,2),
         local_change_range = round(local_change_range/1000,2),
         dor_loss = round(dor_loss/1000,2),
         dor_loss_range = round(dor_loss_range/1000, 2),
         net_change = round(net_change/1000,2),
         net_change_range = round(net_change_range/1000, 2))




# Save to file. ---------
write.csv(c_poly_dor_res,
          paste0('../output/results/yield_losses/E_basin_sum.csv'),
          row.names=FALSE)



# Format for SI TABLE  ------------------------------------------------------

si_country_table <-
  c_poly_dor_res %>% 
  mutate(riv_yield_infootprint = paste0(riv_yield_infootprint, ' (±' , round(riv_yield_range/2,2),')'),
         res_yield             = paste0(res_yield, ' (±' , round(res_yield_range/2,2),')'),
         local_change = paste0(local_change, ' (±' , round(local_change_range/2,2),')'),
         dor_loss = paste0(dor_loss, ' (±' , round(dor_loss_range/2,2),')'),
         net_change = paste0(net_change, ' (±' , round(net_change_range/2,2),')')) %>% 
  
  dplyr::select(-riv_yield_range, -res_yield_range, -local_change_range, -dor_loss_range, -net_change_range)


write.csv(si_country_table,
          paste0('../output/results/yield_losses/si_table_basin_summary.csv'),
          row.names=FALSE)


# # Sanity check with totals
# c_poly_dor_res %>% 
  # summarise(across(where(is.numeric), \(x) sum(x, na.rm = TRUE)))
