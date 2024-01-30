# NOTE: REL TONS:  POSITIVE IF GAIN FROM RESERV


# Set ceiling and floor values
rel_tons_floor = 10^0
rel_tons_ceiling = 10^3

# get points with riv and resev
gdw_pts_res_riv <- st_read(paste0('../output/results/catch_losses/gdw_barriers_localloss_', m, '_', c, '_rep.shp')) %>% 
  select(GDW_ID, res_yield, riv_yield, localloss) %>%
  
  mutate(rel_tons = localloss * -1, 
         rel_perc = rel_tons/ riv_yield *100) %>% 
  
  mutate(rel_tons = ifelse(rel_tons < 0 & rel_tons < -1*rel_tons_ceiling,  -rel_tons_ceiling, rel_tons),
         rel_tons = ifelse(rel_tons < 0 & rel_tons > -1*rel_tons_floor, -rel_tons_floor, rel_tons),
         rel_tons = ifelse(rel_tons > 0 & rel_tons >  rel_tons_ceiling,   rel_tons_ceiling, rel_tons),
         rel_tons = ifelse(rel_tons > 0 & rel_tons <  rel_tons_floor,  rel_tons_floor, rel_tons))


gdw_pts_res_riv <- 
  st_transform(gdw_pts_res_riv, crs = st_crs('+proj=robin')) %>% 
  # Make column of lon/lat
  dplyr::mutate(long = sf::st_coordinates(.)[,1],
                lat = sf::st_coordinates(.)[,2])


# / ---------------------------------------------------------------------------#
#/   MAP OF DIFFERENCE IN CATCH                                 ----------------

# Colorrampe
pos_col <- rev(sequential_hcl(6, palette = 'Blues 3'))[2:6]
neg_col <- rev(sequential_hcl(6, palette = 'Reds 3'))[2:6]


