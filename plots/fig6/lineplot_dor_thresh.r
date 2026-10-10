
# /---------------------------------------------------------------------------#
#/    Get losses for different DOR thresholds
dor_thresh_df <- read.csv('../output/results/dor/gdw_dor_thresholds_102024.csv')

glimpse(dor_thresh_df)


# /---------------------------------------------------------------------------#
#/   Plot

line_dor_thresh <- 
  
  ggplot() +
  
  geom_rect(aes(xmin = 0, xmax = 4, ymin = 1100, ymax = 2200), fill = "grey80") +
  geom_vline(aes(xintercept=2), color='grey25', size=0.3) +
  
  
  geom_point(data=dor_thresh_df, aes(x=thresh*100, y=dor_loss/1000), color='red', size=0.5) +
  geom_line(data=dor_thresh_df, aes(x=thresh*100, y=dor_loss/1000), color='red', size=0.3) +

  
  xlab('Minimum threshold of degree of regulation (DOR)\nfor fish yield losses (%)') + 
  ylab(expression(paste('Downstream fish yield loss (1000 tonnes yr'^-1*')'))) +
  
  
  scale_y_continuous(breaks=pretty_breaks(7), limits=c(1100, 2200), expand=c(0,0))+
  
  scale_x_continuous(limits=c(0, 51),
                     expand=c(0,0),
                     breaks=c(0,2,4, 10,20,30,40,50)) + 
    
  line_plot_theme() +
  theme(panel.border = element_blank(),
        plot.margin=unit(c(8, 4, 8, 2), 'mm'))


line_dor_thresh

