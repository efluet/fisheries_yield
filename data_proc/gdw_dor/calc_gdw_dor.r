
# /---------------------------------------------------------------------------#
#/   Accumulated GDW capacity 
#    Representative maximum storage capacity of reservoir; in million cubic meters
gdw_cap_acc <- rast('../output/dor/GDW_cap_acc_global_v01.tif')
gdw_cap_acc <- crop(gdw_cap_acc, com_ext) #, snap='near')


# /---------------------------------------------------------------------------#
#/   Discharge ; 
# cubic meter per second

q_cms_1km <- rast('../data/discharge/dis_dls/q_cms_1km.tif')
q_cms_1km <- extend(q_cms_1km, com_ext, snap="near")
ext(q_cms_1km) <- com_ext
# make annual
q_cms_1km <- q_cms_1km * 86400 * 365.25 / 10^6
q_cms_1km[q_cms_1km==0] <- NA


# /---------------------------------------------------------------------------#
#/   Calculate DOR 
gdw_dor <- gdw_cap_acc / q_cms_1km  # *100

# Set caps
# In this study, we capped the DOR at 100%, which limits all multi-year reservoirs to the same maximum DOR. 
gdw_dor[gdw_dor > 1] <- 1
# Set lower cap?
# gdw_dor[gdw_dor < 2] <- NA

# Apply the reservoir mask
gdw_dor <- gdw_dor * gdw_mask


# Save to file
writeRaster(gdw_dor, '../output/dor/gdw_dor_v8.tif', overwrite=TRUE)
