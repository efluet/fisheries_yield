
# /----------------------------------------------------------------------------#
#/ Fit robust regression                                            ------------
library(MASS)

basins_wpreds_df_cathy <- 
  read.csv('../output/results/riv_yield_predictors/per_train_basin/from_cathy/preds_riv_yield_perbasin12Feb24.csv') %>% 
  mutate(pop_dens = pop_M / basinarea_Mkm2) %>% 
  mutate(
       logcatch = log10(Catch_tonnesyr),
       logpopdens=log10(pop_dens),
       logq_km3yr = log10(q_km3yr),
       wetperc= glwdv2_perc_nopeat)


# Model selection of all predictor combinations
library(MuMIn)
dd <- dredge( rlm(logcatch ~ logq_km3yr + logpopdens  + wetperc, 
                  data=basins_wpreds_df_cathy))


rlm_riv <- rlm(logcatch ~ logq_km3yr + logpopdens  + wetperc,
               data=basins_wpreds_df_cathy) # %>% tidy()

summary(rlm_riv)
AIC(rlm_riv)


## Plot model diagnostics
png('../output/figures/riv_lm_diagnostics_plot.png', 
    units="mm", width=180, height=180, res=300)
par(mfrow=c(2,2))
plot(rlm_riv, ask = FALSE)
dev.off()

# library(ggfortify)
# p <- autoplot(rlm_riv)


# /----------------------------------------------------------------------------#
#/   Prep riv.yield gridded predictor stack                        ------------

# Get discharge
q_cms <- rast('../data/discharge/dis_dls/q_cms_1km.tif')
# Apply low-discharge mask, to prevent catch from being distributed to these areas
q_cms[q_cms < 0.1] <- NA
# Convert to km3/yr
q_km3yr <- q_cms * 0.031556952   # 1 cms == 0.03... km3yr
names(q_km3yr) <- c('q_km3yr')


# Get wetlands area % and km2
# glwdv2_areakm2_1km_nopeat<- rast('../output/results/riv_yield_predictors/grids/aggregated/glwdv2_areakm2_1km_nopeat.tif')
glwdv2_perc_1km_nopeat <- rast('../output/results/riv_yield_predictors/grids/replaced/glwdv2_perc_1km_nopeat_1km_replaced2024.tif')
glwdv2_perc_1km_nopeat[glwdv2_perc_1km_nopeat>100] <- 100

# Get population
pop <- rast('../output/results/riv_yield_predictors/grids/replaced/pop_1km_replaced2024.tif')

# Get temperature
temp <- rast('../data/waterTemp/temp_1km.tif')


# /----------------------------------------------------------------------------#
#/   Stack all predictions                                          ------------
predstack        <- c(q_km3yr, pop)
# Apply Log10 transformation
predstack[predstack==0] <- 10^-10   # Replace 0s with small value
predstack <- log10(predstack)       # log10 transform all layers

# Add untransformed predictors
predstack <- c(predstack, glwdv2_perc_1km_nopeat)


names(predstack) <- c('logq_km3yr', 'logpop', 'wetperc')

# Filter entire stack with Q mask
# This will reduce size when converted to df
predstack[is.na(q_km3yr)] <- NA


# /----------------------------------------------------------------------------#
#/   Cap gridded values to training range                           ------------


#/    Read basin predictors
# Prep the training basins to plot plotting predictor distribution and range
basin_preds_df <- 
  basins_wpreds_df_cathy %>% 
  dplyr::select(pop_dens, q_km3yr, wetperc) %>% 
  mutate(datatype = 'Training Basins') 




# Get maximum value from training basins
max_log10q_km3yr <- max(log10(basin_preds_df$q_km3yr))
max_log10popdens <- max(log10(basin_preds_df$pop_dens))
max_wetperc      <- max(basin_preds_df$wetperc)


# Apply ceilings values
log10q_km3yr <- predstack[[1]]
log10q_km3yr[log10q_km3yr > max_log10q_km3yr] <- max_log10q_km3yr

log10popdens <- predstack[[2]]
log10popdens[log10popdens > max_log10popdens] <- max_log10popdens

wetperc <- predstack[[3]]
wetperc[wetperc > max_wetperc] <- max_wetperc


# Stack the capped rasters
predstack_cap <- c(log10q_km3yr, log10popdens, wetperc)

# Remove large objects to clean up space
rm(q_cms, pop, temp, glwdv2_perc_1km_nopeat, log10q_km3yr, log10popdens, wetperc) # q_km3yr, 




# /----------------------------------------------------------------------------#
#/   Plot predictor distribution & ranges                           ------------

# Prep dataframe of capped predictor stack
predstack_df <- 
  predstack %>% 
  data.frame %>% 
  filter(logpop!=-10,
         !is.na(logq_km3yr)) %>% 
  mutate(pop_dens=10^logpop,
         q_km3yr=10^logq_km3yr,) %>% 
  dplyr::select(pop_dens, q_km3yr, wetperc) %>% 
  mutate(datatype = 'Global')
  

