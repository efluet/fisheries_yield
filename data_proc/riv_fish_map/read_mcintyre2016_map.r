library('raster')


# read grids
fnl_catch <- raster('../data/mcintyre2016map/grids/fnl_catch.tif')
logfnl_catch <- raster('../data/mcintyre2016map/grids/logfnl_catch.tif')
ntre_fnlcatch <- raster('../data/mcintyre2016map/grids/ntre_fnlcatch.tif')



fnl_catch_sum <- cellStats(fnl_catch, stat='sum', na.rm=TRUE)
fnl_catch_sum / 10^6

ntre_fnlcatch_sum <- cellStats(ntre_fnlcatch, stat='sum', na.rm=TRUE)
ntre_fnlcatch_sum / 10^6
