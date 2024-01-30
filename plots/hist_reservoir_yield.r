
# /----------------------------------------------------------------------------#
#/   

gdw_barriers <- st_read('../output/gdw/GDW_barriers_v0_2_resyield.shp')


gdw_barriers_robin <- st_transform(gdw_barriers, crs("+proj=robin")) %>% 
  dplyr::mutate(LON_robin = sf::st_coordinates(.)[,1],
                LAT_robin = sf::st_coordinates(.)[,2])

gdw_barriers_robin <- arrange(gdw_barriers_robin, res_yield)


# /-----------------------------------------------------------------------------
#/
hist_reserv_yield <-
  ggplot() +

  # geom_histogram(data=gdw_barriers_robin,
  #                aes(x=res_yield, y=stat(count)/sum(stat(count))), fill='grey92', color='grey10', size=0.2, boundary=0, closed = "left", binwidth=0.25) +

  geom_histogram(data=subset(gdw_barriers_robin, res_yield<10^-1),
                 aes(x=res_yield, y=stat(count)/nrow(gdw_barriers_robin)*100), fill='grey92', color='grey10', size=0.2, boundary=0, closed = "left", binwidth=0.25) +

  geom_histogram(data=subset(gdw_barriers_robin, res_yield>=10^-1 & res_yield<10^0),
                 aes(x=res_yield, y=stat(count)/nrow(gdw_barriers_robin)*100), fill='#fdee68', color='grey10', size=0.2, boundary=0, closed = "left", binwidth=0.25) +

  geom_histogram(data=subset(gdw_barriers_robin, res_yield>=10^0 & res_yield<10^1),
                 aes(x=res_yield, y=stat(count)/nrow(gdw_barriers_robin)*100), fill='#79d27c', color='grey10', size=0.2, boundary=1, closed = "left", binwidth=0.25) +

  geom_histogram(data=subset(gdw_barriers_robin, res_yield>=10^1 & res_yield<10^2),
                 aes(x=res_yield, y=stat(count)/nrow(gdw_barriers_robin)*100), fill='#44d5cd', color='grey10', size=0.2, boundary=1, closed = "left", binwidth=0.25) +

  geom_histogram(data=subset(gdw_barriers_robin, res_yield>=10^2 & res_yield<10^3),
                 aes(x=res_yield, y=stat(count)/nrow(gdw_barriers_robin)*100), fill='#3333ff', color='grey10', size=0.2, boundary=1, closed = "left", binwidth=0.25) +

  geom_histogram(data=subset(gdw_barriers_robin, res_yield>=10^3),
                 aes(x=res_yield, y=stat(count)/nrow(gdw_barriers_robin)*100), fill='#000099', color='grey10', size=0.2, boundary=1, closed = "left", binwidth=0.25) +


  
  scale_x_log10(breaks=c(10^-3, 10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3, 10^4),
                labels=expression(10^-3, 10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3, 10^4),
                limits=c(10^-3, 10^5),
                expand=c(0,0)) +
  
  scale_y_continuous(expand=c(0, NA)) +
  
  ylab("Percentage of reservoir count (%)") +
  xlab(expression(paste('Fish yield per reservoir (tons yr'^-1*')'))) +
  line_plot_theme() +
  theme(panel.border = element_blank())


