

# /----------------------------------------------------------------------------
#/     Read in GIEMS tiles
#          - These have the MAMin, MAMax, LTMax

t <-  read.csv("../output/seltiles/tiles_giemsd15_sel_basins_wbasinnames_v2.csv",
              stringsAsFactors = F) %>%
      select(TARGET_FID, ICELL, NAME, AREAkm2, MAMinPix, MAMAXPix, IAMaxPix, MAMinPerc, MAMAXPerc, IAMaxPerc, GLWDallPer) %>%
      mutate(pixcnt = MAMinPix/(MAMinPerc/100)) %>%
      mutate(pixcnt = ifelse(pixcnt=="NaN", 3600, pixcnt))


# /----------------------------------------------------------------------------
#/     Read in summarized monthly zstat per tile
#          - These have the monthly GIEMS-D15

m <- read.csv("../output/seltiles/flooddur_pergiemstile_fid_v2.csv",
              stringsAsFactors = F) %>%
    select(FID2, SUM) %>%
    mutate(monthly_sum = SUM/10) %>%
    select(-SUM)


# /----------------------------------------------------------------------------
#/     Join them Read in summarized monthly zstat per tile


a <-  full_join(t, m, by= c("TARGET_FID" = "FID2")) %>%
  
      # calcualte monthly index as km2 x month
      mutate(monthlykm2 = monthly_sum / pixcnt * AREAkm2) %>%
      mutate(maminkm2 = MAMinPerc/100 * AREAkm2) %>%
      mutate(mamaxkm2 = MAMAXPerc/100 * AREAkm2) %>%
      mutate(iamaxm2 = IAMaxPerc/100 * AREAkm2) %>%
  
      select(-TARGET_FID, -ICELL, -MAMinPerc, -MAMAXPerc, -MAMinPix, -MAMAXPix, -IAMaxPix, -IAMaxPerc, -GLWDallPer, -pixcnt, -monthly_sum) %>%
      group_by(NAME) %>%
      summarise_all(sum) %>%
      ungroup() %>%
      filter(NAME != "", NAME != "Pearl")

glimpse(a)


# save the data to CSV
write.csv(a, "../output/giemsd15_area_perbasin.csv")



# /----------------------------------------------------------------------------
#/     Scatterplot of monthly vs annual GIEMS-D15 per basin

ggplot(a) + 
  
  geom_point(aes(x=monthlykm2/10^6, y=maminkm2/10^6), color="blue") + 
  geom_point(aes(x=monthlykm2/10^6, y=mamaxkm2/10^6), color="purple") + 
  geom_point(aes(x=monthlykm2/10^6, y=iamaxm2/10^6), color="green") +
  
  ylab("GIEMS-D15 inundated extent\n(million km2)") +
  xlab("Cumulative monthly inundated index\n(million km2 x month)") +
  ggtitle("Comparison of monthly index and annual extents (MAMin, MAMax, IAMax)\nfor 33 basins with both.") +
  
  # waterbody label
  geom_text_repel(data = subset(a, monthlykm2/10^6 > 0.2),
                  aes(x=monthlykm2/10^6, y=iamaxm2/10^6, label = NAME),
                  color='green',
                  segment.color='grey25',
                  size = 3,
                  nudge_x = 0,
                  segment.size = 0.25,
                  box.padding = unit(0.5, 'mm'),
                  point.padding = unit(0.5, 'mm')) +
  theme_bw()




# /----------------------------------------------------------------------------
#/     Save plot to file 

ggsave('../output/figures/scatterplot_inundated_monthlyindex_annual.png',
       width=187, height=187, dpi=300, units="mm")  #, type = "cairo-png")
dev.off()

