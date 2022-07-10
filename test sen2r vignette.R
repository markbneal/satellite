# test sen2r vignette
# http://sen2r.ranghetti.info/articles/sen2r_cmd.html

# note, some code commented out as redundant, because from vignette,
# other code commented ou for speed or was for testing


# remotes::install_github("ranghetti/sen2r")

# installed updates of all cran packages first, was a pain, but the worked
# then restarting R session
library(tidyverse)
library(lubridate)
library(forcats)
library(ggsflabel)


library(sf)
#install.packages("geojsonsf")
library(geojsonsf)
#install.packages("RCurl")
library(RCurl)
library(curl)
# install.packages(c("shinyFiles"))
library(sen2r)

library(rgdal)
# library(raster) # older, slower
library(terra) #newer than terra, stars is another option

# to use sen2r interactively, use this command
#sen2r()


# Set paths
# out_dir_1  <- tempfile(pattern = "sen2r_out_1_") # output folder
# out_dir_2  <- tempfile(pattern = "sen2r_out_2_") # output folder, my preferred extent
# safe_dir_1 <- tempfile(pattern = "sen2r_safe_")  # folder to store downloaded SAFE


dir.create("C:/sen2r/sen2r_safe_")
dir.create("C:/sen2r/sen2r_out_1_")
dir.create("C:/sen2r/sen2r_out_2_")
safe_dir_1 <- "C:/sen2r/sen2r_safe_"  # folder to store downloaded SAFE, note, this folder gets large, 5+ GB!
out_dir_1  <- "C:/sen2r/sen2r_out_1_" # output folder
out_dir_2  <- "C:/sen2r/sen2r_out_2_" # output folder

#myextent_1 <- system.file("extdata/vector/barbellino.geojson", package = "sen2r") #from demo

#get from github, https://stackoverflow.com/a/40139270/4927395
# url_file<-"https://raw.githubusercontent.com/markbneal/satellite/master/research_farm_aoi.RDS" 
# download.file(url_file,"research_farm_aoi.RDS", method="curl")

research_farm_aoi <- readRDS("research_farm_aoi.RDS") #read it in if you don't want to do it interactively
#Note: this AOI is large compared to extent of farm, should probably use bounding box (Bbbox) generated below for Scott Farm
research_farm_aoi_sf <- st_sf(research_farm_aoi)
myextent_1 <- sf_geojson(research_farm_aoi_sf)
class(myextent_1)

write_scihub_login('markbneal','9627490A')

sessionInfo()

# This goes to the server and creates the images for the specifications listed
out_paths_1 <- sen2r(
  gui = FALSE,
  step_atmcorr = "l2a",
  extent = myextent_1,
  #extent_name = "Barbellino",
  extent_name = "ResearchFarm",
  timewindow = c(as.Date("2022-06-13"), as.Date("2022-06-25")), 
  # time needs to be recent, or are archived and take time (hours?) until they are available, see note below
  list_prods = c("BOA","SCL"),
  list_indices = c("NDVI","MSAVI2"),
  list_rgb = c("RGB432B"),
  mask_type = "cloud_and_shadow",
  max_mask = 10,
  path_l2a = safe_dir_1,
  path_out = out_dir_1
)

# Note; Option to use Google to avoid waiting for ESA archived data
# https://www.r-bloggers.com/2021/06/downloading-sentinel-2-archives-from-google-cloud-with-sen2r/
# check_gcloud()
# check_sen2r_deps()


# make metadata list for loop ####-----------------------------------
list.files(safe_dir_1)
list.files(out_dir_1)
image_files <- list.files(file.path(out_dir_1, "NDVI"), pattern = ".tif")
image_files
class(image_files)

image_metadata <- image_files %>% 
  as_tibble() %>% 
  rename(file = value) %>% 
  mutate(date = as_date((str_sub(str_extract(file, "_([^_]+)_"), 2,-2)))) %>% 
  arrange(date)

path = file.path(out_dir_1, "NDVI")

# list.files(out_dir_2)
# list.files(file.path(out_dir_2, "NDVI"))
# path = file.path(out_dir_2, "NDVI")

# Scott farm paddocks from shapefile ####-------------------------------

scott_farm <- st_read("Scott-farm_NZTM_08v4.shp")
st_crs(scott_farm)

scott_farm <- st_transform(scott_farm, crs = st_crs(sat_data_sf))

bbox_scott <- st_bbox(scott_farm)


