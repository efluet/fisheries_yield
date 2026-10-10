# # df <- read.csv('../data/reservoir_yield/ResYield_data_modeling_Feb2018_tropical_reserv_reg.csv') %>% 
#   # filter(date.of.data != '') #is.na(X))
# df
# 
# m <- lm(logC ~ logA, df)
# m
# 
# ggplot(df, aes(x=logA, y=logC)) +
#   geom_smooth(method = "lm", fullrange = TRUE, color='grey60') +
#   geom_point() + 
#   xlab('log Reservoir Area') +
#   xlab('log Reservoir Catch') +
#   ggtitle('Tropical reservoir yield') +
#   line_plot_theme()




# /----------------------------------------------------------------------------#
#/ TROPICAL RESERVOIR interval

uncert_range <- predict(lm_trop, interval = "prediction", level=0.95, se.fit = FALSE) %>% 
  data.frame() %>% 
  # Rename
  rename(fit_log10=fit,
         lwr_log10=lwr,
         upr_log10=upr) %>%
  # Back-estimate to tonnes 
  mutate(fit_tonnesyr = 10^fit_log10,
         lwr_tonnesyr = 10^lwr_log10,
         upr_tonnesyr = 10^upr_log10) %>% 
  mutate(range= upr_tonnesyr- lwr_tonnesyr)


glimpse(uncert_range)

# Sum of observation reservoir yield
sum(cs_trop$CATCH_tonnesyr)

# Predictions
uncert_range %>% summarise(tot_fit=sum(fit_tonnesyr),
                           tot_uncert=sqrt(sum(range^2)))

