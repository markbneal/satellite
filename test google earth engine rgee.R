#testing rgee, Google Earth Engine
# https://github.com/r-spatial/rgee

# Get installation working ####-------------------------------------------------------------

#install.packages("rgee")
devtools::install_github("https://github.com/r-spatial/rgee")
#install.packages("magrittr")

library(rgee)

## Notes from install on laptop ####

 ee_Initialize() #one off, first time use

# Welcome to the Earth Engine client library for R!
#   ---
#   It seems it is your first time using rgee. First off, keep in mind that
# Google Earth Engine is only available to registered users, check the
# official website https://earthengine.google.com/ to get more information.
# Before start coding is necessary to set up a Python environment. Run
# rgee::ee_install() to set up automatically, after that, restart the R
# session to see changes. See more than 250+ examples of rgee at
# https://csaybar.github.io/rgee-examples/
#   
#   Would you like to stop to receive this message? [Y/n]: y
# Error in ee_connect_to_py(ee_current_version, n = 5) : 
#   The current Python PATH: C:/Users/nealm/AppData/Local/r-miniconda/envs/r-reticulate/python.exe
# does not have the earthengine-api installed. Are you restarted/terminated your R session?.
# If no, please try:
#   > ee_install(): To create and set a Python environment with all rgee dependencies.

ee_install()

Yee_clean_pyenv() 
ee_check()
<<<<<<< HEAD
ee_check_python()
ee_check_credentials()
=======
ee_install_upgrade()
reticulate::py_install('earthengine-api==0.1.235')

# NOTE: The Earth Engine Python API version 0.1.243 is installed
# correctly in the system but rgee was tested using the version
# 0.1.235. To avoid possible issues, we recommend install the
# version used by rgee (0.1.235). You might use:
#   * rgee::ee_install_upgrade()
# * reticulate::py_install('earthengine-api==0.1.235')
# * pip install earthengine-api==0.1.235 (Linux and Mac0S)
# * conda install earthengine-api==0.1.235 (Linux, Mac0S, and Windows)

# note: I updated conda as per instructions.
# I also skipped using ee_check(), a possible issue.

#after forced shutdown of processing, some issues

## notes from Install on workbench ####

ee_Initialize() #one off, first time use

# Preparing transaction: ...working... done
# Verifying transaction: ...working... done
# Executing transaction: ...working... done
# Would you like to stop to receive this message? [Y/n]:n
# Error in ee_connect_to_py(path = ee_current_version, n = 5) : 
#   The current Python PATH: /home/nealm@dexcel.co.nz/.local/share/r-miniconda/envs/r-reticulate/bin/python
# does not have the Python package "earthengine-api" installed. Are you restarted/terminated.
# your R session after install miniconda or run ee_install()?
#   If no do it, please try again:
#   > ee_install(): To create and set a Python environment with all rgee dependencies.
# > ee_install_set_pyenv(): To set a specific Python environment.

#ee_install() # restarted R and workbench session befre this, looks like it worked

# Well done! rgee has been successfully installed on your system.
# You need restart R to see changes (Windows users must terminate R!). After that, we recommend
# running ee_check() to perform a full check of all non-R rgee dependencies.
# Do you want restart your R session? 

#ee_check()

# > ee_check()
# ◉  Python version
# ✔ [Ok] /home/nealm@dexcel.co.nz/.virtualenvs/rgee/bin/python v3.8
# ✔ [X] earthengine-api not installed

# advice: https://github.com/r-spatial/rgee/issues/91
#rgee::ee_install_upgrade()

ee_check()
# > ee_check()
# ◉  Python version
# ✔ [Ok] /home/nealm@dexcel.co.nz/.virtualenvs/rgee/bin/python v3.8
# ✔ [X] numpy not installed

library(reticulate)
py_config()

# To install gcloud, as recommended by ee_check(), but without admin permissions, I uses this other package

install.packages("cloudml")
library(cloudml)
gcloud_install()
library(cloudml)
cloudml_train("train.R")

# However, there is no browser to login, so you need to do without
# https://github.com/rstudio/cloudml/issues/191
# in terminal:
# gcloud auth login --no-launch-browser



# install.packages("cloudml")


# Quick Demo
# 1. Compute the trend of night-time lights (JS version) ####-----------------------------------------

ee_Initialize()
# #above didn't work
# ee_install()
# #ther restart r session
# library(rgee)
# ee_clean_pyenv()
# #may need to restart rstudio, not just r session as recommended
 ee_install()
