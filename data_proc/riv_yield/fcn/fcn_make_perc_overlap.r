
# /--------------------------------------------------------------------------#
#/   Calculate each pixels % of national fish yield in each country       -----

make_perc_overlap_raster <- function(r) {
  
  # r <- r * 10^6
  
  # Sum grid per country
  zt <-   as.data.frame(zonal(r, ciso_num, 'sum', na.rm=T)) %>%
          rename(adm0_a3 = 1,
                 value = 2) %>% 
    tibble::rownames_to_column(., var="id") %>%
    mutate(id = as.numeric(id))

  # Substitute values of CISO raster based on country ISO code
  # overlap_sum <- subst(ciso_num, from=zt$id, to=zt$value)
  overlap_sum <- subst(ciso_num, from=zt$adm0_a3, to=zt$value)
  
  # Calc fraction of overlap within each country.
  perc_overlap <- r / overlap_sum
  
  # Remove the Inf
  perc_overlap[!is.finite(perc_overlap)] <- 0
  
  return(perc_overlap)
}



# writeRaster(overlap_sum, '../output/results/overlap_sum_test.tif')
# writeRaster(perc_overlap, '../output/results/perc_overlap_test2.tif')
# writeRaster(ciso_num, '../output/results/ciso_num_test.tif')
# 
# 
# ztmax <-   as.data.frame(zonal(r, ciso, 'max', na.rm=T)) %>%
#   rename(adm0_a3 = 1,
#          value = 2) %>% 
#   tibble::rownames_to_column(., var="id") %>%
#   mutate(id = as.numeric(id))
