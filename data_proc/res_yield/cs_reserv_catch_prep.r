
# TODO: Clean up temperate reservoirs with dubious area estimate;
#       For ex:  Green Grove Zimbabwe,  San Pedro de Taumb Brasil,

# /----------------------------------------------------------------------------#
#/  Read database of waterbody case studies 
cs <- 
  # read.csv('../../../Chap5_inland_fish_catch/output/case_studies/cs_wCoords_cparea_fdens_compil.csv') %>% 
  read.csv('../../../Chap5_inland_fish_catch/output/case_studies/cs_wCoords_cparea_fdens_compil_2024.csv') %>% 
  filter(WB_TYPE == 'Reservoir') %>% 
  dplyr::select(WB_NAME, WB_NR, WB_TYPE, COUNTRY, Year, 
         CATCH, CATCHUNITS, CPAREA, CPAREAUNITS, 
         WBAREA, AREAunit, AREA_COMPIL, AREA_COMPIL_HA, lat, long, REF_NAME) %>%
  # Compute catch from CPUA
  mutate(CATCH_tonnesyr = ifelse(is.na(CATCH) & !is.na(CPAREAUNITS) & !is.na(AREA_COMPIL_HA), CPAREA*AREA_COMPIL_HA/1000, CATCH)) %>% 
  # Concatenate years and sources
  group_by(WB_NAME, WB_NR, COUNTRY) %>%
  mutate(Year = paste0(Year, collapse = ", "),
         REF_NAME = paste0(REF_NAME, collapse = "; ")) %>% 
  ungroup() %>% 
  # Average per waterbody
  group_by(WB_NAME, WB_NR, COUNTRY, Year, REF_NAME) %>%
  summarise(CATCH_tonnesyr = mean(CATCH_tonnesyr, na.rm=T),
            CPAREA = mean(CPAREA, na.rm=T),
            AREA_km2 = mean(AREA_COMPIL_HA*0.01, na.rm=T),
            lat=mean(lat, na.rm=T),
            long=mean(long, na.rm=T)) %>% 
  ungroup() %>% 
  # Make latitude group
  mutate(LAT_GROUP = ifelse(lat <= -23 | lat >= 23, 'Temperate', NA),
         LAT_GROUP = ifelse(lat <  23  & lat > -23, 'Tropical', LAT_GROUP)) %>% 
  # Log-transform
  mutate(log10CATCH_tonnesyr = log10(CATCH_tonnesyr),
         log10AREA_km2 = log10(AREA_km2)) %>% 
  # Remove missing rows
  filter(!is.na(LAT_GROUP),
         !is.na(CATCH_tonnesyr),
         !is.na(AREA_km2)) %>% 
  rename(CPAREA_kghayr=CPAREA,
         SOURCES= REF_NAME,
         YEARS=Year,
         LAT=lat,
         LONG=long) 

glimpse(cs)

##. Exclude bc it contains aquaculture ponds
cs <- cs %>% filter(WB_NAME != 'Bung Boraped')


# /----------------------------------------------------------------------------#
#/ Append Russia and South Africa reservoir from Cathy
cathy_temp_res <- 
  read.csv('../data/reservoir_yield/ResYield_data_modeling_Feb2018_temperate.csv') %>% 
  dplyr::select(Reservoir, Country, Area..km2., Latitude, Longitude, Obs.Yield..T.yr., logA, logYield, Source) %>% 
  mutate(lat_group = 'Temperate')

names(cathy_temp_res) <- c('WB_NAME', 'COUNTRY', 'AREA_km2', 'LAT', 'LONG', 'CATCH_tonnesyr', 
                           'log10AREA_km2', 'log10CATCH_tonnesyr', 'SOURCES', 'LAT_GROUP')

# glimpse(cathy_temp_res)

# /----------------------------------------------------------------------------#
#/  Append 46 tropical reservoirs from Cathy
cathy_trop_res <- 
  read.csv('../data/reservoir_yield/ResYield_data_modeling_Feb2018_tropical_reserv_reg.csv') %>% 
  dplyr::select(WB.Name, Country, date.of.data, Area..km2., Latitude, Longitude, Observed.Catch..t., logA, logC, source) %>% 
  mutate(lat_group = 'Tropical')

names(cathy_trop_res) <- c('WB_NAME', 'COUNTRY', 'YEARS', 'AREA_km2', 'LAT', 'LONG', 'CATCH_tonnesyr', 
                           'log10AREA_km2', 'log10CATCH_tonnesyr', 'SOURCES', 'LAT_GROUP')


# /----------------------------------------------------------------------------#
#/  Combine reserv yield data source                                 -----------

cs <- cs %>% 
      bind_rows(., cathy_temp_res) %>% 
      bind_rows(., cathy_trop_res) %>% 
      arrange(WB_NAME) %>% 
      dplyr::select(WB_NAME, COUNTRY, LAT, LONG, YEARS, 
             AREA_km2, CPAREA_kghayr, CATCH_tonnesyr, 
             log10AREA_km2, log10CATCH_tonnesyr, SOURCES, LAT_GROUP)

