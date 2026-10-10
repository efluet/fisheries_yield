

# Apply ceiling maximum value
# pred_catch_uncertrng[pred_catch_uncertrng>10^6] <- NA

# Test Q only model
# lm_riv <- lm(log10(Catch_tonnesyr) ~ log10(q_m3sec), data=basins_wpreds_df) #%>% tidy()
# summary(lm_riv)

# Histograms of predictor distributions for SI  
# library(Hmisc)
# hist.data.frame(basins_wpreds_df)
# basins_wpreds_df['glwdv2_area_Mkm2_nopeat','glwdv2_perc_nopeat']

# filter(model.run %in% selruns)


# List of models to use
# selruns <- c('lm2c') # 'lm2b', 'lm10c','lm1b')
# selruns <- c('lm7b','lm9b') # These models don't have wetland
# selruns <- c('lm1b', 'lm11b') # This model is only Q and Q+wetland%

# A: absW + Q; B: propW + Q; C: propW + Q + Pop),



# /----------------------------------------------------------------------------#
# #/  Get model parameters

# f <- '../output/results/linear_models/Linear Model Outputs wAICs Jan2020 EF.csv'
# models <- read.csv(f) %>% filter(train_data_amazon_yn == 1)  # Keep only models with Amazon
# models[is.na(models)] = 0  # Replace all NAs by 0s
# mutate(Catch_tonnesyr = log10(Catch_tonnesyr),
#        pop_M = log10(pop_M), 
#        q_m3sec = log10(q_m3sec)) %>%


# basins_wpreds_df <- 
#   read.csv('../output/results/riv_yield_predictors/per_train_basin/preds_riv_yield_perbasin.csv') %>%
#     mutate(logcatch = log10(Catch_tonnesyr),
#            logpop=log10(pop_M),
#            logq_cms = log10(q_m3sec),
#            wetperc= glwdv2_perc_nopeat) %>% 
#     # dplyr::select(pop_M, Catch_tonnesyr, q_m3sec, glwdv2_perc_nopeat) %>% 
#     dplyr::select(logcatch, logpop, logq_cms, wetperc) 
# 

# rlm_riv <- rlm(logcatch ~ logpop  + logq_cms + wetperc,
#                data=basins_wpreds_df)


# Append values to table
# basins_wpreds_df['predlog10C'] <- lm_riv$fitted.values

# Tot test
# predstack <- crop(predstack, ext(5, 20, 30, 45))

# C = Pop + Q + Wet%
# pred_catch_log10 <- rlm_riv$coefficient[1] + rlm_riv$coefficient[2]*predstack[[1]] + rlm_riv$coefficient[3]*predstack[[2]] + rlm_riv$coefficient[4]*predstack[[3]]
