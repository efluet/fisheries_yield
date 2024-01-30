
# /----------------------------------------------------------------------------#
#/  FIG.4A -  Net loss per continent; for REL and RIL                            ----------

continent_rel_ril <- 
  read.csv(paste0('../output/results/catch_losses/country_sum_', m, '_', c, '_rep_oct2023.csv')) %>%
  select(-continent) %>% 
  left_join(., countries %>% as.data.frame() %>% select(adm0_a3, continent), by=c('adm0_a3_us'='adm0_a3')) %>% 
  filter(!is.na(continent)) %>%
  group_by(continent) %>% 
  summarise_if(is.numeric, sum, na.rm=TRUE) %>% 
  mutate(loss_reserv_footprint= res_yield - riv_yield,
         loss_entire_basin= res_yield - riv_yield - dist2) %>% 
  filter(continent != 'Seven seas (open ocean)') %>% 
  select(continent, loss_reserv_footprint, loss_entire_basin) %>% 
  pivot_longer(cols=c( loss_reserv_footprint, loss_entire_basin), names_to='vartype',values_to='values') %>% 
  mutate(vartype=ifelse(vartype=='loss_reserv_footprint', 'Reservoir footprint', vartype),
         vartype=ifelse(vartype=='loss_entire_basin', 'Reservoir footprint + downstream', vartype)) %>% 
  # Add line skip to the continent
  mutate(continent=ifelse(continent=='North America', 'North\nAmerica', continent),
         continent=ifelse(continent=='South America', 'South\nAmerica', continent))


continent_rel_ril$vartype <- factor(continent_rel_ril$vartype, 
                                      levels=rev(c('Reservoir footprint','Reservoir footprint + downstream')))


# Map barplot per continents
barplot_yield_change_per_continent <- 
  ggplot(continent_rel_ril) +
  geom_bar(aes(x=continent, y=values/1000, fill=vartype), position='dodge', stat='identity', width=0.6) +
  
  geom_hline(aes(yintercept=0), size=0.2) +
  scale_fill_manual(values= c( 'Reservoir footprint'= '#00b0b3',
                               'Reservoir footprint + downstream'= '#ab00d1')) +
  scale_x_discrete(position = "top") +
  scale_y_continuous(breaks=pretty_breaks(8), limits=c(-1800, 200)) +
  xlab('') + ylab('Change in fish yield\n(1000 tonnes / year)') +

  line_plot_theme() +
  theme(axis.line.x  = element_blank(),
        panel.border = element_blank(),
        axis.ticks.x = element_blank(),
        legend.position = c(0.4, 0.4),
        plot.margin=unit(c(-1, -1, 6, 1), 'mm'))



# /----------------------------------------------------------------------------#
#/ Largest local GAINS for individual reservoirs; for REL and RIL                            ----------

# get points with riv and reset 
rel_perreserv <- 
  st_read(paste0('../output/results/catch_losses/gdw_barriers_localloss_', m, '_', c, '_rep.shp')) %>% 
  st_drop_geometry() %>% 
  dplyr::mutate(rel_tons = localloss*-1)

# Subset to only positive gains
rel_perreserv_gain <- rel_perreserv %>% filter(rel_tons>0) 

# Group reservoirs in top20 or others, and summarise
rel_perreserv_gain <- 
  rel_perreserv_gain %>% 
  arrange() %>% 
  top_n(rel_tons, n = 20) %>% 
  mutate(group = 'top20') %>% 
  select(GDW_ID, group) %>% 
  right_join(., rel_perreserv_gain) %>%
  mutate(DAM_NAME = paste0(DAM_NAME, ', ', COUNTRY)) %>% 
  mutate(DAM_NAME = ifelse(is.na(group), 'All others (n=30,710)', DAM_NAME)) %>% 
  group_by(DAM_NAME) %>% 
  summarize(rel_tons=sum(rel_tons, na.rm=T)) %>% 
  ungroup() %>% 
  arrange(-rel_tons)

glimpse(rel_perreserv_gain)

#reorder origin by ascending count
rel_perreserv_gain$DAM_NAME <- reorder(rel_perreserv_gain$DAM_NAME, desc(rel_perreserv_gain$rel_tons))

rel_perreserv_gain <- 
  rel_perreserv_gain %>% 
  mutate(cumul_tons = cumsum(rel_tons),
         cumul_perc = cumul_tons/sum(rel_tons)*100)


# Map barplot
barplot_yield_gain_per_reserv <- 
  ggplot(rel_perreserv_gain) +
  geom_bar(aes(x=DAM_NAME, y=rel_tons/1000), fill='#0066A5', stat='identity', width=0.7) +
  
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
        plot.margin=unit(c(1, -1, -1, 1), 'mm'))



# /----------------------------------------------------------------------------#
#/ Net loss per continent; for REL and RIL                            ----------


rel_perreserv_loss <- rel_perreserv %>% filter(rel_tons<0) %>% mutate(rel_tons = rel_tons * -1)

rel_perreserv_loss <- 
  rel_perreserv_loss %>% 
  arrange() %>% 
  top_n(rel_tons, n = 20) %>% 
  mutate(group = 'top20') %>% 
  select(GDW_ID, group) %>% 
  right_join(., rel_perreserv_loss) %>%
  mutate(DAM_NAME = paste0(DAM_NAME, ', ', COUNTRY)) %>% 
  mutate(DAM_NAME = ifelse(is.na(group), 'All others (n=30,710)', DAM_NAME)) %>% 
  group_by(DAM_NAME) %>% 
  summarize(rel_tons=sum(rel_tons, na.rm=T)) %>% 
  ungroup() %>% 
  arrange(-rel_tons)

glimpse(rel_perreserv_loss)

#reorder origin by ascending count
rel_perreserv_loss$DAM_NAME <- reorder(rel_perreserv_loss$DAM_NAME, desc(rel_perreserv_loss$rel_tons))

rel_perreserv_loss <- 
  rel_perreserv_loss %>% 
  mutate(cumul_tons = cumsum(rel_tons),
         cumul_perc = cumul_tons/sum(rel_tons)*100)


# Map barplot
barplot_yield_loss_per_reserv <- 
  ggplot(rel_perreserv_loss) +
  geom_bar(aes(x=DAM_NAME, y=rel_tons/1000), fill="#B71729", stat='identity', width=0.7) +
  
  geom_line(aes(x=DAM_NAME, y = cumul_tons/1000, group = 1), size=0.3) +
  geom_point(aes(x=DAM_NAME, y = cumul_tons/1000), size=0.3) +
  
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
        plot.margin=unit(c(1, -1, -1, 1), 'mm'))



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


ggsave('../output/figures/fig4/fig4_barplot_rel_3panel_oct2023.png',
       barplot_rel,
       width=120, height=185, dpi=500, units='mm' )

ggsave('../output/figures/fig4/fig4_barplot_rel_3panel_oct2023.pdf',
       barplot_rel,
       width=120, height=185, dpi=500, units='mm' )


