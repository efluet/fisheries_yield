# Unzip the different directions


# Convert the GDW points to raster using storage volume as pixel value


# flow accumulation
import pysheds

# Instantiate grid from raster
grid = Grid.from_raster('./data/dem.tif')
dem = grid.read_raster('./data/dem.tif')

# Resolve flats and compute flow directions
inflated_dem = grid.resolve_flats(dem)
fdir = grid.flowdir(inflated_dem)


# fdir= '/home/groups/robertj2/reserv_fish/data/hydrosheds/hyd_eu_dir_30s.tif'
# acc = grid.accumulation(fdir, dirmap=dirmap)# , weight)


from pysheds.grid import Grid

# Instantiate grid from raster
grid = Grid.from_raster('/home/groups/robertj2/reserv_fish/data/hydrosheds/hyd_eu_dir_30s.tif')
dem = Grid.read_raster('/home/groups/robertj2/reserv_fish/data/hydrosheds/hyd_eu_dir_30s.tif')

# Resolve flats and compute flow directions
inflated_dem = grid.resolve_flats(dem)
fdir = grid.flowdir(inflated_dem)
Computing accumulation
Accumulation is computed using the grid.accumulation method.

# Compute accumulation
acc = grid.accumulation(fdir)



#-------------------------------------------
# If the pointer file contains ESRI flow direction values instead, the --esri_pntr parameter must be specified.
import whitebox



def accumulate_upstream_runoff(flow_direction_raster, runoff_raster, output_raster):
    # Create an instance of the WhiteboxTools tool
    wbt = whitebox.WhiteboxTools()

    # Run the D8FlowAccumulation tool
    # wbt.d8_flow_accumulation(
    #     flow_direction_raster,
    #     runoff_raster,
    #     output_raster
    		esri_pntr=False, 
    # )



    print(f"Upstream runoff accumulation saved to {output_raster}")

# Usage example
flow_direction_raster = "flow_direction.tif"  # Replace with the path to your flow direction raster
runoff_raster = "runoff.tif"  # Replace with the path to your runoff raster
output_raster = "upstream_accumulation.tif"  # Replace with the desired output path and filename

accumulate_upstream_runoff(flow_direction_raster, runoff_raster, output_raster)


    # wbt.d8_flow_accumulation(
	# 	i, 
	# 	output, 
	# 	out_type="cells", 
	# 	log=False, 
	# 	clip=False, 
	# 	pntr=False, 
	# 	esri_pntr=False, 
	# 	callback=default_callback
	# )