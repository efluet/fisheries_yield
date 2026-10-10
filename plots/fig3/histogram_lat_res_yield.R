


gdw_barriers <- st_read('../output/results/res_yield_gdw/GDW_barriers_v0_2_resyield_102024.shp') %>% 
  rename(res_yield = rs_yld_)

gdw_barriers_robin <- st_transform(gdw_barriers, crs("+proj=robin")) %>% 
  dplyr::mutate(LON_robin = sf::st_coordinates(.)[,1],
                LAT_robin = sf::st_coordinates(.)[,2])

gdw_barriers_robin <- arrange(gdw_barriers_robin, res_yield)


#------------------------------------------------------------------

# Transform to geographic coordinates (longitude/latitude)
gdw_barriers_geo <- st_transform(gdw_barriers, crs = 4326) %>%
  mutate(
    lon = st_coordinates(.)[, 1],
    lat = st_coordinates(.)[, 2])

# Sum res_yield per 5-degree latitude bin
res_lat_sum <- gdw_barriers_geo %>%
  st_drop_geometry() %>%
  mutate(
    lat_bin = floor(lat / 5) * 5 ) %>%
  group_by(lat_bin) %>%
  summarise(
    sum_res_yield = sum(res_yield, na.rm = TRUE),
    .groups = "drop")



# Plot --------------------------------------------------------
lat_hist_res_yield <- 
  
  ggplot(res_lat_sum) +
  
  geom_col(aes(x = lat_bin, y = sum_res_yield/1000), 
           fill='grey85', color='grey10', width=5, linewidth=0.1) +
  coord_flip() +
  labs(
    x = "Latitude band (°)",
    y = expression(paste('Reservoir yield\n(1000 tonnes yr'^-1*')'))) +
    # y = "River yield\n(1000 tonnes/yr)") +
  line_plot_theme() +
  theme(panel.border = element_blank()) +
  scale_x_continuous(expand=c(0,0), limits=c(-56,84), position = "top") +
  scale_y_reverse(expand=c(0,0))




# # Plot
# ggplot(lat_sum, aes(x = lat_bin, y = sum_res_yield)) +
#   geom_col(width = 5, fill = "steelblue", color = "white") +
#   scale_x_continuous(
#     breaks = seq(-90, 90, by = 10),
#     name = "Latitude (°)",
#     expand = c(0, 0)
#   ) +
#   labs(
#     y = "Sum of residual yield",
#     title = "Latitudinal distribution of residual yield"
#   ) +
#   theme_minimal()
