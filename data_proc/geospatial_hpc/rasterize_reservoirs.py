# Script prepares reservoir rasters

# if 0==1: 
# 	print('WTF IS THIS!')

# if 0==1:
	# ml python/3.9.0
	# ml load physics
	# ml load sqlite/3.37.2
	# ml load proj/9.1.0
	# ml load  gdal/3.4.1 # gdal/3.5.2
	# ml load geos
	# ml system
	# ml load devel
	# ml py-numpy # /1.20.3_py39
	# ml py-scikit-image/0.19.3_py39
	# # set wd
	# cd /home/groups/robertj2/reserv_fish
	# python3   # Start python


import pandas as pd
import geopandas as gpd
import rasterio as rio
from rasterio import features
import fiona
fiona.supported_drivers  
import subprocess
import glob
import os
from pathlib import Path


#///////////////////////////////////////////////////
# rasterize at 50m then aggregate to 1km
# 23° degrees latitudinal threshold between tropical VS temperate
# From Gunther: 
#	- projects were unselected, probably when they a combination of: a) had no reservoir shape; b) had no volume attribute; c) were lake controlled, or d) when there was no FAO yield data available (quite a few countries). You can use the field INC in the shapefile ‘grand_dams’ to identify the ones that were used (1) versus the one’s not used (0) for producing the DOR raster.
# 	- a) we decided that a DOR of below 2% should not reduce fish yield, it will be set to zero; b) similarly a DOR at or above 100 will be set to 100%. The units of the DOR raster are fractional DOR value, so if you wanted the percentages, you need to multiply the values by 100.


# /---------------------------------------------------------------------------#
#/   Rasterize fractional 
pd.set_option('display.max_columns', 10)

gdw_poly = gpd.read_file('./data/GDW/GDW_v0_2_beta/GDW_v0_2_beta_shp/GDW_reservoirs_v0_2.shp')
gdw_poly = gdw_poly.iloc[:,[0,1,2,3,5,13,15,20,25,64]] # [:,0:29]

# Filter lakes by attributes
gdw_poly = gdw_poly[gdw_poly.AREA_SKM >= 0.1]
gdw_poly = gdw_poly[gdw_poly.LAKE_CTRL.isnull()]
gdw_poly = gdw_poly[(gdw_poly.TIMELINE.isnull()) | (gdw_poly['TIMELINE']=='Modified')]




def rasterize_shapefile(input_shapefile, output_raster, raster_resolution, bounds):
	# Build the gdal_rasterize command
	# cmd = ['gdal_rasterize', '-burn', '1', '-tr', str(out_res[0]), str(out_res[1]), input_shapefile, output_raster]
	# -te <xmin> <ymin> <xmax> <ymax>
	cmd = ['gdal_rasterize', '-burn', '1', '-te', str(bounds[0]-0.008333333333), str(bounds[1]-0.008333333333), str(bounds[2]+0.008333333333), str(bounds[3]+0.008333333333), '-tr', str(raster_resolution[0]), str(raster_resolution[1]), input_shapefile, output_raster]
	subprocess.run(cmd)  	# Execute the command as a subprocess


def aggregate_raster(input_raster, output_raster):
	# Build the gdalwarp command
	cmd = ['gdalwarp', '-tap', '-tr', '0.008333333333', '0.008333333333', '-r', 'average', '-t_srs', 'EPSG:4326', '-dstnodata', '0', '-overwrite', input_raster, output_raster]
	# cmd = ['gdalwarp', '-crop_to_cutline', '-tr', '0.008333333333', '0.008333333333', '-r', 'average', '-t_srs', 'EPSG:4326', '-dstnodata', '0', '-overwrite', input_raster, output_raster]
	subprocess.run(cmd)  	# Execute the command as a subprocess
	

# /---------------------------------------------------------------------------#
#/  

# gdw_poly = gdw_poly.iloc[0:30]
# gdw_poly = gdw_poly.iloc[[27095]]


# Loop through
for index, row in gdw_poly.iterrows():
	print(index)
	geometry = row.geometry
	bounds = geometry.bounds
	#
	# Create a new GeoDataFrame with only the current row
	single_row_gdf = gpd.GeoDataFrame([row], geometry=[geometry], crs=gdw_poly.crs)
	#
	# Export the GeoDataFrame to a shapefile
	output_filename = f'./output/temp/row_{index}.shp'
	single_row_gdf.to_file(output_filename, driver='ESRI Shapefile')
	# Rasterize to 50m res
	# rasterize_shapefile(f'./output/temp/row_{index}.shp', f'./output/temp/row_{index}_50m.tif', (0.0004166667, 0.0004166667))
	rasterize_shapefile(f'./output/temp/row_{index}.shp', f'./output/temp/row_{index}_50m.tif', (0.0004166667, 0.0004166667), bounds)
	#
	# Run aggregate to 1km res
	aggregate_raster(f'./output/temp/row_{index}_50m.tif', f'./output/temp/1km/row_{index}_1km.tif')
	#
	# Delete all temp files
	for f in Path('./output/temp').glob("*"):
		if f.is_file():
			os.remove(f)


# /---------------------------------------------------------------------------
#/  ONCE ALL RESERVOIR LOOPS FINISHED MOSAIC ALL
input_dir = './output/temp/1km'
vrt_file =  'vrt_file.vrt'
output_raster = 'GDW_frac_1km.tif'
#
vrt_command = 'gdalbuildvrt ' + vrt_file + ' *.tif'
os.system('cd ' + input_dir + '; ' + vrt_command)

translate_cmd  = 'gdal_translate -a_srs EPSG:4326 -ot "Float32" -of GTiff -co "TILED=YES" -co "BIGTIFF=YES" -co "COMPRESS=LZW" -co "NUM_THREADS=ALL_CPUS" '+ vrt_file + ' ' + output_raster
		
os.system('cd ' + input_dir + '; ' + translate_cmd)

 
# # /---------------------------------------------------------------------------
# #/  Rasterize all reservoirs at 1km, with GWD_IDs

# if 1:
# 	def rasterize_shapefile(input_shapefile, output_raster):
# 		# Build the gdal_rasterize command
# 		# gdal="COMPRESS=LZW" 
# 		cmd = ['gdal_rasterize', 
# 			   '-at', '-tap', 
# 			   '-a', 'GDW_ID', 
# 			   '-co', "COMPRESS=LZW",
# 			   '-tr', str(0.008333333333), str(0.008333333333), 
# 			   input_shapefile, 
# 			   output_raster]
# 		subprocess.run(cmd)  	# Execute the command as a subprocess


# rasterize_shapefile('./data/GDW/GDW_v0_2_beta/GDW_v0_2_beta_shp/GDW_reservoirs_v0_2.shp',
# 					f'./output/GDW_reservoirs_v0_2_GDWIDs.tif')



# def rasterize_shapefile(input_shapefile, output_raster, raster_resolution):
# 	# Build the gdal_rasterize command
# 	cmd = ['gdal_rasterize', '-burn', '1', '-tr', str(raster_resolution[0]), str(raster_resolution[1]), input_shapefile, output_raster]
# 	subprocess.run(cmd)  	# Execute the command as a subprocess