# Save for Cathy
if(1){
  write.csv(cs, '../output/results/res_train_yield/cs_reserv_catch_2024.csv', row.names = F)}


# /----------------------------------------------------------------------------#
#/  Extract temperature                                               ----------

temp_1km <- rast('../data/waterTemp/temp_1km.tif')

cs_pts <- 
  cs %>% 
  filter(!is.na(LAT)) %>% 
  st_as_sf(., coords = c("LONG","LAT"), remove = FALSE) %>% 
  st_set_crs(st_crs(4326)) %>% 
  st_as_sf() %>% 
  mutate(temp = terra::extract(temp_1km, cs_pts, fun=mean, na.rm=T)[,2]) %>% 
  mutate(predC = predict(lm(log10CATCH_tonnesyr ~ log10AREA_km2 + temp, data=cs_pts)))

glimpse(cs_pts)
# lm_res <- lm(log10CATCH_tonnesyr ~ log10AREA_km2 + temp, data=cs_pts)
# summary(lm_res)




# /----------------------------------------------------------------------------#
#/ Scatterplot of regressions

scatterplot_reservoir_yield_lm <-
  
  ggplot(data=cs, aes(x=log10AREA_km2, y=log10CATCH_tonnesyr, color=LAT_GROUP))+
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE, size=0.4) +
  
  geom_point(data=cs, aes(x=log10AREA_km2, y=log10CATCH_tonnesyr, color=LAT_GROUP), size=0.15) +
  geom_point(data=cs, aes(x=log10AREA_km2, y=log10CATCH_tonnesyr, color=LAT_GROUP), size=0.15) +
  
  scale_color_manual(labels = c(temp_label, trop_label), values = c("blue", "red")) +
  scale_x_continuous(breaks=pretty_breaks()) +
  scale_y_continuous(breaks=pretty_breaks(n=6)) +
  line_plot_theme() +
  theme(legend.position = c(0.01, 0.93),
        legend.title = element_blank())


ggsave('../output/figures/scatterplot_reservoir_yield_lm_v4.png',
       scatterplot_reservoir_yield_lm,
       width= 70, height=65, dpi=500, units='mm')









# /----------------------------------------------------------------------------#
#/ Prep for regression

# Average rows to remove duplicates
cs <- cs %>% 
      group_by(WB_NAME, COUNTRY, LAT_GROUP) %>% 
      summarise(across(everything(), mean)) %>%  #list(min = min))) %>% 
      ungroup()

glimpse(cs)

cs_temp <- cs %>% filter(LAT_GROUP=='Temperate')
cs_trop <- cs %>% filter(LAT_GROUP=='Tropical')


lm_temp <- lm(log10CATCH_tonnesyr ~ log10AREA_km2, data=cs_temp) #%>% tidy()
lm_trop <- lm(log10CATCH_tonnesyr ~ log10AREA_km2, data=cs_trop) #%>% tidy()

library(broom)
## Make labels 
temp_label <- paste0("Temperate; n=", nrow(cs_temp), '; R^2=', round(glance(lm_temp)$r.squared,2), '; logC=', 
                     round(tidy(lm_temp)$estimate[1],2),'+', 
                     round(tidy(lm_temp)$estimate[2],2), '×logA')

trop_label <- paste0("Tropical; n=", nrow(cs_trop), '; R^2=', round(glance(lm_trop)$r.squared,2), '; logC=', 
                     round(tidy(lm_trop)$estimate[1],2),'+', 
                     round(tidy(lm_trop)$estimate[2],2), '×logA')



# /----------------------------------------------------------------------------#
#/ Scatterplot of regressions

scatterplot_reservoir_yield_lm <-
  
  ggplot(data=cs, aes(x=log10AREA_km2, y=log10CATCH_tonnesyr, color=LAT_GROUP))+
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE, size=0.4) +
  
  geom_point(data=cs, aes(x=log10AREA_km2, y=log10CATCH_tonnesyr, color=LAT_GROUP), size=0.15) +
  geom_point(data=cs, aes(x=log10AREA_km2, y=log10CATCH_tonnesyr, color=LAT_GROUP), size=0.15) +
  
  scale_color_manual(labels = c(temp_label, trop_label), values = c("blue", "red")) +
  scale_x_continuous(breaks=pretty_breaks()) +
  scale_y_continuous(breaks=pretty_breaks(n=6)) +
  line_plot_theme() +
  theme(legend.position = c(0.01, 0.93),
        legend.title = element_blank())


ggsave('../output/figures/scatterplot_reservoir_yield_lm_v4.png',
       scatterplot_reservoir_yield_lm,
       width= 70, height=65, dpi=500, units='mm')



