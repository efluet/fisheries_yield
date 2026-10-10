

# /----------------------------------------------------------------------------#
#/  Get local losses


gdw_barriers_localloss <- 
  st_read(paste0('../output/results/yield_losses/localloss_gdw_barrier_lm2c_catch.c2_rep_cap_2024_v10.gpkg'))


glimpse(gdw_barriers_localloss)


# Get global totals
sum(gdw_barriers_localloss$res_yield, na.rm=T)
sqrt(sum(gdw_barriers_localloss$res_yield_range^2, na.rm=T))/2

# River sums
sum(gdw_barriers_localloss$riv_yield, na.rm=T)
# sum(riv_yield_per_reserv$riv_yield, na.rm=T)

sqrt(sum(gdw_barriers_localloss$riv_yield_range^2, na.rm=T))/2

# Local loss sum
sum(gdw_barriers_localloss$localloss, na.rm=T)
sqrt(sum(gdw_barriers_localloss$localloss^2, na.rm=T))




# /---------------------------------------------------------------------------#
#/    Downstream losses
dor_2p_loss <- rast('../output/results/dor_yield_losses/gdw_dor_2p_loss_102024.tif')


global(dor_2p_loss, 'sum', na.rm=T)                                        



# 
# # /----------------------------------------------------------------------------#
# #/  INDIVIDUAL DAM COMPARISON
# 
# #/     GRAND local losses
# grand_pts_dat <- 
#   st_read(paste0('../output/results/catch_losses/riv_catch_perreserv_pts_', m, '_', c, '_rep.shp')) %>% 
#   st_drop_geometry() %>% 
#   mutate(lat_group = ifelse(LAT_DD >= 23 | LAT_DD<= -23, 'Temperate', 'Tropical')) %>% 
#   arrange(desc(RES_YLD_TN))
#   # group_by(lat_group) %>% 
#   # summarise(n(), na.rm=T)
# 
# 
# glimpse(grand_pts_dat)
# 
# 
# 
# # /----------------------------------------------------------------------------#
# #/    GDW local losses
# gdw_barriers_localloss <- 
#   st_read(paste0('../output/results/catch_losses/gdw_barriers_localloss_', m, '_', c, '_rep.shp')) %>% 
#   st_drop_geometry() %>% 
#   arrange(desc(res_yield)) 
#   # group_by(lat_group) %>% 
#   # summarise(n(), na.rm=T)
# 
# glimpse(gdw_barriers_localloss)
# 
# 
# 
# # /----------------------------------------------------------------------------#
# #/   LATITUDE COMPARISON
# 
# 
# #/     GRAND local losses
# grand_pts_dat <- 
#   st_read(paste0('../output/results/catch_losses/riv_catch_perreserv_pts_', m, '_', c, '_rep.shp')) %>% 
#   st_drop_geometry() %>% 
#   mutate(lat_group = ifelse(LAT_DD >= 23 | LAT_DD<= -23, 'Temperate', 'Tropical')) %>% 
#   group_by(lat_group) %>% 
#   summarise_if(is.numeric, sum, na.rm=T) %>% 
#   rename(res_yield = RES_YLD_TN,
#          riv_yield = riv_catch) %>% 
#   select(lat_group, res_yield, riv_yield)
# 
# 
# glimpse(grand_pts_dat)
# 
# 
# #/    GDW local losses
# gdw_barriers_localloss <- 
#   st_read(paste0('../output/results/catch_losses/gdw_barriers_localloss_', m, '_', c, '_rep.shp')) %>% 
#   st_drop_geometry() %>% 
#   group_by(lat_group) %>% 
#   summarise_if(is.numeric, sum, na.rm=T) %>% 
#   select(lat_group, res_yield, riv_yield)
# 
# glimpse(gdw_barriers_localloss)



# sum(gdw_barriers_localloss$res_yield, na.rm=T)
# sum(gdw_barriers_localloss$riv_yield, na.rm=T)
# sum(gdw_barriers_localloss$localloss, na.rm=T)
# gdw_barriers_resyield[(gdw_barriers_resyield$lat_group=='Temperate'),'res_yield']



# gdw_barriers_localloss <- st_read(paste0('../output/results/yield_losses/localloss_gdw_barrier_', m, '_', c, '_rep_2024_v05.shp'))
# st_read(paste0('../output/results/yield_losses/gdw_barriers_localloss_', m, '_', c, '_rep.shp'))

