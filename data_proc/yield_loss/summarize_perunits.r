
library(exactextractr)

# /----------------------------------------------------------------------------#
#/    Get riverine catch per DOR losses threshold

riv_catch         <- rast(paste0('../output/results/distrib_catch/distrib_catch_', m, '_', c, '_1km_2023_rep.tif')) * 10^6
riv_catch_dist_2  <- rast(paste0('../output/results/catch_losses/gdw_dor_2p_loss.tif'))

riv_catch_dor_stack <- c(riv_catch, riv_catch_dist_2)
names(riv_catch_dor_stack) <- c('riv_catch', 'riv_loss_dor2')


# /----------------------------------------------------------------------------#
#/    get reservoir points with river and reservoir catch             ---------
gdw_pts_res_riv <- st_read(paste0('../output/results/catch_losses/gdw_barriers_localloss_', m, '_', c, '_rep.shp')) %>% 
                             select(GDW_ID, res_yield, riv_yield) %>% 
                             rename(res_yield = 2,
                                    riv_yield_infootprint = 3)


# /----------------------------------------------------------------------------#
#/    Summarize per country                                            ---------

c_poly <- st_read('../data/nat_earth/ne_110m_admin_0_countries.shp') %>% 
             select(name, adm0_a3_us) %>% 
             tibble::rownames_to_column() %>% 
              mutate(id = rowname) %>% 
              mutate(id = as.numeric(id)) %>% 
              select(-rowname)

# Extract riverine catch and DOR loss per country
c_dor_df <- exact_extract(riv_catch_dor_stack, c_poly, fun='sum', max_cells_in_memory= 723816000) %>% 
                     data.frame() %>% 
                     tibble::rownames_to_column() %>% 
                     rename(id=1, riv_catch=2, dist2=3) %>%   #dor=3, distall=4, dist5=5, 
                     mutate(id = as.numeric(id))

# Join DOR losses back to country polygon 
c_poly_dor <- merge(c_poly, c_dor_df, by='id', all.x=T)

# Then join the country polygon to the GDW points, then sum per country
c_res_df <- st_join(gdw_pts_res_riv, c_poly, join = st_intersects, left=F) %>% 
                       st_drop_geometry() %>% 
                       # mutate(rowname = as.numeric(rowname)) %>% 
                       # rename(id = rowname) %>% 
                       group_by(id, name, adm0_a3_us) %>% 
                       summarize_at(c('res_yield', 'riv_yield_infootprint'), list(sum)) %>% 
                       ungroup() %>% 
                       mutate(continent=countrycode(sourcevar=adm0_a3_us, origin='iso3c', destination='continent')) %>%
                       mutate(un_region=countrycode(sourcevar=adm0_a3_us, origin='iso3c', destination='un.regionsub.name')) #%>% 
                       # select(-one_of('name', 'adm0_a3_us'))

# Rejoin the summed point values to the country polygons 
c_poly_dor_res <- merge(c_poly_dor, c_res_df, by='adm0_a3_us', all.x=T) %>% st_drop_geometry()


# Save to file
write.csv(c_poly_dor_res, paste0('../output/results/catch_losses/country_sum_', m, '_', c, '_rep_oct2023.csv'), row.names=FALSE)



# /----------------------------------------------------------------------------#
#/     Summarize per hydrobasin - lvl 4                                ---------

hb4_poly <- st_read('../data/hydrobasins/BasinATLAS_v10_lev04.shp') %>% 
               select(HYBAS_ID) %>% 
               tibble::rownames_to_column() %>% 
               mutate(id = rowname) %>% 
               mutate(id = as.numeric(id)) %>% 
               select(-rowname)


# Extract DOR rasters
hb4_dor_df <- exact_extract(riv_catch_dor_stack, hb4_poly, fun='sum', max_cells_in_memory= 723816000) %>% 
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


# Save df to file
write.csv(data.frame(hb4_poly_dor_res), paste0('../output/results/catch_losses/hydrobasin4_sum_', m, '_', c, '_rep_oct2023.csv'), row.names=FALSE)


# Join data to polygons and save to shapefile
writeVector(vect(hb4_poly_dor_res),  paste0('../output/results/catch_losses/hydrobasin4_poly_dat_', m, '_', c, '_rep_oct2023.shp'), overwrite=T)





