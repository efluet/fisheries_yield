
# /----------------------------------------------------------------------------#
#/    aggregate Reservoir and DOR to 1km

com_ext <- ext(-180, 180, -56, 84)


# Reservoir mask in percent
res_mask_percent <- rast('../data/fromGG/FishYieldsExport/res_mask_percent1.tif')
res_mask_percent <- aggregate(res_mask_percent, fact=2, fun=mean, na.rm=T, cores=8)
res_mask_percent <- extend(res_mask_percent, com_ext, snap="near")
ext(res_mask_percent) <- com_ext
writeRaster(res_mask_percent, '../data/fromGG/FishYieldsExport/res_mask_percent1_1km.tif', overwrite=TRUE)


# DOR
dor1 <- rast('../data/fromGG/FishYieldsExport/dor1.tif')
dor1 <- aggregate(dor1, fact=2, fun=max, na.rm=T, cores=8)
dor1 <- extend(dor1, com_ext, snap="near")
ext(dor1) <- com_ext
writeRaster(dor1, '../data/fromGG/FishYieldsExport/dor1_1km.tif', overwrite=TRUE)



# Distance 2
dist2 <- rast('../data/fromGG/FishYieldsExport/distance_2.tif')
dist2 <- aggregate(dist2, fact=2, fun=max, na.rm=T, cores=8)
dist2 <- extend(dist2, com_ext, snap='near') # "near")
# dist2 <- extend(dist2, com_ext, snap='in')
ext(dist2) <- ext(-180, 180, -56, 84.00833333)
dist2 <- crop(dist2, com_ext, snap='near')
writeRaster(dist2, '../data/fromGG/FishYieldsExport/distance_2_1km.tif', overwrite=TRUE)



# Distance 5
dist5 <- rast('../data/fromGG/FishYieldsExport/distance_5.tif')
dist5 <- aggregate(dist5, fact=2, fun=max, na.rm=T, cores=8)
dist5 <- extend(dist5, com_ext, snap="near")
ext(dist5) <- com_ext
writeRaster(dist5, '../data/fromGG/FishYieldsExport/distance_5_1km.tif', overwrite=TRUE)



# Distance ALL
distall <- rast('../data/fromGG/FishYieldsExport/distance_all.tif')
distall <- aggregate(distall, fact=2, fun=max, na.rm=T, cores=8)
distall <- extend(distall, com_ext, snap="near")
ext(distall) <- com_ext
writeRaster(distall, '../data/fromGG/FishYieldsExport/distance_all_1km.tif', overwrite=TRUE)


rm(res_mask_raster, dist2, dist5, distall)





# /----------------------------------------------------------------------------#
#/    Make raster of GRAND_ID from reservoir polygons

grand_poly_mask_1km <- vect('../data/fromGG/FishYieldsExport/grand_poly_raster.shp')
grand_mask_1km <- rasterize(grand_poly_mask_1km, res_mask_percent, field="GRAND_ID")

writeRaster(grand_mask_1km, '../data/fromGG/FishYieldsExport/grandid_mask_1km.tif', overwrite=TRUE)

