# Read predictor grids: Q, Pop, MAMax, Temp
# Rescale to 5km 10km



# /----------------------------------------------------------------------------#
#/  Dischage
# q <- raster('../../../Chap3_holocene_global_wetland_loss/data/cru_discharge/Global_CRU2000Corrected_Discharge_aLTM_30min.ascii')
# q <- disaggregate(q, fact=6, method='')
# q <- aggregate(q, fact=10, method=mean)
# q <- log(q)

q_dls <- raster('../data/discharge/dis_dls/500mq_dkls')

# Aggregate to 10km
q_dls_10km <- aggregate(q_dls, fact=20, fun=sum)

# Convert units: 1 decaliter = 0.01
q_cls_10km = q_dls_10km * 0.01

writeRaster(q_cls_10km, '../data/discharge/dis_dls/q_cls_10km.tif', overwrite=TRUE)


# /----------------------------------------------------------------------------#
#/ Read MAMax
mamax <- raster('../data/giemsd15/giems_d15_v10.tif')


f <- function(x) { 
  if(x %in% c(1,2)) { 1
  }else{ 0} }

# Apply function that changes MAMin & MAMax to 1, rest to 0
# This step takes several hours on the 500m grid.
mamax <- calc(mamax, fun=f, progress='text')#, filename='output.tif')

mamax_10km <- aggregate(mamax, fact=20, fun=sum)

# 
writeRaster(mamax_10km, '../data/giemsd15/giems_d15_v10_mamax_10km.tif', overwrite=TRUE)



# /----------------------------------------------------------------------------#
#/ Population
pop <- raster('../data/pop/gpw_v4_population_count_rev11_2015_30_sec.tif')
pop_10km <- aggregate(pop, fact=10, fun=sum)

writeRaster(pop_10km, '../data/pop/pop_10km.tif', overwrite=TRUE)



# /----------------------------------------------------------------------------#
#/ Read temperature; natively at 10km
temp <- raster('../data/waterTemp/waterTemperature_average_1998_2014.tif')
# Conver to degree Celcius
temp <- temp - 273
# temp <- aggregate(temp, fact=10, fun=mean)
temp_1km <- resample(temp, fact=10, fun=mean)
temp_1km <- log(temp_1km)


