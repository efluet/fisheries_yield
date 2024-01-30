
library(sp)
library(rgdal)
library(rgeos)


# /-----------------------------------------------------------------------------
#/    get polygon of continent outline                                     -----
# FIXED - SO THERE'S NO LINE STRETCHING BETWEEN ALASKA-KAMATCHAKA when plotting map.
# natearth_dir <- "../../chap5_global_inland_fish_catch/data/gis/nat_earth"
natearth_dir <- "../data/nat_earth"

# Set common extent lat-long bounds
com_ext <- extent(-180, 180,  -56, 85)

# read and reproject outside box
bbox <- readOGR(natearth_dir, "ne_110m_wgs84_bounding_box") 
bbox <- raster::crop(bbox, com_ext)  # Set smaller extent, excl. Antarctica
bbox_robin <- spTransform(bbox, CRS("+proj=robin"))  # reproject bounding box
bbox_robin_df <- fortify(bbox_robin)


#/    get polygon of continent outline                                     -----
library(rworldmap)
data(coastsCoarse)
# crs(bbox) <- crs(coastsCoarse)
coastsCoarse <- gIntersection(coastsCoarse, bbox, byid = TRUE, drop_lower_td = TRUE)
coastsCoarse <- raster::crop(coastsCoarse, com_ext)  # Set smaller extent, excl. Antarctica
coastsCoarse_robin <- spTransform(coastsCoarse, CRS("+proj=robin"))
coastsCoarse_robin <- as(coastsCoarse_robin, 'SpatialLinesDataFrame')
coastsCoarse_robin_df <- fortify(coastsCoarse_robin)


# read and reproject countries  -  and ticks to  Robinson 
# natearth_dir <- "../../chap5_global_inland_fish_catch/data/gis/nat_earth"
countries <- readOGR(natearth_dir, "ne_110m_admin_0_countries")
countries <- raster::crop(countries, com_ext)  # Set smaller extent, excl. Antarctica
countries_robin <- spTransform(countries, CRS("+proj=robin"))
countries_robin_df <- fortify(countries_robin)





# /-----------------------------------------------------------------------------
#/    SF !!! -- get polygon of continent outline                                     -----

natearth_dir <- "../data/nat_earth"

# Set common extent lat-long bounds
com_ext <- extent(-180, 180,  -56, 85)

# read and reproject outside box
bbox_robin_sf <- st_read(natearth_dir, "ne_110m_wgs84_bounding_box") %>% 
                  st_crop(com_ext) %>% 
                  st_transform(CRS("+proj=robin")) 


library(rworldmap)
data(coastsCoarse)
coastsCoarse_robin_sf <- st_as_sf(coastsCoarse) %>% 
                          st_crop(com_ext) %>% 
                          st_transform(CRS("+proj=robin")) 




countries_robin_sf <- st_read(natearth_dir, "ne_110m_admin_0_countries") %>% 
                      st_crop(com_ext) %>% 
                      st_transform(CRS("+proj=robin")) 
                      
  
# countries <- raster::crop(countries, com_ext)  # Set smaller extent, excl. Antarctica
# countries_robin <- spTransform(countries, CRS("+proj=robin"))
# countries_robin_df <- fortify(countries_robin)


# bbox <- raster::clip(bbox, com_ext)  # Set smaller extent, excl. Antarctica
# bbox_robin <- spTransform(bbox, CRS("+proj=robin"))  # reproject bounding box
# bbox_robin_df <- fortify(bbox_robin)


#/    get polygon of continent outline                                     -----
library(rworldmap)
data(coastsCoarse)
# crs(bbox) <- crs(coastsCoarse)
coastsCoarse <- gIntersection(coastsCoarse, bbox, byid = TRUE, drop_lower_td = TRUE)
coastsCoarse <- raster::crop(coastsCoarse, com_ext)  # Set smaller extent, excl. Antarctica
coastsCoarse_robin <- spTransform(coastsCoarse, CRS("+proj=robin"))
coastsCoarse_robin <- as(coastsCoarse_robin, 'SpatialLinesDataFrame')
coastsCoarse_robin_df <- fortify(coastsCoarse_robin)


# read and reproject countries  -  and ticks to  Robinson 
# natearth_dir <- "../../chap5_global_inland_fish_catch/data/gis/nat_earth"
countries <- readOGR(natearth_dir, "ne_110m_admin_0_countries")
countries <- raster::crop(countries, com_ext)  # Set smaller extent, excl. Antarctica
countries_robin <- spTransform(countries, CRS("+proj=robin"))
countries_robin_df <- fortify(countries_robin)









# ### get country shpfiles =======================================================
# 
# library(rnaturalearth)
# 
# # read and reproject countries  -  and ticks to  Robinson 
# natearth_dir <- '../data/nat_earth'
# countries <- readOGR(natearth_dir, 'ne_110m_admin_0_countries')
# countries_df <- fortify(countries)
# countries_robin <- spTransform(countries, CRS('+proj=robin'))
# countries_robin_df <- fortify(countries_robin)
# 
# 
# # read and reproject outside box
# # bbox <- ne_download(scale = 'small', type='wgs84_bounding_box', category='physical', returnclass = 'sp')
# bbox <- readOGR(natearth_dir, 'ne_110m_wgs84_bounding_box')
# bbox_robin <- spTransform(bbox, CRS('+proj=robin'))  # reproject bounding box
# bbox_robin_df <- fortify(bbox_robin)
# 
# 
# 
# library(sf)
# 
# 
# # /----------------------------------------------------------------------------#
# #/    get polygon of continent outline                                     -----
# library(rworldmap)
# data(coastsCoarse)
# coastsCoarse_robin <- spTransform(coastsCoarse, CRS('+proj=robin')) 
# coastsCoarse_robin_df <- fortify(coastsCoarse_robin)
# 
# 
# 
# ### DOESN'T WORK - FIX DATELINE CROSSING IN ROBINSON PROJECTION
# coastsCoarse_sf <- st_as_sf(coastsCoarse)
# 
# coastsCoarse_sf_dateline <- st_wrap_dateline(coastsCoarse_sf, options = c('WRAPDATELINE=YES', 'DATELINEOFFSET=0'))
# 
# coastsCoarse_sf_trans <- st_transform(coastsCoarse_sf_dateline, 54030)
# 
# coastsCoarse_sf_trans_st <- as(coastsCoarse_sf_trans, 'Spatial')
# 
# 
