
# Set ceiling and floor values
rel_tons_floor = 10^0
rel_tons_ceiling = 10^3

# get points with riv and resev
grand_pts_res_riv <- st_read(paste0('../output/results/catch_losses/gdw_barriers_localloss_', m, '_', c, '_rep.shp')) %>% 
                     select(GRAND_ID, RES_YLD_TN, riv_catch) %>%

                      mutate(rel_tons = RES_YLD_TN - riv_catch, 
                             rel_perc = (RES_YLD_TN - riv_catch)/ riv_catch *100) %>% 
  
                      mutate(rel_tons = ifelse(rel_tons < 0 & rel_tons < -1*rel_tons_ceiling,  -rel_tons_ceiling, rel_tons),
                             rel_tons = ifelse(rel_tons < 0 & rel_tons > -1*rel_tons_floor, -rel_tons_floor, rel_tons),
                             rel_tons = ifelse(rel_tons > 0 & rel_tons >  rel_tons_ceiling,   rel_tons_ceiling, rel_tons),
                             rel_tons = ifelse(rel_tons > 0 & rel_tons <  rel_tons_floor,  rel_tons_floor, rel_tons))


grand_pts_res_riv <- 
          st_transform(grand_pts_res_riv, crs = st_crs("+proj=robin")) %>% 
          # Make column of lon/lat
          dplyr::mutate(long = sf::st_coordinates(.)[,1],
                        lat = sf::st_coordinates(.)[,2])


# / ---------------------------------------------------------------------------#
#/   MAP OF DIFFERENCE IN CATCH                                 ----------------


pos_col <- rev(sequential_hcl(6, palette = "Blues 3"))[2:6]
neg_col <- rev(sequential_hcl(6, palette = "Reds 3"))[2:6]


