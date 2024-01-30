# /----------------------------------------------------------------------------#
#/  Set location to latlong_wgs84 PERMANENT
# Add ons are located in the main GUI window > Tools Tab (at bottom) > Add Ons at the bottom of list




# Set region
g.region -s raster=GDW_v0_2_beta_barriers_filt_v2_test
# dir_sub.tif2@PERMANENT 
# g.region rast='yourDEM'
# <PERMANENT> in <world_latlong_wgs84

# Set projection
g.proj -c epsg=4326 location=latlong


# Set mapset
g.mapset mapset=PERMANENT location=latlong
# g.mapset mapset=efluet -c location=PERMANENT

# /----------------------------------------------------------------------------#
#/  Get TEST inputs

cd /Users/efluet/Library/CloudStorage/Dropbox/side_projects/fisheries_riv_res_map/output/dor

# Import DIR raster
r.in.gdal -e --overwrite --verbose input=hyd_global_dir_30s_red_test.tif output=hyd_global_dir_30s_red_test memory=6000
# Import Weight raster based on reservoir locations
r.in.gdal -e --overwrite --verbose input=GDW_v0_2_beta_barriers_filt_v2_test.tif output=GDW_v0_2_beta_barriers_filt_v2_test memory=6000

# List rasters
g.list raster


# /----------------------------------------------------------------------------#
#/  Calculate flow accumulation using r.accumulate

r.accumulate -0 -r --overwrite --verbose direction=hyd_global_dir_30s_red_test format=degree weight=GDW_v0_2_beta_barriers_filt_v2_test accumulation=flow_acc_v01

# Save to output
r.out.gdal --overwrite input=flow_acc_v01 output=flow_acc_test_2.tif




# /----------------------------------------------------------------------------#
#/  Get GLOBAL inputs

cd /Users/efluet/Library/CloudStorage/Dropbox/side_projects/fisheries_riv_res_map/output/dor

# Import DIR raster
r.in.gdal -e --overwrite --verbose input=hyd_global_dir_30s_red.tif output=hyd_global_dir_30s_red memory=6000
# Import Weight raster based on reservoir locations
r.in.gdal -e --overwrite --verbose input=GDW_v0_2_beta_barriers_filt_v2.tif output=GDW_v0_2_beta_barriers_filt_v2 memory=6000

# List rasters
g.list raster


# /----------------------------------------------------------------------------#
#/  Calculate flow accumulation using r.accumulate

r.accumulate -0 -r --overwrite --verbose direction=hyd_global_dir_30s_red format=degree weight=GDW_v0_2_beta_barriers_filt_v2 accumulation=flow_acc

# Save to output
r.out.gdal --overwrite input=flow_acc output=GDW_cap_acc_global_v01.tif





# g.remove -f type=raster pattern='*'