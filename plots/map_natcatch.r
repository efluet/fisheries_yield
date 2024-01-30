source('./plots/themes/map_theme.r')


# Read catch
natcatch <- read.csv('../output/catch_stats/riv_catch_1997_2014_andcomposited.csv') %>% 
            # filter(country_code != 'SDN') %>% 
            rename(catch.c1 = fao.avg.catch.1997.2014) %>% 
            mutate(catch.c1 =ifelse(catch.c1<0.001, 0.001, catch.c1),
                   catch.c2 =ifelse(catch.c2<0.001, 0.001, catch.c2),
                   catch.c3 =ifelse(catch.c3<0.001, 0.001, catch.c3))

names(natcatch)

# /----------------------------------------------------------------------------#
#/  get country and bbox polygons for mapping                              -----
source('./plots/get_country_bbox_shp_for_ggplot_map.r')


# /----------------------------------------------------------------------------#
#/ get country shpfiles 
library(sf)
c <- st_read('../data/nat_earth/ne_110m_admin_0_countries.shp', quiet=T) %>% 
     # join the data table to shapefile 
     left_join(., natcatch, by=c('adm0_a3'='country_code'), all.x=T, all.y=F)



# /----------------------------------------------------------------------------#
#/      Make map
plot_c1 = 
  ggplot() +
  geom_sf(data= subset(c, !is.na(catch.c1)), aes(fill = catch.c1), size=0) +
  geom_sf(data=c, fill=NA, color='black', size=0.1) +
  theme_bw() +
  
  ggtitle('FAO Catch') +
  labs(fill = 'Million tonnes') + 
  # coord_sf(xlim = NULL, ylim = c(90,-55), expand=F) +  
  theme_fig() +
  scale_fill_distiller(type='seq', direction=1, palette = 'YlGnBu', trans='log',
                       breaks=c(0.001, 0.001, 0.01, 0.1, 1, 2.5),
                       limits=c(0.001, 2.5)) +
  theme(legend.position='right',
        legend.direction = 'vertical',
        plot.margin = unit(c(-2,-1,-2,-4), 'mm')) +
  guides(fill = guide_colorbar(barwidth = 1, barheight = 8))


# /----------------------------------------------------------------------------#
#/      Make map

plot_c2 = 
  ggplot() +
  geom_sf(data= subset(c, !is.na(catch.c2)), aes(fill = catch.c2), size=0) +
  geom_sf(data=c, fill=NA, color='black', size=0.1) +
  
  geom_sf(data=subset(c, label.c2=='HCES'), fill=NA, color='red', size=0.35) +
  # scale_fill_viridis('Area') +
  
  theme_bw() +
  
  ggtitle('FAO Catch & 42 survey substitution') +
  labs(fill = 'Million tonnes') +
  # coord_sf(ylim = c(90,-55), expand=F) +  
  # coord_sf(xlim = NULL, ylim = c(90,-55), expand=F) +  
  theme_fig() +
  scale_fill_distiller(type='seq', direction=1, palette = 'YlGnBu', trans='log',
                       breaks=c(0.001, 0.001, 0.01, 0.1, 1, 2.5),
                       limits=c(0.001, 2.5)) +
  theme(legend.position='right',
        legend.direction = 'vertical',
        plot.margin = unit(c(-2,-1,-2,-4), 'mm')) +
  guides(fill = guide_colorbar(barwidth = 1, barheight = 8))



# /----------------------------------------------------------------------------#
plot_c3 = 
  ggplot() +
  geom_sf(data= subset(c, !is.na(catch.c3)), aes(fill = catch.c3), size=0) +
  geom_sf(data=c, fill=NA, color='black', size=0.1) +
  
  geom_sf(data=subset(c, label.c3=='HCES'), fill=NA, color='red', size=0.35) +
  geom_sf(data=subset(c, label.c3=='GLM'), fill=NA, color='red', size=0.35) +
  
  # theme_bw() +
  
  ggtitle('FAO Catch & 42 survey substitution & ~40 extrapolation') +
  labs(fill = 'Million tonnes') +

  # coord_sf(xlim = NULL, ylim = c(90,-55), expand=F) +  
  theme_fig() +
  scale_fill_distiller(type='seq', direction=1, palette = 'YlGnBu', trans='log',
                       breaks=c(0.001, 0.001, 0.01, 0.1, 1, 2.5),
                       limits=c(0.001, 2.5)) +
  theme(legend.position='right',
        legend.direction = 'vertical',
        plot.margin = unit(c(-2,-1,-2,-4), 'mm')) +
  guides(fill = guide_colorbar(barwidth = 1, barheight = 8))



# /----------------------------------------------------------------------------#
library(cowplot)
library(gridExtra)
ps <-  plot_grid(plot_c1, 
                plot_c2,
                plot_c3,
                ncol=1, nrow=3, align="hv")
                # labels=c("A","B","C"))

### Save figure to file --------------------------------------------------------
ggsave('../output/figures/maps_catch1to3_combined_2021.png', ps,
       width=130, height=180, dpi=400, units="mm", type = "cairo-png")
dev.off()
