
library(Metrics)

# /----------------------------------------------------------------------------#
#/  Read reservoir inputs

cs_pts <- 
  st_read('../output/results/res_train_yield/cs_reserv_catch_2024_wpreds_v10.gpkg')
  

# Fit model
lm_reserv <- rlm(log10CATCH_tonnesyr ~ log10AREA_km2 + temp, data=cs_pts)

# Compute the R2; because robust 
pred <- predict(lm_reserv)
rlm_r2 <- cor(cs_pts$log10CATCH_tonnesyr, pred)^2

res_plot_label <- paste0('logCatch = -0.18 + 0.75×log10Area + 0.04×Temp + 0.03×log10Pop', '\n', 
                         'n=', nrow(cs_pts), '    ',
                         'R2=',round(rlm_r2, 2), '\n',
                         'RMSE=', round(rmse(cs_pts$CATCH_tonnesyr, cs_pts$predCATCH_tonnesyr)/10^6, 3), ' M tonnes/yr')



# /----------------------------------------------------------------------------#
#/ Scatterplot of regressions

colfunc_purp <- colorRampPalette(c("#f1b3ff", "#41004f"))


scatterplot_reservoir_yield_lm <-
  
  ggplot(cs_pts) +
  
  annotate(geom="text", x=1.2*10^-2, y=2.6*10^4, label=res_plot_label, hjust=0, color="black", size=1.8) +
  
  geom_abline(slope=1, intercept = 0, linewidth=0.5, color='grey80') +
  geom_point(data=cs_pts, aes(x=CATCH_tonnesyr, y=predCATCH_tonnesyr, color=CATCH_tonnesyr), 
             size=.4) +
  
  geom_errorbar(aes(x=CATCH_tonnesyr,  y=predCATCH_tonnesyr, 
                    ymin=predCATCH_tonnesyr_lwr, ymax=predCATCH_tonnesyr_upr,
                    color=CATCH_tonnesyr),
                alpha=0.8,
                linewidth=.2,    # Thinner lines
                width=0,
                position=position_dodge(.9)) +

  scale_color_gradientn(colors=colfunc_purp(5), 
                        #c('#fdee68','#79d27c','#44d5cd','#3333ff','#000099'),#low='#ffffcc', high='blue',
                        trans='log',
                        breaks=c(10^-1, 10^0, 10^1, 10^2, 10^3, 10^4),
                        labels=expression(10^-1, 10^0, 10^1, 10^2, 10^3, 10^4),
                        limits=c(10^-1, 10^4),
                        guide=F) +
  
  scale_x_log10(breaks = breaks_log(n=8, base = 10), labels = label_log(digits = 1), expand=c(0,0)) +
  scale_y_log10(breaks = breaks_log(n=8, base = 10), labels = label_log(digits = 1), expand=c(0,0)) +
  
  coord_cartesian(xlim=c(10^-2, 10^5), ylim=c(10^-2,10^5)) +
  line_plot_theme() +
  
  # ggtitle('Reservoir yield') +
  xlab(paste0('Literature reservoir fish yield (tonnes/yr) \nTotal= ', round(sum(cs_pts$CATCH_tonnesyr)/10^6, 2), ' M tonnes/yr')) +
  ylab(paste0('Predicted reservoir fish yield (tonnes/yr) \nTotal= ', round(sum(cs_pts$predCATCH_tonnesyr)/10^6, 2), ' M tonnes/yr')) +

  theme(legend.position = c(0.5, 0.93),
        legend.title = element_blank(),
        plot.margin=unit(c(3, 2, 2, 2), 'mm'))


scatterplot_reservoir_yield_lm


