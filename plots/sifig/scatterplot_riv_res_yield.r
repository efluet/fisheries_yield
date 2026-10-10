

# get points with riv and resev
gdw_pts_res_riv <- 
  st_read(paste0('../output/results/yield_losses/localloss_gdw_barrier_lm2c_catch.c2_rep_cap_2024_v10.gpkg')) %>% 
  dplyr::select(GDW_ID, res_yield, riv_yield, localloss) %>%
  
  mutate(rel_tons = localloss * -1, 
         rel_perc = rel_tons/ riv_yield *100)



library(ggrepel)


pos_col <- rev(sequential_hcl(6, palette = 'Blues 3'))[2:6]
neg_col <- rev(sequential_hcl(6, palette = 'Reds 3'))[2:6]

cols <- c(neg_col, pos_col)


scatterplot_res_vs_riv <-
  ggplot() +

  geom_point(data=subset(gdw_pts_res_riv, rel_tons > 0 & rel_tons <=  10^0), aes(x=riv_yield, y=res_yield), color=pos_col[1], size=0.2) +
  geom_point(data=subset(gdw_pts_res_riv, rel_tons< 0 & rel_tons >= -10^0), aes(x=riv_yield, y=res_yield), color=neg_col[1], size=0.2) +
      
  geom_point(data=subset(gdw_pts_res_riv, rel_tons > 10^0 & rel_tons <=  10^1), aes(x=riv_yield, y=res_yield), color=pos_col[2], size=0.2) +
  geom_point(data=subset(gdw_pts_res_riv, rel_tons< -10^0 & rel_tons >= -10^1), aes(x=riv_yield, y=res_yield), color=neg_col[2], size=0.2) +
        
  geom_point(data=subset(gdw_pts_res_riv, rel_tons > 10^1 & rel_tons <=  10^2), aes(x=riv_yield, y=res_yield), color=pos_col[3], size=0.2) +
  geom_point(data=subset(gdw_pts_res_riv, rel_tons< -10^1 & rel_tons >= -10^2), aes(x=riv_yield, y=res_yield), color=neg_col[3], size=0.2) +
  
  geom_point(data=subset(gdw_pts_res_riv, rel_tons > 10^2 & rel_tons <=  10^3), aes(x=riv_yield, y=res_yield), color=pos_col[4], size=0.2) +
  geom_point(data=subset(gdw_pts_res_riv, rel_tons< -10^2 & rel_tons >= -10^3), aes(x=riv_yield, y=res_yield), color=neg_col[4], size=0.2) +
  
  geom_point(data=subset(gdw_pts_res_riv, rel_tons> 10^3),  aes(x=riv_yield, y=res_yield), color=pos_col[5], size=0.2) +
  geom_point(data=subset(gdw_pts_res_riv, rel_tons< -10^3), aes(x=riv_yield, y=res_yield), color=neg_col[5], size=0.2) +
  

  geom_abline(slope=1, intercept = 0, linewidth=0.5, color='grey50') +
  
  scale_y_log10(breaks = breaks_log(n=6, base = 10), labels = label_log(digits = 1), expand=c(0,0)) +
  scale_x_log10(breaks = breaks_log(n=10, base = 10), labels = label_log(digits = 1), expand=c(0,0)) +

  # coord_cartesian(xlim=c(10^-10, 10^5), ylim=c(10^-1,10^4)) +
  coord_equal(xlim=c(10^-6, 10^5), ylim=c(10^-1,10^4)) +
    
    
  xlab('Predicted river fish yield (tonnes/yr)') +
  ylab('Predicted reservoir fish yield (tonnes/yr)') +
    
    
  line_plot_theme() +
  
  theme(legend.position = c(0.5, 0.93),
        legend.title = element_blank(),
        plot.margin=unit(c(3, 2, 2, 2), 'mm'))





# /----------------------------------------------------------------------------#
#/    Save figure to file
ggsave(paste0('../output/figures/si/scatterplot_res_vs_riv_yield_perreserv.pdf'),
       scatterplot_res_vs_riv,
       width=178, height=80, dpi=300, units="mm")


ggsave(paste0('../output/figures/si/scatterplot_res_vs_riv_yield_perreserv.png'),
       scatterplot_res_vs_riv,
       width=178, height=80, dpi=400, units="mm", type = "cairo-png")

