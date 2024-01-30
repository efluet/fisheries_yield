
# Set flood and ceiling values
floor = 10^1 ; ceiling = 10^5

# Set flood and ceiling percentages
perc_floor = 10^0 ; perc_ceiling = 2* 10^2

m='lm2c'
c='catch.c2'

# /----------------------------------------------------------------------------#
#/   GET HYDROBASIN4 WITH YIELD DIFF DATA                                           -------

hydrobasin4_poly_dat <- st_read(paste0('../output/results/catch_losses/hydrobasin4_poly_dat_', m, '_', c, '_rep_oct2023.shp')) %>%
                        # st_drop_geometry() %>% 
                        rename(dor = dist2,
                               riv_yield_infootprint = riv_yield_) %>% 
                        replace(is.na(.), 0) %>% 
                        # Calculate net yield change; positive means net gain; negative is net loss from damming
                        mutate(diff_tons = res_yield - riv_yield_infootprint - dor) %>%
                        # % change relative to total riverine catch
                        mutate(diff_perc = diff_tons / riv_catch *100) %>%
                        replace(is.na(.), 0) %>% 
                        filter(diff_tons != 0) %>% 
                        # Apply floor and ceiling values to TONS
                        mutate(diff_tons = ifelse(diff_tons < 0 & diff_tons < -1*ceiling,  -ceiling, diff_tons),
                               diff_tons = ifelse(diff_tons < 0 & diff_tons > -1*floor, -floor, diff_tons),
                               diff_tons = ifelse(diff_tons > 0 & diff_tons >  ceiling,   ceiling, diff_tons),
                               diff_tons = ifelse(diff_tons > 0 & diff_tons <  floor,  floor, diff_tons)) %>% 
                        # Apply floor and ceiling values to PERCENTAGE
                        mutate(diff_perc = ifelse(diff_perc < 0 & diff_perc < -1*perc_ceiling,  -perc_ceiling, diff_perc),
                               diff_perc = ifelse(diff_perc < 0 & diff_perc > -1*perc_floor, -perc_floor, diff_perc),
                               diff_perc = ifelse(diff_perc > 0 & diff_perc >  perc_ceiling,   perc_ceiling, diff_perc),
                               diff_perc = ifelse(diff_perc > 0 & diff_perc <  perc_floor,  perc_floor, diff_perc)) %>% 
                        # Reproject
                        st_transform(CRS("+proj=robin")) %>% 
                        st_simplify(preserveTopology = FALSE, dTolerance = 15000)



hydrobasin4_poly_dat_df <- hydrobasin4_poly_dat %>% st_drop_geometry()

# / ---------------------------------------------------------------------------#
#/   PREP COLOR RANGES                                                 ---------

pos_col <- rev(sequential_hcl(7, palette = "Blues 3"))[2:6]
neg_col <- rev(sequential_hcl(7, palette = "Reds 3"))[2:6]


# / ---------------------------------------------------------------------------#
#/   MAP TONS DIFFERENCE IN CATCH                                        ---------

hydrobasin_map_tonnes <-
  
  ggplot()+
  
  # # countries background & outline
  geom_sf(data=countries_robin_sf, fill='grey90', color=NA, size=0.08) +
  # 
  # # Coastline
  geom_sf(data=coastsCoarse_robin_sf, color='grey40', size=0.1) +
  
  # Add reservoir points
  geom_sf(data=subset(hydrobasin4_poly_dat, diff_tons>0), aes(fill=diff_tons), size=0.1, color='grey20') +
  
  scale_fill_gradientn(colors= pos_col,
                       trans="log",
                       breaks=c(10^1, 10^2, 10^3, 10^4, 10^5), # 
                       labels=c(expression(10^{1}),
                                expression(10^{2}),
                                expression(10^{3}),
                                expression(10^{4}),
                                expression(10^{5})),
                       limits=c(10^{1}, 10^{5})) +
  
  # ADD NEW SCALE
  new_scale_fill() +

  # Add reservoir points
  geom_sf(data=subset(hydrobasin4_poly_dat, diff_tons<0), aes(fill=diff_tons * -1), size=0.1, color='grey20') +

  scale_fill_gradientn(colors= neg_col,
                       trans="log",
                       breaks=c(10^1, 10^2, 10^3, 10^4, 10^5), # 
                       labels=c(expression(10^{1}),
                                expression(10^{2}),
                                expression(10^{3}),
                                expression(10^{4}),
                                expression(10^{5})),
                       limits=c(10^{1}, 10^{5})) +
  
  
  guides(fill = guide_colorbar(
    nbin=5, raster=F, barheight = .6, barwidth=8, reverse=T,
    frame.colour=c('black'), frame.linewidth=0.3,
    ticks.colour='black',  direction='horizontal',
    title = expression(paste('Net change in fish yield (tonnes year'^-1*')')))) +
  
  
  # Add outline bounding box
  geom_sf(data=bbox_robin_sf, color='black', size=0.08, fill=NA) +
  
  coord_sf() +
  theme_raster_map() +
  
  theme(legend.position = 'bottom',
        legend.direction = 'horizontal')

