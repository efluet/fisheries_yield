# prep GLWDv2

# Read in data
# Use  GLWD_v2_delta_area_ha_x10.tif
glwdv2_path_comb       <- '../../../Chap2_glwdv2/output/results/glwd_v2_delta/GLWD_v2_delta_combined_classes_tif/GLWD_v2_delta_combined_classes/'
glwdv2_path_class_ha   <- '../../../Chap2_glwdv2/output/results/glwd_v2_delta/GLWD_v2_delta_area_by_class_ha_tif/GLWD_v2_delta_area_by_class_ha/'
glwdv2_path_class_ptc <- '../../../Chap2_glwdv2/output/results/glwd_v2_delta/GLWD_v2_delta_area_by_class_pct_tif/GLWD_v2_delta_area_by_class_pct/'


glwdv2_area <- rast(paste0(glwdv2_path_comb, 'GLWD_v2_delta_area_ha_x10.tif'))
glwdv2_perc <- rast(paste0(glwdv2_path_comb, 'GLWD_v2_delta_area_pct.tif'))


# Sum to 1km
# Note:  It doesn't look like x10 is actually applied?
glwdv2_areakm2_1km <- aggregate(glwdv2_area, fact=2, fun=sum, cores=8) *0.01 /10
glwdv2_perc_1km <- aggregate(glwdv2_perc, fact=2, fun=mean, cores=8)



# /----------------------------------------------------------------------------#
#/   Peatland and mangrove


c22_km2 <-  rast(paste0(glwdv2_path_class_ha, 'GLWD_v2_delta_class_22_ha_x10.tif')) %>% 
            aggregate(., fact=2, fun=sum, cores=16) *0.01 /10
c23_km2 <-  rast(paste0(glwdv2_path_class_ha, 'GLWD_v2_delta_class_23_ha_x10.tif')) %>% 
            aggregate(., fact=2, fun=sum, cores=16) *0.01 /10
c24_km2 <-  rast(paste0(glwdv2_path_class_ha, 'GLWD_v2_delta_class_24_ha_x10.tif')) %>% 
            aggregate(., fact=2, fun=sum, cores=16) *0.01 /10
c25_km2 <-  rast(paste0(glwdv2_path_class_ha, 'GLWD_v2_delta_class_25_ha_x10.tif')) %>% 
            aggregate(., fact=2, fun=sum, cores=16) *0.01 /10
c26_km2 <-  rast(paste0(glwdv2_path_class_ha, 'GLWD_v2_delta_class_26_ha_x10.tif')) %>% 
            aggregate(., fact=2, fun=sum, cores=16) *0.01 /10
c27_km2 <-  rast(paste0(glwdv2_path_class_ha, 'GLWD_v2_delta_class_27_ha_x10.tif')) %>% 
            aggregate(., fact=2, fun=sum, cores=16) *0.01 /10
c28_km2 <-  rast(paste0(glwdv2_path_class_ha, 'GLWD_v2_delta_class_28_ha_x10.tif')) %>% # Mangrove 
            aggregate(., fact=2, fun=sum, cores=16) *0.01 /10


# Get percent of classes
c22_perc <-  rast(paste0(glwdv2_path_class_ptc, 'GLWD_v2_delta_class_22_pct.tif')) %>% 
             aggregate(., fact=2, fun=mean, cores=16)
c23_perc <-  rast(paste0(glwdv2_path_class_ptc, 'GLWD_v2_delta_class_23_pct.tif')) %>% 
             aggregate(., fact=2, fun=mean, cores=16)
c24_perc <-  rast(paste0(glwdv2_path_class_ptc, 'GLWD_v2_delta_class_24_pct.tif')) %>% 
             aggregate(., fact=2, fun=mean, cores=16)
c25_perc <-  rast(paste0(glwdv2_path_class_ptc, 'GLWD_v2_delta_class_25_pct.tif')) %>% 
             aggregate(., fact=2, fun=mean, cores=16)
c26_perc <-  rast(paste0(glwdv2_path_class_ptc, 'GLWD_v2_delta_class_26_pct.tif')) %>% 
             aggregate(., fact=2, fun=mean, cores=16)
c27_perc <-  rast(paste0(glwdv2_path_class_ptc, 'GLWD_v2_delta_class_27_pct.tif')) %>% 
             aggregate(., fact=2, fun=mean, cores=16)
c28_perc <-  rast(paste0(glwdv2_path_class_ptc, 'GLWD_v2_delta_class_28_pct.tif'))  %>% 
             aggregate(., fact=2, fun=mean, cores=16)


# /----------------------------------------------------------------------------#
#/   Subtract from totals

# Subtract peat from totals
glwdv2_areakm2_1km_nopeat = glwdv2_areakm2_1km -c22_km2 - c23_km2 - c24_km2 - c25_km2 - c26_km2 - c27_km2 - c28_km2
glwdv2_perc_1km_nopeat    = glwdv2_perc_1km -c22_perc- c23_perc- c24_perc- c25_perc- c26_perc- c27_perc- c28_perc


# Save to file
writeRaster(glwdv2_areakm2_1km_nopeat, '../output/results/riv_yield_predictors/grids/aggregated/glwdv2_areakm2_1km_nopeat.tif', overwrite=T)
writeRaster(glwdv2_perc_1km_nopeat, '../output/results/riv_yield_predictors/grids/aggregated/glwdv2_perc_1km_nopeat.tif', overwrite=T)
