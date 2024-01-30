
# /----------------------------------------------------------------------------#
#/ INDIVIDUAL DAM COMPARISON

#/     GRAND local losses
grand_pts_dat <- 
  st_read(paste0('../output/results/catch_losses/riv_catch_perreserv_pts_', m, '_', c, '_rep.shp')) %>% 
  st_drop_geometry() %>% 
  mutate(lat_group = ifelse(LAT_DD >= 23 | LAT_DD<= -23, 'Temperate', 'Tropical')) %>% 
  arrange(desc(RES_YLD_TN))
  # group_by(lat_group) %>% 
  # summarise(n(), na.rm=T)


glimpse(grand_pts_dat)



# /----------------------------------------------------------------------------#
#/    GDW local losses
gdw_barriers_localloss <- 
  st_read(paste0('../output/results/catch_losses/gdw_barriers_localloss_', m, '_', c, '_rep.shp')) %>% 
  st_drop_geometry() %>% 
  arrange(desc(res_yield)) 
  # group_by(lat_group) %>% 
  # summarise(n(), na.rm=T)

glimpse(gdw_barriers_localloss)



# /----------------------------------------------------------------------------#
#/   LATITUDE COMPARISON


#/     GRAND local losses
grand_pts_dat <- 
  st_read(paste0('../output/results/catch_losses/riv_catch_perreserv_pts_', m, '_', c, '_rep.shp')) %>% 
  st_drop_geometry() %>% 
  mutate(lat_group = ifelse(LAT_DD >= 23 | LAT_DD<= -23, 'Temperate', 'Tropical')) %>% 
  group_by(lat_group) %>% 
  summarise_if(is.numeric, sum, na.rm=T) %>% 
  rename(res_yield = RES_YLD_TN,
         riv_yield = riv_catch) %>% 
  select(lat_group, res_yield, riv_yield)


glimpse(grand_pts_dat)


#/    GDW local losses
gdw_barriers_localloss <- 
  st_read(paste0('../output/results/catch_losses/gdw_barriers_localloss_', m, '_', c, '_rep.shp')) %>% 
  st_drop_geometry() %>% 
  group_by(lat_group) %>% 
  summarise_if(is.numeric, sum, na.rm=T) %>% 
  select(lat_group, res_yield, riv_yield)

glimpse(gdw_barriers_localloss)



# sum(gdw_barriers_localloss$res_yield, na.rm=T)
# sum(gdw_barriers_localloss$riv_yield, na.rm=T)
# sum(gdw_barriers_localloss$localloss, na.rm=T)
# gdw_barriers_resyield[(gdw_barriers_resyield$lat_group=='Temperate'),'res_yield']



# /---------------------------------------------------------------------------#
#/    Downstream losses
dor_2p_loss <- rast(paste0('../output/results/catch_losses/gdw_dor_2p_loss.tif'))
dor_2p_loss

global(dor_2p_loss, 'sum', na.rm=T)                                        
