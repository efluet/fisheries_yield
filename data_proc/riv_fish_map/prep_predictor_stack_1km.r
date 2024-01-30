# Read predictor grids: Q, Pop, MAMax, Temp
# Rescale to 5km 10km



# /----------------------------------------------------------------------------#
#/  Discharge
q_dls <- rast('../data/discharge/dis_dls/500mq_dkls')
# writeRaster(q_dls, '../data/discharge/dis_dls/500mq_dkls.tif', overwrite=TRUE) # , options=c("TFW=YES")) # "COMPRESS=NONE", 

# Aggregate to 1km
q_dls_1km <- aggregate(q_dls, fact=2, fun=max, cores=8)

# Convert units: 1 decaliter = 0.01 cubic meter
q_cms_1km = q_dls_1km * 0.01
# q_cls_1km <- app(q_cls_1km, fun=function(x) {x * 0.01}, cores =8)

# Write to file
writeRaster(q_cms_1km, '../data/discharge/dis_dls/q_cms_1km.tif', overwrite=TRUE)# , options=c("TFW=YES")) # "COMPRESS=NONE", 


# /----------------------------------------------------------------------------#
#/   Read MAMax                                                   -------------
mamax <- rast('../data/giemsd15/giemsd15/giems_d15_v10.tif')


# Function reclassifying pixels
f <- function(x) { 
  if((x==1 | x==2)) { 1
  }else{ 0} }

mamax[mamax==2] <- 1
mamax[mamax==3] <- 0

# Aggregate from 500m to 1km
mamax_1km <- aggregate(mamax, fact=2, fun=sum)

# Save to file
writeRaster(mamax_1km, '../data/giemsd15/giems_d15_v10_mamax_1km.tif', overwrite=TRUE)



# /----------------------------------------------------------------------------#
#/ Population; NATIVELY AT 1KM
pop <- raster('../data/pop/gpw_v4_population_count_rev11_2015_30_sec.tif')
pop_10km <- aggregate(pop, fact=10, fun=sum)

writeRaster(pop_10km, '../data/pop/pop_10km.tif', overwrite=TRUE)



# /----------------------------------------------------------------------------#
#/ Read temperature;  NOT USED
temp <- rast('../data/waterTemp/waterTemperature_average_1998_2014.tif')
# Conver to degree Celcius
temp <- temp - 273
# temp <- aggregate(temp, fact=10, fun=mean)
temp_1km <- terra::resample(temp, q_cls, method='bilinear') #, threads=TRUE)
# temp_1km <- log(temp_1km)

# Save to file
writeRaster(temp_1km, '../data/waterTemp/temp_1km.tif', overwrite=TRUE)







# Apply function that changes MAMin & MAMax to 1, rest to 0
# This step takes several hours on the 500m grid.
# mamax <- calc(mamax, fun=f, progress='text')
# mamax <- lapp(mamax, fun=f,  cores=4) # progress='text',

# matrix for classification. This matrix must have 1, 2 or 3 columns. If there are three columns, the first two columns are "from" "to" of the input values, and the third column "becomes" has the new value for that range.

# m <- c(1, 1, 1,
#        2, 2, 1,
#        3, 3, 0)
# rclmat <- matrix(m, ncol=3, byrow=TRUE)

# q <- raster('../../../Chap3_holocene_global_wetland_loss/data/cru_discharge/Global_CRU2000Corrected_Discharge_aLTM_30min.ascii')
# q <- disaggregate(q, fact=6, method='')
# q <- aggregate(q, fact=10, method=mean)
# q <- log(q)