# Generate map
reserv_rel_map <-
  
  ggplot()+
  
  # countries background & outline
  geom_polygon(data=countries_robin_df, aes(long, lat, group=group), fill='grey90', color='white', size=0.12) +
  
  # Coastline
  geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='grey40', size=0.1) +
  

  # Add reservoir points
  geom_point(data=subset(gdw_pts_res_riv, rel_tons>0), aes(long, lat, color=rel_tons), size=0.15) +
  
  scale_color_gradientn(colors= pos_col,
                        trans='log',
                        breaks=c(10^0, 10^1, 10^2, 10^3),
                        labels=c(expression(10^{0}),
                                 expression(10^{1}),
                                 expression(10^{2}),
                                 expression(10^{3})),
                        limits=c(10^{0}, 10^{3})) +
  
  #==========================    
  new_scale_color() +
  
  # Add reservoir points
  geom_point(data=subset(gdw_pts_res_riv, rel_tons<0), aes(long, lat, color=rel_tons * -1), size=0.15) +
  
  scale_color_gradientn(colors= neg_col,
                        trans='log',
                        breaks=c(10^0, 10^1, 10^2, 10^3),
                        labels=c(expression(10^{0}),
                                 expression(10^{1}),
                                 expression(10^{2}),
                                 expression(10^{3})),
                        limits=c(10^{0}, 10^{3})) +

  
  guides(color = guide_colorbar(
    nbin=4, raster=F, barheight = .6, barwidth=8, reverse=TRUE,
    frame.colour=c('black'), frame.linewidth=0.4,
    ticks.colour='black',  direction='horizontal',
    title = expression(paste('Change in fish yield (tonnes/year)')))) +
  
  # Add outline bounding box
  geom_path(data=bbox_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
  
  coord_equal() +  theme_raster_map() +
  
  theme(legend.position = 'bottom',
        legend.direction = 'horizontal')+
  
  # Re-add the largest winners & losers
  # Largest losers
  
  geom_point(data=subset(gdw_pts_res_riv, rel_tons > 10^1 & rel_tons <=  10^2), aes(long, lat), color='#5295D4', size=0.15) +
  geom_point(data=subset(gdw_pts_res_riv, rel_tons< -10^1 & rel_tons >= -10^2), aes(long, lat), color='#F84855', size=0.15) +

  
  geom_point(data=subset(gdw_pts_res_riv, rel_tons > 10^2 & rel_tons <=  10^3), aes(long, lat), color='#0066A5', size=0.15) +
  geom_point(data=subset(gdw_pts_res_riv, rel_tons< -10^2 & rel_tons >= -10^3), aes(long, lat), color='#B71729', size=0.15) +

  
  geom_point(data=subset(gdw_pts_res_riv, rel_tons> 10^3), aes(long, lat), color='#00366C', size=0.15) +
  geom_point(data=subset(gdw_pts_res_riv, rel_tons< -10^3), aes(long, lat), color='#69000C', size=0.15)



reserv_rel_map



# /----------------------------------------------------------------------------#
#/   SAVE MAP TO FILE

ggsave('../output/figures/fig3_bargraph/fig3a_map_rel_tons_diff_v2_rep_oct2023.pdf',
       reserv_rel_map,
       width=180, height=110, dpi=500, units='mm' )

ggsave('../output/figures/fig3_bargraph/fig3a_map_rel_tons_diff_v2_rep_oct2023.png',
       reserv_rel_map,
       width=180, height=110, dpi=500, units='mm' )




# /----------------------------------------------------------------------------#
#/   Make 2nd MAP for  COLORBAR OF POSITIVE COLORS (LATER ASSEMBLED WITH COMPLETE MAP IN ILLUSTRATOR)

reserv_rel_map_poscoloramp <-
  
  ggplot()+
  
  # countries background & outline
  geom_polygon(data=countries_robin_df, aes(long, lat, group=group), fill='grey90', color=NA, size=0.08) +
  
  # Coastline
  geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='grey40', size=0.1) +
  
  # Add reservoir points
  geom_point(data=subset(gdw_pts_res_riv, rel_tons>0), aes(long, lat, color=rel_tons), size=0.8) +
  
  scale_color_gradientn(colors= neg_col,
                        trans='log',
                        breaks=c(10^0, 10^1, 10^2, 10^3),
                        labels=c(expression(10^{0}),
                                 expression(10^{1}),
                                 expression(10^{2}),
                                 expression(10^{3})),
                        limits=c(10^{0}, 10^{3})) +
  
  guides(color = guide_colorbar(
    nbin=4, raster=F, barheight = .6, barwidth=8, #reverse=TRUE,
    frame.colour=c('black'), frame.linewidth=0.4,
    ticks.colour='black',  direction='horizontal',
    title = expression(paste('Change in fish yield (tonnes yr'^-1*')')))) +
  
  
  # Add outline bounding box
  geom_path(data=bbox_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
  
  coord_equal() +  theme_raster_map() +
  
  theme(legend.title = element_blank(),
        legend.position = 'bottom',
        legend.direction = 'horizontal')


reserv_rel_map_poscoloramp


# /----------------------------------------------------------------------------#
#/   
ggsave('../output/figures/fig3_bargraph/fig3_map_rel_tons_diff_negcoloramp_rep_oct2023.png',
       reserv_rel_map_poscoloramp,
       width=180, height=110, dpi=500, units='mm' )

ggsave('../output/figures/fig3_bargraph/fig3_map_rel_tons_diff_negcoloramp_rep_oct2023.pdf',
       reserv_rel_map_poscoloramp,
       width=180, height=110, dpi=500, units='mm' )


# /----------------------------------------------------------------------------#
#/   BARPLOT OF TOTALS                                                ----------


# get points with riv and reservoir yield
gdw_pts_res_riv <- 
  st_read(paste0('../output/results/catch_losses/gdw_barriers_localloss_', m, '_', c, '_rep.shp')) %>% 
  # join country/continent
  st_join(., st_as_sf(countries), join=st_intersects)  %>% 
  st_drop_geometry() %>% 
  filter(!is.na(continent)) %>% 
  group_by(continent) %>% 
  
  # Get Count, area and yield
  summarise(count = n(),
            AREA_SKM = sum(AREA_SKM, na.rm=T),
            res_yield= sum(res_yield, na.rm=T)) %>% 
  ungroup() %>% 
  
  # Calculate percentage of total of Count, area and yield
  mutate(count_perc = count/sum(count)*100,
         AREA_SKM_perc = AREA_SKM/sum(AREA_SKM)*100,
         RES_YLD_TN_perc = res_yield/sum(res_yield)*100) %>% 
  
  select(continent, count_perc, AREA_SKM_perc, RES_YLD_TN_perc) %>% 
  pivot_longer(cols=count_perc:RES_YLD_TN_perc, names_to='vartype', values_to='values') %>% 
  mutate(vartype=ifelse(vartype=='count_perc', 'Count', vartype),
         vartype=ifelse(vartype=='AREA_SKM_perc', 'Area', vartype),
         vartype=ifelse(vartype=='RES_YLD_TN_perc', 'Fish\nYield', vartype))



# Order variables
gdw_pts_res_riv$vartype <- factor(gdw_pts_res_riv$vartype, 
                                    levels=c('Fish\nYield','Area','Count'))

gdw_pts_res_riv$continent <- factor(gdw_pts_res_riv$continent, 
                                      levels=rev(c( 'Africa', 'Asia', 'Europe', 'North America', 'Oceania', 'South America')))


# Map barplot
barplot_resev_perc <- 
  ggplot() +
  geom_bar(data=gdw_pts_res_riv, 
           aes(x=vartype, y=values, fill=continent), position='stack', stat='identity', width=0.7) +
  
  geom_text(data=subset(gdw_pts_res_riv, vartype=='Count'),
            aes(x=vartype, y=values, color=continent, label=continent), position='stack', stat='identity', size=1.8) +
  
  # Percentage values
  geom_text(data=gdw_pts_res_riv,
            aes(x=vartype, y=values*0.8, label=paste0(round(values),'%')), color='black', position='stack', stat='identity', size=1.8) +
  
  coord_flip() +
  scale_fill_brewer(palette='Set2') +
  scale_color_brewer(palette='Set2') +
  scale_y_continuous(expand=c(0,0)) +
  xlab('') + ylab('Percentage of total (%)') +
  line_plot_theme() +
  theme(
    axis.line.y  = element_blank(),
    axis.ticks.y =  element_blank(),
    panel.border = element_blank(), 
    legend.position = 'none')

barplot_resev_perc


ggsave('../output/figures/fig3_bargraph/fig3_bargraph_reserv_perc_of_global_oct2023.png',
       barplot_resev_perc,
       width=166, height=35, dpi=500, units='mm' )

ggsave('../output/figures/fig3_bargraph/fig3_bargraph_reserv_perc_of_global_oct2023.pdf',
       barplot_resev_perc,
       width=166, height=35, dpi=500, units='mm' )

