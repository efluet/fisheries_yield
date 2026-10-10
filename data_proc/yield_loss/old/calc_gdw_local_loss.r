
# /----------------------------------------------------------------------------#
#/  Get GDW rasters                                                 ------------

# Get fractional reservoir cover
gdw_frac_1km <- rast('../output/results/res_yield_gdw/GDW_reservoirs_v0_2_frac_ex.tif')

# Get GDW IDs
gdw_1km_ids <- rast('../output/results/res_yield_gdw/GDW_reservoirs_v0_2_GDWIDs_ex.tif')


# /----------------------------------------------------------------------------#
#/   Get GDW barrier point shapefile with reservoir yield             ----------
gdw_barriers_resyield <- 
  st_read('../output/results/res_yield_gdw/GDW_barriers_v0_2_resyield_102024.shp') %>% 
  rename(res_yield = rs_yld_,
         res_yield_range = uncrt_r)


# /----------------------------------------------------------------------------#
#/  Get river yield raster

# Get river yield fit raster
catch_distrib_fit <- rast('../output/results/riv_yield_distrib/riv_yield_distrib_lm2c_catch.c2_1km_2024_rep_cap_v10.tif') * 10^6

# Get range of predicted river yield
catch_distrib_range <- rast('../output/results/riv_yield_distrib/riv_yield_distrib_range_lm2c_catch.c2_1km_2024_rep_cap.tif') * 10^6


# Compute upper and lower bounds
catch_distrib_upr <- catch_distrib_fit + catch_distrib_range/2
catch_distrib_lwr <- catch_distrib_fit - catch_distrib_range/2

# Set 0 floor to uncertainty values
catch_distrib_lwr[catch_distrib_lwr < 0] <- 0

# GLOBAL Sum quadrature of uncertainty ranges
global(catch_distrib_fit, sum, na.rm=T)
global(catch_distrib_range, function(x) sqrt(sum(x^2, na.rm=T))) 


# /----------------------------------------------------------------------------#
#/  Sum riverine yield under reservoir footprints; summarize by ID

# Calculate fraction of riverine yield covered by reservoirs 
riv_yield_frac = catch_distrib_fit * gdw_frac_1km


# Sum yield losses per reservoir; summarizing by GDW ID
library(rasterDT)
riv_yield_per_reserv <- zonalDT(raster(riv_yield_frac), raster(gdw_1km_ids), fun = sum, na.rm=TRUE)
riv_yield_per_reserv <- as.data.frame(riv_yield_per_reserv)
names(riv_yield_per_reserv) <- c('GDW_ID', 'riv_yield')
glimpse(riv_yield_per_reserv)


# Sum all lower bound river yield values
riv_yield_per_reserv_lwr <- zonalDT(raster(catch_distrib_lwr)^2, raster(gdw_1km_ids), fun = sum, na.rm=TRUE)
riv_yield_per_reserv_lwr_df <- 
  data.frame(riv_yield_per_reserv_lwr) %>%
  mutate(fit = sqrt(fit))
  # mutate(fit = 10^sqrt(fit))

names(riv_yield_per_reserv_lwr_df) <- c('GDW_ID', 'riv_yield_lwr')
glimpse(riv_yield_per_reserv_lwr_df)


# Sum all upper bound river yield values
riv_yield_per_reserv_upr <- zonalDT(raster(catch_distrib_upr)^2, raster(gdw_1km_ids), fun = sum, na.rm=TRUE)
riv_yield_per_reserv_upr_df <- 
  data.frame(riv_yield_per_reserv_upr) %>% 
  mutate(fit = sqrt(fit))

names(riv_yield_per_reserv_upr_df) <- c('GDW_ID', 'riv_yield_upr')
glimpse(riv_yield_per_reserv_upr_df)



# /----------------------------------------------------------------------------#
#/    Join river yield per reservoir to dam shapefile by ID            ---------

gdw_barriers_localloss <- 
    left_join(gdw_barriers_resyield, riv_yield_per_reserv, by='GDW_ID') %>% 
    left_join(., riv_yield_per_reserv_lwr_df, by='GDW_ID') %>% 
    left_join(., riv_yield_per_reserv_upr_df, by='GDW_ID') %>%
    mutate(riv_yield_range = riv_yield_upr - riv_yield_lwr, 
           localloss = riv_yield - res_yield,
           localloss_range = sqrt(res_yield_range^2 + res_yield_range^2))



# /----------------------------------------------------------------------------#
#/    TOTALS

# Get global totals

sum(gdw_barriers_resyield$res_yield, na.rm=T)
# sum(gdw_barriers_localloss$res_yield, na.rm=T)
sqrt(sum(gdw_barriers_localloss$res_yield_range^2, na.rm=T))/2

# River sums
# sum(gdw_barriers_localloss$riv_yield, na.rm=T)
sum(riv_yield_per_reserv$riv_yield, na.rm=T)
sqrt(sum(gdw_barriers_localloss$riv_yield_range^2, na.rm=T))/2

# Local loss sum
sum(gdw_barriers_localloss$localloss, na.rm=T)
sqrt(sum(gdw_barriers_localloss$localloss_range^2, na.rm=T))/2


# /----------------------------------------------------------------------------#
#/    Save barrier points with local loss                            -----------

st_write(gdw_barriers_localloss,
            paste0('../output/results/yield_losses/localloss_gdw_barrier_', m, '_', c, '_rep_cap_2024_v10.gpkg'), 
            append=F)


