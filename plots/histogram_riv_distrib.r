catch_distrib_1km <- rast("../output/results/distrib_catch/distrib_catch_lm2c_catch.c2_1km_2023_rep.tif" )

# Aggregate to 50km for visualization
catch_distrib_50km <- aggregate(catch_distrib_1km, fact=50, fun=sum, na.rm=FALSE)

# convert from megaton to tons
catch_distrib_50km <- catch_distrib_50km * 10^6

catch_distrib_50km_df <- WGSraster2dfROBIN(catch_distrib_50km)
names(catch_distrib_50km_df) <- c('x','y','catch')


# /-----------------------------------------------------------------------------
#/  Get color ramp from map
colfunc <- colorRampPalette(c('#ffffcc', 'blue'))
colfunc(5)

# /-----------------------------------------------------------------------------
#/
hist_riv_yield <- 
  ggplot() +

  # geom_histogram(data=catch_distrib_50km_df, 
  #                aes(x=catch, y=stat(count)/sum(stat(count))), fill='grey92', color='grey10', size=0.2, boundary=0, closed = "left", binwidth=0.25) +

  geom_histogram(data=subset(catch_distrib_50km_df, catch<10^-1),
                 aes(x=catch, y=stat(count)/nrow(catch_distrib_50km_df)*100), fill='grey92', color='grey10', size=0.2, boundary=0, closed = "left", binwidth=0.25) +

  geom_histogram(data=subset(catch_distrib_50km_df, catch>=10^-1 & catch<10^0),
                 aes(x=catch, y=stat(count)/nrow(catch_distrib_50km_df)*100), fill='#fdee68', color='grey10', size=0.2, boundary=0, closed = "left", binwidth=0.25) +

  geom_histogram(data=subset(catch_distrib_50km_df, catch>=10^0 & catch<10^1),
                 aes(x=catch, y=stat(count)/nrow(catch_distrib_50km_df)*100), fill='#79d27c', color='grey10', size=0.2, boundary=1, closed = "left", binwidth=0.25) +
  
  geom_histogram(data=subset(catch_distrib_50km_df, catch>=10^1 & catch<10^2),
                 aes(x=catch, y=stat(count)/nrow(catch_distrib_50km_df)*100), fill='#44d5cd', color='grey10', size=0.2, boundary=1, closed = "left", binwidth=0.25) +

  geom_histogram(data=subset(catch_distrib_50km_df, catch>=10^2 & catch<10^3),
                 aes(x=catch, y=stat(count)/nrow(catch_distrib_50km_df)*100), fill='#3333ff', color='grey10', size=0.2, boundary=1, closed = "left", binwidth=0.25) +

  geom_histogram(data=subset(catch_distrib_50km_df, catch>=10^3),
                 aes(x=catch, y=stat(count)/nrow(catch_distrib_50km_df)*100), fill='#000099', color='grey10', size=0.2, boundary=1, closed = "left", binwidth=0.25) +

  
  
  scale_x_log10(breaks=c(10^-3, 10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3, 10^4),
                labels=expression(10^-3, 10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3, 10^4),
                limits=c(10^-3, 10^5),
                expand=c(0,0)) +

  scale_y_continuous(expand=c(0, NA)) +
  
  ylab("Percentage of 0.5° land cells (%)") +
  xlab(expression(paste('Riverine fish yield (tons yr'^-1*'cell'^-1*')'))) +
  line_plot_theme() +
  theme(panel.border = element_blank())

  

