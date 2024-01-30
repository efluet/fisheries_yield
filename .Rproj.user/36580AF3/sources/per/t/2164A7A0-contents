# /---------------------------------------------------------------------------#
#/    Get threshold
dor_thresh_df <- read.csv('../output/dor/gdw_dor_thresholds.csv')

glimpse(dor_thresh_df)


# /---------------------------------------------------------------------------#
#/   Plot

line_dor_thresh <- ggplot() +
  
  geom_vline(aes(xintercept=2), color='grey85', size=0.3) +
  geom_point(data=dor_thresh_df, aes(x=thresh*100, y=dor_loss/1000), color='red', size=0.5) +
  geom_line(data=dor_thresh_df, aes(x=thresh*100, y=dor_loss/1000), color='red', size=0.3) +

  
  xlab('Minimum degree of regulation (DOR) for fish yield losses (%)') + 
  ylab(expression(paste('Decline in downstream fish yield (1000 tonnes yr'^-1*')'))) +
  
  scale_x_continuous(expand=c(0,0),
                     breaks=c(0,2,10,20,30,40,50))+
  
  line_plot_theme() +
  theme(panel.border = element_blank(),
        plot.margin=unit(c(1, 2, 1, 1), 'mm'))



# /---------------------------------------------------------------------------#
#/   
ggsave('../output/figures/si_lineplot_dor_thresh.pdf',
       line_dor_thresh,
       width= 90, height=90, dpi=500, units='mm')

ggsave('../output/figures/si_lineplot_dor_thresh.png',
       line_dor_thresh,
       width= 90, height=90, dpi=500, units='mm')



