
# /---------------------------------------------------------------
#/  Generate panels

# Latitudinal distribution
source('plots/fig3/histogram_lat_riv_distrib.r')

# PLOT A - Map of distributed riverine catch
source('plots/fig3/map_distrib_catch_2024.r')

# PLOT B - Histogram of riverine distributed catch
source('plots/fig3/histogram_riv_distrib.r')


#---------
# Latitude historgram
source('plots/fig3/histogram_lat_res_yield.r')

# PLOT C - Map of reservoir yield
source('plots/fig3/map_reserv_yield.r')

# PLOT D - Histogram of reservoir yield
source('plots/fig3/hist_reservoir_yield.r')




# /---------------------------------------------------------------
#/ Arrange plots grob into layout 

fig3_panels <- 
  plot_grid(lat_hist_riv_yield, riv_yield_map, hist_riv_yield,
            lat_hist_res_yield, res_yield_map, hist_reserv_yield,
            
            ncol=3, nrow=2,
            # rel_heights = c(1, 0.8), #, 1, 0.8),
            rel_widths = c(.2, 1, 0.42), #, 1, 0.5),
            
            labels = c('A',"", 'B','C',"",'D')) +
            # align='h') + 
  theme(plot.background = element_rect(fill = "white", color = NA))





# /----------------------------------------------------------------------------#
#/    Save figure to file
ggsave(paste0('../output/figures/fig3/fig3_riv_reserv_yield_v11.pdf'),
       fig3_panels,
       width=200, height=118, dpi=300, units="mm")

ggsave(paste0('../output/figures/fig3/fig3_riv_reserv_yield_v11.png'),
       fig3_panels,
       width=200, height=118, dpi=400, units="mm", type = "cairo-png")

dev.off()





# yield_maps <- 
#   plot_grid(riv_yield_map, hist_riv_yield,
#             res_yield_map, hist_reserv_yield,
#             ncol=2, nrow=2,
#             # rel_heights = c(1, 0.8), #, 1, 0.8),
#             rel_widths = c(1, 0.45), #, 1, 0.5),
#             
#             labels = c('A','B','C','D'))
# # align='hv')
