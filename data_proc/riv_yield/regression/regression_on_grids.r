
# Read predictor grids: Q, Pop, MAMax, Temp
# Rescale to 5km 10km
# Apply regression predictors

# /----------------------------------------------------------------------------#
#/ Read temp
temp <- raster('../data/waterTemp/waterTemperature_average_1998_2014.tif')
temp <- aggregate(temp, fact=10, fun=mean) - 273
temp <- log(temp)

# /----------------------------------------------------------------------------#
#/ Read MAMax
mamax <- raster('../data/giemsd15/giems_d15_v10.tif')
# mamax <- crop(mamax, extent(6, 6.5, 5, 5.5))


f <- function(x) { 
  if(x %in% c(1,2)) { 1
  }else{ 0} }

# Apply function that changes MAMin & MAMax to 1, rest to 0
mamax <- calc(mamax, fun=f, progress='text')#, filename='output.tif')

area <- area(mamax)
mamax <- mamax * area
mamax <- aggregate(mamax, fact=10, fun=sum)



# /----------------------------------------------------------------------------#
#/  Dischage
# q <- raster('../../../Chap3_holocene_global_wetland_loss/data/cru_discharge/Global_CRU2000Corrected_Discharge_aLTM_30min.ascii')
# q <- disaggregate(q, fact=6, method='')
# q <- aggregate(q, fact=10, method=mean)
# q <- log(q)

q <- raster('../data/discharge/500mQ_dkls')

# /----------------------------------------------------------------------------#
#/ Pop
pop <- raster('../data/pop/gpw_v4_population_count_rev11_2015_30_sec.tif')
pop <- aggregate(pop, fact=100, fun=sum)


# Stack all predictions
predstack <- stack(q)#, temp) #, pop)




# /----------------------------------------------------------------------------#
#/ function that applies the LM


funa <- function(x) { 
    if(is.na(x)) { c(NA) } else {
        1.83 + 1.05*x[1] #+ 0.45*x[2] #+ 0.24*x[3]
    }
}

# rs4 <- calc(s, fun=function(x){x[1]+x[2]*x[3]})


r <- calc(predstack, funa)
writeRaster(r, '../output/distrib_grid/regression_grid.tif', overwrite=TRUE)
