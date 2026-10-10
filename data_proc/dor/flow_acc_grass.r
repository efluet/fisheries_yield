
library(terra)
library(here)


# /----------------------------------------------------------------------------#
#/ Prep DIR grid
dir <- rast("../output/dor/hyd_global_dir_30s.tif")


# Going TOP RIGHT COUNTER CLOCKWISE
dir[dir==128] = 45
dir[dir==64] = 90
dir[dir==32] = 135
dir[dir==16] = 180
dir[dir==8] = 225
dir[dir==4] = 270
dir[dir==2] = 315
dir[dir==1] = 360

# Set projection
crs(dir)  <- "epsg:4326"

# Save to file
writeRaster(dir,
            "../output/dor/hyd_global_dir_30s_red.tif",
            overwrite=T,
            datatype="INT2U")

# /----------------------------------------------------------------------------#
#/ Export DIR subset  
dir_sub <- crop(dir, ext(6, 8, 45, 47))

# Export subset
writeRaster(dir_sub, 
            "../output/dor/hyd_global_dir_30s_red_test.tif",
            overwrite=T,
            datatype="INT2U")


# /----------------------------------------------------------------------------#
#/ Prep Barriers 

barriers <- rast("../output/dor/GDW_v0_2_beta_barriers_filt_v2.tif")
barriers[is.nan(barriers)] <- 0
barriers <- rast("../output/dor/GDW_v0_2_beta_barriers_filt_v2.tif")
# Export subset
writeRaster(barriers, 
            "../output/dor/GDW_v0_2_beta_barriers_filt_v2.tif",
            overwrite=T)


# /----------------------------------------------------------------------------#
#/  Subset weights
barriers_sub <- crop(barriers, ext(6, 8, 45, 47))

writeRaster(barriers_sub,
            "../output/dor/GDW_v0_2_beta_barriers_filt_v2_test.tif",
            overwrite=T)
# datatype="INT2U")

