import zipfile
import os

def unzip_all_files(folder_path):  
    file_list = os.listdir(folder_path)     # Get a list of all files in the folder
    for file_name in file_list: # Iterate over the files
        if file_name.endswith('.zip'):
            # Create the full file path
            file_path = os.path.join(folder_path, file_name)
            # Extract the zip file
            with zipfile.ZipFile(file_path, 'r') as zip_ref:
                zip_ref.extractall(folder_path)
            print(f"Extracted: {file_name}")

# Usage example
folder_path = './data/hydrosheds'  # Replace with the path to your folder containing the zip files

unzip_all_files(folder_path)



# /---------------------------------------------------
#/  Mosaic all Flo Dir parts

input_dir = './data/hydrosheds'
vrt_file =  'vrt_file.vrt'
output_raster = 'hyd_global_dir_30s.tif'
#
vrt_command = 'gdalbuildvrt ' + vrt_file + ' *.tif'
os.system('cd ' + input_dir + '; ' + vrt_command)

# translate_cmd= 'gdal_translate ' + vrt_file + ' ' + output_raster
translate_cmd  = 'gdal_translate -a_srs EPSG:4326 -ot "Float32" -of GTiff -co "TILED=YES" -co "BIGTIFF=YES" -co "COMPRESS=LZW" -co "NUM_THREADS=ALL_CPUS" '+ vrt_file + ' ' + output_raster
        
os.system('cd ' + input_dir + '; ' + translate_cmd)

