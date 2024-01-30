
# /----------------------------------------------------------------------------#
#/   Prep input predictors

# Get discharge
q_cls <- rast('../data/discharge/dis_dls/q_cls_1km.tif')

# Get wetland area % and km2
mamax_perc <- rast('../output/results/mamax_perc_1km_replaced.tif')
mamax_km2  <- rast('../output/results/mamax_km2_1km_replaced.tif')

# Get population
pop <- rast('../output/results/pop_1km_replaced.tif')

# Get temperature
temp <- rast('../data/waterTemp/temp_1km.tif')



# /----------------------------------------------------------------------------#
#/   Stack all predictions
# predstack <- stack(q_cls_10km, mamax_10km_km2, mamax_10km_perc, pop_10km)
predstack        <- c(q_cls, mamax_km2, mamax_perc, pop, temp)
names(predstack) <- c('q_cls', 'mamax_km2', 'mamax_perc', 'pop','temp')

# Apply Log10 transformation
predstack[predstack==0] <- 10^-10   # Replace 0s with small value
predstack <- log10(predstack)       # log10 transform all layers

# Delete grids
# rm(q_cls_10km, mamax_10km_km2, mamax_10km_perc, pop_10km)

# Crop for testing
# predstack <- crop(predstack, extent(-30,5,-30,5))



# /----------------------------------------------------------------------------#
#/ Read national catch data
natcatch <- read.csv('../output/catch_stats/riv_catch_1997_2014_andcomposited.csv') %>% 
            # filter(country_code != 'SDN') %>% 
            rename(catch.c1 = fao.avg.catch.1997.2014) 
            # mutate(catch.c1 =ifelse(catch.c1<0.001, 0.001, catch.c1),
            #        catch.c2 =ifelse(catch.c2<0.001, 0.001, catch.c2),
            #        catch.c3 =ifelse(catch.c3<0.001, 0.001, catch.c3))


# /----------------------------------------------------------------------------#
#/  Get model parameters

f <- '../output/results/linear_models/Linear Model Outputs wAICs Jan2020 EF.csv'
models <- read.csv(f) %>% filter(train_data_amazon_yn == 1)  # Keep only models with Amazon
models[is.na(models)] = 0  # Replace all NAs by 0s
# filter(model.run %in% selruns)


# List of models to use
selruns <- c('lm2c') # 'lm2b', 'lm10c','lm1b')
# selruns <- c('lm7b','lm9b') # These models don't have wetland
# selruns <- c('lm1b', 'lm11b') # This model is only Q and Q+wetland%

# A: absW + Q; B: propW + Q; C: propW + Q + Pop),


# /----------------------------------------------------------------------------#
#/ Get function that distributes catch

source('data_proc/riv_fish_map/fcn/make_iso_country_grid.r')
source('data_proc/riv_fish_map/fcn/fcn_make_perc_overlap.r')
source('data_proc/riv_fish_map/fcn/fcn_distrib_catch.r')


# /----------------------------------------------------------------------------#
#/ loop through the models, applying
for(m in selruns){
  
  
  # Run subscript that applies regression (not a function); This generates pred_catch
  source('data_proc/riv_fish_map/fcn/fcn_apply_reg_grids.r')
  print(paste('Applied regression:', m, ' to grids.')) # print progress message
  
  # reread output raster
  pred_catch <- rast(paste0('../output/results/pred_catch/pred_catch_', m, '_1km_2023.tif'))
  
  
  # Loop through catch types
  for(c in c('catch.c1', 'catch.c2')){  #, 'catch.c3')){
  
    # Run the distribution algorithm
    catch_distrib <- distrib_catch(pred_catch, natcatch, c)
    
    # convert from megaton to tons
    # catch_distrib <- catch_distrib*10^6

    print(paste(' - Distributed catch ', c))
        
    # save output raster
    writeRaster(catch_distrib, paste0('../output/results/distrib_catch/distrib_catch_', m, '_', c, '_1km_2023_rep.tif'), overwrite=TRUE)
    # save log10 output raster
    writeRaster(log10(catch_distrib), paste0('../output/results/distrib_catch/distrib_catch_', m, '_', c, '_1km_2023_rep_log10.tif'), overwrite=TRUE)
  
  }
}




# mamax_perc <- rast('../data/giemsd15/giems_d15_v10_mamax_1km.tif')/4
# mamax_km2 <- mamax_perc * cellSize(mamax_perc, mask=TRUE)
# 
# # Get population
# pop <- rast('../data/pop/gpw_v4_population_count_rev11_2015_30_sec.tif')
# pop <- crop(pop, ext(mamax_perc))
