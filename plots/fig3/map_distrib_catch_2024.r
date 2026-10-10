

# /----------------------------------------------------------------------------#
#/  Read and prep riverine catch grids

catch_distrib_1km <- rast('../output/results/riv_yield_distrib/riv_yield_distrib_lm2c_catch.c2_1km_2024_rep_cap_v10.tif')

# Aggregate to 50km for visualization
catch_distrib_50km <- aggregate(catch_distrib_1km, fact=50, fun=sum, na.rm=FALSE)

# convert from megaton to tons
catch_distrib_50km <- catch_distrib_50km * 10^6

catch_distrib_50km_df <- WGSraster2dfROBIN(catch_distrib_50km)
names(catch_distrib_50km_df) <- c('x','y','catch')

catch_distrib_50km_df <- catch_distrib_50km_df %>%
                          # Keep only positives; modified to keep above 1kg/yr
                          filter(catch > 10^-1) %>%
                          # set lower bound at 10<-1
                          mutate(catch=ifelse(catch<10^-1, 10^-1, catch),
                                 catch=ifelse(catch>10^4, 10^4, catch))



# /----------------------------------------------------------------------------#
#/   Make map of riverine fish yield

riv_yield_map <-
  ggplot() +
  
  # countries background & outline
  geom_sf(data=countries_robin_sf, fill='grey92', color=NA) +
  
  # Add wetloss raster  
  geom_raster(data=catch_distrib_50km_df, aes(x=x, y=y, fill=catch)) +
  
  # add outline of background countries
  geom_sf(data=coastsCoarse_robin_sf, color='grey20', size=0.1, lwd=0.1) +
  
  # Add outline bounding box
  geom_sf(data=bbox_robin_sf, color='black', fill=NA, size=0.2) +
  
  # coord_equal() +  
  theme_raster_map() +
  # labs(title = 'Distributed FAO & Survey catch (c2)', subtitle = mod_eq) +
  
  scale_y_continuous(limits=c(-6600000, 8953595)) +

  scale_fill_gradientn(colors=c('#fdee68','#79d27c','#44d5cd','#3333ff','#000099'),#low='#ffffcc', high='blue',
                      trans='log',
                      breaks=c(10^-1, 10^0, 10^1, 10^2, 10^3, 10^4),
                      labels=expression(10^-1, 10^0, 10^1, 10^2, 10^3, 10^4),
                      limits=c(10^-1, 10^4)) +
  
  
  guides(fill = guide_colorbar(nbin=5, raster=F,
                               barheight = 0.4, barwidth=7, # reverse=T,
                               frame.colour=c('black'), frame.linewidth=0.3,
                               ticks.colour='black',  direction='horizontal', 
                               title = expression(paste('Riverine fish yield (tonnes yr'^-1*'cell'^-1*')')))) +

  
  theme(legend.position = c(0.5, 0.01), #'bottom',
        # legend.direction = 'vertical',
        plot.margin = unit(c(-2, -3, 2, -3), "mm"))