reserv_rel_map <-
  
  ggplot()+
  
  # countries background & outline
  geom_polygon(data=countries_robin_df, aes(long, lat, group=group), fill='grey90', color='white', size=0.12) +
  
  # Coastline
  geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='grey40', size=0.1) +
  
  # Add reservoir points
  geom_point(data=subset(grand_pts_res_riv, rel_tons>0), aes(long, lat, color=rel_tons), size=0.35) +
  
  scale_color_gradientn(colors= pos_col,
                        trans="log",
                        breaks=c(10^0, 10^1, 10^2, 10^3),
                        labels=c(expression(10^{0}),
                                 expression(10^{1}),
                                 expression(10^{2}),
                                 expression(10^{3})),
                        limits=c(10^{0}, 10^{3})) +
  
  #==========================    
  new_scale_color() +

  # Add reservoir points
  geom_point(data=subset(grand_pts_res_riv, rel_tons<0), aes(long, lat, color=rel_tons * -1), size=0.35) +
  
  scale_color_gradientn(colors= neg_col,
                        trans="log",
                        breaks=c(10^0, 10^1, 10^2, 10^3),
                        labels=c(expression(10^{0}),
                                 expression(10^{1}),
                                 expression(10^{2}),
                                 expression(10^{3})),
                        limits=c(10^{0}, 10^{3})) +
  
  guides(color = guide_colorbar(
    nbin=10, raster=F, barheight = .6, barwidth=14, reverse=TRUE,
    frame.colour=c('black'), frame.linewidth=0.4,
    ticks.colour='black',  direction='horizontal',
    title = expression(paste("Change in fish yield (tonnes/year)")))) +
  
  # Add outline bounding box
  geom_path(data=bbox_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
  
  coord_equal() +  theme_raster_map() +
  
  theme(legend.position = 'bottom',
        legend.direction = 'horizontal')


reserv_rel_map



# /----------------------------------------------------------------------------#
#/   SAVE MAP TO FILE

ggsave('../output/figures/map_yield_loss/rel_map/map_rel_tons_diff_v2_rep_oct2023.pdf',
       reserv_rel_map,
       width=180, height=110, dpi=500, units='mm' )

ggsave('../output/figures/map_yield_loss/rel_map/map_rel_tons_diff_v2_rep_oct2023.png',
       reserv_rel_map,
       width=180, height=110, dpi=500, units='mm' )




# /----------------------------------------------------------------------------#
#/   MAP PANEL WITH COLORBAR OF POSITIVE COLORS (LATER ASSEMBLED WITH COMPLETE MAP IN ILLUSTRATOR)

reserv_rel_map_poscoloramp <-
  
  ggplot()+
  
  # countries background & outline
  geom_polygon(data=countries_robin_df, aes(long, lat, group=group), fill='grey90', color=NA, size=0.08) +
  
  # Coastline
  geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='grey40', size=0.1) +
  
  # Add reservoir points
  geom_point(data=subset(grand_pts_res_riv, rel_tons>0), aes(long, lat, color=rel_tons), size=0.8) +
  
  scale_color_gradientn(colors= pos_col,
                        trans="log",
                        breaks=c(10^0, 10^1, 10^2, 10^3),
                        labels=c(expression(10^{0}),
                                 expression(10^{1}),
                                 expression(10^{2}),
                                 expression(10^{3})),
                        limits=c(10^{0}, 10^{3})) +
  
    guides(color = guide_colorbar(
    nbin=10, raster=F, barheight = .6, barwidth=14, #reverse=TRUE,
    frame.colour=c('black'), frame.linewidth=0.4,
    ticks.colour='black',  direction='horizontal',
    title = expression(paste("Change in fish yield (tonnes/year)")))) +
  
  
  # Add outline bounding box
  geom_path(data=bbox_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
  
  coord_equal() +  theme_raster_map() +
  
  theme(legend.position = 'bottom',
        legend.direction = 'horizontal')


reserv_rel_map_poscoloramp


ggsave('../output/figures/map_yield_loss/rel_map/map_rel_tons_diff_poscoloramp_rep.png',
       reserv_rel_map_poscoloramp,
       width=180, height=110, dpi=500, units='mm' )

ggsave('../output/figures/map_yield_loss/rel_map/map_rel_tons_diff_poscoloramp_rep.pdf',
       reserv_rel_map_poscoloramp,
       width=180, height=110, dpi=500, units='mm' )


# /----------------------------------------------------------------------------#
#/   BARPLOT OF TOTALS                                                ----------


# get points with riv and reset 
grand_pts_res_riv <- 
    st_read(paste0('../output/results/catch_losses/riv_catch_perreserv_pts_', m, '_', c, '_rep.shp')) %>% 
    # join country/continent
    st_join(., st_as_sf(countries), join=st_intersects)  %>% 
    st_drop_geometry() %>% 
    filter(!is.na(continent)) %>% 
    group_by(continent) %>% 
  
    # Get Count, area and yield
    summarise(count = n(),
              AREA_SKM = sum(AREA_SKM, na.rm=T),
              RES_YLD_TN= sum(RES_YLD_TN, na.rm=T)) %>% 
    ungroup() %>% 
  
    # Calculate percentage of total of Count, area and yield
    mutate(count_perc = count/sum(count)*100,
           AREA_SKM_perc = AREA_SKM/sum(AREA_SKM)*100,
           RES_YLD_TN_perc = RES_YLD_TN/sum(RES_YLD_TN)*100) %>% 
  
    select(continent, count_perc, AREA_SKM_perc, RES_YLD_TN_perc) %>% 
    pivot_longer(cols=count_perc:RES_YLD_TN_perc, names_to='vartype', values_to='values') %>% 
    mutate(vartype=ifelse(vartype=='count_perc', 'Count', vartype),
           vartype=ifelse(vartype=='AREA_SKM_perc', 'Area', vartype),
           vartype=ifelse(vartype=='RES_YLD_TN_perc', 'Fish\nYield', vartype))



# Order variables
grand_pts_res_riv$vartype <- factor(grand_pts_res_riv$vartype, 
                                levels=c('Fish\nYield','Area','Count'))

grand_pts_res_riv$continent <- factor(grand_pts_res_riv$continent, 
                                    levels=rev(c( "Africa", "Asia", "Europe", "North America", "Oceania", "South America")))


# Map barplot
barplot_resev_perc <- 
  ggplot() +
  geom_bar(data=grand_pts_res_riv, 
           aes(x=vartype, y=values, fill=continent), position='stack', stat='identity', width=0.7) +
  
  geom_text(data=subset(grand_pts_res_riv, vartype=='Count'),
           aes(x=vartype, y=values, color=continent, label=continent), position='stack', stat='identity', size=1.8) +
  
  # Percentage values
  geom_text(data=grand_pts_res_riv,
            aes(x=vartype, y=values*0.8, label=paste0(round(values),'%')), color='black', position='stack', stat='identity', size=1.8) +
  
  coord_flip() +
  scale_fill_brewer(palette='Set2') +
  scale_color_brewer(palette='Set2') +
  scale_y_continuous(expand=c(0,0)) +
  xlab('') + ylab('Percentage of total (%)') +
  line_plot_theme +
  theme(
    axis.line.y  = element_blank(),
    axis.ticks.y =  element_blank(),
    panel.border = element_blank(), 
    legend.position = 'none')

barplot_resev_perc


ggsave('../output/figures/bargraph_reserv_perc_of_global.png',
       barplot_resev_perc,
       width=180, height=35, dpi=500, units='mm' )

ggsave('../output/figures/bargraph_reserv_perc_of_global.pdf',
       barplot_resev_perc,
       width=180, height=35, dpi=500, units='mm' )

