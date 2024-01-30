
# /----------------------------------------------------------------------------#
#/   MAKE LIST OF ALL PRED & DISTRIB RASTERS

# get list of all pred catches
pred_catch_dir <- '../output/results/pred_catch/'
pred_catch_ls <- list.files(pred_catch_dir)
pred_catch_ls <- unlist(lapply(pred_catch_ls, function(x){ paste0(pred_catch_dir, x) }))


# get list of files for all distrib catches.
distrib_catch_dir <- '../output/results/distrib_catch/'
distrib_catch_ls <- list.files(distrib_catch_dir)
distrib_catch_ls <- unlist(lapply(distrib_catch_ls, function(x){ paste0(distrib_catch_dir, x) }))

# Combine lists
catch_ls <- c(pred_catch_ls, distrib_catch_ls)


# this is the model/map we selected as final
catch_ls <- "../output/results/distrib_catch/distrib_catch_lm2c_c2.tif" 



r <- raster(catch_ls)
r[r<10000] <- NA
r <- stack(r, ciso)

# rdf <- SpatialPixelsDataFrame(r)
rdf <- as.data.frame(r)
names(rdf) <- c('catch','isoa3')
rdf <- rdf %>%  filter(!is.na(catch))
glimpse(rdf)



# /------------------------------------
#/   PLOT HISTOGRAM OF 
ggplot(rdf) +

  geom_histogram(aes(x=distrib_catch_lm2c_c2), 
                 color='black',fill= '#8ae0e7', 
                 bins=35, alpha=0.85, na.rm = TRUE, size=0.2) +

  
  geom_vline(xintercept = 10^-3, color='red') +
  geom_vline(xintercept = 1054, color='red') +
  geom_vline(xintercept = 74, color='red') +
  
  
  scale_x_log10(
    breaks = scales::trans_breaks("log10", function(x) 10^x),
    labels = scales::trans_format("log10", scales::math_format(10^.x)),
    limits = c(10^-10, 10^5)
  ) +
  
  scale_y_continuous(breaks=c(0, 50000, 100000, 150000)) +
  
  xlab('Pixel fish catch (tons yr^-1)') +
  # labs(x=expression(Pixel~fish~catch~(tons yr^{-1}))) +
  
  ylab('Pixel count') +
  ggtitle('Global distribution of fish catch') +
  
  line_plot_theme +
  theme(      text = element_text(size=8, colour='black'),
              ### LEGEND
              legend.text = element_text(size = 8),
              legend.background = element_blank(),
              legend.key.size = unit(4, "mm"),
              legend.title=element_blank()
  )



#------------------------------------
ggplot(rdf) +
  
  stat_ecdf(aes(x=distrib_catch_lm2c_c2), 
                 color='black', alpha=0.85, na.rm = TRUE, size=0.2) +
  
  # scale_x_log10(
  #   breaks = scales::trans_breaks("log10", function(x) 10^x),
  #   labels = scales::trans_format("log10", scales::math_format(10^.x)),
  #   limits = c(10^-10, 10^5)
  # ) +
  
  scale_y_continuous(breaks=c(0, 50000, 100000, 150000)) +
  
  xlab('Pixel fish catch (tons yr^-1)') +
  # labs(x=expression(Pixel~fish~catch~(tons yr^{-1}))) +
  
  ylab('Pixel count') +
  ggtitle('Global distribution of fish catch') +
  
  line_plot_theme +
  theme(      text = element_text(size=8, colour='black'),
              ### LEGEND
              legend.text = element_text(size = 8),
              legend.background = element_blank(),
              legend.key.size = unit(4, "mm"),
              legend.title=element_blank()
  )
# 
# stat_ecdf(
#   mapping = NULL,
#   data = NULL,
#   geom = "step",
#   position = "identity",
#   ...,
#   n = NULL,
#   pad = TRUE,
#   na.rm = FALSE,
#   show.legend = NA,
#   inherit.aes = TRUE
# )


ggplot(rdf) +
  
  geom_histogram(aes(x=distrib_catch_lm2c_c2), 
                 color='black',fill= '#8ae0e7', 
                 bins=35, alpha=0.85, na.rm = TRUE, size=0.2) +
  


# /----------------------------------------------------------------------------#
#/    Save figure to file 
ggsave('../output/figures/global_distribution_lm2c_catch.png', 
       width=160, height=160, dpi=240, units='mm', type = 'cairo-png')
dev.off()

