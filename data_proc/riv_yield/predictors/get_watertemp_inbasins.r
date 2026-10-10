library(raster)
library(here)
library(rgeos)
library(rgdal)
here()


# /--------------------------------------------
#/  RIVER BASINS 

# read basin shapefile 
rb <- readOGR('../data/river_basins/catch_bas_all_dissolved_v2.shp')


rb_data = rb@data
rb_data$ID <- as.numeric(rownames(rb@data))

# rasterize
r <- raster(ncol=360*2, nrow=180*2)
rb_r <- rasterize(rb, r, field = rb@data[c('NAME')], #, fun = "mean", 
                     update = TRUE, updateValue = "NA")

plot(rb_r)
# 



# /-----------------------------------------
#/ WATER TEMP
wt <- raster('../data/waterTemp/waterTemperature_average_1998_2014.tif')



# Extract
x <- raster::extract(wt, rb, fun=mean, na.rm=T, df=T)

names(x) <- c('ID', 'waterTemp_avg_1998_2014')
x$average_1998_2014 <- round(x$waterTemp_avg_1998_2014,2) - 273
x$ID <- x$ID - 1

# /----------------------------------------#
#/ Join to basin name 
xj <- left_join(x, rb_data, by='ID')


# /--------------------------------#
#/  SAVE FILE 
write.csv(xj, '../output/waterTemp/waterTemp_average_1998_2014.csv', row.names = F)
