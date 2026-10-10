
library(MASS)
library(Metrics)


basins_wpreds_df <- 
  read.csv('../output/results/riv_yield_distrib/basins_wpreds_df_wdistrib.csv')



# /----------------------------------------------------------------------------#
#/    Fit robust regression to get predicted yield

# Compare parameters to Cathy's model fit:  log10C = 2.747 + 0.57*logPop + 0.405*logQ + 0.018*Wet%
rlm_riv <- rlm(logcatch ~ logpopdens  + logq_km3yr + wetperc, data=basins_wpreds_df) # %>% tidy()
summary(rlm_riv)
AIC(rlm_riv)

# RLM model
riv_rlm <- rlm(basins_wpreds_df$Catch_tonnesyr ~ basins_wpreds_df$fit)

# Compute the R2; because robust 
pred <- predict(riv_rlm)
rlm_r2 <- cor(basins_wpreds_df$Catch_tonnesyr, basins_wpreds_df$fit)^2


# ## Make labels 
pred_plot_label <- 
  paste0(#'Robust linear regression predicted yield','\n',
          'logCatch = 2.74 + 0.54×log10Pop + 0.41×log10Q + 0.2×Wet%', '\n',
          'n=', nrow(basins_wpreds_df), '      ', 
          'R2=', round(rlm_r2, 2),  ' \n',
          'AIC=', round(AIC(rlm_riv), 1), ' \n',
          'RMSE=', round(rmse(basins_wpreds_df$Catch_tonnesyr, basins_wpreds_df$fit)/10^6,3), ' M tonnes/yr') 



# /----------------------------------------------------------------------------#
#/   Scatterplot of RLM fit
library(ggrepel)

colfunc_green <- colorRampPalette(c('#5ae673', '#00360a'))

scatterplot_riv_fish_lm_obs_v_pred <- 
ggplot(basins_wpreds_df)+

  annotate(geom='text', x=1.2*10^1, y=2.2*10^6, label=pred_plot_label, hjust=0, color='black', size=1.8) +
  
  geom_abline(slope=1, intercept = 0, size=0.5, color='grey80') +
  
  geom_point(aes(x=Catch_tonnesyr, y=fit, color=Catch_tonnesyr), size=0.8) +
  
  geom_errorbar(aes(x=Catch_tonnesyr,  y=fit, ymin=lwr, ymax=upr,
                    color=Catch_tonnesyr),
               size=.2,    # Thinner lines
               width=0,
               position=position_dodge(.9))+
  
  
  # ggtitle('lm2c-2024:  log10Catch = log10Q + log10Pop + log10GLWDv2Frac') +
  # ggtitle('Predicted yield - Robust linear regression') +

  xlab(paste0('Literature river yield (tonnes/yr) \nTotal= ', round(sum(basins_wpreds_df$Catch_tonnesyr)/10^6,2), ' M tonnes/yr')) +
  ylab(paste0('Predicted river yield (tonnes/yr) \nTotal= ', round(sum(basins_wpreds_df$fit)/10^6,2), ' M tonnes/yr')) +
  
  scale_y_log10(breaks = breaks_log(n= 8, base = 10), labels = label_log(digits = 1), expand=c(0,0)) +
  scale_x_log10(breaks = breaks_log(n= 8, base = 10), labels = label_log(digits = 1), expand=c(0,0)) +

  scale_color_gradientn(#colors= pos_col,
    colors=colfunc_green(5), #RColorBrewer::brewer.pal(9, 'Greens')[3:9]),
    trans='log',
    limits=c(10^{2}, 3*10^{6}),
    guide=F) +
  
  line_plot_theme() +
  coord_cartesian(xlim=c(10^1,10^7), ylim=c(10^1,10^7))+
  # coord_equal() +
  theme(axis.line.x  = element_blank(),
        #panel.border = element_blank(),
        axis.ticks.x = element_blank(),
        plot.background = element_rect(fill = 'white', colour = NA),
        legend.position = c(0.4, 0.4),
        plot.margin=unit(c(3, 2, 2, 2), 'mm'))


