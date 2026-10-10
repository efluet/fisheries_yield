
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


# /---------------------------------------------------------------------------
#/  Rasterize fractional 
pd.set_option('display.max_columns', 10)

gdw_pt = gpd.read_file('./data/GDW/GDW_v0_2_beta/GDW_v0_2_beta_shp/GDW_barriers_v0_2.shp')
gdw_pt = gdw_pt.iloc[:,[0,1,2,3,5,13,15,20,25,30,36,64]]

# CAP_MCM: Representative maximum storage capacity of reservoir in million cubic meters; consolidated from other ‘Cap’ columns in the following order of priority: ‘Cap_max’ over ‘Cap_rep’ over ‘Cap_min’; exceptions apply if value in ‘Cap_max’ column seems unreliable or rounded; if no capacity was reported, it was estimated using statistical approaches (see section 2.7); see also notes below
# Cap_max; Reported ‘maximum storage capacity’ in million cubic meters; see notes below
# DOR_PC: Degree of Regulation (DOR) in percent; equivalent to “residence time” of water in the reservoir; calculated as ratio between storage capacity (‘Cap_mcm’) and total annual flow (derived from ‘Dis_avg_ls’); 
# values capped at 10,000 indicate exceedingly high values, which may be due to inconsistencies in the data and/or incorrect allocation to the river network and the associated discharges

# Filter lakes by attributes
gdw_pt = gdw_pt[gdw_pt.AREA_SKM >= 0.1]
gdw_pt = gdw_pt[gdw_pt.LAKE_CTRL.isnull()]
gdw_pt = gdw_pt[(gdw_pt.TIMELINE.isnull()) | (gdw_pt['TIMELINE']=='Modified')]

# Save subset of barriers to file
gdw_pt.to_file('./output/GDW_v0_2_beta_barriers_filt', driver='ESRI Shapefile')



# /---------------------------------------------------------------------------
#/ Declare function that rasterizes points; Build the gdal_rasterize command; 	#
def rasterize_shapefile(input_shapefile, output_raster):
	cmd = [ 'gdal_rasterize', 
			'-at', '-tap', 
			'-a', 'CAP_MCM', 
			'-a_nodata', '0',
			'-co', "COMPRESS=LZW",
			'-te', str(-180), str(-56), str(180), str(84),  # xmin, ymin, xmax, ymax 
			'-tr', str(0.008333333333), str(0.008333333333), 
			'-ts', str(43200), str(16800),  # Number of columns, number of rows
			'-ot', 'Float32',  # Output data type (Byte)
			input_shapefile, 
			output_raster]
	#
	subprocess.run(cmd)  	# Execute the command as a subprocess


rasterize_shapefile('./output/GDW_v0_2_beta_barriers_filt/GDW_v0_2_beta_barriers_filt.shp',
					'./output/GDW_v0_2_beta_barriers_filt_v2.tif')