hydrobasin_map_tonnes


# /----------------------------------------------------------------------------#
#/   SAVE MAP TO FILE                                             -------

ggsave('../output/figures/fig6/map_hydrobasins4_tons_diff_v3_rep_oct2023.pdf',
       hydrobasin_map_tonnes,
       width=180, height=110, dpi=400, units='mm' )


# /----------------------------------------------------------------------------#
#/  FORMAT POSITIVE COLOR RAMP                                          --------

hydrobasin_map_colorramp <-
  
  ggplot()+
  # countries background & outline
  geom_sf(data=countries_robin_sf, fill='grey90', color=NA, size=0.08) +

  # Coastline
  geom_sf(data=coastsCoarse_robin_sf, color='grey40', size=0.1) +
  
  # Add hydrobasins
  geom_sf(data=subset(hydrobasin4_poly_dat, diff_tons>0), aes(fill=diff_tons), size=0.1, color='grey20') +
  
  scale_fill_gradientn(colors= pos_col,
                       trans="log",
                       breaks=c(10^1, 10^2, 10^3, 10^4, 10^5), # 
                       labels=c(expression(10^{1}),
                                expression(10^{2}),
                                expression(10^{3}),
                                expression(10^{4}),
                                expression(10^{5})),
                       limits=c(10^{1}, 10^{5})) +
  
  guides(fill = guide_colorbar(
    nbin=5, raster=F, barheight = .6, barwidth=8, #reverse=TRUE,
    frame.colour=c('black'), frame.linewidth=0.3,
    ticks.colour='black',  direction='horizontal',
    title = expression(paste('Net change in fish yield (tonnes year'^-1*')')))) +
  
  # Add outline bounding box
  geom_sf(data=bbox_robin_sf, color='black', size=0.08, fill=NA) +
  
  coord_sf() +
  theme_raster_map() +
  
  theme(legend.position = 'bottom',
        legend.direction = 'horizontal')



# /----------------------------------------------------------------------------#
#/   SAVE MAP TO FILE                         ----------

ggsave('../output/figures/fig6/map_hydrobasins4_tons_diff_v3_colorramp_rep_oct2023.pdf',
       hydrobasin_map_colorramp,
       width=180, height=110, dpi=400, units='mm' )


# / ---------------------------------------------------------------------------#
#/   MAP OF PERC DIFFERENCE IN CATCH                                   ---------

