dor <- rast('../output/dor/gdw_dor_v8.tif')
dl_loss <- rast('../output/results/catch_losses/gdw_dor_2p_loss.tif')

df <- c(dor, dl_loss) 

df <- as.data.frame(df, na.rm=T)
names(df) <- c('flow_acc_v01','gdw_dor_2p_loss')

df_count <- 
  df %>% 
  filter(flow_acc_v01 >= 0.02,
         !is.na(gdw_dor_2p_loss)) #%>% 
  # mutate(gdw_dor_2p_loss_bin=cut(gdw_dor_2p_loss, breaks=seq(0, 1, 0.01), labels=seq(0.01, 1, 0.01))) %>% 
  # group_by(gdw_dor_2p_loss_bin) %>% 
  # summarize(n=n()/1000)


glimpse(df_count)


# /---------------------------------------------------------------------------#
#/   Plot

bar_dor_count <- ggplot() +
  
  # geom_bar(data=df_count, aes(x=gdw_dor_2p_loss_bin, y=n), 
  #          fill='#ba1182', color=NA, stat='identity') +
  
  stat_ecdf(data=df_count, aes(x=flow_acc_v01), color='#ba1182') +
  
  xlab('Degree of Regulation (%)') + 
  ylab(expression(paste('Number of 1km cells (x1000)'))) +
  
  scale_y_continuous(expand=c(0,0)) +
  # scale_x_continuous(breaks=seq(0,1,0.1), labels=seq(0,1,0.1), expand=c(0,0)) +
  
  line_plot_theme() +
  theme(panel.border = element_blank(),
        plot.margin=unit(c(1, 2, 4, 1), 'mm'))


bar_dor_count


# /---------------------------------------------------------------------------#
#/   
ggsave('../output/figures/si_barplot_dor_count.pdf',
       bar_dor_count,
       width= 90, height=90, dpi=500, units='mm')

ggsave('../output/figures/si_barplot_dor_count.png',
       bar_dor_count,
       width= 90, height=90, dpi=500, units='mm')
