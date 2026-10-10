# Train multiplanel SI plot



# SI Fig - Map training data: basins and reservoirs 
source('plots/SIfig_map_train_basins_reserv.r')

# Reservoir scatteplot
source('plots/scatterplot_res_yield_obs_v_pred.r')

# SI Fig - scatterplot of river model obs vs pred
source('plots/scatterplot_riv_fish_lm_obs_v_pred.r')




# /---------------------------------------------------------------
#/ Arrange plots grob into layout 
library(cowplot)

emptyplot <- ggplot() + theme_void()

train_plots <- 
  plot_grid(train_reserv_map, scatterplot_reservoir_yield_lm,
            train_basin_map, scatterplot_riv_fish_lm_obs_v_pred, 
            emptyplot, scatterplot_riv_fish_distrib_obs_v_pred,
            ncol=2, nrow=3,
            # align='v',
            rel_widths = c(1, 0.7), #, 1, 0.5),
            labels = c('A','B','C','D','','E')) +
          theme(plot.background = element_rect(fill = "white", colour = NA))

# rel_heights = c(1, 0.8), #, 1, 0.8),
# rel_widths = c(1, 0.5), #, 1, 0.5),


# /----------------------------------------------------------------------------#
#/    Save figure to file
ggsave(paste0('../output/figures/train_multiplanel.pdf'),
       train_plots,
       width=178, height=180, dpi=300, units="mm")

ggsave(paste0('../output/figures/train_multiplanel.png'),
       train_plots,
       width=178, height=180, dpi=400, units="mm", type = "cairo-png")

dev.off()
