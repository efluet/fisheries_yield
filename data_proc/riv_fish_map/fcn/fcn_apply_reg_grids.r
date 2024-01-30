
# /----------------------------------------------------------------------------#
#/   GET REGRESSION PARAMETERS FOR CURRENT MODEL

# Get regression model parameters from df
p <-  models %>%
      filter(model.run == m) %>%
      dplyr::select(Intercept, Coeff.Q, Coeff.Wet.km2, Coeff.Wet.Perc, Coeff.Pop, Coeff.Temp)


# Fill all the blanks with zeros; this simplifies the code later on; allows to keep all reg parameters
p[is.na(p)] <- 0
p <- as.numeric(p)  # convert from df row to vector


print(p) # print parameters


# /----------------------------------------------------------------------------#
#/    FUNCTION THAT APPLIES REGRESSION PARAMETERS TO RASTER
regmodel <- function(x) { 
  # ignore pixels where there are NAs
  if(any(is.na(x))) { 
    c(NA) 
  } else {
    # Intcept. +  Q    +  Wet.km2 +   Wet.Perc   +   Pop. + Temp
    p[1]  + p[2]*x[1] + p[3]*x[2] + p[4]*x[3]  + p[5]*x[4]  + p[6]*x[5]}
  }



# /----------------------------------------------------------------------------#
#/    APPLY FUNCTION TO RASTERS AND SAVE
pred_catch_log10 <- terra::app(predstack, regmodel) # , cores=6)

# Back convert catch into log
pred_catch <- 10^(pred_catch_log10)

# save output raster
writeRaster(pred_catch, paste0('../output/results/pred_catch/pred_catch_', m, '_1km_2023.tif'), overwrite=TRUE)
