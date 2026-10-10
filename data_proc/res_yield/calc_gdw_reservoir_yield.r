

# /----------------------------------------------------------------------------#
#/   Get reservoir yield & area for regression                   ----------
cs <- read.csv('../output/results/res_train_yield/cs_reserv_catch_2024.csv')

# Average rows to remove duplicates
cs <- cs %>% 
  group_by(WB_NAME, COUNTRY, LAT_GROUP) %>% 
  summarise(across(everything(), mean)) %>%  #list(min = min))) %>% 
  ungroup()

cs_temp <- cs %>% filter(LAT_GROUP=='Temperate')
cs_trop <- cs %>% filter(LAT_GROUP=='Tropical')

library(broom)
lm_temp <- lm(log10CATCH_tonnesyr ~ log10(AREA_km2), data=cs_temp) #%>% tidy()
lm_trop <- lm(log10CATCH_tonnesyr ~ log10(AREA_km2), data=cs_trop) #%>% tidy()



# /----------------------------------------------------------------------------#
#/    Read in GDW barriers point shapefile                              -------
gdw_barriers <- st_read('../data/GDW/GDW_v0_2_beta/GDW_v0_2_beta_shp/GDW_barriers_v0_2.shp') %>% 
                dplyr::select(GDW_ID, RES_NAME, DAM_NAME, COUNTRY,LAKE_CTRL, TIMELINE, AREA_SKM) %>% 
                dplyr::mutate(LON = sf::st_coordinates(.)[,1],
                              LAT = sf::st_coordinates(.)[,2]) %>%
                rename(AREA_km2 = AREA_SKM)
                # st_drop_geometry()

# Filter reservoirs/barriers by attributes
gdw_barriers = gdw_barriers[gdw_barriers$AREA_km2 >= 0.1,]
gdw_barriers = gdw_barriers[is.na(gdw_barriers$LAKE_CTRL),]
gdw_barriers = gdw_barriers[is.na(gdw_barriers$TIMELINE) | gdw_barriers$TIMELINE=='Modified',]


# /----------------------------------------------------------------------------#
#/   Calculate yield depending on latitude                        ----------

gdw_barriers <- 
  gdw_barriers %>% 
    mutate(LAT_GROUP = ifelse(LAT <= -23 | LAT >= 23, 'Temperate', NA),
           LAT_GROUP = ifelse(LAT <  23  & LAT > -23, 'Tropical', LAT_GROUP)) %>%
  # Compute yield based on latitude group
  mutate(res_yield_tonnesyr = ifelse(LAT_GROUP == 'Temperate', 10^(log10(AREA_km2) *lm_temp$coefficients[2] + lm_temp$coefficients[1]), NA),
         res_yield_tonnesyr = ifelse(LAT_GROUP == 'Tropical' , 10^(log10(AREA_km2) *lm_trop$coefficients[2] + lm_trop$coefficients[1]), res_yield_tonnesyr)) %>% 
  bind_cols(.,
            predict.lm(lm_temp, newdata=data.frame(gdw_barriers['AREA_km2']), interval='prediction') %>% 
              data.frame() %>%
              mutate(uncert_range=10^upr - 10^lwr) %>% 
              dplyr::select(-fit, -upr, -lwr)
            )

glimpse(gdw_barriers)

# res_yield_uncert <- predict.lm(lm_temp, newdata=data.frame(gdw_barriers['AREA_km2']), interval='prediction') %>% 
#   data.frame()


# glimpse(gdw_barriers)
# hist(gdw_barriers$res_yield)
sum(gdw_barriers$res_yield_tonnesyr)
sqrt(sum((gdw_barriers$uncert_range)^2))



# /----------------------------------------------------------------------------#
#/   Save reservoir points with yield

st_write(gdw_barriers, '../output/gdw/GDW_barriers_v0_2_resyield.shp', delete_layer=T)





### This is based on regressions from Cathy (pre-2024) 
# gdw_barriers <- gdw_barriers %>% 
#   # Make latitude group
#   mutate(lat_group = ifelse(LAT <= -23 | LAT >= 23, 'Temperate', NA),
#          lat_group = ifelse(LAT <  23  & LAT > -23, 'Tropical', lat_group)) %>% 
#   # Compute yield based on latitude group
#   mutate(res_yield = ifelse(lat_group == 'Temperate', 10^(log10(AREA_SKM) *0.7866 + 0.327), NA),
#          res_yield = ifelse(lat_group == 'Tropical' , 10^(log10(AREA_SKM) *0.7461 + 1.091), res_yield))
