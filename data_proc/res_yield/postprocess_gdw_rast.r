# Standardize inputs

# Mask of reservoirs at 1km
gdw_1km_ids <- rast('../output/results/res_yield_gdw/GDW_reservoirs_v0_2_GDWIDs.tif')
gdw_1km_ids_ext <- align(com_ext, gdw_1km_ids, snap="near")
gdw_1km_ids <- extend(gdw_1km_ids, gdw_1km_ids_ext, snap="near")
gdw_1km_ids[gdw_1km_ids==0] <- NA
writeRaster(gdw_1km_ids, '../output/results/res_yield_gdw/GDW_reservoirs_v0_2_GDWIDs_ex.tif')

# Mask of reservoirs FRAC
gdw_1km_frac <- rast('../output/results/res_yield_gdw/GDW_frac_1km.tif')
gdw_1km_frac_ext <- align(com_ext, gdw_1km_frac, snap="near")
gdw_1km_frac <- extend(gdw_1km_frac, gdw_1km_frac_ext)# , snap="near")
gdw_1km_frac[gdw_1km_frac==0] <- NA
writeRaster(gdw_1km_frac, '../output/results/res_yield_gdw/GDW_reservoirs_v0_2_frac_ex.tif')



# # Mask of reservoirs FRAC
# gdw_1km_frac <- rast('../output/results/res_yield_gdw/GDW_frac_1km')
# gdw_1km_ids_ext <- align(ext(glwdv2_perc_1km_nopeat), gdw_1km_ids, snap="near")
# gdw_1km_ids <- extend(gdw_1km_ids, gdw_1km_ids_ext, snap="near")
# gdw_1km_ids[gdw_1km_ids==0] <- NA
