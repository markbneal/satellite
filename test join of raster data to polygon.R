# test the join of raster data (NDVI) to polygons (paddocks)
#starting from examples
# https://geocompr.robinlovelace.net/raster-vector.html

# load packages
library(dplyr)
library(terra)
library(sf)

srtm = rast(system.file("raster/srtm.tif", package = "spDataLarge"))
class(srtm)
zion = read_sf(system.file("vector/zion.gpkg", package = "spDataLarge"))
zion = st_transform(zion, crs(srtm))


plot(srtm)
plot(zion)

zion_vect = vect(zion)
srtm_cropped = crop(srtm, zion_vect)

zion_srtm_values = terra::extract(x = srtm, y = zion_vect)

class(zion_srtm_values)

