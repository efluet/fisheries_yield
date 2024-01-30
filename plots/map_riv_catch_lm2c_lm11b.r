# /----------------------------------------------------------------------------#
#/   Get distributed riverine yield from Q+pop+wet% model

m='lm2c'
c='catch.c2'
# Read raster
riv_catch_lm2c_rep <- rast(paste0('../output/results/distrib_catch/distrib_catch_', m, '_', c, '_1km_2023_rep.tif')) * 10^6
riv_catch_lm2c_rep[!is.finite(riv_catch_lm2c_rep)] <- 0  # Replace Inf by 0

# Get total
global(riv_catch_lm2c_rep, sum, na.rm=T)



# /----------------------------------------------------------------------------#
#/   Get distributed riverine yield from Q-only model

m='lm11b'
c='catch.c2'
# Read raster
riv_catch_lm11b <- rast(paste0('../output/results/distrib_catch/distrib_catch_', m, '_', c, '_1km_2023.tif')) #* 10^6
riv_catch_lm11b[!is.finite(riv_catch_lm11b)] <- 0  # Replace Inf by 0


# Get total
global(riv_catch_lm11b, sum, na.rm=T)



# /----------------------------------------------------------------------------#
#/   Calculate difference between catch maps

diff = riv_catch_lm2c_rep - riv_catch_lm11b 

# Aggregate for visual clarity
diff_50km <- aggregate(diff, fact=50, fun=sum, na.rm=T, cores=8)

diff_50km_df <- WGSraster2dfROBIN(diff_50km)
names(diff_0km_df) <- c('x','y','diff')


floor=-1000
ceiling=1000

diff_50km_df <- diff_50km_df %>% 
                rename(diff=lyr.1) %>% 
                filter(diff != 0 ) %>% 
                mutate(diff=ifelse(diff>ceiling, ceiling, diff),
                       diff=ifelse(diff<floor, floor, diff))


# / ---------------------------------------------------------------------------#
#/   MAP OF DIFFERENCE IN RIV CATCH BETWEEN MODELS              ----------------

diff_map <-
  
  ggplot()+

  # countries background & outline
  geom_polygon(data=countries_robin_df, aes(long, lat, group=group), fill='grey92', color=NA) +
  
  # Add reservoir points
  geom_raster(data=diff_50km_df, aes(x, y, fill=diff)) +
  

  
  # countries background & outline
  geom_polygon(data=countries_robin_df, aes(long, lat, group=group), fill=NA, color='grey20', size=0.12) +
  
  # Coastline
  geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='grey20', size=0.2) +
  
  # Add outline bounding box
  geom_path(data=bbox_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
  
  scale_fill_gradient2(
    low = "#28c72d",
    mid = "grey92",
    high = "purple",
    midpoint = 0,
    space = "Lab",
    na.value = "grey92",
    guide = "colourbar",
  ) +

  guides(fill = guide_colorbar(
    nbin=10, raster=F, barheight = .6, barwidth=14, #reverse=TRUE,
    frame.colour=c('black'), frame.linewidth=0.4,
    ticks.colour='black',  direction='horizontal',
    title = expression(paste("Difference in fish catch\nbetween models lm11b and lm2crep\n(tonnes per year per 50km pixel)")))) +

  coord_equal() +  theme_raster_map() +
  
  theme(legend.position = 'bottom',
        legend.direction = 'horizontal')


diff_map



# /----------------------------------------------------------------------------#
#/   SAVE MAP TO FILE

ggsave('../output/figures/distrib_catch_map/riv_catch_diff_lm11b_lm2crep.pdf',
       diff_map,
       width=180, height=110, dpi=500, units='mm' )

ggsave('../output/figures/distrib_catch_map/riv_catch_diff_lm11b_lm2crep.png',
       diff_map,
       width=180, height=110, dpi=500, units='mm' )

