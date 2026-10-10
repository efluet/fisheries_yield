
# /---------------------------------------------------------------------------#
#/   Make distribution of yield and DOR


# Stack 
gdw_dor <- rast('../output/results/dor/gdw_dor_v8.tif')

# Riverine catch
catch_distrib_1km <- rast('../output/results/riv_yield_distrib/riv_yield_distrib_lm2c_catch.c2_1km_2024_rep_cap_v10.tif')



# /---------------------------------------------------------------------------#
#/    Mask reservoir footprings from DOR losses to avoid counting 

# Prep the GDW mask
gdw_frac_1km <- rast('../output/results/res_yield_gdw/GDW_frac_1km.tif')
gdw_frac_1km <- extend(gdw_frac_1km, gdw_dor, snap="near")

# Make inverse fraction of reservoir; to partially mask fish outside footprint
# This primarily affects pixels immediately downstream of reservoir
gdw_frac_1km[is.na(gdw_frac_1km)] <- 0
non_gdw_frac <- 1 - gdw_frac_1km


# Stack the rasters
riv_dor <- c(gdw_dor, catch_distrib_1km, non_gdw_frac)

# Mask small DOR losses 
riv_catch_dor[riv_catch_dor < 10^-4] <- NA


# convert to df
df <- as.data.frame(riv_dor, na.rm = TRUE)


# Cut flow DOR into 0.1 bins
df$flow_bin <- cut(
  df$flow_acc_v01,
  breaks = seq(0, 1, by = 0.02),
  include.lowest = TRUE,
  right = FALSE)


result <- df %>%
  mutate(fit = fit * flow_acc_v01 * (1-GDW_frac_1km)) %>% 
  group_by(flow_bin) %>%
  summarise(sum_fit = sum(fit, na.rm = TRUE), .groups = "drop")


#-----------------------------------------------------------
result_cdf <- result %>%
  mutate(
    flow_mid = (as.numeric(sub("\\[\\s*([0-9.]+).*", "\\1", flow_bin)) +
                  as.numeric(sub(".*,\\s*([0-9.]+)\\).*", "\\1", flow_bin))) / 2 ) %>%
  mutate(flow_mid = ifelse(is.na(flow_mid), 1, flow_mid)) %>% 
  arrange(flow_mid) %>%
  mutate(cum_fit = cumsum(sum_fit))


#---------------------------------------------------------------

dor_loss_cdf <- 
  
  ggplot(result_cdf, aes(x = flow_mid, y = cum_fit*10)) +
  geom_line(color = "red", linewidth = 0.5) +
  labs(
    x = "Degree of Regulation (DOR)",
    y = "Cumulative downstream yield loss\n(M tonnes/yr)") +
  scale_x_continuous(expand=c(0,0), breaks=pretty_breaks(8), limits=c(0,1)) +
  # scale_x_reverse(expand=c(0,0), breaks=pretty_breaks(8), limits=c(1,0)) +
  scale_y_continuous(expand=c(0,0), breaks=pretty_breaks(10)) +
  line_plot_theme()


ggsave('../output/figures/si/figSI_dor_cdf_losses_v10.pdf',
       dor_loss_cdf,
       width=80, height=70, dpi=500, units='mm' )

ggsave('../output/figures/si/figSI_dor_cdf_losses_v10.png',
       dor_loss_cdf,
       width=80, height=70, dpi=500, units='mm' )
