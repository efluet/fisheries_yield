

# /---------------------------------------------------------------------------#
#/. Boxplot of individual dams per size class

gdw_barriers_rel_tons <- 
  st_read('../output/results/yield_losses/localloss_gdw_barrier_lm2c_catch.c2_rep_cap_2024_v10.gpkg') %>% 
  # dplyr::select(GDW_ID, res_yield, riv_yield, localloss) %>%
  # mutate(rel_tons = localloss * -1, 
  #        rel_perc = rel_tons/ riv_yield *100)
  st_drop_geometry() %>% 
  rename(AREA_SKM = AREA_k2) %>% 
  mutate(rel_tons=localloss * -1) %>% 
  mutate(area_group=cut(AREA_SKM, breaks=c(0, 0.1, 1, 10, 100, 1000, 10000), 
                      labels=c('0-0.1','0.1-1','1-10','10-100','100-1000','1000-10,000'))) %>% 
  filter(rel_tons >= -1000 | rel_tons <= 1000 )




# /---------------------------------------------------------------------------#
#/   

pos_col <- rev(sequential_hcl(6, palette = 'Blues 3'))[2:6]
neg_col <- rev(sequential_hcl(6, palette = 'Reds 3'))[2:6]

cols <- c(rev(neg_col), pos_col)


# /---------------------------------------------------------------------------#
#/   Plot local loss per size
library(see)


points_net_change_perarea <- 
  ggplot()+
  
  geom_text(data=gdw_barriers_rel_tons_summarized, 
            aes(x=area_group, y=1100, label= paste0('n=', n)), size=2) + # 150000
  
  # Add 0 line
  geom_hline(aes(yintercept=0), size=0.2, color='grey40') +
  
  
  geom_boxplot(data= gdw_barriers_rel_tons, aes(x=area_group, y=rel_tons, color=rel_tons), 
               outlier.shape = NA, coef = 2.69, width=0.5, linewidth=0.2, color='grey15',  fill='grey80') +
  
  # Box plot
  # geom_point(data= gdw_barriers_rel_tons, aes(x=area_group, y=rel_tons, color=rel_tons), position = "jitter", size=0.25) +
  # 
  # geom_point(data=subset(gdw_barriers_rel_tons, rel_tons > 0 & rel_tons <=  10^0), aes(x=area_group, y=rel_tons), color=pos_col[1], size=0.4, position='jitter') +
  # geom_point(data=subset(gdw_barriers_rel_tons, rel_tons< 0 & rel_tons >= -10^0), aes(x=area_group, y=rel_tons), color=neg_col[1], size=0.4, position='jitter') +
  # 
  # geom_point(data=subset(gdw_barriers_rel_tons, rel_tons > 10^0 & rel_tons <=  10^1), aes(x=area_group, y=rel_tons), color=pos_col[2], size=0.4, position='jitter') +
  # geom_point(data=subset(gdw_barriers_rel_tons, rel_tons< -10^0 & rel_tons >= -10^1), aes(x=area_group, y=rel_tons), color=neg_col[2], size=0.4, position='jitter') +
  # 
  # geom_point(data=subset(gdw_barriers_rel_tons, rel_tons > 10^1 & rel_tons <=  10^2), aes(x=area_group, y=rel_tons), color=pos_col[3], size=0.4, position='jitter') +
  # geom_point(data=subset(gdw_barriers_rel_tons, rel_tons< -10^1 & rel_tons >= -10^2), aes(x=area_group, y=rel_tons), color=neg_col[3], size=0.4, position='jitter') +
  # 
  # geom_point(data=subset(gdw_barriers_rel_tons, rel_tons > 10^2 & rel_tons <=  10^3), aes(x=area_group, y=rel_tons), color=pos_col[4], size=0.4, position='jitter') +
  # geom_point(data=subset(gdw_barriers_rel_tons, rel_tons< -10^2 & rel_tons >= -10^3), aes(x=area_group, y=rel_tons), color=neg_col[4], size=0.4, position='jitter') +
  # 
  # geom_point(data=subset(gdw_barriers_rel_tons, rel_tons> 10^3),  aes(x=area_group, y=rel_tons), color=pos_col[5], size=0.4) +
  # geom_point(data=subset(gdw_barriers_rel_tons, rel_tons< -10^3), aes(x=area_group, y=rel_tons), color=neg_col[5], size=0.4) +
  # 
  guides(color = guide_colorbar(
    nbin=10, raster=F, barheight = .6, barwidth=8, reverse=F,
    frame.colour=c('black'), frame.linewidth=0.2,
    ticks.colour='black',  direction='horizontal',
    title = expression(paste('Change in fish yield (tonnes/year)\n(river - reservoir yield)')))) +
  

  xlab(expression(paste('Reservoir area class (km'^2*')'))) + 
  ylab(expression(paste('Local change in fish yield (tonnes yr'^-1*')'))) +
  
  scale_y_continuous(limits=c(-10^3, 1.15 *10^3), expand=c(0,0)) +
  
  scale_x_discrete(expand=c(0,0), position = "top") +

  line_plot_theme() +
  theme(axis.line.x  = element_blank(),
        panel.border = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.x  = element_text(size=7, colour='black', face='bold'),
        legend.title = element_blank(),
        legend.position = c(0.1, 0.8),
        plot.margin=unit(c(1, 5, 1, 1), 'mm'))


