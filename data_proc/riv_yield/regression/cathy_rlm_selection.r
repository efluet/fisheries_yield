# data <- read.csv(file="preds_riv_yield_perbasin12Feb24.csv")
data <- read.csv('../output/results/riv_yield_predictors/per_train_basin/from_cathy/preds_riv_yield_perbasin12Feb24.csv') 


#logging variables of interest 
data$logQ <- log10(data$q_km3yr)
data$logC <- log10(data$Catch_tonnesyr)
data$logC <- log10(data$Catch_tonnesyr / data$basinarea_Mkm2*10^6)
data$logPdM <- log10(data$pop_M/(data$basinarea_Mkm2))

library(MuMIn)
library(MASS)

#creating set of variables to be used in multivariate regressions -  vars includes both wetland but just discard rows with both
# vars <- c("logC","logP","logPd","logQ","logMaMax",, "glwdv2_perc_nopeat")
vars <- c("logC","logQ","logPdM", "temp_degC", "glwdv2_perc_nopeat")


#creating data frame with just the variables from above
nDat <- data[,vars]
# Running all possible subsets using regular and robust regression

#needed line of code to run dredge
options(na.action = "na.fail")

#now run models using linear regression with all variables from above to create an object needed for dredge later
mm <- lm(logC~.,data=nDat)

#now run models using robust linear regression for all variables 
mmr <- rlm(logC~.,data=nDat)

#use dredge function to run all possible subsets
dd <- dredge(mm)
# Fixed term is "(Intercept)"
#now using robust regression
ddr <- dredge(mmr)
# Fixed term is "(Intercept)"
#another needed line of code to run dredge
options(na.action = "na.omit")
# View all results all subsets
# model_selection <- 
  # ddr %>% 
  knitr::kable(ddr,digits=c(3,3,3,3,3,3,1,1,1,3)) #%>%
  # data.frame()

model_selection


# # Compare parameters to Cathy's model fit:  log10C = 2.747 + 0.57*logPop + 0.405*logQ + 0.018*Wet%
rlm_riv <- lm(logC ~ logQ + logPdM  + glwdv2_perc_nopeat,
               data=data) #%>% tidy()
summary(rlm_riv)
