m <- 'lm2b'
r <- raster(paste0('../output/pred_catch/pred_catch_', m, 'tif'))


# /-----------------------------------------------------------------------------
#/   MAKE GRID OF COUNTRY ISO CODES 
source('data_proc/make_iso_country_grid.r')


# /--------------------------------------------------------------------------#
#/   Calculate each pixels % of national overlap (of wet-LU)              -----
#    by dividing the pixels by the national total of overlap.
#    Why are there negative values?  becaus of negative pot-wet?
source('data_proc/fcn_make_perc_overlap.r')


perc_overlap <- make_perc_overlap_raster(r)
  


# /--------------------------------------------------------------------------#
#/   CATCH statistics                                              -------

# read catch df
natcatch <- read.csv('../output/catch/riv_catch_1997_2014_andcomposited.csv') %>% 
            filter(country_code != 'SDN') %>% 
            rename(catch.c1 = fao.avg.catch.1997.2014) %>% 
            # mutate(catch.c1 =ifelse(catch.c1<0.001, 0.001, catch.c1),
            #        catch.c2 =ifelse(catch.c2<0.001, 0.001, catch.c2),
            #        catch.c3 =ifelse(catch.c2<0.001, 0.001, catch.c3)) %>%
  mutate(ISO_A3 = country_code) %>% 
  left_join(., isolookup2, by='ISO_A3') %>% 
  filter(!is.na(ID))
            

names(natcatch)
glimpse(natcatch)

# /-----------------------------------------------------------------------------
#/  Get function to distrib catch
source('data_proc/fcn_distrib_catch.r')




# Run function distributing
# catch_distrib_c1 <- distrib_catch(natcatch, 'catch.c1')*10^6
# catch_distrib_c2 <- distrib_catch(natcatch, 'catch.c2')*10^6
# catch_distrib_c3 <- distrib_catch(natcatch, 'catch.c3')*10^6

