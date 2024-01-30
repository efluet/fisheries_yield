# /------------------------------------------------------------------------
#/ Function to distribute catch
distrib_catch <- function(pred_catch, natcatch, catch_col){
  
  # Make percentage overlap grid
  perc_overlap <- make_perc_overlap_raster(pred_catch)

  # Append the numerical IDs from the ISO lookup
  catch_sub <- full_join(natcatch, isolookup2, by=c('country_code'='adm0_a3')) %>% 
                arrange(country_code)
  
  # Subset to two columns; NO FUCKING IDEA WHY THIS IS NEEDED, BUT IT WOULDNT WORK OTHERWISE.
  catch_sub <- catch_sub[c('ID', catch_col)]
  catch_sub <- catch_sub %>% rename(ID=1, natcatch=2)
  catch_sub <- catch_sub %>% 
               filter(!is.na(ID)) %>%
               mutate(natcatch=ifelse(is.na(natcatch), 0, natcatch))
  # catch_sub[is.na(catch_sub$natcatch), natcatch] <- 0
  
  # Substitute values of country ISO code with the value of area drained
  # catch_sum <- raster::sub(ciso, catch_sub, by='ID', which=catch_col, subsWithNA=TRUE)
  #  NOTE:  SUBST HAD AN ARGUMENT OTHERS TO REPLACE MISSING VALUES, BUT THAT DOES NOT EXIST ANYMORE...
  catch_sum <- subst(ciso_num, from=catch_sub$ID, to=catch_sub$natcatch) #, others=NA)
  
  # Then multiply the % of overlap with the national drained area.
  # This distributes the drained area over the country pixels.
  catch_distributed <- perc_overlap * catch_sum
  
  return(catch_distributed)
}