# mutate(rel_tons = riv_catch - RES_YLD_TN, 
# rel_perc = (riv_catch - RES_YLD_TN)/ riv_catch)

# # /----------------------------------------------------------------------------#
# #/     Summarize per hydrobasin - lvl 3                                ---------
# 
# hb3_poly <- st_read('../data/hydrobasins/BasinATLAS_v10_lev03.shp') %>% 
#   select(HYBAS_ID) %>% 
#   tibble::rownames_to_column() %>% 
#   mutate(id = rowname) %>% 
#   mutate(id = as.numeric(id)) %>% 
#   select(-rowname)
# 
# 
# # Extract DOR rasters
# hb3_dor_df <- exact_extract(riv_catch_dor_stack, hb3_poly, fun='sum', max_cells_in_memory= 723816000) %>% 
#   data.frame() %>% 
#   tibble::rownames_to_column() %>% 
#   rename(id=1, riv_catch=2, dist2=3) %>%  # dor=3, distall=4, dist5=5, 
#   mutate(id = as.numeric(id))
# 
# # Join DOR back to 
# hb3_poly_dor <- merge(hb3_poly, hb3_dor_df, by='id', all.x=T)
# 
# # Extract 
# hb3_res_df <- 
#   st_join(gdw_pts_res_riv, hb3_poly, join = st_intersects, left=F) %>% 
#   st_drop_geometry() %>% 
#   # mutate(rowname = as.numeric(rowname)) %>% 
#   # rename(id = rowname) %>% 
#   group_by(id, HYBAS_ID) %>% 
#   summarize_at(c('res_yield', 'riv_yield'), list(sum))
# 
# 
# hb3_poly_dor_res <- merge(hb3_poly_dor, hb3_res_df, by='id', all.x=T) # %>% st_drop_geometry()
# 
# 
# # Save df to file
# write.csv(data.frame(hb3_poly_dor_res), paste0('../output/results/catch_losses/hydrobasin3_sum_', m, '_', c, '_rep_oct2023.csv'), row.names=FALSE)
# 
# 
# # Join data to polygons and save to shapefile
# writeVector(vect(hb3_poly_dor_res),  paste0('../output/results/catch_losses/hydrobasin3_poly_dat_', m, '_', c, '_rep_oct2023.shp'), overwrite=T)


# riv_catch_dor     <- rast(paste0('../output/results/catch_losses/riv_catch_dor_', m, '_', c, '_rep.tif'))
# riv_catch_dist_all<- rast(paste0('../output/results/catch_losses/riv_catch_dist_all_', m, '_', c, '_rep.tif'))
# riv_catch_dist_5  <- rast(paste0('../output/results/catch_losses/riv_catch_dist_5_', m, '_', c, '_rep.tif'))

# # Stack all rasters
# riv_catch_dor_stack <- c(riv_catch, riv_catch_dor, riv_catch_dist_all, riv_catch_dist_5, riv_catch_dist_2)
# 
# names(riv_catch_dor_stack) <- c('riv_catch', 'riv_catch_dor', 'riv_catch_dist_all', 'riv_catch_dist_5', 'riv_catch_dist_2')


# hydrobasin4_poly_dat <- merge(hydrobasin4, hydrobasin4_dat, by='HYBAS_ID', all.x=T)

# Extract DOR losses (RIL)
# countries_riv_dor <- extract(riv_catch_dor_stack, vect(countries), fun=sum, method="simple", na.rm=T) %>% 
#                      tibble::rownames_to_column()
# 
# countries_riv_dor <- countries_riv_dor %>% 
#                      rename(ID=1, id=2, dor=3, distall=4, dist5=5, dist2=6) %>% 
#                      mutate(ID = as.numeric(ID)) %>% 
#                      left_join(., isolookup2, by='ID')

# hydrobasin4_riv_dor <- extract(riv_catch_dor_stack, vect(hydrobasin4), fun=sum, method="simple", na.rm=T) %>% 
#                         tibble::rownames_to_column() # %>%
# rename(ID=1, dor=2, distall=3, dist5=4, dist2=5) # %>% left_join(., isolookup2, by='ID')

# hydrobasin4_riv_dor <- hydrobasin4_riv_dor %>% 
#                        rename(ID=1, id=2, dor=3, distall=4, dist5=5, dist2=6) %>% 
#                        mutate(ID = as.numeric(ID)) %>% 
#                        left_join(., isolookup2, by='ID')
