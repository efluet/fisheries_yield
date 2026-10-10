# Calculate reservoir yield per GDW reservoirs


# /----------------------------------------------------------------------------#
#/   Get training reservoir points data                               ----------
cs <- st_read('../output/results/res_train_yield/cs_reserv_catch_2024_wpreds_v10.gpkg')



# /----------------------------------------------------------------------------#
#/    Fit regression parameters

lm_reserv <- lm(log10CATCH_tonnesyr ~ log10AREA_km2 + temp + log10pop_buf, data=cs)
summary(lm_reserv)

# lm_reserv_t <- lm_reserv %>% tidy()
# summary(lm_reserv)



# /----------------------------------------------------------------------------#
#/    Read in GDW barriers point shapefile                              -------
gdw_barriers <- 
  st_read('../data/GDW/GDW_v0_2_beta/GDW_v0_2_beta_shp/GDW_barriers_v0_2.shp') %>%
  dplyr::select(GDW_ID, RES_NAME, DAM_NAME, COUNTRY,LAKE_CTRL, TIMELINE, AREA_SKM) %>%
  dplyr::mutate(LON = sf::st_coordinates(.)[,1],
                LAT = sf::st_coordinates(.)[,2]) %>%
  rename(AREA_km2 = AREA_SKM) %>%
  mutate(log10AREA_km2 = log10(AREA_km2))
  # st_drop_geometry()

# Filter reservoirs/barriers by attributes
gdw_barriers = gdw_barriers[gdw_barriers$AREA_km2 >= 0.1,]
gdw_barriers = gdw_barriers[is.na(gdw_barriers$LAKE_CTRL),]
gdw_barriers = gdw_barriers[is.na(gdw_barriers$TIMELINE) | gdw_barriers$TIMELINE=='Modified',]


# /----------------------------------------------------------------------------#
#/   Extract temperature per GDW point                                ----------

# Get temp grid.
temp_1km <- rast('../data/waterTemp/temp_1km.tif')

# Extract temp in reservoir
gdw_barriers <- 
  gdw_barriers %>% 
  st_as_sf() %>% 
  mutate(temp = terra::extract(temp_1km, gdw_barriers, fun=mean, na.rm=T)[,2])



# /----------------------------------------------------------------------------#
#/   Extract POPULATION in buffer for all GDW reservoirs              ----------


# Get population raster
pop <- rast('../data/pop/gpw_v4_population_count_rev11_2015_30_sec.tif')

# Create buffer around reservoir polygons;  as multiples of the ~500m pixels
gdw_barriers_buf <- st_buffer(gdw_barriers, 0.0041666667 * 2)

# Summarize population in each reservoir buffer
gdw_barriers <- 
  gdw_barriers %>%  
  mutate(pop_buf = terra::extract(pop, gdw_barriers_buf, fun=mean, ID=TRUE, na.rm=T)[,2]) %>% 
  mutate(pop_buf = ifelse(pop_buf==0, 10^-10, pop_buf)) %>% 
  filter(!is.na(pop_buf)) %>% 
  mutate(log10pop_buf = log10(pop_buf))


# /----------------------------------------------------------------------------#
#/   Run predictions over GDW                                         ----------

gdw_barriers <- 
  bind_cols(gdw_barriers,
            predict.lm(lm_reserv, 
                       newdata=gdw_barriers[,c('log10AREA_km2', 'log10pop_buf','temp')], interval='prediction') %>%
            data.frame() %>%
            mutate(res_yield_tonnesyr = 10^fit)) %>% 
            mutate(uncert_range = (10^upr - 10^lwr)) %>% 
            dplyr::select(-fit, -upr, -lwr)


# glimpse(gdw_barriers)
sum(gdw_barriers$res_yield_tonnesyr, na.rm=T) #/10^6
sqrt(sum(gdw_barriers$uncert_range, na.rm=T)^2) #/10^6



# /----------------------------------------------------------------------------#
#/   Save reservoir points with yield

st_write(gdw_barriers, 
         '../output/results/res_yield_gdw/GDW_barriers_v0_2_resyield_102024.gpkg', 
         delete_layer=T)






#$$$$$$$$$$$$$$
# Summarize population per reservoir; # Run buffer extraction
# gdw_barriers_buf_pop <- 
# terra::extract(pop, gdw_barriers, fun=sum, ID=TRUE, na.rm=T) %>% 
# mutate(pop_buf = ifelse(gpw_v4_population_count_rev11_2015_30_sec==0, 10^-10, gpw_v4_population_count_rev11_2015_30_sec)) %>% 
# mutate(log10pop_buf = log10(pop_buf))

# Join the pop buffer to predictor table 
# gdw_barriers[,'log10pop_buf'] <- gdw_barriers_buf_pop$log10pop_buf


