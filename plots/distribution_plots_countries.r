
# /----------------------------------------------------------------------------#
#/   Combine catch rasters into stack 

# Make empty stack, including country codes
comb_catch_stack <- stack(ciso)

# Read distrib catch rasters
for (m in selruns) {
  
  # Read raster
  catch_distrib <- raster(paste0('../output/results/distrib_catch/distrib_catch_', m, '_c2',  '_rep.tif'))

  # Add it to stack
  comb_catch_stack <- stack(comb_catch_stack, catch_distrib)
  }

# CROP for testing
# comb_catch_stackcrop <- crop(comb_catch_stack, extent(10,12,10,12))

# /----------------------------------------------------------------------------#
#/  PREP THE DF OF DISTRIBUTED CATCH

# rename raster grid
names(comb_catch_stack) <- c('iso3a', selruns)

# Convert stack of raster to dataframe
catch_df <- as.data.frame(comb_catch_stack, na.rm=TRUE) 


# Make column of model equation, to join to df
library(stringr)
eq_label <- models %>% 
  filter(model.run %in% selruns) %>% 
  mutate(eq_label=paste(model.run, '  ', eq)) %>% 
  mutate(eq = str_sub(eq, 5, -1)) %>% 
  dplyr::select(model.run, eq_label, eq)


# Subset countries to Global, Brazil, Thailand, India, China
catch_df_sel <- catch_df %>% 
                filter(iso3a_ISO_A3 %in% c('BRA','THA','IND','CHN','USA')) %>% 
                pivot_longer(cols=lm2c:lm1b, names_to='model.run') %>% 
                left_join(., eq_label, by='model.run')


### test that the sums are actually correct
# catch_df_sel %>% 
#   group_by(iso3a_ISO_A3, model.run) %>% 
#   summarise(sum=sum(value, na.rm = TRUE)) 


# /----------------------------------------------------------------------------#
#/ Histogram plot

h <- ggplot(catch_df_sel)+
# h <- ggplot(subset(catch_df_sel, value>10^-5))+

  geom_histogram(aes(x=value, fill=model.run), bins=25, alpha=0.85, na.rm = TRUE) +
  # geom_hline(aes(yintercept=0), size=0.4, color='black') +
  
  scale_x_log10(
    breaks = scales::trans_breaks("log10", function(x) 10^x),
    labels = scales::trans_format("log10", scales::math_format(10^.x)),
    limits = c(10^-10, 10^5)
  ) +
  
  xlab('Pixel fish catch (tons yr^-1') +
  ylab('Pixel count') +

  # facet_grid(model.run~iso3a_ISO_A3) + 
  facet_grid(eq~iso3a_ISO_A3) +
  line_plot_theme +
  theme(      text = element_text(size=8, colour='black'),
              ### LEGEND
              legend.text = element_text(size = 8),
              legend.background = element_blank(),
              legend.key.size = unit(4, "mm"),
              legend.title=element_blank()
              )

# /----------------------------------------------------------------------------#
#/    Save figure to file 
ggsave('../output/figures/distrib_c2_histogram_panel_plot_v2_rep.png', h, 
       width=220, height=180, dpi=240, units="mm", type = "cairo-png")
dev.off()








# # /----------------------------------------------------------------------------#
# #/ Density plot
# 
# ggplot(catch_df_sel)+
#   
#   geom_density(aes(x=value, fill=model.run), alpha=0.5, size=0.1) +
#   # geom_histogram(aes(x=layer, fill), bins=15) +
#   
#   # scale_y_continuous(expand = c(0.1,0.1)) +
#   scale_x_log10(
#     breaks = scales::trans_breaks("log10", function(x) 10^x),
#     labels = scales::trans_format("log10", scales::math_format(10^.x))
#     # limits = c(10^-10, 10^5)
#     ) +
# 
#   xlab(expression(paste('Pixel fish catch (tons yr'^-1*')'))) +
#   ylab('Density') +
#   facet_wrap(~iso3a_ISO_A3,  ncol=1) + #strip.position='right'
#   line_plot_theme
# 
# 
# # /----------------------------------------------------------------------------#
# #/    Save figure to file 
# ggsave('../output/figures/distrib_c2_density_plot.png',
#        width=140, height=200, dpi=200, units="mm", type = "cairo-png")
# dev.off()
# 