#plot raster data on NDVI ####---------------------------------

paddock_data <- vector("list", length = dim(image_metadata)[1])


# loop for map creation ####---------------------------------------------

for (i in 1:dim(image_metadata)[1]) {

  #file_to_plot <- paste0(path, "/S2A2A_20200720_065_Barbellino_NDVI_10.tif") 
  file_to_plot <- paste0(path, "/", image_metadata$file[i])
  # file_to_plot
  GDALinfo(file_to_plot)
  # sat_data <- raster(file_to_plot) #using raster, slower, older
  sat_data <- rast(file_to_plot)
  names(sat_data) <- "NDVI"
  # class(sat_data)
  # summary(sat_data)
  
  # plot(sat_data)
  
  # ggplot() +
  #   geom_raster(data = sat_data , aes(x = x, y = y, fill = S2A2A_20200720_065_Barbellino_NDVI_10)) + 
  #   coord_quickmap()
  
  sat_data_df <- as.data.frame(sat_data, xy = TRUE)
  
  # ggplot() +
  #   geom_raster(data = sat_data_df , aes(x = x, y = y, fill = NDVI)) + 
  #   coord_quickmap()
  
  # make sat_data (SpatRaster if using terra, RasterLayer if using raster) into an sf object for plotting (note, now they are points in the middle of the pixel
  # st_crs(sat_data)
  sat_data_sf <- sf::st_as_sf(sat_data_df, coords = c("x","y"), crs = st_crs(sat_data)) %>% 
    mutate(date = image_metadata$date[i]) #creates date data to allow for grouping later
  
  # ggplot()+
  #   geom_sf(data = sat_data_sf, aes(colour = NDVI))
  
  sat_data_sf_crop <- st_crop(sat_data_sf, bbox_scott)
  
  ggplot()+
    geom_sf(data = sat_data_sf_crop, aes(colour = NDVI))+
    geom_sf(data = scott_farm, colour = "black", fill = NA)+
    geom_sf_text(data = scott_farm, aes(label = PAD_NAME), colour = "black", size = 2)+
    ggtitle(paste0("Scott Farm NDVI ", image_metadata$date[i]))
    
  
  ggsave(paste0("Scott Farm NDVI map ", image_metadata$date[i], ".png"), height = 9, width = 12)
  
  # Save paddock data ##
  # i=1
  # rm(i)
  paddock_data[[i]] <- scott_farm %>% 
    st_join(sat_data_sf)
  
  ggplot(paddock_data[[i]], aes(x=reorder(PAD_NAME, NDVI, fun = median), y = NDVI))+
    geom_boxplot(outlier.size = 0.1)+
    coord_flip()
  
  #return(paddock_data)
  
  ggsave(paste0("Scott Farm NDVI boxplot by paddock ", image_metadata$date[i], ".png"), height = 18, width = 12)
  
  # counter, how far through images
  print(paste0("saved ", i, " of ", dim(image_metadata)[1]))
}

# # Make NDVI summary per paddock for each date ####---------------------------
# file_to_plot <- paste0(path, "/", image_metadata$file[1])
# sat_data <- rast(file_to_plot)
# names(sat_data) <- "NDVI"
# 
# sat_data_df <- as.data.frame(sat_data, xy = TRUE)
# # make sat_data (SpatRaster if using terra, RasterLayer if using raster) into an sf object for plotting (note, now they are points in the middle of the pixel
# sat_data_sf <- sf::st_as_sf(sat_data_df, coords = c("x","y"), crs = st_crs(sat_data))
# sat_data_sf_crop <- st_crop(sat_data_sf, bbox_scott)
# 
# paddock_data <- scott_farm %>% 
#   st_join(sat_data_sf)
# 
# ggplot(paddock_data, aes(x=reorder(PAD_NAME, NDVI, fun = median), y = NDVI))+
#   geom_boxplot(outlier.size = 0.1)+
#   coord_flip()
# 
# ggsave(paste0("Scott Farm NDVI boxplot by paddock ", image_metadata$date[1], ".png"), height = 18, width = 12)

# plot NDVI over time with facet for each paddock ####-----------------------

# Need to create a list of paddock data

paddock_data_all <- bind_rows(paddock_data)

# Calculate differences between dates ####-----------------------------------

Ensure dates are ordered, summarise and calcuate difference relative to lag()


# plot paddock differences from last image on map  for each date ####--------

Take differencec, join to scott farm shapes, and plot for each time