# /----------------------------------------------------------------------------#
#/ Get river basin shapefile
basins_file = '../data/river_basins/catch_bas_all_dissolved_v2.shp'
basins <- readOGR(basins_file)#, 'ne_110m_admin_0_countries')
basins@data$ID <- as.numeric(rownames(basins@data)) + 1 # add numeric id


# /----------------------------------------------------------------------------#
#/ get basin catch (from McIntyre 2016)
basin_catch <- read.csv('../data/basin_catch/river_fisheries_pete_catch.csv') %>% 
  select(WB_NAME2, CATCH, CATCHUNITS) %>% 
  filter(!is.na(CATCH))

# Black Volta; Pandjari; Pearl; Red Volta; Rufiji/Ruaha; White Volta; San Francisco



# /----------------------------------------------------------------------------@
#/ create output df
outdf <- data.frame(name=as.character(),
                    sumarea=as.numeric())

catch_stack <- stack()


library(Metrics)

# /----------------------------------------------------------------------------#
#/ loop through pred catch grids; get global sum
for (c in catch_ls){
  
  
  print(c)
  
  # Get global sum
  r <- raster(c)
  s <- sum_raster(r)/10^6
  
  outdf <- bind_rows(outdf,
                     data.frame(name=c, sumarea= s) )

}


# /----------------------------------------------------------------------------#
#/  Extract cath in basins

ex <- raster::extract(r, basins, fun=sum, na.rm=TRUE, df=TRUE)
ex2 <- left_join(ex, basins@data, by='ID')
ex3 <- full_join(ex2, basin_catch, by=c('NAME'='WB_NAME2'))
names(ex3) <- c('ID', 'distrib_catch', 'NAME', 'CATCH','CATCHUNITS')
ex3 <- ex3 %>% 
  filter(!is.na(CATCH)) %>% 
  filter(distrib_catch != 0) 
# mutate(distrib_catch = ifelse(distrib_catch==0, 1, distrib_catch))

# calculate r2 & RMSE
rmse(ex3$CATCH, ex3$distrib_catch)

rsq <- function (x, y) cor(x, y) ^ 2
rsq(ex3$CATCH, ex3$distrib_catch)
rsq(log10(ex3$CATCH), log10(ex3$distrib_catch))




# /----------------------------------------------------------------------------
#/     Scatterplot of distrib  VS  basin catch

ggplot(ex3) + 
  
  geom_abline(aes(slope=1, intercept=0), color='grey80') +
  
  geom_point(aes(x=CATCH, y=distrib_catch), color='black') + 
  
  xlab('Literature catch estimates (tons/year)') +
  ylab('Distributed catch FAO & Surveys (tons/year)') +
  
  # ggtitle('Comparison of monthly index and annual extents (MAMin, MAMax, IAMax)\nfor 33 basins with both.') +
  
  scale_x_log10(
    breaks = scales::trans_breaks('log10', function(x) 10^x),
    labels = scales::trans_format('log10', scales::math_format(10^.x))) +
  
  scale_y_log10(
    breaks = scales::trans_breaks('log10', function(x) 10^x),
    labels = scales::trans_format('log10', scales::math_format(10^.x))) +
  
  
  # waterbody label
  geom_text_repel(data = ex3,  #subset(ex3, monthlykm2/10^6 > 0.2),
                  aes(x=CATCH, y=distrib_catch, label = NAME),
                  color='grey25',
                  segment.color='grey25',
                  size = 3,
                  nudge_x = 0,
                  segment.size = 0.25,
                  box.padding = unit(0.5, 'mm'),
                  point.padding = unit(0.5, 'mm')) +
  theme_bw()




# /----------------------------------------------------------------------------#
#/    Save figure to file 
ggsave('../output/figures/scatterplot_basin_catch_vs_distrib_lm2c.png', 
       width=160, height=160, dpi=240, units='mm', type = 'cairo-png')
dev.off()





# /-----------------------------------------------------------------------------
#/  Calculate difference betwen models

d = lm7b_distrib_c2 - lm10c_distrib_c2


ddf = as.data.frame(d) %>% filter(!is.na(layer))

ggplot(ddf) +
  geom_density(aes(x=layer))






# basinstiles_file = '../data/giemsd15/basins/tiles_giemsd15_sel_basins.shp'
# natearth_dir <- '../../chap5_global_inland_fish_catch/data/gis/nat_earth'
# 
# countries_df <- fortify(countries)
# countries_robin <- spTransform(countries, CRS('+proj=robin'))
# countries_robin_df <- fortify(countries_robin)
# 


# ddf = fortify(d)
# 
# lapply( s, as.data.frame ) 