scatterplot_riv_fish_lm_obs_v_pred


# geom_text_repel(
#   aes(x=Catch_tonnesyr, y=fit, label = NAME),
#   color='grey70',
#   segment.color='grey70',
#   size = 3,
#   nudge_x = 0,
#   segment.size = 0.25,
#   box.padding = unit(0.5, 'mm'),
#   point.padding = unit(.5, 'mm')) +

# scatterplot_riv_fish_lm_obs_v_pred



# /----------------------------------------------------------------------------#
#/   Scatterplot of DISTRIB vs OBS


#/   MAKE PLOT LABEL using model
riv_rlm <- lm(basins_wpreds_df$Catch_tonnesyr ~ basins_wpreds_df$distrib_fit)

# Compute the R2; because robust 
rlm_r2 <- cor(basins_wpreds_df$Catch_tonnesyr, predict(riv_rlm))^2


# Make label
distrib_plot_label <- 
  paste0('Distributed river catch constrained by national totals','\n',
  'n=', nrow(basins_wpreds_df), '     ',
  'R2=', round(rlm_r2, 2), '   \n',
  'RMSE=', round(rmse(basins_wpreds_df$Catch_tonnesyr, basins_wpreds_df$distrib_fit)/10^6,3), ' M tonnes/yr')



# /----------------------------------------------------------------------------#
#/   Scatterplot of DISTRIB

library(ggrepel)

scatterplot_riv_fish_distrib_obs_v_pred <- 
  
  ggplot(basins_wpreds_df)+
  
  annotate(geom='text', x=1.2*10^1, y=2.5*10^6, label=distrib_plot_label, hjust=0, color='black', size=1.8) +
  
  geom_abline(slope=1, intercept = 0, size=0.5, color='grey80') +
  geom_point(aes(x=Catch_tonnesyr, y=distrib_fit, color=Catch_tonnesyr), size=0.8) +
  geom_errorbar(aes(x=Catch_tonnesyr,  y=distrib_fit, ymin=distrib_lwr, ymax=distrib_upr,
                    color=Catch_tonnesyr),
              size=.1,    # Thinner lines
              width=0,
              position=position_dodge(.9)) +
              # color='red3') +

  scale_y_log10(breaks = breaks_log(n=8, base = 10), labels = label_log(digits = 1), expand=c(0,0)) +
  scale_x_log10(breaks = breaks_log(n= 8, base = 10), labels = label_log(digits = 1), expand=c(0,0)) +
  
  # ggtitle('Distributed river catch constrained by national totals') +
  xlab(paste0('Literature river yield (tonnes/yr) \nTotal= ', round(sum(basins_wpreds_df$Catch_tonnesyr)/10^6,2), ' M tonnes/yr')) +
  ylab(paste0('Distributed river yield (tonnes/yr) \nTotal= ', round(sum(basins_wpreds_df$distrib_fit)/10^6,2), ' M tonnes/yr')) +
  
  scale_color_gradientn(#colors= pos_col,
    colors=colfunc_green(5), #RColorBrewer::brewer.pal(9, 'Greens')[3:9]),
    trans='log',
    limits=c(10^{2}, 3*10^{6}),
    guide=F) +
  
  line_plot_theme() +
  coord_cartesian(xlim=c(10^1,10^7), ylim=c(10^1,10^7))+
  theme(axis.line.x  = element_blank(),
        #panel.border = element_blank(),
        plot.background = element_rect(fill = 'white', colour = NA),
        axis.ticks.x = element_blank(),
        legend.position = c(0.4, 0.4),
        plot.margin=unit(c(3, 2, 2, 2), 'mm'))

scatterplot_riv_fish_distrib_obs_v_pred

  
