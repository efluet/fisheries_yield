


# /----------------------------------------------------------------------------#
#/  Plot distribution of net difference 

ggplot(gdw_barriers_resrivyield) +
  geom_bar(aes(x=as.factor(GDW_ID), y=res_yield), stat='identity', fill='blue', color=NA,) +
  geom_bar(aes(x=as.factor(GDW_ID), y=-1 * riv_yield), stat='identity', fill='orange', color=NA) +
  scale_x_discrete(limits = factor(gdw_barriers_resrivyield$GDW_ID))  +
  xlab('') +
  ylab('Fish yield\n(positive=reservoir; negative=riverine)') +
  line_plot_theme +
  theme(panel.border = element_blank(), 
        axis.line.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.x = element_blank())




# /----------------------------------------------------------------------------#
#/    Save figure to file
ggsave(paste0('../output/figures/barplot_local_loss.pdf'),
       # yield_maps,
       width=178, height=100, dpi=300, units="mm")

ggsave(paste0('../output/figures/barplot_local_loss.png'),
       # yield_maps,
       width=178, height=100, dpi=400, units="mm", type = "cairo-png")

dev.off()



# /----------------------------------------------------------------------------#
#/  Plot distribution of local loss vs size
ggplot() +
  geom_bar(gdw_barriers_resrivyield)