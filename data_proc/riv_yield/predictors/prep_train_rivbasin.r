
# TODO: Problematic basins:  Uruguay: 900 vs 4000 
# Tocantins vs Tocantins-Araguaia
# Ganges/Bramaputra, only one or both?
#       Gambia was almost certainly too high in the 2020 version
#       


# Deactivate the s2 geometry bc it is too strict and causes errors
sf::sf_use_s2(FALSE)

basins  <- read_sf('../data/basin_riv_catch/river_basins/all/merged2024_v9.shp') %>%
           dplyr::select('NAME') %>% 
           st_simplify(dTolerance=0.01) %>% 
           st_make_valid() %>% 
           group_by(NAME) %>%
           # st_union() %>% 
          # st_as_sf %>% 
          # st_cast('MULTIPOLYGON') %>%
          # st_cast("POLYGON") %>%
           summarise(geometry = sf::st_union(geometry)) %>%
           ungroup() 

basins = basins[!st_is_empty(basins),]

# sf::sf_use_s2(TRUE)           

  

# /----------------------------------------------------------------------------#
#/   Prep input predictors

# Get discharge
q_cms <- rast('../data/discharge/dis_dls/q_cms_1km.tif')

# Copy var
q_cms_weight <- q_cms
# q_cms_weight[q_cms_weight==0] <- 0.000001
# Log transform
q_cms_weight <- log10(q_cms_weight)
q_cms_weight[is.infinite(q_cms_weight)] <- NA
q_cms_weight[is.na(q_cms_weight)]<-NA
q_cms_weight <- q_cms_weight + 2
q_cms_weight[is.na(q_cms_weight)]<-0

# Get population grid
pop <- rast('../output/results/riv_yield_predictors/grids/replaced/pop_1km_replaced.tif')
# Get water temp grid
temp_1km <- rast('../data/waterTemp/temp_1km.tif')

# Read GLWDv2 grids
glwdv2_areakm2_1km_nopeat<- rast('../output/results/riv_yield_predictors/grids/aggregated/glwdv2_areakm2_1km_nopeat.tif')
glwdv2_perc_1km_nopeat   <- rast('../output/results/riv_yield_predictors/grids/aggregated/glwdv2_perc_1km_nopeat.tif')



# /----------------------------------------------------------------------------#
#/   Stack predictors & Extract per basin

library(exactextractr) # Faster extraction
library(raster)


basins_pred_df <- data.frame(NAME=basins$NAME,

                             basinarea_Mkm2 = terra::area(as_Spatial(basins, cast = TRUE), na.rm=T)/10^6 / 10^6,
                             pop_M=exact_extract(pop, basins, fun = 'sum')/10^6,
                             q_m3sec=exact_extract(q_cms, basins, fun = 'max'),#*0.031556952,
                             temp_degC=exact_extract(temp_1km, basins, fun = 'weighted_mean', weights = q_cms_weight),

                             # mamax_Mkm2 = exact_extract(mamax_km2, basins, fun = 'sum') / 10^6 / 10^6,
                             # mamax_mperc = exact_extract(mamax_perc, basins, fun = 'mean')*100,
                             # 
                             # glwdv2_area_Mkm2 = exact_extract(glwdv2_areakm2_1km, basins, fun = 'sum') / 10^6,                             
                             # glwdv2_perc = exact_extract(glwdv2_perc_1km, basins, fun = 'mean'),

                             glwdv2_area_Mkm2_nopeat = exact_extract(glwdv2_areakm2_1km_nopeat, basins, fun = 'sum') / 10^6,
                             glwdv2_perc_nopeat = exact_extract(glwdv2_perc_1km_nopeat, basins, fun = 'mean'))

glimpse(basins_pred_df)


# /----------------------------------------------------------------------------#
#/   Join attributes extracted predictors to the basin yield df

# Read in updated catch table
riv_yield_basin_2024 <- 
  # read.csv('../data/riv_yield_train_basins/river_basins/riv_yield_basin_2024.csv') %>% 
  read.csv('../data/riv_yield_train_basins/riv_yield_basin_2024.csv') %>% 
  dplyr::select(NAME, Basin_longname, Catch_tonnesyr)            

# Join catch to table
basins_wpreds = 
  merge(basins, basins_pred_df, by='NAME', all.x=T) %>% 
  merge(., riv_yield_basin_2024, by='NAME', all.x=T) %>% 
  filter(!is.na(Catch_tonnesyr)) %>% 
  dplyr::select(NAME, Basin_longname, basinarea_Mkm2, pop_M, q_m3sec, temp_degC, 
                glwdv2_area_Mkm2_nopeat, glwdv2_perc_nopeat, Catch_tonnesyr, geometry)


# Convert to df
basins_wpreds_df <- basins_wpreds %>% st_drop_geometry() %>% data.frame()


# /----------------------------------------------------------------------------#
#/   Save file

# Save to file
write.csv(basins_wpreds_df, '../output/results/riv_yield_predictors/per_train_basin/preds_riv_yield_perbasin.csv', row.names = F)


# Save dissolved shapefile
st_write(basins_wpreds, '../data/basin_riv_catch/river_basins/catch_bas_all_dissolved_v3.shp', delete_dsn=T)





# Get wetland area % and km2
# mamax_perc <- rast('../output/results/riv_yield_predictors/grids/replaced/mamax_perc_1km_replaced.tif')
# mamax_km2  <- rast('../output/results/riv_yield_predictors/grids/replaced/mamax_km2_1km_replaced.tif')

# glwdv2_areakm2_1km <- rast('../output/results/riv_yield_predictors/grids/aggregated/glwdv2_areakm2_1km.tif')
# glwdv2_perc_1km <- rast('../output/results/riv_yield_predictors/grids/aggregated/glwdv2_perc_1km.tif')