points_net_change_perarea



# /---------------------------------------------------------------------------#
#/    Barplot of totals

gdw_barriers_rel_tons_summarized <- 
  st_read('../output/results/yield_losses/localloss_gdw_barrier_lm2c_catch.c2_rep_cap_2024_v10.gpkg') %>% 
  st_drop_geometry() %>% 
  tibble() %>% 
  rename(AREA_SKM = AREA_k2) %>% 
  mutate(rel_tons=localloss * -1) %>% 
  mutate(area_group=cut(AREA_SKM, breaks=c(0, 0.1, 1, 10, 100, 1000, 10000), 
                        labels=c('0-0.1','0.1-1','1-10','10-100','100-1000','1000-10,000'))) %>% 
  group_by(area_group) %>% #, lat_group) %>%
  summarize(n=n(),
            AREA_SKM=sum(AREA_SKM, na.rm=T),
            res_yield=sum(res_yield, na.rm=T),
            riv_yield=sum(riv_yield, na.rm=T),
            rel_tons=sum(rel_tons, na.rm=T),
            rel_tons_uncert = sqrt(sum(rel_tons^2, na.rm=T))) 


gdw_barriers_rel_tons_summarized



# /----------------------------------------------------------------------------#
#/  
barplot_sum_change_perarea <- 
  ggplot()+
  
  # Box plot
  geom_bar(data= gdw_barriers_rel_tons_summarized, aes(x=area_group, y=rel_tons/10^6), 
           size=0.25, stat='identity', fill='grey85', color=NA, width=0.5) +
  
  geom_errorbar(data= gdw_barriers_rel_tons_summarized, 
                aes(x=area_group, ymin=(rel_tons-rel_tons_uncert/2)/10^6, ymax=(rel_tons+rel_tons_uncert/2)/10^6), 
                size=0.25, stat='identity', color='grey20', width=0, linewidth=0.2) +
  
  # Add 0 line
  geom_hline(aes(yintercept=0), size=0.2, color='grey40') +

  xlab("") +
  # xlab(expression(paste('Reservoir area class (km'^2*')'))) + 
  ylab(expression(paste('Total local change in fish yield (M tonnes yr'^-1*')'))) +
  
  # scale_y_continuous(limits=c(-10^3, 10^3), expand=c(0,0)) +
  scale_x_discrete(expand=c(0,0)) +
  
  line_plot_theme() +
  theme(axis.line.x  = element_blank(),
        panel.border = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.x = element_blank(),
        legend.title = element_blank(),
        legend.position = c(0.1, 0.8),
        plot.margin=unit(c(1, 5, 1, 1), 'mm'))
  

barplot_sum_change_perarea


# /----------------------------------------------------------------------------#
#/  Arrange plots grob into layout 

size_plots <- 
  plot_grid(points_net_change_perarea,
            barplot_sum_change_perarea,
            ncol=1, nrow=2,
            align='v',
            labels = c('A','B'))


# /---------------------------------------------------------------------------#
#/   
ggsave('../output/figures/fig8/multipanel_size_vs_localloss_v2.pdf',
       size_plots,
       width=100, height=110, dpi=500, units='mm')


ggsave('../output/figures/fig8/multipanel_size_vs_localloss_v2.png',
       size_plots,
       width=100, height=110, dpi=500, units='mm')