# #restarting rstudio, just to be safe!

createTimeBand <-function(img) {
  year <- ee$Date(img$get('system:time_start'))$get('year')$subtract(1991L)
  ee$Image(year)$byte()$addBands(img)
}

createTimeBand <-function(img) {
  year <- ee$Date(img$get('system:time_start'))$get('year')$subtract(1991L)
  ee$Image(year)$byte()$addBands(img)
}

collection <- ee$
  ImageCollection('NOAA/DMSP-OLS/NIGHTTIME_LIGHTS')$
  select('stable_lights')$
  map(createTimeBand)

col_reduce <- collection$reduce(ee$Reducer$linearFit())
col_reduce <- col_reduce$addBands(
  col_reduce$select('scale'))
ee_print(col_reduce)


Map$setCenter(9.08203, 47.39835, 3)
Map$addLayer(
  eeObject = col_reduce,
  visParams = list(
    bands = c("scale", "offset", "scale"),
    min = 0,
    max = c(0.18, 20, -0.18)
  ),
  name = "stable lights trend"
)


# 3. Create an NDVI-animation (JS version) ####---------------------------------------------

library(tidyverse)
library(sf)
library(geojsonsf)

NZ <- st_read("NZL_adm0.shp")
#plot(NZ, max.plot=1)
# ggplot(NZ)+
#   geom_sf() #Chatham Islands!

ggplot(NZ)+
  geom_sf()+ 
  coord_sf(xlim = c(166,179), ylim = c(-48,-33)) #without Chatham Islands!

NZ <- st_crop(NZ, xmin=166, xmax=179, ymin=-48, ymax=-33)
# NZ <- st_transform(NZ, 54032) #azimuthal equidistant # https://stackoverflow.com/a/60008553/4927395
# NZ <- st_simplify(NZ, dTolerance=10000)
# NZ <- st_transform(NZ, 4326) 
NZ <- st_simplify(NZ, dTolerance=0.05)


ggplot(NZ)+
  geom_sf() 

# mask <- NZ %>% 
#   sf_as_ee()

research_farm_aoi <- readRDS("research_farm_aoi.RDS")
class(research_farm_aoi)
research_farm_aoi_sf <- st_sf(research_farm_aoi)
#research_farm <- sf_geojson(research_farm_aoi_sf)


ggplot(research_farm_aoi_sf)+
  geom_sf() 

mask <- research_farm_aoi_sf %>% 
  sf_as_ee()

# The demo (Arequipa region of Peru) #for original example with NDVI
# mask <- system.file("shp/arequipa.shp", package = "rgee") %>% 
#   st_read(quiet = TRUE) %>% 
#   sf_as_ee() 


region <- mask$geometry()$bounds()

#col <- ee$ImageCollection('MODIS/006/MOD13A2')$select('NDVI')  #for original example with NDVI
col <- ee$ImageCollection('COPERNICUS/S2_SR') # from "example true colour..."

col <- col$map(function(img) {
  doy <- ee$Date(img$get('system:time_start'))$getRelative('day', 'year')
  img$set('doy', doy)
})

distinctDOY <- col$filterDate('2018-11-30', '2020-11-30')

filter <- ee$Filter$equals(leftField = 'doy', rightField = 'doy');


join <- ee$Join$saveAll('doy_matches')
joinCol <- ee$ImageCollection(join$apply(distinctDOY, col, filter))

comp <- joinCol$map(function(img) {
  doyCol = ee$ImageCollection$fromImages(
    img$get('doy_matches')
  )
  doyCol$reduce(ee$Reducer$median())
})

# visParams = list(
#   min = 0.0,
#   max = 9000.0,
#   bands = "NDVI_median",
#   palette = c(
#     'FFFFFF', 'CE7E45', 'DF923D', 'F1B555', 'FCD163', '99B718', '74A901',
#     '66A000', '529400', '3E8601', '207401', '056201', '004C00', '023B01',
#     '012E01', '011D01', '011301'
#   )
# )  #for original example with NDVI

visParams <- list(bands = c("B4", "B3", "B2"),min = 100,max = 8000,gamma = c(1.9,1.7,1.7)) # from "example true colour..."

rgbVis <- comp$map(function(img) {
  do.call(img$visualize, visParams) %>% 
    ee$Image$clip(mask)
})

