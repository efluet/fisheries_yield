

# /----------------------------------------------------------------------------#
#/    Read in GDW barriers point shapefile 
gdw_barriers <- st_read('../data/GDW/GDW_v0_2_beta/GDW_v0_2_beta_shp/GDW_barriers_v0_2.shp') %>% 
                dplyr::select(GDW_ID, RES_NAME, DAM_NAME, COUNTRY,LAKE_CTRL, TIMELINE, AREA_SKM) %>% 
                dplyr::mutate(LON = sf::st_coordinates(.)[,1],
                              LAT = sf::st_coordinates(.)[,2]) #%>% 
                # st_drop_geometry()



# Filter reservoirs/barriers by attributes
gdw_barriers = gdw_barriers[gdw_barriers$AREA_SKM >= 0.1,]
gdw_barriers = gdw_barriers[is.na(gdw_barriers$LAKE_CTRL),]
gdw_barriers = gdw_barriers[is.na(gdw_barriers$TIMELINE) | gdw_barriers$TIMELINE=='Modified',]


# /----------------------------------------------------------------------------#
#/   Calculate yield depending on latitude



gdw_barriers <- gdw_barriers %>% 
  # Make latitude group
  mutate(lat_group = ifelse(LAT <= -23 | LAT >= 23, 'Temperate', NA),
         lat_group = ifelse(LAT <  23  & LAT > -23, 'Tropical', lat_group)) %>% 
  # Compute yield based on latitude group
  mutate(res_yield = ifelse(lat_group == 'Temperate', 10^(log10(AREA_SKM) *0.7866 + 0.327), NA),
         res_yield = ifelse(lat_group == 'Tropical' , 10^(log10(AREA_SKM) *0.7461 + 1.091), res_yield))




glimpse(gdw_barriers)
hist(gdw_barriers$res_yield)
sum(gdw_barriers$res_yield)


# /----------------------------------------------------------------------------#
#/   Save barriers with yield

st_write(gdw_barriers, '../output/gdw/GDW_barriers_v0_2_resyield.shp', delete_layer=T)
