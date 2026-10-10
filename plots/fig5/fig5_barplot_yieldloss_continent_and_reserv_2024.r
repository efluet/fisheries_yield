
# /----------------------------------------------------------------------------#
#/  FIG.4A -  Net loss per continent; for REL and RIL                 ----------

# Start with country-level summary
continent_rel_ril <-
  read.csv('../output/results/yield_losses/country_sum/country_sum_lm2c_catch.c2_rep_cap_102024.csv') %>%
  
  rename(
    riv_yield = riv_catch,
    dor_2p_loss = dist2) %>%
  
  mutate(
    local_change = res_yield - riv_yield_infootprint,
    net_change = res_yield - riv_yield_infootprint - dor_2p_loss,
    
    # Country-level uncertainty of the difference
    local_change_range = sqrt(res_yield_range^2 + riv_yield_range^2)) %>%
  
  filter(!is.na(continent)) %>%
  group_by(continent) %>%
  
  summarise(
    # Positive and negative changes
    local_gain = sum(local_change[local_change > 0], na.rm = TRUE),
    local_loss = sum(local_change[local_change < 0], na.rm = TRUE),
    
    # Uncertainty ranges for gains and losses
    local_gain_range = sqrt(sum(local_change_range[local_change > 0]^2, na.rm = TRUE)),
    local_loss_range = sqrt(sum(local_change_range[local_change < 0]^2, na.rm = TRUE)),
    
    # Downstream losses
    downstream_loss = sum(dor_2p_loss, na.rm = TRUE),
    
    # Net change and uncertainty
    net_change = sum(local_change, na.rm = TRUE) - sum(dor_2p_loss, na.rm = TRUE),
    net_change_range = sqrt(sum(local_change_range^2, na.rm = TRUE)),
    
    .groups = "drop") %>%
  
  filter(continent != "Seven seas (open ocean)") %>%
  
  mutate(
    downstream_loss = -downstream_loss,
    net_change = local_gain + local_loss + downstream_loss) %>% 
  
  mutate(
    # Local gain bounds
    local_gain_low  = local_gain - local_gain_range/2,
    local_gain_high = local_gain + local_gain_range/2,
    
    # Local loss bounds
    local_loss_low  = local_loss - local_loss_range/2,
    local_loss_high = local_loss + local_loss_range/2,
    
    # Net change bounds
    net_change_low  = net_change - net_change_range/2,
    net_change_high = net_change + net_change_range/2) 
  
# LONG
continent_rel_ril_long <- continent_rel_ril %>%
  dplyr::select(
    continent,
    local_gain, local_gain_low, local_gain_high,
    local_loss, local_loss_low, local_loss_high,
    downstream_loss,
    net_change, net_change_low, net_change_high
  ) %>%
  pivot_longer(
    cols = -continent,
    names_to = c("vartype", "type"),
    names_pattern = "^(.*?)(?:_(low|high))?$",
    values_to = "value"
  ) %>%
  mutate(type = replace_na(na_if(type, ""), "middle")) %>% 
  pivot_wider(
    names_from = type,
    values_from = value
  ) 


# Clean up names and factors
continent_rel_ril_long <- 
  continent_rel_ril_long %>% 
  mutate(vartype=ifelse(vartype=='local_gain', 'Local gain', vartype),
         vartype=ifelse(vartype=='local_loss', 'Local loss', vartype),
         vartype=ifelse(vartype=='downstream_loss', 'Downstream loss', vartype),
         vartype=ifelse(vartype=='net_change', 'Net change', vartype)) %>% 
  # Add line skip to the continent
  mutate(continent=ifelse(continent=='North America', 'North\nAmerica', continent),
         continent=ifelse(continent=='South America', 'South\nAmerica', continent))



# 
continent_rel_ril_long$vartype <- factor(continent_rel_ril_long$vartype,
                                      levels=c('Local gain','Local loss','Downstream loss','Net change'))


#------------------------------------------------------------
# Map barplot per continents
barplot_yield_change_per_continent <- 
  
  ggplot(continent_rel_ril_long, aes(x = continent, ymin = low/10^6, ymax = high/10^6, fill = vartype)) +
  geom_bar(position = position_dodge(), aes(y = middle/10^6), stat = "identity", width=0.8) +
  geom_errorbar(position = position_dodge(width = 0.8), colour = "black", width=0.1, lwd=0.3) +
  
  geom_hline(aes(yintercept=0), size=0.2) +
  # scale_fill_manual(values= c( 'Local changeReservoir footprint'= '#00b0b3',
  #                              'Reservoir footprint + downstream'= '#ab00d1')) +
  scale_x_discrete(position = "top") +
  # scale_y_continuous(breaks=pretty_breaks(8), limits=c(-1800, 200)) +
  xlab('') + ylab('Change in fish yield (M tonnes / year)') +

  line_plot_theme() +
  theme(axis.line.x  = element_blank(),
        panel.border = element_blank(),
        axis.ticks.x = element_blank(),
        legend.title = element_blank(),
        legend.position = c(0.8, 0.4),
        plot.margin=unit(c(-1, -1, 6, 7), 'mm'))

