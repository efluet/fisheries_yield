
# /----------------------------------------------------------------------------#
#/   Training data

# Get training river basins
training_rivbasins <- 
  st_read('../data/riv_yield_train_basins/river_basins/catch_bas_all_dissolved_v3.shp')

# Get training reservoir
training_reserv <- 
  read.csv('../output/results/res_train_yield/cs_reserv_catch_2024_wpreds_v05.csv') %>%  # cs_reserv_catch_2024
  filter(!is.na(LAT)) %>% 
  st_as_sf(., coords = c("LONG","LAT"), remove = FALSE) %>% 
  st_set_crs(4326) # st_crs(training_rivbasins))


# /----------------------------------------------------------------------------#
#/   Map predictor basins                                            -----------

# Generate map
train_basin_map <-
  
  ggplot()+
  
  # countries background & outline
  geom_sf(data=countries_robin_sf, fill='grey90', color='white', size=0.12) +
  
  # Coastline
  geom_sf(data=coastsCoarse_robin_sf, fill=NA, color='grey50', lwd=0.15, size=0.01) +
  
  # Add river basins
  geom_sf(data=training_rivbasins, aes(fill=Ctch_tn), color='grey20', lwd=0.1) +
  
  # Add outline bounding box
  geom_sf(data=bbox_robin_sf, color='black', fill=NA, size=0.0) +
  
  # scale_fill_distiller(palette='Greens', direction=1)+
  scale_fill_gradientn(#colors= pos_col,
    colors=(RColorBrewer::brewer.pal(9, 'Greens')[3:9]),
    trans='log',
    breaks=c(10^0, 10^1, 10^2, 10^3, 10^4, 10^5, 10^6),
    labels=c(expression(10^{0}),
             expression(10^{1}),
             expression(10^{2}),
             expression(10^{3}),
             expression(10^{4}),
             expression(10^{5}),
             expression(10^{6})),
    limits=c(10^{2}, 3*10^{6})) +
  
  guides(fill = guide_colorbar(
    nbin=6, raster=F, barheight = .6, barwidth=8, #reverse=TRUE,
    frame.colour=c('black'), frame.linewidth=0.4,
    ticks.colour='black',  direction='horizontal',
    title = expression(paste('River fish yield (tonnes yr'^-1*')')))) +
  
  coord_sf() +  theme_raster_map() +
  
  theme(legend.position = 'bottom',
        legend.direction = 'horizontal',
        plot.margin=unit(c(1, 0, 2, -5), 'mm'))




# /----------------------------------------------------------------------------#
#/   Map of training reservoirs


colfunc_purp <- colorRampPalette(c("#f1b3ff", "#41004f"))

# Training reervoir map
train_reserv_map <-
  
  ggplot()+
  
  # countries background & outline
  geom_sf(data=countries_robin_sf, fill='grey90', color='white', size=0.12) +
  
  # Coastline
  geom_sf(data=coastsCoarse_robin_sf, fill=NA, color='grey50', lwd=0.15, size=0.01) +
  
  # Add reservoirs
  geom_sf(data=training_reserv, aes(color=CATCH_tonnesyr), lwd=0.1, size=0.2) +
  
  # Add outline bounding box
  geom_sf(data=bbox_robin_sf, color='black', fill=NA, size=0.0) +
  
  scale_color_gradientn(colors=colfunc_purp(5), 
                        #c('#fdee68','#79d27c','#44d5cd','#3333ff','#000099'),#low='#ffffcc', high='blue',
                       trans='log',
                       breaks=c(10^-1, 10^0, 10^1, 10^2, 10^3, 10^4),
                       labels=expression(10^-1, 10^0, 10^1, 10^2, 10^3, 10^4),
                       limits=c(10^-1, 10^4)) +
  
  guides(color = guide_colorbar(nbin=5, raster=F,
                                barheight = 0.6, barwidth=8, # reverse=T,
                                frame.colour=c('black'), frame.linewidth=0.4,
                                ticks.colour='black',  direction='horizontal', 
                                title = expression(paste('Reservoir fish yield (tonnes yr'^-1*')')))) +
  
  coord_sf() +  
  theme_raster_map() +
  
  theme(legend.position = 'bottom',
        legend.direction = 'horizontal',
        plot.margin=unit(c(1, 0, 2, -3), 'mm'))


train_reserv_map




# Tropical lines
# geom_line(aes(x=c(-16600000, 16600000), y=c(2460000, 2460000)), size=0.1, linetype = "dashed", color='grey40') +
# geom_line(aes(x=c(-16600000, 16600000), y=c(-2460000, -2460000)), size=0.1, linetype = "dashed", color='grey40') +
