
# /----------------------------------------------------------------------------#
#/ 0. INITIALIZE                                                         --------

library(here); here()

source('data_proc/setup/import_libs.r')
source('plots/themes/map_raster_theme.r')
source('plots/themes/line_plot_theme.r')
source('plots/get_country_bbox_shp_for_ggplot_map.r')


# /----------------------------------------------------------------------------#
#/ 1A  PREP DATA FOR RIVER YIELD (IDEALIZED RIVER UNDER RESERVOIRS)   ----------


#  Prep national catch statistics
# Different versions based on merger of FAO and HCES (c1, c2, c3)
source('data_proc/riv_yield/read_fao_catch.r')

# Map of country-scale riverine catch; for all three estimates
source('plots/map_natcatch.r')

# prep predictions (run only once);  (slow on laptop); Only run once
# source('data_proc/prep_predictor_stack.r')
if (0) {source('data_proc/riv_fish_map/predictors/prep_predictor_stack_1km.r')}


# Aggregate reservoir and DOR rasters from Gunther from 500m to 1km
# Needed to prepare riverine predictor under reservoirs before replacing the values
source('data_proc/prep_riv_reserv_inputs/agg_reserv_dor_to1km.r')
source('data_proc/riv_yield/predictors/prep_glwdv2_wetland.r')

# Replace riverine predictors under reservoirs; to fix wetland and population
source('data_proc/riv_yield/predictors/replace_preds_under_reserv_gdw.r')


# /----------------------------------------------------------------------------#
#/ 1B   COMPUTE RIVER YIELD                                          -----------

# Prep the river basin polygons
source('data_proc/riv_yield/predictors/prep_train_rivbasin.r')

#/   Regression predict RIVERINE MAP!
# 3 equations: A: absW + Q; B: propW + Q; C: propW + Q + Pop
source('data_proc/riv_yield/regression/regression_riv_pred_1km_2024.r')

# Distribute catch over the predicted layer
source('data_proc/riv_yield/distrib_catch_2024.r')

# Compile the uncertainty members into a range
source('data_proc/riv_yield/compile_riv_uncert.r')

# Get pred and distrib river yield per training basins 
source('data_proc/riv_yield/get_train_basins_pred_distrib.r')


# /----------------------------------------------------------------------------#
#/ 2   COMPUTE RESERVOIR YIELD                                        ----------

if(0) {
  # Rasterize GDW reservoir polygons - This was done on Sherlock
  # See 'geospatial_hpc/rasterize_reservoirs.py
  
  # Postprocess raster
  source('data_proc/res_yield/postprocess_gdw_rast.r')}

# Prep reservoir yield data (from cs database) 
source('data_proc/res_yield/train_reserv_catch.r')

# Fit regression reservoir yield (incl. pop surrounding reservoirs)
source('data_proc/res_yield/calc_gdw_reservoir_yield_v2.r')


# /----------------------------------------------------------------------------#
#/ 3   CALC LOCAL LOSS (RIV minus RESERV YIELD)                         ----------

# Calculate the Reservoir Yield Loss
source('data_proc/yield_loss/calc_gdw_local_loss_2024.r')


# /----------------------------------------------------------------------------#
#/ 4  CALC DOWNSTREAM LOSS (RIV times DOR)                             ----------
# source('data_proc/yield_loss/calc_grand_downstream_loss.r')

# Recompute DOR with Global Dam Watch (GDW) data
source('data_proc/dor/calc_gdw_dor.r')

# Calculate losses from DOR
source('data_proc/yield_loss/calc_gdw_downstream_loss.r')



# /----------------------------------------------------------------------------#
#/ 5.  CALCULATE TOTALS - PER HYDROBASINS/COUNTRIES and GLOBAL

# QAQC sums of distrib catch 
# source('data_proc/riv_yield/output_qaqc_sums.r')
# source('data_proc/yield_loss/global_totals_losses.r')
source('data_proc/yield_loss/global_sums_qaqc_2024.r')


# For fig - Summarize by country and hydrobasins
source('data_proc/postprocess/summarize_country.r')
# Summarize per training river basins
source('data_proc/postprocess/E_summarize_bytrainingbasin.R')


# /----------------------------------------------------------------------------#
#/ 6. MAIN FIGURES                                                   ----------

# Fig.2 - Training res & riv maps and scatterplots
source('plots/fig2/fig2_train_multipanel.r')

# Fig.3 - Maps and histograms of riv and reserv yield
source('plots/fig3/fig3_yield_upscaled_multipanel.r')

# Fig.4 - Map of local losses & histogram
source('plots/fig4/fig4_reserv_localloss_multipanel.r')

# Fig.5 - Barplots of individual reservoir yield loss
source('plots/fig5/fig5_barplot_yieldloss_continent_and_reserv_2024.r')

# Fig.6 - Map DOR losses and DOR thresholds
source('plots/fig6/fig6_map_dor_ril.r')

# Fig.7 - HydroBASIN map of net change 
# Summarize fish yield losses per units (countries, basins)
source('plots/fig7/fig7_map_loss_perhydrobasin.r')

# Fig.8 - Plot Reservoir size VS local losses 
source('plots/sifig/barplot_yield_change_perarea.r')


# /----------------------------------------------------------------------------#
#/ 7. SI FIGURES                                                      ----------

# Fig. SN - Map difference between lm2c lm11c distrib maps; Q-only model VS Q+pop+wet% model
source('plots/sifig/map_riv_catch_lm2c_lm11b.r')

# Fig. SN: Plot scatter of reserv vs river yield
source('plots/sifig/scatterplot_riv_res_yield.r')

# SI PLOT - cumulative distributions for selected countries
# source('plots/distribution_plots_countries.r')


# /----------------------------------------------------------------------------#
#/ 8. PREP DATASET FOR ZENODO                                         ----------

# Prepare datasets for repository
source('data_proc/postprocess/prep_data_toshare.r')


