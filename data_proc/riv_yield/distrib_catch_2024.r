
# /----------------------------------------------------------------------------#
#/ Get function that distributes catch

source('data_proc/riv_yield/fcn/make_iso_country_grid.r')
source('data_proc/riv_yield/fcn/fcn_make_perc_overlap.r')
source('data_proc/riv_yield/fcn/fcn_distrib_catch.r')


# /----------------------------------------------------------------------------#
#/ Read national catch data
natcatch <- read.csv('../output/results/national_catch/riv_catch_1997_2014_andcomposited.csv') %>% 
  # filter(country_code != 'SDN') %>% 
  rename(catch.c1 = fao.avg.catch.1997.2014) 
# mutate(catch.c1 =ifelse(catch.c1<0.001, 0.001, catch.c1),
#        catch.c2 =ifelse(catch.c2<0.001, 0.001, catch.c2),
#        catch.c3 =ifelse(catch.c3<0.001, 0.001, catch.c3))



# /----------------------------------------------------------------------------#
#/  Get discharge mask
q_cms <- rast('../data/discharge/dis_dls/q_cms_1km.tif')
# Apply low-discharge mask, to prevent catch from being distributed to these areas
q_cms[q_cms < 0.1] <- NA
# Convert to km3/yr
q_km3yr <- q_cms * 0.031556952   # 1 cms == 0.03... km3yr
names(q_km3yr) <- c('q_km3yr')



# /----------------------------------------------------------------------------#
#/ loop through the models, sapplying


# Run subscript that applies regression (not a function); This generates pred_catch
# source('data_proc/riv_fish_map/fcn/fcn_apply_reg_grids.r')
# print(paste('Applied regression:', m, ' to grids.')) # print progress message

# reread output raster
pred_catch <- rast(paste0('../output/results/riv_yield_predicted/pred_catch_1km_2024_rep_cap_v10.tif'))[[1]]  
# pred_catch_lm2c2024_1km_2024_rep_v06.tif'))[[1]]

# Set ceiling of predicted river catch
# pred_catch[pred_catch>10^2] <- 10^2
pred_catch[pred_catch==0] <- NA 

# Apply river mask
pred_catch[is.na(q_km3yr)] <- NA


# /----------------------------------------------------------------------------#
#/    APPLY DISTRIBUTION TO PREDICTED CATCH MAP

# Loop through catch types
for(c in c('catch.c2')){  #,'catch.c1', 'catch.c3')){
  
  # Run the distribution algorithm
  catch_distrib <- distrib_catch(pred_catch, natcatch, c)
  
  # convert from megaton to tons
  # catch_distrib <- catch_distrib*10^6
  
  print(paste(' - Distributed catch ', c))
  
  # save output raster
  writeRaster(catch_distrib, paste0('../output/results/riv_yield_distrib/riv_yield_distrib_', m, '_', c, '_1km_2024_rep_cap_v10.tif'), 
              overwrite=TRUE)

  }



# /----------------------------------------------------------------------------#
#/    Distribute the 100 realizations

for (i in seq(1,100)){
  
  # reread output raster
  pred_catch <- rast(paste0('../output/results/riv_yield_predicted/uncert_member/pred_catch_uncertmember_', i, '.tif'))
  # ext(pred_catch) <- c(-180,180,-56, 84)
  pred_catch[pred_catch>10^5] <- 10^5
  # pred_catch[pred_catch==0] <- NA
  
  
# Loop through catch types
  for(c in c('catch.c2')){  #,'catch.c1', 'catch.c3')){
    
    # Run the distribution algorithm
    catch_distrib <- distrib_catch(pred_catch, natcatch, c)
    
    # convert from megaton to tons
    # catch_distrib <- catch_distrib*10^6
    
    print(paste(' - Distributed catch ', c))
    
    # save output raster
    writeRaster(catch_distrib, 
                paste0('../output/results/riv_yield_distrib/members/riv_yield_distrib_', m, '_', c, '_1km_2024_rep_member', i,'.tif'), 
                overwrite=TRUE, 
                gdal="COMPRESS=LZW")
    
    # save log10 output raster
    # writeRaster(log10(catch_distrib), paste0('../output/results/riv_yield_distrib/members/riv_yield_distrib_', m, '_', c, '_1km_2024_rep_member',i,'log10.tif'), 
                # overwrite=TRUE, gdal="COMPRESS=LZW")
    
    }
  }






# save log10 output raster
# writeRaster(log10(catch_distrib), paste0('../output/results/riv_yield_distrib/riv_yield_distrib_', m, '_', c, '_1km_2024_rep_log10_v03.tif'), 
# overwrite=TRUE)
# pred_catch_log10 <- terra::app(predstack, regmodel) # , cores=6)
# Back convert catch into log
# pred_catch <- 10^(pred_catch_log10)
# save output raster
# writeRaster(pred_catch, paste0('../output/results/pred_catch/pred_catch_', m, '_1km_2023.tif'), overwrite=TRUE)
