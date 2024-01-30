
# / ---------------------------------------------------------------------------#
#/   


riv_catch_dor <- rast('../output/results/catch_losses/gdw_dor_2p_loss.tif')
# paste0('../output/results/catch_losses/riv_catch_dor_', m, '_', c, '_rep.tif'))
# Mask small DOR losses 
riv_catch_dor[riv_catch_dor < 10^-4] <- NA


# Set floor and ceiling values
floorval = 10^0
ceilingval = 10^3


riv_catch_dor_50km <- aggregate(riv_catch_dor, fact=50, fun=sum, na.rm=T, cores=8)
riv_catch_dor_50km_df <- WGSraster2dfROBIN(riv_catch_dor_50km)
riv_catch_dor_50km_df <- riv_catch_dor_50km_df %>% 
                          rename(ril = lyr.1) %>%
                          mutate(ril = ifelse(ril < floorval, floorval, ril),
                                 ril = ifelse(ril > ceilingval, ceilingval, ril))


#### PLOTTED AS POINTS
if(0){
  riv_catch_dor_10km_pts <- st_as_sf(as.points(riv_catch_dor_10km, values=TRUE, na.rm=TRUE))
  riv_catch_dor_10km_pts <- 
    st_transform(riv_catch_dor_10km_pts, crs = st_crs("+proj=robin")) %>% 
    # Make column of lon/lat
    dplyr::mutate(long = sf::st_coordinates(.)[,1],
                  lat = sf::st_coordinates(.)[,2])
  }


# / ---------------------------------------------------------------------------#
#/   RIL MAP

# Negative colors
neg_col <- rev(sequential_hcl(6, palette = "Reds 3"))[3:6]


ril_dor_map <-
  
  ggplot()+
  
  # countries background & outline
  geom_polygon(data=countries_robin_df, aes(long, lat, group=group), fill='grey92', color=NA, size=0.08) +
  
  # Coastline
  geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='grey40', size=0.1) +
  
  # Add reservoir points
  geom_raster(data=riv_catch_dor_50km_df, aes(x, y, fill=ril)) +

  scale_fill_gradientn(colors= neg_col,
                        trans="log",
                        breaks=c(10^0, 10^1, 10^2, 10^3),
                        labels=c(expression(10^{0}),
                                 expression(10^{1}),
                                 expression(10^{2}),
                                 expression(10^{3})),
                        limits=c(10^{0}, 10^{3})) +
  
  
  guides(fill = guide_colorbar(
          nbin=4, raster=F, barheight = .6, barwidth=8, # reverse=TRUE,
          frame.colour=c('black'), frame.linewidth=0.4,
          ticks.colour='black',  direction='horizontal',
          title = expression(paste('Decline in riverine fish yield (tonnes yr'^-1*'cell'^-1*')')))) +
  # expression(paste('Riverine fish yield (tons yr'^-1*'cell'^-1*')')))

  # Add outline bounding box
  geom_path(data=bbox_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
  
  coord_equal() +  theme_raster_map() +
  
  theme(legend.position = 'bottom',
        legend.direction = 'horizontal')


ril_dor_map



# /----------------------------------------------------------------------------#
#/   SAVE MAP TO FILE

ggsave('../output/figures/fig5/map_ril_dor_tons_threshp2_oct2023.pdf',
       ril_dor_map,
       width=180, height=110, dpi=500, units='mm' )

ggsave('../output/figures/fig5/map_ril_dor_tons_threshp2_oct2023.png',
       ril_dor_map,
       width=180, height=110, dpi=500, units='mm' )

