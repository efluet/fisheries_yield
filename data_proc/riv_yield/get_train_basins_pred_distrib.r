
# /----------------------------------------------------------------------------#
#/   Read training basins w/ predictors

basins_wpreds_df <- 
  read.csv('../output/results/riv_yield_predictors/per_train_basin/from_cathy/preds_riv_yield_perbasin12Feb24.csv') %>% 
  mutate(pop_dens = pop_M / basinarea_Mkm2) %>% 
  mutate(
    logcatch = log10(Catch_tonnesyr),
    logpopdens=log10(pop_dens),
    logq_km3yr = log10(q_km3yr),
    wetperc= glwdv2_perc_nopeat)


# /----------------------------------------------------------------------------#
#/    Fit robust regression to get predicted yield
library(MASS)


rlm_riv <- rlm(logcatch ~ logpopdens  + logq_km3yr + wetperc, data=basins_wpreds_df)
summary(rlm_riv)
AIC(rlm_riv)

# # Attach predicted values to table 
basins_wpreds_df['lm_pred_yield'] <- rlm_riv$fitted.values

basins_wpreds_df <- 
  bind_cols(basins_wpreds_df, 10^predict(rlm_riv, interval='prediction')) %>% 
  mutate(range=upr-lwr)



# /----------------------------------------------------------------------------#
#/    GET DISTRIB CATCH PER BASIN

# Get training river basins polygons
training_rivbasins <- st_read('../data/riv_yield_train_basins/river_basins/catch_bas_all_dissolved_v3.shp')

# Get river yield maps
catch_distrib_fit   <- rast('../output/results/riv_yield_distrib/riv_yield_distrib_lm2c_catch.c2_1km_2024_rep_cap_v10.tif') * 10^6
catch_distrib_range <- rast('../output/results/riv_yield_distrib/riv_yield_distrib_range_lm2c_catch.c2_1km_2024_rep_cap.tif') * 10^6

# Extract distrib per basin 
catch_distrib_fit_perbasin   <- extract(catch_distrib_fit, training_rivbasins, fun=sum, na.rm=T)

quad_sum <- function(x) sqrt(sum(x^2, na.rm = T))
catch_distrib_range_perbasin <- extract(catch_distrib_range, training_rivbasins, fun=quad_sum)

# Rename columns
names(catch_distrib_fit_perbasin)   <- c('ID','distrib_fit')
names(catch_distrib_range_perbasin) <- c('ID','distrib_range')


# Join fit and range
catch_distrib_perbasin <-
  full_join(catch_distrib_fit_perbasin, catch_distrib_range_perbasin, by='ID') %>% 
  mutate(distrib_lwr = distrib_fit - distrib_range/2,
         distrib_upr = distrib_fit + distrib_range/2) %>% 
  tibble()



# /----------------------------------------------------------------------------#
#/    Join DISTRIB to river basin predictor table
basins_wpreds_df_wdistrib <- 
  basins_wpreds_df %>% 
  bind_cols(., catch_distrib_perbasin)

glimpse(basins_wpreds_df_wdistrib)


# Write to file
write.csv(basins_wpreds_df_wdistrib, '../output/results/riv_yield_distrib/basins_wpreds_df_wdistrib.csv', row.names=F)




# basins_wpreds_df <- 
#   read.csv('../output/results/riv_yield_predictors/per_train_basin/from_cathy/preds_riv_yield_perbasin12Feb24.csv') %>% 
#   mutate(logcatch = log10(Catch_tonnesyr),
#          logpop=log10(pop_M),
#          logq_km3yr = log10(q_km3yr),
#          wetperc= glwdv2_perc_nopeat) 
# 
# glimpse(basins_wpreds_df)
