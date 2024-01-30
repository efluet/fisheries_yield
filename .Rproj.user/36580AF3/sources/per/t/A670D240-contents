
# TODO: Oct 2023: 
#     - Reproduce global counts of GDW reserv and downstream
#     - Plot different threshold of DOR
#     - Do rivers need replacing under GDW reservoirs; this was done for GRaND reservoirs.


# TODO: 2023: Rerun riv fisheries under GDW reservoirs
# TODO: 2023: Recompute reservoir yield for GDW
# TODO: Compare map to previous one from McIntyre et Al
# TODO: Compare predictions of catch distrib to training data
# TODO: Make consistent lake mask (or lakes excluded.)
# TODO: Replace basin catch CSV I'm using; replace with Cathy's for consistency.
# TODO: Are there more river basins in Lymer's DB?
# TODO:     Why is Pearl missing? It's not in the PNAS paper, but I had it among basins...
# TODO:     Fix basin outlines to include deltas... instead use tiles?
# TODO: USe Cooke 2017 - recreational catch?


# Etienne’s to do (Jan 6 2022):
# A - Get the right updated riverine catch; use the HCES catch estimates
# B - Reservoir catch:  We have it!  (B in fig 1)
# C - Recompute the riverine – reservoir (panel C in Fig 1)
# D – Check the DOR rivers from Guenther’s data; rasterize it; recalculate riverine losses from the new riverine map.


# /----------------------------------------------------------------------------#
#/   INITIALIZE                                                         --------

library(here); here()

source('data_proc/import_libs.r')
source('plots/themes/map_raster_theme.r')
source('plots/themes/line_plot_theme.r')
source('plots/get_country_bbox_shp_for_ggplot_map.r')
m='lm2c'; c='catch.c2'
library(cowplot)


# /----------------------------------------------------------------------------#
#/   PREP DATA FOR RIVER YIELD (IDEALIZED RIVER UNDER RESERVOIRS)       ----------


#  Prep catch statistics (c1, c2, c3)
source('data_proc/riv_fish_map/read_fao_catch.r')

#/ Map of country-scale riverine catch; for all three estimates
source('plots/riv_fish_map/map_natcatch.r')

# prep predictions (run only once);  (slow on laptop); Only run once
# source('data_proc/prep_predictor_stack.r')
if (0) {source('data_proc/riv_fish_map/prep_predictor_stack_1km.r')}


# Aggregate reservoir and DOR rasters from Gunther from 500m to 1km
# Needed to prepare riverine predictor under reservoirs before replacing the values
source('data_proc/prep_riv_reserv_inputs/agg_reserv_dor_to1km.r')
# Replace riverine predictors under reservoirs; to fix wetland and population
source('data_proc/prep_riv_reserv_inputs/replace_preds_under_reserv.r')

# This is the old prediction preparation; for present-day river conditions
# source('data_proc/riv_fish_map/regression_pred.r')


# /----------------------------------------------------------------------------#
#/   CALC RIVER YIELD                                                   --------

#/   Regression predict
# 3 equations: A: absW + Q; B: propW + Q; C: propW + Q + Pop
# Am I correct in understanding that PropWetland and AbsWetland  are both log10 transformed?
# Loop through model # THIS IS WHAT RUNS THE MAPPING!!!!
source('data_proc/riv_fish_map/regression_riv_pred_1km.r')

# This is replaced by new functions
# source('data_proc/riv_fish_map/prep_distrib_catch_grid.r')

# PLOT - cumulative distributions for selected countries
source('plots/distribution_plots_countries.r')

# QAQC sums of distrib catch 
source('data_proc/riv_fish_map/output_qaqc_sums.r')

# PLOT - Map difference between lm2c lm11c distrib maps; Q-only model VS Q+pop+wet% model
source('plots/map_riv_catch_lm2c_lm11b.r')



# /----------------------------------------------------------------------------#
#/   CALC RESERV YIELD                                               ----------

# Run yield regression models for tropical and temperate reservoirs from NRRP & other data 
source('data_proc/reservoir_yield/cs_reserv_catch_prep.r')

# Rasterize dams - This was done on Sherlock

# Calculate reservoir yield
source('data_proc/reservoir_yield/calc_gdw_reservoir_yield.r')


# /----------------------------------------------------------------------------#
#/   CALC LOCAL LOSS (RIV minus RESERV YIELD)                         ----------

# Calculate the Reservoir Yield Loss
source('data_proc/yield_loss/calc_grand_local_loss.r')
source('data_proc/yield_loss/calc_gdw_local_loss.r')


# /----------------------------------------------------------------------------#
#/   CALC DOWNSTREAM LOSS (RIV times DOR)                             ----------
# source('data_proc/yield_loss/calc_grand_downstream_loss.r')

# Recompute DOR with Global Dam Watch (GDW) data
source('data_proc/gdw_dor/calc_gdw_dor.r')

# Calculate losses from DOR
source('data_proc/yield_loss/calc_gdw_downstream_loss.r')



# /----------------------------------------------------------------------------#
#/   Calculate GLOBAL TOTALS
source('data_proc/global_totals_losses.R')
# For fig - summarize by country and hydrobasin
source('data_proc/yield_loss/summarize_perunits.r')

# /----------------------------------------------------------------------------#
#/   PLOTS                                                            ----------

# FIGURE 2 - maps and histograms of riv and reserv yield
source('plots/fig2_abcd.r')

# Fig.3 - Map of local reservoir losses & histogram
# source('plots/map_reserv_rel.r')
source('plots/fig3_map_gdw_reserv_localloss.r')

# Fig.4 - Barplots of yield loss per reserv
source('plots/barplot_yieldloss_continent_and_reserv.r')

# Fig.5 - Map DOR losses
source('plots/map_dor_ril.r')

# Fig.6 - HydroBASIN map of net change 
# Summarize fish yield losses per units (countries, basins)
source('plots/map_loss_perhydrobasin.r')




# TODO: SI Fig. of DOR threshold vs DOR losses
source('plots/lineplot_dor_thresh.r')

# TODO: Plot Reservoir size VS local losses 
source('plots/barplot_yield_change_perarea.r')







# /----------------------------------------------------------------------------#
#/    

# Postprocessing: 
# Extract A,B,C per reservoir footprint (n~6k)
# Calculate sums of A,B,C,D per:  countries, basins, continents.
# Send these tables to Cathy (for Fig 3 & 6)

# Etienne redoes: Fig 2. + recaption;  Fig. 4  and Fig.5
# Check if there is paper on diadromy range;map?

# Insert riverine map methods?  Link to draft: https://docs.google.com/document/d/1ltJm3XRIPArgFG4vuJTctHTGvhKwGvrhikFKr4BANcw/edit?usp=sharing

# Notes to get Riverine fisheries for each reservoir:
# Only once: Aggregate res_mask_percent1 to 1km; summing the percentages

# Multiple res_mask_percent1_1km with the riverine catch raster

# Extract masked riv catch over per reservoir using polygons
# fromCathy/EFC/grand_poly_yields$Reservoir 

# Calculate the difference in fish yield
