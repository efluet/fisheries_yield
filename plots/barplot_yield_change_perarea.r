
# 
gdw_barriers_localloss <- 
  st_read(paste0('../output/results/catch_losses/gdw_barriers_localloss_', m, '_', c, '_rep.shp')) %>% 
  st_drop_geometry() %>% 
  mutate(localloss=localloss * -1) %>% 
  mutate(area_group=cut(AREA_SKM, breaks=c(0, 0.1, 1, 10, 100, 1000, 10000), 
                      labels=c('0-0.1','0.1-1','1-10','10-100','100-1000','1000-10,000'))) %>% 
  group_by(area_group, lat_group) %>% 
  summarize(n=n(),
            AREA_SKM=sum(AREA_SKM, na.rm=T),
            res_yield=sum(res_yield, na.rm=T),
            riv_yield=sum(riv_yield, na.rm=T),
            localloss=sum(localloss, na.rm=T))


glimpse(gdw_barriers_localloss)

# /---------------------------------------------------------------------------#
#/   Plot

barplot_net_change_perarea <- 
  ggplot(gdw_barriers_localloss)+

  geom_bar(aes(x=area_group, y=localloss/1000, fill=lat_group), 
           stat='identity', color=NA, width=0.5, position='dodge') +
  
  geom_hline(aes(yintercept=0), size=0.2, color='grey80') +

  geom_text(aes(x=area_group, y=50, label=n, group=lat_group), 
           stat='identity', size=1.8, position = position_dodge(width = .8)) +
    
  xlab(expression(paste('Reservoir size class (area in km'^2*')'))) + 
  ylab(expression(paste('Local change in fish yield (1000 tonnes yr'^-1*')'))) +
  
  scale_y_continuous(limits=c(-200, 60), expand=c(0,0)) +
  scale_x_discrete(expand=c(0,0)) +
  scale_fill_manual(values=c('#18c92d','#f2600c')) +
  
  line_plot_theme() +
  theme(axis.line.x  = element_blank(),
        panel.border = element_blank(),
        axis.ticks.x = element_blank(),
        legend.title = element_blank(),
        legend.position = c(0.2, 0.2),
        plot.margin=unit(c(1, 2, 1, 1), 'mm'))


# /---------------------------------------------------------------------------#
#/   
ggsave('../output/figures/barplot_net_change_perarea.pdf',
       barplot_net_change_perarea,
       width=90, height=60, dpi=500, units='mm')


ggsave('../output/figures/barplot_net_change_perarea.png',
       barplot_net_change_perarea,
       width=90, height=60, dpi=500, units='mm')
