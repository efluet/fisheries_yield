
# /----------------------------------------------------------------------------#
#/   Make stack of predictor grids

# Get discharge
q_cls_10km <- raster('../data/discharge/dis_dls/q_cls_10km.tif')


# Get wetland area % and km2
mamax_10km_perc <- raster('../data/giemsd15/giems_d15_v10_mamax_10km.tif')/400
mamax_10km_km2 <- mamax_10km_perc*area(mamax_10km_perc)

# Get population
pop_10km <- raster('../data/pop/pop_10km.tif')
pop_10km <- crop(pop_10km, extent(mamax_10km_perc))


# Stack all predictions
predstack <- stack(q_cls_10km, mamax_10km_km2, mamax_10km_perc, pop_10km)
names(predstack) <- c('q_cls', 'mamax_km2', 'mamax_perc', 'pop')

# Apply Log10 transformation
predstack[predstack==0] <- 10^-10
predstack <- log10(predstack)

# Delete grids
rm(q_cls_10km, mamax_10km_km2, mamax_10km_perc, pop_10km)

# Crop for testing
# predstackcrop <- crop(predstack, extent(-30,18,-30,18))



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
models <- read.csv(f) %>%
          filter(train_data_amazon_yn == 1)  # Keep only models with Amazon
          # filter(model.run %in% selruns)


# List of models to use
selruns <- c('lm2c', 'lm2b', 'lm10c','lm1b')  #'lm7b',
# A: absW + Q; B: propW + Q; C: propW + Q + Pop),


# /----------------------------------------------------------------------------#
#/ Get function that distributes catch

source('data_proc/fcn_distrib_catch.r')
source('data_proc/make_iso_country_grid.r')
source('data_proc/fcn_make_perc_overlap.r')


# /----------------------------------------------------------------------------#
#/ loop through the models, applying
for(m in selruns){
  
  # Run subscript that applies regression (not a function) 
  # This generates pred_catch
  source('data_proc/fcn_apply_reg_grids.r')
  print(paste('Applied regression:', m, ' to grids.')) # print progress ticker
  
  
  # Loop through catch types
  #for(c in c('catch.c1', 'catch.c2', 'catch.c3')){
  
  # Run the distribution algorithm
  catch_distrib <- distrib_catch(pred_catch, natcatch, 'catch.c2')
  
  # convert from megaton to tons
  catch_distrib <- catch_distrib*10^6  
  
  # save output raster
  writeRaster(catch_distrib, paste0('../output/results/distrib_catch/distrib_catch_', m, '_c2',  '1km_2023.tif'), overwrite=TRUE)
  print(paste(' - Distributed catch c2'))
  
  # save output raster
  writeRaster(log10(catch_distrib), paste0('../output/results/distrib_catch/distrib_catch_', m, '_c2',  '1km_2023_log10.tif'), overwrite=TRUE)
  print(paste(' - Distributed catch c2'))
  
  
  # Make map
  source('plots/map_distrib_catch.r')
  
}


