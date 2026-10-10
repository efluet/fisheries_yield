# Post-process distributed river catch
# Read all distributed catch members, and stack together


riv_yield_member_stack <- c()


# Loop through members
for (i in seq(1,100)){
  
  print(i)
  
  # Read single member
  membername <- paste0('../output/results/riv_yield_distrib/members/riv_yield_distrib_', m, '_', c, '_1km_2024_rep_member', i,'.tif')
  riv_yield_member <- rast(membername)

  # Append to stack
  riv_yield_member_stack <- c(riv_yield_member_stack, riv_yield_member)
  
  }


# Convert format
riv_yield_member_stack <- rast(riv_yield_member_stack)

# Get per-pixel percentile on entire stack
riv_yield_member_perc <- terra::quantile(riv_yield_member_stack, probs=c(0.025, 0.975), na.rm=T)
names(riv_yield_member_perc) <- c('lwr','upr')

# Calculate 95th percentile range
riv_yield_member_range <- riv_yield_member_perc[[2]] - riv_yield_member_perc[[1]]

# Save to file
outname <- paste0('../output/results/riv_yield_distrib/riv_yield_distrib_range_', m, '_', c, '_1km_2024_rep_cap.tif')
writeRaster(riv_yield_member_range, outname, overwrite=TRUE)


# Global sum by quadrature of uncertainty ranges
global(riv_yield_member_range, function(x) sqrt(sum(x^2, na.rm=T)))

# Total distrib uncertainty: 0.028025