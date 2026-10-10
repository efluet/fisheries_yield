


# Get Catch distrib
catch_distrib_1km <- rast('../output/results/riv_yield_distrib/riv_yield_distrib_lm2c_catch.c2_1km_2024_rep_cap_v10.tif')

# Get latitude for each raster cell
xy <- crds(catch_distrib_1km, df = TRUE, na.rm = FALSE)
values <- values(catch_distrib_1km, mat = FALSE)

# Create a data frame
df <- data.frame(
  lat = xy[, 2],
  value = values
)


# Create 5-degree latitude bands
df$lat_band <- floor(df$lat / 5) * 5

# Sum values per band
riv_lat_sum <- aggregate(value ~ lat_band, data = df, FUN = sum, na.rm = TRUE)



# Plot --------------------------------------------------------
lat_hist_riv_yield <- 
  
  ggplot(riv_lat_sum) +
  
  geom_col(aes(x = lat_band, y = value), fill='grey85', color='grey10', width=5, linewidth=0.1) +
  coord_flip() +
  labs(
    x = "Latitude band (°)",
    y = expression(paste('River yield\n(M tonnes yr'^-1*')'))) +
  line_plot_theme() +
  theme(panel.border = element_blank()) +
  scale_x_continuous(expand=c(0,0), limits=c(-56,84), position = "top") +
  scale_y_reverse(expand=c(0,0), breaks=pretty_breaks(n=2))


