# /----------------------------------------------------------------------------#
#/      Read and format catch table                                         -------

ca <- read.csv("../data/fao_fishstatj/global_catch_production_all_to2014.csv", stringsAsFactors = F)

# remove all '.' and 'X' in the column names 
colnames(ca) <- gsub("[.]|X","",colnames(ca))


# Then Remove non numeric flags from cells in the cabase.
ca <- as.data.frame(apply(ca, 2, function(y) gsub("0 0", "0", y)))
ca <- as.data.frame(apply(ca, 2, function(y) gsub(" F", "", y)))
ca <- as.data.frame(apply(ca, 2, function(y) gsub("-", "", y)))

### THIS DOESNT WORK ANYMORE - AS OF JULY 2021
# ca <- as.data.frame(apply(ca, 2, function(y) gsub('...', '', y, fixed = TRUE)))

glimpse(ca)

# /----------------------------------------------------------------------------#
#/       Reshape table and complete clean up                            --------

# reshape table from wide to long format
ca <- ca %>%
  filter(MeasureMeasure == "Quantity (tonnes)") %>% 
  gather(year, catch, 5:ncol(ca)) %>%
  # Filter for empty columns
  filter(catch != "" & 
           # catch != 0 &
           FishingareaFAOmajorfishingarea!="")

# convert year and catch column to numeric
ca$year <- as.numeric(as.character(ca$year))
ca$catch <- as.numeric(as.character(ca$catch))

# convert column to character
ca$FishingareaFAOmajorfishingarea <- as.character(ca$FishingareaFAOmajorfishingarea)



# /----------------------------------------------------------------------------#
#/      Sum production by area, country and year                          ------

# Sum by country and change the ...? 
ca_sum_bycountry <- ca %>%
  # mutate(source = ifelse(grepl("Inland waters", FishingareaFAOmajorfishingarea), "Inland", "Marine")) %>%
  mutate(source = ifelse(grepl("Inland waters", FishingareaFAOmajorfishingarea), "Inland", "Marine")) %>%
  filter(source == "Inland") %>%
  group_by(CountryCountry, source, year) %>%
  summarise(sum_catch = sum(catch, na.rm=T)) %>%
  mutate(type = "Catch")


  # Remove column
ca_sum_bycountry$FishingareaFAOmajorfishingarea <- NULL



# /----------------------------------------------------------------------------#
#/      Add ISO country code column                                      -------

# Match country name with code, for later joining
ca_sum_bycountry$country_code <- countrycode(ca_sum_bycountry$CountryCountry, 
                                             'country.name', 'iso3c', warn = TRUE)

### Filter by year and average
ca_avg_bycountry <- ca_sum_bycountry %>%
                    filter(year >= 1997 & year <= 2014) %>%
                    group_by(CountryCountry, country_code) %>%
                    summarise(fao.avg.catch.1997.2014 = mean(sum_catch) / 10^6) %>%
                    ungroup() 


# Append missing countries 
# missingcountries<-
#   data.frame(CountryCountry = c('Libya','Saudi Arabia', 'Oman', 'Yemen', 'United Arab Emirates'),
#            country_code=c('LBY', 'SAU', 'OMN', 'YEM', 'ARE'),
#            fao.avg.catch.1997.2014 = c(0, 0, 0, 0, 0))
# 
# ca_avg_bycountry <- bind_rows(ca_avg_bycountry, missingcountries)

# /----------------------------------------------------------------------------#
#/      Read in predicted catch, from HCES and GLM (Fluet-Chouinard et al, 2018; PNAS)

pred <- read.csv("../output/catch_stats/global_country_agg_pred_fao_catch.csv", stringsAsFactors = F) %>%
          dplyr::select(-fao.catch.2008, composite.catch, composted.label)
        

# /----------------------------------------------------------------------------#
#/      combine df and calculate different composites