barplot_yield_change_per_continent





# /----------------------------------------------------------------------------#
#/ Largest local GAINS for individual reservoirs; for REL and RIL                            ----------

# get points with riv and reset 
rel_perreserv <- 
  # st_read(paste0('../output/results/yield_losses/localloss_gdw_barrier_', m, '_', c, '_rep_2024_v06.gpkg')) %>% 
  st_read(paste0('../output/results/yield_losses/localloss_gdw_barrier_lm2c_catch.c2_rep_cap_2024_v10.gpkg')) %>% 
  
  st_drop_geometry() %>% 
  dplyr::mutate(rel_tons = localloss*-1,
                rel_tons_range = localloss_range)

# Subset to only positive gains
rel_perreserv_gain <- rel_perreserv %>% filter(rel_tons>0) 

# Group reservoirs in top20 or others, and summarise
rel_perreserv_gain <- 
  rel_perreserv_gain %>% 
  arrange() %>% 
  top_n(rel_tons, n = 20) %>% 
  mutate(group = 'top20') %>%
  # ungroup() %>% 
  # select(GDW_ID, group) %>% 
  right_join(., rel_perreserv_gain) %>%
  mutate(DAM_NAME = paste0(DAM_NAM, ', ', COUNTRY)) %>%
  mutate(DAM_NAME = ifelse(is.na(group), 'All others (n=30,710)', DAM_NAME)) %>% 
  group_by(DAM_NAME) %>% 
  # Summarize the other 30k 
  summarize(rel_tons=sum(rel_tons, na.rm=T),
            rel_tons_range = sqrt(sum(rel_tons_range^2, na.rm=T))) %>% 
  
  # Calculate upper and lower
  dplyr::mutate(rel_tons_lwr = (rel_tons - rel_tons_range/2),
                rel_tons_upr = (rel_tons + rel_tons_range/2)) %>% 
  ungroup() %>% 
  arrange(-rel_tons)

glimpse(rel_perreserv_gain)


#reorder origin by ascending count
rel_perreserv_gain$DAM_NAME <- reorder(rel_perreserv_gain$DAM_NAME, desc(rel_perreserv_gain$rel_tons))

rel_perreserv_gain <- 
  rel_perreserv_gain %>% 
  mutate(cumul_tons = cumsum(rel_tons),
         cumul_perc = cumul_tons/sum(rel_tons)*100)


nrow_lab <- nrow(rel_perreserv_gain)


# /----------------------------------------------------------------------------#
#/ GAIN barplot
barplot_yield_gain_per_reserv <- 
  ggplot(rel_perreserv_gain) +
  
  geom_hline(aes(yintercept=0), size=0.2, color='grey15') +
  
  # Add bar
  geom_bar(aes(x=DAM_NAME, y=rel_tons/1000), fill='#0066A5', stat='identity', width=0.7) +
  # Add errorbars
  geom_errorbar(aes(x=DAM_NAME, y=rel_tons/1000, ymin=rel_tons_lwr/1000, ymax=rel_tons_upr/1000), 
                stat='identity', width=0.1, lwd=0.2) +
  
  # Add % in black
  geom_line(aes(x=DAM_NAME, y = cumul_tons/1000, group = 1), size=0.3) +
  geom_point(aes(x=DAM_NAME, y = cumul_tons/1000), size=0.3) +
  
  scale_y_continuous(expand=c(0,0),
                     breaks=pretty_breaks(8),
                     sec.axis = sec_axis(
                                         ~. / max(rel_perreserv_gain$cumul_tons)*1000,
                                         labels = scales::percent_format(accuracy = 5L), 
                                         name = "Cumulative percentage (%)",
                                         breaks=pretty_breaks(8))) +

  xlab('') + ylab('Gain in fish yield\n(1000 tonnes / year)') +
  line_plot_theme() +
  theme(axis.line.y.left = element_line(color = '#0066A5'), 
        axis.ticks.y.left = element_line(color = '#0066A5'),
        axis.text.y.left = element_text(color = '#0066A5'),
        axis.title.y.left = element_text(color = '#0066A5'),
        axis.text.x = element_text(angle = 45, hjust = 1),
        plot.margin=unit(c(1, -1, -1, 7), 'mm'))

