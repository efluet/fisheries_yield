

# /----------------------------------------------------------------------------#
#/    SUM CATCH DISTRIB

catch_distrib <-  rast(paste0('../output/results/riv_yield_distrib/riv_yield_distrib_', m, '_', c, '_1km_2024_rep_cap_v10.tif'))

global(catch_distrib, sum, na.rm=T)



# /----------------------------------------------------------------------------#
#/   RIVER BASINS SUMS
basins_wpreds_df_wdistrib <- read.csv('../output/results/riv_yield_distrib/basins_wpreds_df_wdistrib.csv')

colSums(Filter(is.numeric, basins_wpreds_df_wdistrib))/10^6



# /----------------------------------------------------------------------------#
#/  

gdw_barriers <- st_read('../output/results/res_yield_gdw/GDW_barriers_v0_2_resyield_102024.gpkg')

glimpse(gdw_barriers)

# Get global totals
sum(gdw_barriers$res_yield, na.rm=T)
sqrt(sum(gdw_barriers$res_yield_range^2, na.rm=T))/2



# /----------------------------------------------------------------------------#
#/  Get local losses

gdw_barriers_localloss <- 
  st_read(paste0('../output/results/yield_losses/localloss_gdw_barrier_lm2c_catch.c2_rep_cap_2024_v10.gpkg'))




# Get global totals ------------------------------------------------------------


# River sums
sum(gdw_barriers_localloss$riv_yield, na.rm=T)
# sum(riv_yield_per_reserv$riv_yield, na.rm=T)
sqrt(sum(gdw_barriers_localloss$riv_yield_range^2, na.rm=T))/2


# Reservoir yield
sum(gdw_barriers_localloss$res_yield, na.rm=T)
sqrt(sum(gdw_barriers_localloss$res_yield_range^2, na.rm=T))/2


# Local loss sum
sum(gdw_barriers_localloss$localloss, na.rm=T)
sqrt(sum(gdw_barriers_localloss$localloss^2, na.rm=T))/2



# /---------------------------------------------------------------------------#
#/    Get losses for different DOR thresholds
dor_thresh_df <- read.csv('../output/results/dor/gdw_dor_thresholds_102024.csv')


head(dor_thresh_df)
glimpse(dor_thresh_df)

# Compute uncertainty range of 
(2089103-1999518)/2



# # /---------------------------------------------------------------------------#
# #/    Downstream losses
# dor_2p_loss <- rast('../output/results/dor_yield_losses/gdw_dor_2p_loss_102024.tif')
# 
# global(dor_2p_loss, 'sum', na.rm=T) / 10^6                           



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

