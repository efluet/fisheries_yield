# Calculate animal-protein person equivalent at national scale
# for the catch map optimization of Becky Chaplin-Kramer.

# /----------------------------------------------------------------------------#
#/ Read survey catch & equiv; only for survey countries
survey <- read.csv('../data/protein_equiv/protein_equiv_fao_n_survey.csv') %>% as_tibble()
survey <- survey %>% 
          dplyr::select('country_code', 
                        "mean_dif",
                        "survey.inland.capture.fish.protein.consumption..g.person.day.", 
                        "fao.protein.g.cap.day.all",                                    
                        # "fao.protein.g.cap.day.fish",                             
                        # "fao.protein.g.cap.day.inland.fish",
                        "fao.protein.g.cap.day.inland.capture.fish", 
                        "fao.pers.equiv", 
                        "rev.fao.protein.g.cap.day.all", 
                        "rev.fao.pers.equiv") %>% 
    # Exclude countries with lower survey catch; removed bc cases of zero
    filter(mean_dif > 0)
  

# /----------------------------------------------------------------------------#
#/ Read Mcintyre catch & equiv.
fao <- read.csv('../data/protein_equiv/Pete calculations from PNAS paper for protein supply.csv') %>% as_tibble() %>% 
  dplyr::select('Country',
                'X2010_Popx1000.from.Cathy.',
                'Protein.Consumption.from.all.animals.percap_g_day..from.Cathy.',
                'PBM.FWwild.g_per_day_percap..from.Cathy.',
                'Final.catch.value.formatted.for.GIS..from.Cathy.',
                'Fwwild_v_animal..per.capita.fish.animal.protein.',
                'FWwild.Dependence..pop.Fwwild_v_animal.') %>% 
  # Match country name with code, for later joining
  mutate(country_code = countrycode(Country, 'country.name', 'iso3c', warn = TRUE),
         FWwild.Dependence..pop.Fwwild_v_animal. = FWwild.Dependence..pop.Fwwild_v_animal. / 10^6)



# /----------------------------------------------------------------------------# 
#/      Get lake catch

lake <- 
  read.csv("../data/fromCathy/lake_catch.csv", stringsAsFactors = F) %>% 
  mutate(country_code = countrycode(country, 'country.name', 'iso3c', warn = TRUE))


# /----------------------------------------------------------------------------# 
#/   Join together

comb <- 
  left_join(fao, survey, by='country_code') %>% 
  left_join(., lake, by='country_code')  %>% 
  mutate(lake_catch = ifelse(is.na(lake_catch), 0, lake_catch))
  

comb <- 
  comb %>% 
  # Test if a FAO country
  mutate(rivFWcap_animalproteinequiv_millionppl = ifelse(is.na(mean_dif), 
                               FWwild.Dependence..pop.Fwwild_v_animal.,
                               # (rev.fao.pers.equiv/10^6)* (1 - lake_catch / Final.catch.value.formatted.for.GIS..from.Cathy.) ) )
                               rev.fao.pers.equiv/10^6))

comb <- comb %>% 
        select('Country',
               'country_code',
               # 'lake_catch',
               # 'FWwild.Dependence..pop.Fwwild_v_animal.',
               'rivFWcap_animalproteinequiv_millionppl') 
  # mutate(diff = popequiv2021 - FWwild.Dependence..pop.Fwwild_v_animal.)


comb %>% summarise(across(where(is.numeric), ~ sum(.x, na.rm = TRUE)))


write.csv(comb, '../output/protein_equiv/rivFWcap_animalproteinequiv_millionppl.csv')


# Equation to calculate pop dependence
# FWwild g_per_day_percap / Protein Consumption from all animals percap_g_day = Fwwild_v_animal (per capita fish/animal protein)
# 2010_Popx1000 * Fwwild_v_animal (per capita fish/animal protein) = FWwild Dependence (pop*Fwwild_v_animal)




# combine protein equivalent from Pete 


# Combine FW catch from 
# comb <- 
#   comb %>% 
#   # Test if a FAO country
#   mutate(popequiv2021 = ifelse(is.na(mean_dif), 
#                                X2010_Popx1000.from.Cathy. *  (PBM.FWwild.g_per_day_percap..from.Cathy. / Protein.Consumption.from.all.animals.percap_g_day..from.Cathy.) / 1000,
#                                X2010_Popx1000.from.Cathy. * (rev.fao.protein.g.cap.day.all * (1 - lake_catch / Final.catch.value.formatted.for.GIS..from.Cathy.) / Protein.Consumption.from.all.animals.percap_g_day..from.Cathy.)/1000 
#                                ))


# X2010_Popx1000.from.Cathy. * (rev.fao.protein.g.cap.day.all * (1 - lake_catch / Final.catch.value.formatted.for.GIS..from.Cathy.) / Protein.Consumption.from.all.animals.percap_g_day..from.Cathy.) 