barplot_yield_gain_per_reserv

# /----------------------------------------------------------------------------#
#/ Net loss per continent; for REL and RIL                            ----------

rel_perreserv_loss <- 
  rel_perreserv %>% 
  filter(rel_tons<0) %>% 
  mutate(rel_tons = rel_tons * -1)

nrow_lab <- nrow(rel_perreserv_loss)

rel_perreserv_loss <- 
  rel_perreserv_loss %>% 
  arrange() %>% 
  top_n(rel_tons, n = 20) %>% 
  mutate(group = 'top20') %>% 
  # select(GDW_ID, group) %>% 
  right_join(., rel_perreserv_loss) %>%
  mutate(DAM_NAME = paste0(DAM_NAM, ', ', COUNTRY)) %>% 
  mutate(DAM_NAME = ifelse(is.na(group), paste0('All others (n=', nrow_lab,')'), DAM_NAME)) %>% 
  group_by(DAM_NAME) %>% 
  # Summarize the other 30k 
  summarize(rel_tons=sum(rel_tons, na.rm=T),
            rel_tons_range = sqrt(sum(rel_tons_range^2, na.rm=T))) %>% 
  
  # Calculate upper and lower
  dplyr::mutate(rel_tons_lwr = (rel_tons - rel_tons_range/2),
                rel_tons_upr = (rel_tons + rel_tons_range/2)) %>% 
  ungroup() %>% 
  arrange(-rel_tons)

glimpse(rel_perreserv_loss)

#reorder origin by ascending count
rel_perreserv_loss$DAM_NAME <- reorder(rel_perreserv_loss$DAM_NAME, desc(rel_perreserv_loss$rel_tons))

rel_perreserv_loss <- 
  rel_perreserv_loss %>% 
  mutate(cumul_tons = cumsum(rel_tons),
         cumul_perc = cumul_tons/sum(rel_tons)*100)


# /----------------------------------------------------------------------------#
#/ Map barplot
barplot_yield_loss_per_reserv <- 
  
  ggplot(rel_perreserv_loss) +
  
  geom_hline(aes(yintercept=0), size=0.2, color='grey15') +
  
  geom_bar(aes(x=DAM_NAME, y=rel_tons/1000), fill="#B71729", stat='identity', width=0.7) +
  
  # Add errorbars
  geom_errorbar(aes(x=DAM_NAME, y=rel_tons/1000, ymin=rel_tons_lwr/1000, ymax=rel_tons_upr/1000), 
                stat='identity', width=0.1, lwd=0.2) +
  
  # Add %
  geom_line(aes(x=DAM_NAME, y = cumul_tons/1000, group = 1), size=0.3) +
  geom_point(aes(x=DAM_NAME, y = cumul_tons/1000), size=0.3) +
  # Scale
  scale_y_continuous(expand=c(0,0),
                     breaks=pretty_breaks(8),
                     sec.axis = sec_axis(
                       ~. / max(rel_perreserv_loss$cumul_tons)*1000,
                       labels = scales::percent_format(accuracy = 5L), 
                       name = "Cumulative percentage (%)",
                       breaks=pretty_breaks(8))) +
  
  xlab('') + ylab('Loss in fish yield\n(1000 tonnes / year)') +
  line_plot_theme() +
  theme(axis.line.y.left = element_line(color = "#B71729"), 
        axis.ticks.y.left = element_line(color = "#B71729"),
        axis.text.y.left = element_text(color = "#B71729"),
        axis.title.y.left = element_text(color = "#B71729"),
        axis.text.x = element_text(angle = 45, hjust = 1),
        plot.margin=unit(c(1, -1, -1, 7), 'mm'))

barplot_yield_loss_per_reserv

# /----------------------------------------------------------------------------#
#/ Arrange in grid                            ----------

# arrange plots grob into layout 
barplot_rel <- 
  plot_grid(barplot_yield_change_per_continent,
            barplot_yield_gain_per_reserv,
            barplot_yield_loss_per_reserv,
            
            ncol=1, nrow=3,
            rel_heights = c(1, 1.2, 1.3),
            # rel_widths = c(.5, 1),
            labels = c('A','B','C'),
            align='v')



# /----------------------------------------------------------------------------#
#/ 
ggsave('../output/figures/fig5/fig5_barplot_rel_3panel_errbar_v12.png',
       barplot_rel,
       width=120, height=185, dpi=500, units='mm' )

ggsave('../output/figures/fig5/fig5_barplot_rel_3panel_errbar_v12.pdf',
       barplot_rel,
       width=120, height=185, dpi=500, units='mm' )

