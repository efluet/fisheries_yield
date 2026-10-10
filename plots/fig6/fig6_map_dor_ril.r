
# / ---------------------------------------------------------------------------#
#/   

# Read DOR yield losses
riv_catch_dor <- rast('../output/results/dor_yield_losses/gdw_dor_2p_loss_102024.tif')

# Mask small DOR losses 
riv_catch_dor[riv_catch_dor < 10^-4] <- NA


# Aggregate
riv_catch_dor_50km <- aggregate(riv_catch_dor, fact=50, fun=sum, na.rm=T, cores=8)

# Reproject
riv_catch_dor_50km_df <- WGSraster2dfROBIN(riv_catch_dor_50km)

# Set floor and ceiling values
floorval = 10^0
ceilingval = 10^3

# Apply floor/ceiling values
riv_catch_dor_50km_df <- riv_catch_dor_50km_df %>% 
                          rename(ril = fit) %>%
                          mutate(ril = ifelse(ril < floorval, floorval, ril),
                                 ril = ifelse(ril > ceilingval, ceilingval, ril))


# riv_catch_dor_50km_df[riv_catch_dor_50km_df < 10^0] <- 10^0


# / ---------------------------------------------------------------------------#
#/   RIL MAP

# Negative colors
neg_col <- rev(sequential_hcl(6, palette = "Reds 3"))[2:6]




ril_dor_map <-
  
  ggplot()+
  
  # countries background & outline
  geom_sf(data=countries_robin_sf, fill='grey92', color=NA) +
  
  # add outline of background countries
  geom_sf(data=coastsCoarse_robin_sf, color='grey20', size=0.1, lwd=0.1) +

  # Add reservoir points
  geom_raster(data=riv_catch_dor_50km_df, aes(x, y, fill=ril)) + 

  # Add outline bounding box
  geom_sf(data=bbox_robin_sf, color='black', fill=NA, size=0.2) +
  
  scale_fill_gradientn(colors= neg_col,
                        trans="log",
                        breaks=c(10^0, 10^1, 10^2, 10^3),
                        labels=c(expression(10^{0}),
                                 expression(10^{1}),
                                 expression(10^{2}),
                                 expression(10^{3})),
                        limits=c(10^{0}, 10^{3})) +
  
  
  guides(fill = guide_colorbar(
          nbin=4, raster=F, barheight = .4, barwidth=8, # reverse=TRUE,
          frame.colour=c('black'), frame.linewidth=0.2,
          ticks.colour='black',  direction='horizontal',
          title = expression(paste('Downstream riverine yield loss (tonnes yr'^-1*'cell'^-1*')')))) +
  
  coord_sf() +  theme_raster_map() +
  
  theme(legend.position = 'bottom',
        legend.direction = 'horizontal',
        plot.margin=unit(c(1, -3, 1, -3), 'mm'))


ril_dor_map


# /-----------------------------------------------------------------------------
#/  Lineplot to DOR losses                                              --------
# SI Fig. of DOR threshold vs DOR losses
source('plots/fig6/lineplot_dor_thresh.r')


# /-----------------------------------------------------------------------------
#/ Arrange plots grob into layout                                       --------

dor_multipanel <- 
  plot_grid(ril_dor_map, 
            line_dor_thresh,
            ncol=2, nrow=1,
            rel_widths = c(1.7, 0.8),
            rel_heights = c(1, 0.8),
            align='h',
            labels = c('A','B'))


# /----------------------------------------------------------------------------#
#/   SAVE MAP TO FILE

ggsave('../output/figures/fig6/fig6_dor_losses_threshp2_v11.pdf',
       dor_multipanel,
       width=178, height=70, dpi=500, units='mm' )

ggsave('../output/figures/fig6/fig6_dor_losses_threshp2_v11.png',
       dor_multipanel,
       width=178, height=70, dpi=500, units='mm' )