gifParams <- list(
  region = region,
  dimensions = 600,
  crs = 'EPSG:3857',
  framesPerSecond = 6
)

print(rgbVis$getVideoThumbURL(gifParams))

browseURL(rgbVis$getVideoThumbURL(gifParams))

# Simple map display ####-----------------------------------------------------------
# https://github.com/r-spatial/rgee/blob/examples/GetStarted/02_simple_mapdisplay.R

library(rgee)
# ee_reattach() # reattach ee as a reserved word

ee_Initialize()

# Load an image.
image <- ee$Image("LANDSAT/LC08/C01/T1/LC08_044034_20140318")

# Display the image.
Map$centerObject(image)
Map$addLayer(image, name = "Landsat 8 original image")

# Define visualization parameters in an object literal.
vizParams <- list(
  bands = c("B5", "B4", "B3"),
  min = 5000, max = 15000, gamma = 1.3
)

# complete simple example from rgee github ####------------------------------
# https://github.com/r-spatial/rgee/blob/examples/GetStarted/09_a_complete_example.R

library(rgee)
# ee_reattach() # reattach ee as a reserved word

ee_Initialize()

# This function gets NDVI from Landsat 8 imagery.
addNDVI <- function(image) {
  return(image$addBands(image$normalizedDifference(c("B5", "B4"))))
}

# This function masks cloudy pixels.
cloudMask <- function(image) {
  clouds <- ee$Algorithms$Landsat$simpleCloudScore(image)$select("cloud")
  return(image$updateMask(clouds$lt(10)))
}

# Load a Landsat collection, map the NDVI and cloud masking functions over it.
collection <- ee$ImageCollection("LANDSAT/LC08/C01/T1_TOA")$
  filterBounds(ee$Geometry$Point(c(-122.262, 37.8719)))$
  filterDate("2014-03-01", "2014-05-31")$
  map(addNDVI)$
  map(cloudMask)

# Reduce the collection to the mean of each pixel and display.
meanImage <- collection$reduce(ee$Reducer$mean())
vizParams <- list(
  bands = c("B5_mean", "B4_mean", "B3_mean"),
  min = 0,
  max = 0.5
)

Map$addLayer(
  eeObject = meanImage,
  visParams = vizParams,
  name = "mean"
)

# Load a region in which to compute the mean and display it.
counties <- ee$FeatureCollection("TIGER/2016/Counties")
santaClara <- ee$Feature(counties$filter(
  ee$Filter$eq("NAME", "Santa Clara")
)$first())

Map$addLayer(
  eeObject = santaClara,
  visParams = list(palette = "yellow"),
  name = "Santa Clara"
)

# Get the mean of NDVI in the region.
mean <- meanImage$select("nd_mean")$reduceRegion(
  reducer = ee$Reducer$mean(),
  geometry = santaClara$geometry(),
  scale = 30
)
mean$get("nd_mean")$getInfo()

# Print mean NDVI for the region.
cat("Santa Clara spring mean NDVI:", mean$get("nd_mean")$getInfo())
Map$addLayer(image, vizParams, "Landsat 8 False color")

# Use Map to add features and feature collections to the map. For example,
counties <- ee$FeatureCollection("TIGER/2016/Counties")

Map$addLayer(
  eeObject = counties,
  visParams = vizParams,
  name = "counties"
)


#example true colour image with Sentinel 2 ####---------------------------------
#example from amazeone.com.br/barebra/pandora/rgeebookT1eng.pdf
#html downloaded in this file - not clear of authorship
#cache downloaded as html
#brazil backcountry
# long <-  -44.366
# lat <-  -17.69

#Research Farms
long <- 175.35
lat <- -37.77

col <- ee$ImageCollection('COPERNICUS/S2_SR')

point <- ee$Geometry$Point(long,lat) #-37.77,175.35
start <- ee$Date("2020-01-11")
end <- ee$Date("2020-11-20")
filter <- col$filterBounds(point)$filterDate(start,end)
img <- filter$first()

#Creating the visualization parameter list by listing the bands used,gamma correction for each band, minimum and maximum values used.
# RGB Visible
vPar <- list(bands = c("B4", "B3", "B2"),min = 100,max = 8000,gamma = c(1.9,1.7,1.7))

#Finally we define the center of the map coordinates and the map scalebefore plotting the map with the predefined parameter.
Map$setCenter(long,lat, zoom = 14)
Map$addLayer(img, vPar, "True Color Image")

