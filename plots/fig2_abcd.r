
# PLOT A - Map of distributed riverine catch
source('plots/map_distrib_catch.r')

# PLOT B - Histogram of riverine distributed catch
source('plots/histogram_riv_distrib.r')

# PLOT C - Map of reservoir yield
source('plots/map_reserv_yield.r')

# PLOT D - Histogram of reservoir yield
source('plots/hist_reservoir_yield.r')




# /---------------------------------------------------------------
#/ Arrange plots grob into layout 
library(cowplot)

yield_maps <- 
  plot_grid(riv_yield_map, hist_riv_yield,
            res_yield_map, hist_reserv_yield,
            
            ncol=2, nrow=2,
            # rel_heights = c(1, 0.8), #, 1, 0.8),
            rel_widths = c(1, 0.5), #, 1, 0.5),
            
            labels = c('A','B','C','D'))
            # align='hv')


# /----------------------------------------------------------------------------#
#/    Save figure to file
ggsave(paste0('../output/figures/fig2_riv_reserv_yield_oct2023.pdf'),
       yield_maps,
       width=178, height=108, dpi=300, units="mm")

ggsave(paste0('../output/figures/fig2_riv_reserv_yield_oct2023.png'),
       yield_maps,
       width=178, height=108, dpi=400, units="mm", type = "cairo-png")

dev.off()
