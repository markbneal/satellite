#testing rgee, Google Earth Engine
# https://github.com/r-spatial/rgee

# Get installation working ####-------------------------------------------------------------

#install.packages("rgee")
#devtools::install_github("https://github.com/r-spatial/rgee")

library(rgee)

#ee_Initialize()

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

#ee_install()

#ee_check()

# note: I updated conda as per instructions.
# I also skipped using ee_check(), a possible issue.

#after forced shutdown of processing, some issues

# Quick Demo
# 1. Compute the trend of night-time lights (JS version) ####-----------------------------------------

ee_Initialize()
# #above didn't work
# ee_install()
# #ther restart r session
# library(rgee)
# ee_clean_pyenv()
# #may need to restart rstudio, not just r session as recommended
# ee_install()
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

mask <- NZ %>% 
  sf_as_ee()

# The demo (Arequipa region of Peru) 
# mask <- system.file("shp/arequipa.shp", package = "rgee") %>% 
#   st_read(quiet = TRUE) %>% 
#   sf_as_ee()


region <- mask$geometry()$bounds()

col <- ee$ImageCollection('MODIS/006/MOD13A2')$select('NDVI')

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

visParams = list(
  min = 0.0,
  max = 9000.0,
  bands = "NDVI_median",
  palette = c(
    'FFFFFF', 'CE7E45', 'DF923D', 'F1B555', 'FCD163', '99B718', '74A901',
    '66A000', '529400', '3E8601', '207401', '056201', '004C00', '023B01',
    '012E01', '011D01', '011301'
  )
)

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

