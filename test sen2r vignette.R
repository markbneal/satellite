# test sen2r vignette
# http://sen2r.ranghetti.info/articles/sen2r_cmd.html

# remotes::install_github("ranghetti/sen2r")
# installing updates of all cran
# then restarting R session

# Set paths
# out_dir_1  <- tempfile(pattern = "sen2r_out_1_") # output folder
# out_dir_2  <- tempfile(pattern = "sen2r_out_2_") # output folder, my preferred extent
# safe_dir_1 <- tempfile(pattern = "sen2r_safe_")  # folder to store downloaded SAFE


dir.create("C:/sen2r/sen2r_safe_")
dir.create("C:/sen2r/sen2r_out_1_")
dir.create("C:/sen2r/sen2r_out_2_")
safe_dir_1 <- "C:/sen2r/sen2r_safe_"  # folder to store downloaded SAFE
out_dir_1  <- "C:/sen2r/sen2r_out_1_" # output folder
out_dir_2  <- "C:/sen2r/sen2r_out_2_" # output folder

myextent_1 <- system.file("extdata/vector/barbellino.geojson", package = "sen2r") 

#use my preferred extent
library(sf)
#install.packages("geojsonsf")
library(geojsonsf)
#install.packages("RCurl")
library(RCurl)
library(curl)
#get from github, https://stackoverflow.com/a/40139270/4927395
# url_file<-"https://raw.githubusercontent.com/markbneal/satellite/master/research_farm_aoi.RDS" 
# download.file(url_file,"research_farm_aoi.RDS", method="curl")

# research_farm_aoi <- readRDS("research_farm_aoi.RDS") #read it in if you don't want to do it interactively
# research_farm_aoi_sf <- st_sf(research_farm_aoi)
# myextent_1 <- sf_geojson(research_farm_aoi_sf)
# class(myextent_1)

library(sen2r)
write_scihub_login('markbneal','9627490A')

library(leaflet)
library(shinyFiles)

sessionInfo()
#update.packages(ask=FALSE)


out_paths_1 <- sen2r(
  gui = FALSE,
  step_atmcorr = "l2a",
  extent = myextent_1,
  extent_name = "Barbellino",
  timewindow = c(as.Date("2019-07-13"), as.Date("2019-07-25")),
  list_prods = c("BOA","SCL"),
  list_indices = c("NDVI","MSAVI2"),
  list_rgb = c("RGB432B"),
  mask_type = "cloud_and_shadow",
  max_mask = 10,
  path_l2a = safe_dir_1,
  path_out = out_dir_1
)

out_paths_2 <- sen2r(
  gui = FALSE,
  step_atmcorr = "l2a",
  extent = myextent_1,
  extent_name = "ResearchFarm",
  timewindow = c(as.Date("2020-07-01"), as.Date("2020-11-24")),  #this is 5 months - a lot of data, several hours download.
  list_prods = c("BOA","SCL"),
  list_indices = c("NDVI","MSAVI2"),
  list_rgb = c("RGB432B"),
  mask_type = "cloud_and_shadow",
  max_mask = 10, 
  path_l2a = safe_dir_1,
  path_out = out_dir_2
)

#sen2r("/home/rstudio-user/.sen2r/proc_par/s2proc_20201123_220204.json")


sen2r()
#install.packages(c("shinyFiles"))

list.files(safe_dir_1)
# list.files(out_dir_1)
# list.files(file.path(out_dir_1, "NDVI"))
# path = file.path(out_dir_1, "NDVI")

list.files(out_dir_2)
list.files(file.path(out_dir_2, "NDVI"))
path = file.path(out_dir_2, "NDVI")

#plot raster data on NDVI ####---------------------------------
#install.packages("ggplot")
#remotes::install_github("https://github.com/tidyverse/ggplot2")
library(ggplot2)
library(rgdal)
#file_to_plot <- paste0(path, "/S2A2A_20200720_065_Barbellino_NDVI_10.tif") 
file_to_plot <- paste0(path, "XXXXXXXXXXXXXXXX.tif")
file_to_plot
GDALinfo(file_to_plot)
sat_data <- raster(file_to_plot)
sat_data
summary(sat_data)

# ggplot() +
#   geom_raster(data = sat_data , aes(x = x, y = y, fill = S2A2A_20200720_065_Barbellino_NDVI_10)) + 
#   coord_quickmap()

ggplot() +
  geom_raster(data = sat_data , aes(x = x, y = y, fill = XXXXXXXXXXXXXXXXXXXXXXXXXXX)) + 
  coord_quickmap()