j <-  left_join(ca_avg_bycountry, pred, by=c("country_code"="iso.code")) %>%  # JULY2021- USE LEFT JOIN BC SOME COUNTRIES MISSING IN PRED; EX. NEW ZEALAND
      # Fix Sudan
      dplyr::filter(CountryCountry != 'Sudan (former)') %>% 
      mutate(country.name = ifelse(CountryCountry == 'South Sudan', 'South Sudan', country.name)) %>% 
      mutate(country_code = ifelse(CountryCountry == 'South Sudan', 'SDS', country_code)) %>% 

      #inner_join(ca_avg_bycountry, pred, by=c("country_code"="iso.code")) %>%
      dplyr::select(-CountryCountry) %>%
  
      # update JULY2021 - NOT HCES LOWER THAN FAO ARE NOT REPLACED.
      # calculate t2
      mutate(catch.c2 = ifelse(!is.na(hces.catch) & hces.catch>fao.avg.catch.1997.2014, hces.catch, fao.avg.catch.1997.2014)) %>%
      mutate(label.c2 = ifelse(!is.na(hces.catch) & hces.catch>fao.avg.catch.1997.2014, "HCES", "FAO")) %>%
  
      # calculate t3:
      mutate(catch.c3 = ifelse(!is.na(hces.catch) & hces.catch>fao.avg.catch.1997.2014, hces.catch, fao.avg.catch.1997.2014)) %>%
      mutate(catch.c3 = ifelse(is.na(hces.catch) & !is.na(glm.corr.ratio), fao.avg.catch.1997.2014 * (glm.corr.ratio/100), catch.c3)) %>%
      mutate(label.c3 = ifelse(!is.na(hces.catch) & hces.catch>fao.avg.catch.1997.2014, "HCES", "FAO")) %>%
      mutate(label.c3 = ifelse(is.na(hces.catch) & !is.na(glm.corr.ratio), "GLM", label.c3)) %>%
  
      dplyr::select(-composite.catch, -composted.label, -glm.catch)

glimpse(j)



# /----------------------------------------------------------------------------#
#/     Get global sums

sum(as.numeric(j$fao.avg.catch.1997.2014), na.rm = TRUE)
sum(as.numeric(j$catch.c2), na.rm = TRUE)
sum(as.numeric(j$catch.c3), na.rm = TRUE)



# /----------------------------------------------------------------------------#
#/      Get lake catch

l <- read.csv("../data/fromCathy/lake_catch.csv", stringsAsFactors = F)

# Match country name with code, for later joining
l$country_code <- countrycode(l$country, 'country.name', 'iso3c', warn = TRUE)

l <- l %>% dplyr::select(-country)


# /----------------------------------------------------------------------------#
#/      Combine catch estimates with lake catch data

j2 <- left_join(j, l, by="country_code") %>%
      mutate(lake_catch = ifelse(is.na(lake_catch), 0, lake_catch/10^6)) %>%
  
      # Subtract lake catch
      mutate(fao.avg.catch.1997.2014 = fao.avg.catch.1997.2014 - lake_catch,
             catch.c2                = catch.c2 - lake_catch,
             catch.c3                = catch.c3 - lake_catch) %>%
      mutate(fao.avg.catch.1997.2014 = ifelse(fao.avg.catch.1997.2014 < 0, 0, fao.avg.catch.1997.2014),
             catch.c2                = ifelse(catch.c2 < 0, 0, catch.c2),
             catch.c3                = ifelse(catch.c3 < 0, 0, catch.c3))



# /----------------------------------------------------------------------------#
#/      Get global sums

sum(as.numeric(j2$fao.avg.catch.1997.2014), na.rm = TRUE)
sum(as.numeric(j2$catch.c2), na.rm = TRUE)
sum(as.numeric(j2$catch.c3), na.rm = TRUE)

glimpse(j2)



# /----------------------------------------------------------------------------#
#/      Save catch df to file

write.csv(j2, '../output/catch_stats/riv_catch_1997_2014_andcomposited.csv')






# /----------------------------------------------------------------------------#
#/      Read in survey data  (NOT NEEDED BECAUSE ALREADY IN PRED DF)
# 
# hces <- read.csv("../../../chap5_global_inland_fish_catch/output/consumption/hh_survey_consump_nat_aggprod_refuse_fw_mc_gamfm.csv") %>%
#   select(country_code, mean, datatype) %>%
#   filter(datatype == "tr_corr_consump") %>%
#   mutate(hces_catch = mean) %>%
#   select(-mean, -datatype)
# 
# glimpse(hces)
