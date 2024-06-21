library(terra)
library(data.table)
library(leaflet)
library(RColorBrewer)
library(ranger)
library(rworldmap)

pred230 <- rast('//objectstore2.nrs.bcgov/ffec/Mosaic_Yukon/GAN_Preds_June21_stand_gen230_large.tif')
pred110 <- rast('//objectstore2.nrs.bcgov/ffec/Mosaic_Yukon/GAN_Preds_June21_stand_gen110_large.tif')
dem <- rast("C:/Users/SBEALE/Desktop/Cropped_WRF_PRISM/DEM.nc")
# pred <- (pred*2.575667) + (-1.4281803)
plot(pred230)

# load the BC PRISM  data for the variable
prism.bc <- rast('//objectstore2.nrs.bcgov/ffec/Climatologies/PRISM_BC/tmax_monClim_PRISM_historical_198101-201012_3.tif')
prism.bc <- project(prism.bc, dem)
plot(prism.bc)

pred230 <- project(pred230, prism.bc)
pred110 <- project(pred110, prism.bc)

# # load the AK PRISM  data for the variable
# prism.ak <- rast('//objectstore2.nrs.bcgov/ffec/Climatologies/PRISM_AK/ak_tmax_1981_2010.03.asc')
# prism.ak <- project(prism.ak, dem)
# plot(prism.ak)

# color scheme
combined <- c(values(prism.bc), values(pred230), values(pred110))
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
  addRasterImage(prism.bc, colors = ColPal.raster, opacity = 1, maxBytes = 7 * 1024 * 1024, group = "BC PRISM") %>%
  addRasterImage(pred230, colors = ColPal.raster, opacity = 1, maxBytes = 7 * 1024 * 1024, group = "GAN 230") %>%
  addRasterImage(pred110, colors = ColPal.raster, opacity = 1, maxBytes = 7 * 1024 * 1024, group = "GAN 110") %>%
  addLayersControl(
    overlayGroups = c("BC PRISM", "GAN 230", "GAN 110"),
    options = layersControlOptions(collapsed = FALSE)
  )
map