hydrobasin_map_perc <-
  
  ggplot()+
  
  # # countries background & outline
  geom_sf(data=countries_robin_sf, fill='grey90', color=NA, size=0.08) +
  # 
  # # Coastline
  geom_sf(data=coastsCoarse_robin_sf, color='grey40', size=0.1) +
  
  # Add reservoir points
  geom_sf(data=subset(hydrobasin4_poly_dat, diff_perc>0), aes(fill=diff_perc), size=0.1, color='grey20') +
  
  scale_fill_gradientn(colors= pos_col,
                       # breaks=pretty_breaks(),
                       breaks=c(1,25,50,75,100, 125, 150, 175, 200),
                       limits=c(1, 200)) +
  
  # ADD NEW SCALE
  new_scale_fill() +
  
  # Add reservoir points
  geom_sf(data=subset(hydrobasin4_poly_dat, diff_perc<0), aes(fill=diff_perc * -1), size=0.1, color='grey20') +
  
  scale_fill_gradientn(colors= neg_col,
                       breaks=c(1,25,50,75,100),
                       limits=c(1, 100)) +
  
  guides(fill = guide_colorbar(
    nbin=4, raster=F, barheight = .6, barwidth=6, reverse=T,
    frame.colour=c('black'), frame.linewidth=0.3,
    ticks.colour='black',  direction='horizontal',
    title = expression(paste("Change in fish yield as percentage of idealized riverine yield (%)")))) +
  
  # Add outline bounding box
  geom_sf(data=bbox_robin_sf, color='black', size=0.08, fill=NA) +
  
  coord_sf() +
  theme_raster_map() +
  
  theme(legend.position = 'bottom',
        legend.direction = 'horizontal')

hydrobasin_map_perc


# /----------------------------------------------------------------------------#
#/   SAVE PERC MAP TO FILE                                             -------

ggsave('../output/figures/fig6/map_hydrobasins4_perc_diff_v3_rep_oct2023.pdf',
       hydrobasin_map_perc,
       width=180, height=110, dpi=400, units='mm' )



# /----------------------------------------------------------------------------#
#/  PERC COLOR RAMP                  -------
hydrobasin_map_perc_colorramp <-
  
  ggplot()+
  
  # # countries background & outline
  geom_sf(data=countries_robin_sf, fill='grey90', color=NA, size=0.08) +
  # 
  # # Coastline
  geom_sf(data=coastsCoarse_robin_sf, color='grey40', size=0.1) +
  
  # Add reservoir points
  geom_sf(data=subset(hydrobasin4_poly_dat, diff_perc>0), aes(fill=diff_perc), size=0.1, color='grey20') +
  
  scale_fill_gradientn(colors= pos_col,
                       # breaks=pretty_breaks(),
                       breaks=c(1,25,50,75,100, 125, 150, 175, 200),
                       limits=c(1, 200)) +
  
  guides(fill = guide_colorbar(
    nbin=8, raster=F, barheight = .6, barwidth=12, #reverse=TRUE,
    frame.colour=c('black'), frame.linewidth=0.3,
    ticks.colour='black',  direction='horizontal',
    title = expression(paste("Change in fish yield as percentage of idealized riverine yield (%)")))) +
  
  
  # Add outline bounding box
  geom_sf(data=bbox_robin_sf, color='black', size=0.08, fill=NA) +
  
  coord_sf() +
  theme_raster_map() +
  
  theme(legend.position = 'bottom',
        legend.direction = 'horizontal')


ggsave('../output/figures/fig6/map_hydrobasins4_perc_diff_v3_rep_colorramp_oct2023.pdf',
       hydrobasin_map_perc_colorramp,
       width=180, height=110, dpi=400, units='mm' )


# /----------------------------------------------------------------------------#
#/   SAVE MAP TO FILE         --------

hydrobasin_map_panels <- 
  plot_grid(hydrobasin_map_tonnes,
            hydrobasin_map_perc,
            
            ncol=1, nrow=2,
            # rel_heights = c(1, 0.8), #, 1, 0.8),
            rel_widths = c(1, 1),
            
            labels = c('A','B'))
          # align='hv')





ggsave('../output/figures/fig6/fig6_perhydrobasin_oct2023.pdf',
       hydrobasin_map_panels,
       width=180, height=120, dpi=400, units='mm' )

# ggsave('../output/figures/map_yield_loss/hydrobasins4_map/map_hydrobasins4_perc_diff_v3_colorramp.png',
#        hydrobasin_map_perc_colorramp,
#        width=180, height=110, dpi=400, units='mm' )



# scale_fill_gradientn(colors= pos_col,
#                      trans="log",
#                      breaks=c(10^0, 10^1, 10^2, 10^3, 10^4, 10^5), # 
#                      labels=c(expression(10^{0}), 
#                               expression(10^{1}),
#                               expression(10^{2}),
#                               expression(10^{3}),
#                               expression(10^{4}),
#                               expression(10^{5})),
#                      limits=c(10^{0}, 10^{5})) +