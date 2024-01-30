
# /----------------------------------------------------------------------------#
#/  Get GDW rasters                                     -------------sure to 

# Prep fractional reservoir cover
gdw_frac_1km <- rast('../output/gdw/GDW_frac_1km.tif')
gdw_frac_1km <- extend(gdw_frac_1km, com_ext, snap="near")
# ext(gdw_frac_1km) <- com_ext

# Get GDW IDs
gdw_1km_ids <- rast('../output/gdw/GDW_reservoirs_v0_2_GDWIDs.tif')
gdw_1km_ids <- extend(gdw_1km_ids, com_ext, snap="near")
# ext(gdw_1km_ids) <- com_ext


# /----------------------------------------------------------------------------#
#/   Get GDW barrier point shapefile with reservoir yield
gdw_barriers_resyield <- st_read('../output/gdw/GDW_barriers_v0_2_resyield.shp')


# /----------------------------------------------------------------------------#
#/  Get riverine catch
catch_distrib_1km <- rast("../output/results/distrib_catch/distrib_catch_lm2c_catch.c2_1km_2023_rep.tif") * 10^6
catch_distrib_1km <- extend(catch_distrib_1km, com_ext, snap="near")
# ext(catch_distrib_1km) <- com_ext


# /----------------------------------------------------------------------------#
#/  Sum riverine yield under reservoir footprints; summarize by ID

# Calculate fraction of riverine yield covered by reservoirs 
riv_yield_frac = catch_distrib_1km * gdw_frac_1km


# Sum losses per GDW ID
library(rasterDT)
riv_yield_per_reserv <- zonalDT(raster(riv_yield_frac), raster(gdw_1km_ids), fun = sum, na.rm=TRUE)
riv_yield_per_reserv <- as.data.frame(riv_yield_per_reserv)
names(riv_yield_per_reserv) <- c('GDW_ID', 'riv_yield')
glimpse(riv_yield_per_reserv)


# Join ID to shapefile
gdw_barriers_localloss <- merge(gdw_barriers_resyield, riv_yield_per_reserv, by='GDW_ID') %>% 
                            mutate(localloss = riv_yield - res_yield) %>% 
                            arrange(localloss)


# Get global totals
sum(gdw_barriers_localloss$res_yield)
sum(gdw_barriers_localloss$riv_yield)
sum(gdw_barriers_localloss$localloss)


# /----------------------------------------------------------------------------#
#/    Save                      ------------

st_write(gdw_barriers_localloss,
            paste0('../output/results/catch_losses/gdw_barriers_localloss_', m, '_', c, '_rep.shp'), 
            append=F)

# Sums to table                                         
# write.csv(gdw_barriers_localloss, paste0('../output/results/catch_losses/gdw_barriers_localloss_', m, '_', c, '_rep.csv'),
#           row.names = FALSE)