# Prep dataframe of capped predictor stack
predstack_cap_df <- 
  predstack_cap %>% 
  data.frame %>% 
  filter(logpop!=-10,
         !is.na(logq_km3yr)) %>% 
  # Backtransform
  mutate(pop_dens=10^logpop,
         q_km3yr=10^logq_km3yr,) %>% 
  dplyr::select(pop_dens, q_km3yr, wetperc) %>% 
  mutate(datatype = 'Global capped')


# Combine 3 dfs for plotting 
preds_forcomp_df <- 
  bind_rows(predstack_df, predstack_cap_df) %>% 
  # bind_rows(., basin_preds_df, ) %>% 
  pivot_longer(cols=c(pop_dens, q_km3yr, wetperc), names_to='var') %>% 
  mutate(var= ifelse(var=='pop_dens', 'Population density (person/km2)', var),
         var= ifelse(var=='q_km3yr', 'Discharge (km3/yr)', var),
         var= ifelse(var=='wetperc', 'Wetland cover percentage (%)', var))

# Replace facet values
basin_preds_df_long = 
  pivot_longer(basin_preds_df, cols=c('pop_dens','q_km3yr','wetperc'), names_to = 'var', values_to = 'value') %>% 
  mutate(var= ifelse(var=='pop_dens', 'Population density (person/km2)', var),
         var= ifelse(var=='q_km3yr', 'Discharge (km3/yr)', var),
         var= ifelse(var=='wetperc', 'Wetland cover percentage (%)', var))


# Plot
predictor_distribution_plot <- 
  ggplot() +
  stat_ecdf(data=sample_n(preds_forcomp_df, 5*10^6), aes(x=value, color=datatype), geom = "step", pad = FALSE) +
  stat_ecdf(data=basin_preds_df_long, aes(x=value, color=datatype), pad = FALSE) + # , geom = "step",
  facet_wrap(var~., scales='free') +
  xlab('Predictor value') +
  ylab('Cumulative fraction') +
  scale_x_log10()+ #breaks_pretty(n=8)) +
  line_plot_theme() +
  theme(      text = element_text(size=7, colour='black'),
              legend.position=c(0.38, 0.9),
              ### LEGEND
              legend.text = element_text(size = 8),
              legend.background = element_blank(),
              legend.key.size = unit(4, "mm"),
              legend.title=element_blank(),
              strip.background = element_blank(),
              strip.text = element_text(size = 8, face='bold'),
  )
  

ggsave('../output/figures/predictor_distribution_ecdf.png', 
       predictor_distribution_plot, 
       width=187, height=70, dpi=300, units="mm", type = "cairo-png")
dev.off()




# /----------------------------------------------------------------------------#
#/ Apply predict to raster stack                                    ------------
# https://stackoverflow.com/questions/74082026/r-problem-with-raster-prediction-from-a-linear-model
# if that doesn't work, then use tthe 
#. If predict interval doesnt work, draw from the bootstrapped parameter interval and take 90th percentile 


names(predstack_cap) <- c('logq_km3yr', 'logpopdens', 'wetperc')
pred_catch_log <- predict(predstack_cap, rlm_riv, interval='prediction')

# Backtransform logCatch back to tonnes/yr
pred_catch <- 10^pred_catch_log

# Calculate uncertainty range
pred_catch_uncertrng <- pred_catch[[3]] - pred_catch[[2]] 

# Select fit and range
pred_catch_out <- c(pred_catch[[1]], pred_catch_uncertrng)

#Save to file
writeRaster(pred_catch_out, 
            paste0('../output/results/riv_yield_predicted/pred_catch_1km_2024_rep_cap_v10.tif'), 
            overwrite=TRUE)



# /----------------------------------------------------------------------------#
#/  Bootstrap uncertainty                                           ------------

# We sample from a truncated normal distribution with 95th percentile 

# Convert to matrices  
fit_m <- as.matrix(pred_catch_out[[1]], wide=TRUE)
uncert_m <- as.matrix(pred_catch_out[[2]], wide=TRUE)
  
# Loop to create members
for (i in seq(1, 100)) {
    
  print(i)
  # Generate series of random values, same lenght as nb. of pixels 
  # 90% of samples within +/-1.96 sd of normal distribution;  1/1.96 = 0.51
  rdm <- rnorm(725760000, mean=0, sd=.51)
  
  # rdm scaled
  rdm_scaled <- rdm * uncert_m + fit_m
  
  uncert_member <- rast(rdm_scaled, crs=st_crs(pred_catch_out), extent=com_ext)
  uncert_member[uncert_member<0] <- 0
  
  writeRaster(uncert_member, paste0('../output/results/riv_yield_predicted/uncert_member/pred_catch_uncertmember_', i, '.tif'), overwrite=TRUE)
  
  }


