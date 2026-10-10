

# /----------------------------------------------------------------------------#
#/   Get reservoir points

gdw_barriers <- st_read('../output/results/res_yield_gdw/GDW_barriers_v0_2_resyield_102024.shp') %>% 
                rename(res_yield = rs_yld_)


gdw_barriers_robin <- st_transform(gdw_barriers, crs("+proj=robin")) %>% 
                      dplyr::mutate(LON_robin = sf::st_coordinates(.)[,1],
                                    LAT_robin = sf::st_coordinates(.)[,2])


# gdw_barriers_robin$orderrank <- rank(gdw_barriers_robin$res_yield, ties.method="first")
gdw_barriers_robin <- arrange(gdw_barriers_robin, res_yield)


# /----------------------------------------------------------------------------#
#/   Make map of riverine fish yield

res_yield_map <- ggplot() +
  
  # countries background & outline
  geom_sf(data=countries_robin_sf, fill='grey92', color=NA) +
  
  # add outline of background countries
  geom_sf(data=coastsCoarse_robin_sf, color='grey20', fill=NA, size=0.1, lwd=0.1) +
  
  # Reservoirs
  geom_point(data=gdw_barriers_robin, aes(x=LON_robin, y=LAT_robin, color=res_yield), size=0.20) +
  
  geom_point(data=subset(gdw_barriers_robin, res_yield>=10^-1 & res_yield<10^0),
             aes(x=LON_robin, y=LAT_robin), color='#fdee68', size=0.1) +
  
  geom_point(data=subset(gdw_barriers_robin, res_yield>=10^0 & res_yield<10^1),
             aes(x=LON_robin, y=LAT_robin), color='#79d27c', size=0.15) +
  
  geom_point(data=subset(gdw_barriers_robin, res_yield>=10^1 & res_yield<10^2),
             aes(x=LON_robin, y=LAT_robin), color='#44d5cd', size=0.15) +
  
  geom_point(data=subset(gdw_barriers_robin, res_yield>=10^2 & res_yield<10^3),
             aes(x=LON_robin, y=LAT_robin), color='#3333ff', size=0.15) +
  
  geom_point(data=subset(gdw_barriers_robin, res_yield>=10^3),
                 aes(x=LON_robin, y=LAT_robin), color='#000099', size=0.15) +
  
  # Tropical lines
  # geom_line(aes(x=c(-16600000, 16600000), y=c(2460000, 2460000)), size=0.1, linetype = "dashed", color='grey40') +
  # geom_line(aes(x=c(-16600000, 16600000), y=c(-2460000, -2460000)), size=0.1, linetype = "dashed", color='grey40') +
  
  # Add outline bounding box
  geom_sf(data=bbox_robin_sf, color='black', fill=NA, size=0.2) +
  
  # coord_equal() +  
  theme_raster_map() +
  # labs(title = 'Distributed FAO & Survey catch (c2)', subtitle = mod_eq) +
  
  scale_y_continuous(limits=c(-6600000, 8953595)) +
  
  scale_color_gradientn(colors=c('#fdee68','#79d27c','#44d5cd','#3333ff','#000099'),#low='#ffffcc', high='blue',
                       trans='log',
                       breaks=c(10^-1, 10^0, 10^1, 10^2, 10^3, 10^4),
                       labels=expression(10^-1, 10^0, 10^1, 10^2, 10^3, 10^4),
                       limits=c(10^-1, 10^4)) +
  
  guides(color = guide_colorbar(nbin=5, raster=F,
                               barheight = 0.4, barwidth=7, # reverse=T,
                               frame.colour=c('black'), frame.linewidth=0.3,
                               ticks.colour='black',  direction='horizontal', 
                               title = expression(paste('Fish yield per reservoir (tonnes yr'^-1*')')))) +
  
  theme(legend.position = c(0.5, 0.01), #'bottom',
        # legend.direction = 'vertical',
        plot.margin = unit(c(-2, -3, 2, -3), "mm"))