dev.off()





gdw_barriers_rel_tons <- 
  # st_read(paste0('../output/results/catch_losses/gdw_barriers_rel_tons_', m, '_', c, '_rep.shp')) %>% 
  st_read(paste0('../output/results/yield_losses/localloss_gdw_barrier_', m, '_', c, '_rep_2024_v05.gpkg')) %>% 
  st_drop_geometry() %>% 
  rename(AREA_SKM = AREA_k2) %>% 
  mutate(rel_tons=localloss * -1) %>% 
  mutate(area_group=cut(AREA_SKM, breaks=c(0, 0.1, 1, 10, 100, 1000, 10000), 
                        labels=c('0-0.1','0.1-1','1-10','10-100','100-1000','1000-10,000')))
# # group_by(area_group) %>% #, lat_group) %>% 
# summarize(n=n(),
#           AREA_SKM=sum(AREA_SKM, na.rm=T),
#           res_yield=sum(res_yield, na.rm=T),
#           riv_yield=sum(riv_yield, na.rm=T),
#           rel_tons=sum(rel_tons, na.rm=T))


glimpse(gdw_barriers_rel_tons)




# # /---------------------------------------------------------------------------#
# #/ Test figure of individual reservoirs
# 
# 
# # Colorrampe
# pos_col <- rev(sequential_hcl(6, palette = 'Blues 3'))[2:6]
# neg_col <- rev(sequential_hcl(6, palette = 'Reds 3'))[2:6]
# 
# 
# ggplot(gdw_barriers_rel_tons, aes(x=riv_yield, y=res_yield))+
#   geom_point(aes(size=AREA_SKM), color='grey70', size=0.1) +
#   
#   # scale_x_log10(limits=c(10^-5, 10^5)) + 
#   xlab('Riverine yield in reservoir footprint (tonnes/yr)') +
#   ylab('Reservoir yield (tonnes/yr)') +
#   scale_x_log10(breaks=c(10^-3, 10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3, 10^4, 10^5),
#                 labels=expression(10^-3, 10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3, 10^4, 10^5),
#                 limits=c(10^-3, 10^5),
#                 expand=c(0,0)) +
#   scale_y_log10(breaks=c(10^-3, 10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3, 10^4, 10^5),
#                 labels=expression(10^-3, 10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3, 10^4, 10^5),
#                 limits=c(10^-3, 10^5),
#                 expand=c(0,0)) +
#   
#   coord_equal() +
#   line_plot_theme() +
#   
#   geom_point(data=subset(gdw_barriers_rel_tons, rel_tons > 10^-1 & rel_tons <=  10^0), color='#D0E4FF', size=0.15) +
#   geom_point(data=subset(gdw_barriers_rel_tons, rel_tons< -10^-1 & rel_tons >= -10^0), color='#FFCCCE', size=0.15) +
#   
#   geom_point(data=subset(gdw_barriers_rel_tons, rel_tons > 10^0 & rel_tons <=  10^1), color='#99BFEF', size=0.15) +
#   geom_point(data=subset(gdw_barriers_rel_tons, rel_tons< -10^0 & rel_tons >= -10^1), color='#FF9197', size=0.15) +
#   
#   geom_point(data=subset(gdw_barriers_rel_tons, rel_tons > 10^1 & rel_tons <=  10^2), color='#5295D4', size=0.15) +
#   geom_point(data=subset(gdw_barriers_rel_tons, rel_tons< -10^1 & rel_tons >= -10^2), color='#F84855', size=0.15) +
#   
#   
#   geom_point(data=subset(gdw_barriers_rel_tons, rel_tons > 10^2 & rel_tons <=  10^3), color='#0066A5', size=0.15) +
#   geom_point(data=subset(gdw_barriers_rel_tons, rel_tons< -10^2 & rel_tons >= -10^3), color='#B71729', size=0.15) +
#   
#   geom_point(data=subset(gdw_barriers_rel_tons, rel_tons> 10^3),  color='#00366C', size=0.15) +
#   geom_point(data=subset(gdw_barriers_rel_tons, rel_tons< -10^3), color='#69000C', size=0.15) +
#   
#   geom_abline(intercept=0, slope=1, size=0.2)
# 
# 
