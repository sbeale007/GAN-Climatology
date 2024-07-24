library(terra)
library(data.table)
library(leaflet)
library(RColorBrewer)
library(ranger)
library(rworldmap)

dem <- rast("C:/Users/SBEALE/Desktop/Cropped_Coarsened_WRF_PRISM/no_overlap/DEM.nc")

# pred_wrf <- rast('C:/Users/SBEALE/Desktop/Gan Predictions/prec/wrf/march_nonan_bc/GAN_prec_bc_march_nonan_gen250.tif')
# pred_wrfextra <- rast('C:/Users/SBEALE/Desktop/Gan Predictions/prec/wrf/march_nonan_extracov/GAN_prec_extracov_march_gen250.tif')
# pred_wrf_ns <- rast('C:/Users/SBEALE/Desktop/Gan Predictions/prec/wrf/north_south_train/GAN_prec_march_nonan_wrf_gen250.tif')
# pred_wc <- rast('C:/Users/SBEALE/Desktop/Gan Predictions/prec/worldclim/march_nonan_bc/GAN_prec_march_nonan_worldclim_gen250.tif')
# pred_wc_ns <- rast('C:/Users/SBEALE/Desktop/Gan Predictions/prec/worldclim/north_south_train_replace_w_wrf/GAN_prec_north_south_train_wc_gen250.tif')

# load the PRISM  data for the variable
prism <- rast('C:/Users/SBEALE/Desktop/Cropped_Coarsened_WRF_PRISM/tmax_03_PRISM.nc')
# 
wc <- rast("C:/Users/SBEALE/Desktop/Cropped_Coarsened_WRF_PRISM/no_overlap/correct/tmax_03_WorldClim_coarse_focal.nc")
wc <- project(wc, prism)
# 
# wrf <- rast('C:/Users/SBEALE/Desktop/Cropped_Coarsened_WRF_PRISM/no_overlap/tmin_03_WRF_coarse.nc')
# wrf <- project(wrf, prism)
# 
daymet <- rast('//objectstore2.nrs.bcgov/ffec/Climatologies/Daymet/daymet_1981_2010_tmax_03.tif')
daymet <- project(daymet, prism)

# pred_wrf <- project(pred_wrf, prism)
# pred_wrfextra <- project(pred_wrfextra, prism)
# pred_wrf_ns <- project(pred_wrf_ns, prism)
# pred_wc <- project(pred_wc, prism)

# color scheme
# combined <- c(values(prism), values(pred_wrf), values(pred_wrfextra), values(pred_wrf_ns), values(pred_wc))
combined <- c(values(prism), values(wc), values(daymet))
combined <- combined[is.finite(combined)]
inc=diff(range(combined))/500
breaks=seq(quantile(combined, 0.005)-inc, quantile(combined, 0.995)+inc, inc)
ColScheme <- colorRampPalette(rev(brewer.pal(11, "RdYlBu")))(length(breaks)-1)
ColPal <- colorBin(ColScheme, bins=breaks, na.color = "white")
ColPal.raster <- colorBin(ColScheme, bins=breaks, na.color = "transparent")


# leaflet map
map <- leaflet() %>%
  addTiles(group = "basemap") %>%
  addProviderTiles('Esri.WorldImagery', group = "sat photo") %>%
  addRasterImage(prism, colors = ColPal.raster, opacity = 1, maxBytes = 7 * 1024 * 1024 , group = "PRISM") %>%
  # addRasterImage(wrf, colors = ColPal.raster, opacity = 1, maxBytes = 7 * 1024 * 1024 , group = "WRF") %>%
  addRasterImage(wc, colors = ColPal.raster, opacity = 1, maxBytes = 7 * 1024 * 1024 , group = "WorldClim") %>%
  addRasterImage(daymet, colors = ColPal.raster, opacity = 1, maxBytes = 7 * 1024 * 1024 , group = "Daymet") %>%
  # addRasterImage(pred_wrf, colors = ColPal.raster, opacity = 1, maxBytes = 7 * 1024 * 1024 , group = "GAN WRF") %>%
  # addRasterImage(pred_wrfextra, colors = ColPal.raster, opacity = 1, maxBytes = 7 * 1024 * 1024 , group = "GAN WRF Extra Covariates") %>%
  # addRasterImage(pred_wrf_ns, colors = ColPal.raster, opacity = 1, maxBytes = 7 * 1024 * 1024 , group = "GAN North + South Train") %>%
  # addRasterImage(pred_wc, colors = ColPal.raster, opacity = 1, maxBytes = 7 * 1024 * 1024 , group = "GAN WorldClim") %>%
  # addRasterImage(pred_wc_ns, colors = ColPal.raster, opacity = 1, maxBytes = 7 * 1024 * 1024 , group = "GAN WorldClim North + South Train") %>%
  addLayersControl(  
    overlayGroups = c("PRISM", "WorldClim", "Daymet"),
    options = layersControlOptions(collapsed = FALSE)
  )
map