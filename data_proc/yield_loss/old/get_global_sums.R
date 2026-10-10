country_rel_ril <- 
  read.csv(paste0('../output/results/catch_losses/country_sum_', m, '_', c, '_rep.csv')) %>%
  select(-continent) %>% 
  left_join(., countries %>% as.data.frame() %>% select(adm0_a3, continent), by=c('adm0_a3_us'='adm0_a3')) %>% 
  filter(!is.na(continent)) %>%
  group_by(continent) %>% 
  summarise_if(is.numeric, sum, na.rm=TRUE) %>% 
  mutate(loss_reserv_footprint= reserv_yield - riv_yield_overreserv,
         loss_entire_basin= reserv_yield - riv_yield_overreserv - dor) %>% 
  filter(continent != 'Seven seas (open ocean)') #%>% 
  # select(continent, loss_reserv_footprint, loss_entire_basin) %>% 
  # pivot_longer(cols=c( loss_reserv_footprint, loss_entire_basin), names_to='vartype',values_to='values') %>% 
  # mutate(vartype=ifelse(vartype=='loss_reserv_footprint', 'Reservoir footprint', vartype),
  #        vartype=ifelse(vartype=='loss_entire_basin', 'Entire basin', vartype)) %>% 
  # # Add line skip to the continent
  # mutate(continent=ifelse(continent=='North America', 'North\nAmerica', continent),
  #        continent=ifelse(continent=='South America', 'South\nAmerica', continent))


glimpse(country_rel_ril)


country_rel_ril %>% summarise(across(riv_catch:loss_entire_basin, sum))
