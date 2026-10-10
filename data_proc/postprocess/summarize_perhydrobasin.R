
# /----------------------------------------------------------------------------#
#/     SUMMARIZE per hydrobasin - lvl 4                                ---------

hb4_poly <- 
  st_read('../data/riv_yield_train_basins/BasinATLAS_Data_v10_shp/BasinATLAS_v10_shp/BasinATLAS_v10_lev04.shp') %>% 
  dplyr::select(HYBAS_ID) %>% 
  tibble::rownames_to_column() %>% 
  mutate(id = rowname) %>% 
  mutate(id = as.numeric(id)) %>% 
  dplyr::select(-rowname)


# Extract DOR rasters
hb4_dor_df <- 
  exact_extract(riv_catch_dor_stack, hb4_poly, fun='sum', max_cells_in_memory= 1447891200) %>% 
  data.frame() %>% 
  tibble::rownames_to_column() %>% 
  rename(id=1, riv_catch=2, dist2=3) %>%   #dor=3, distall=4, dist5=5, 
  mutate(id = as.numeric(id))


# Join DOR back to 
hb4_poly_dor <- merge(hb4_poly, hb4_dor_df, by='id', all.x=T)

# Extract 
hb4_res_df <- 
  st_join(gdw_pts_res_riv, hb4_poly, join = st_intersects, left=F) %>% 
  st_drop_geometry() %>% 
  # mutate(rowname = as.numeric(rowname)) %>% 
  # rename(id = rowname) %>% 
  group_by(id, HYBAS_ID) %>% 
  summarize_at(c('res_yield', 'riv_yield_infootprint'), list(sum))


hb4_poly_dor_res <- merge(hb4_poly_dor, hb4_res_df, by='id', all.x=T) # %>% st_drop_geometry()



# /----------------------------------------------------------------------------#
#/    Save df to file
write.csv(as.data.frame(hb4_poly_dor_res ), 
          paste0('../output/results/yield_losses/hydrobasin4/hydrobasin4_sum_', m, '_', c, '_rep_cap_102024.csv'))#, row.names=FALSE)

# Save to shapefile
writeVector(vect(hb4_poly_dor_res),  
            paste0('../output/results/yield_losses/hydrobasin4/hydrobasin4_poly_dat_', m, '_', c, '_rep_cap_102024.shp'), overwrite=T)
