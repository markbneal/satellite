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

library(jpeg)
# to use sen2r interactively, use this command
#sen2r()


# Set paths
# out_dir_1  <- tempfile(pattern = "sen2r_out_1_") # output folder
# out_dir_2  <- tempfile(pattern = "sen2r_out_2_") # output folder, my preferred extent
# safe_dir_1 <- tempfile(pattern = "sen2r_safe_")  # folder to store downloaded SAFE

# We could keep data directories in the project folder, but need to ensure the folders are in .gitignore file

dir.create("C:/sen2r/sen2r_safe_")
dir.create("C:/sen2r/sen2r_out_1_")
safe_dir_1 <- "C:/sen2r/sen2r_safe_"  # folder to store downloaded SAFE, note, this folder gets large, 5+ GB!
out_dir_1  <- "C:/sen2r/sen2r_out_1_" # output folder

# myextent_1 <- system.file("extdata/vector/barbellino.geojson", package = "sen2r") #from demo

#get from github, https://stackoverflow.com/a/40139270/4927395
# url_file<-"https://raw.githubusercontent.com/markbneal/satellite/master/research_farm_aoi.RDS" 
# download.file(url_file,"research_farm_aoi.RDS", method="curl")

# research_farm_aoi <- readRDS("research_farm_aoi.RDS") #read it in if you don't want to do it interactively
# #Note: this AOI is large compared to extent of farm, should probably use bounding box (Bbox) generated below for Scott Farm
# research_farm_aoi_sf <- st_sf(research_farm_aoi)
# myextent_1 <- sf_geojson(research_farm_aoi_sf)
# class(myextent_1)

scott_bb_geom_sf <- read_rds("scott_bb_geom_sf.RDS")
myextent_1 <- scott_bb_geom_sf
st_crs(myextent_1)

write_scihub_login('markbneal','9627490A')

sessionInfo()

# This goes to the server and creates the images for the specifications listed
out_paths_1 <- sen2r(
  gui = FALSE,
  step_atmcorr = "l2a",
  extent = myextent_1,
  #extent_name = "Barbellino",
  extent_name = "ResearchFarm",
  #timewindow = c(as.Date("2022-06-13"), as.Date("2022-06-25")), 
  #timewindow = c(as.Date("2022-06-26"), as.Date("2022-07-10")), 
  timewindow = c(as.Date("2022-05-01"), as.Date("2022-05-30")), 
    # time needs to be recent, or are archived and take time (hours?) until they are available, see note below
  list_prods = c("BOA","SCL"),
  list_indices = c("NDVI","MSAVI2"),
  list_rgb = c("RGB432B"),
  mask_type = "cloud_and_shadow",
  max_mask = 10,
  path_l2a = safe_dir_1,
  path_out = out_dir_1,
  #server = c("scihub", "gcloud") # Try Scihub first, noting ESA archiving issues below
  server = c("gcloud", "scihub") # Try gcloud first, assuming it is set up, as noted below
)

# Note; Option to use Google to avoid waiting for ESA archived data
# https://www.r-bloggers.com/2021/06/downloading-sentinel-2-archives-from-google-cloud-with-sen2r/ 
# check_gcloud()
# check_sen2r_deps()

# Warning message:
#   Some files were not created:
#   "C:\sen2r\SEN2R_~1/BOA/S2B2A_20220602_029_ResearchFarm_BOA_10.tif"
# "C:\sen2r\SEN2R_~1/BOA/S2A2A_20220604_129_ResearchFarm_BOA_10.tif"
# "C:\sen2r\SEN2R_~1/BOA/S2B2A_20220612_029_ResearchFarm_BOA_10.tif""
# These files will be skipped during next executions from the current parameter file (""). To try again to build them,
# remove their file name in the text file "C:\sen2r\SEN2R_~1\IGNORE~1.TXT". 




# make metadata lists ####-----------------------------------
list.files(safe_dir_1)

# List thumbnails and plot for easy reference ####
list.files(out_dir_1)
thumbnail_files <- list.files(file.path(out_dir_1, "NDVI", "thumbnails"), pattern = "\\.jpg$") # pattern ensures this is the file ending
thumbnail_files
class(thumbnail_files)

thumbnail_metadata <- thumbnail_files %>% 
  as_tibble() %>% 
  rename(file = value) %>% 
  mutate(date = as_date((str_sub(str_extract(file, "_([^_]+)_"), 2,-2)))) %>% 
  arrange(date)

thumbs <- list()
my_path <- file.path(out_dir_1, "NDVI", "thumbnails", "/")
for(j in 1:dim(thumbnail_metadata)[1]) {
  thumbs[[j]] <- readJPEG(paste0(my_path, thumbnail_metadata$file[j]))
  }

my_cols <- 3

my_layout_matrix <- matrix(1:(ceiling((dim(thumbnail_metadata)[1])/my_cols)*my_cols), ncol=my_cols, byrow =TRUE)


rl = lapply(paste0(my_path, thumbnail_metadata$file), jpeg::readJPEG)
gl = lapply(rl, grid::rasterGrob)
png(filename = paste0("thumbs from ", 
                      toString(format(thumbnail_metadata$date, format="%d%b")), #warning, file name could get too long!!
                      ".png")) # file name to save following plot
gridExtra::grid.arrange(grobs=gl, 
                        layout_matrix = my_layout_matrix, 
                        as.table = FALSE,
                        top = toString(format(thumbnail_metadata$date, format="%d%b")))
dev.off() #save plot

# list image data for loop ####
list.files(out_dir_1)
image_files <- list.files(file.path(out_dir_1, "NDVI"), pattern = "\\.tif$") 
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

# save minimal bounding box as geometry
# scott_bb_geom <- st_as_sfc(st_bbox(bbox_scott))
# class(scott_bb_geom)
# scott_bb_geom_sf <- st_as_sf(scott_bb_geom)
# class(scott_bb_geom_sf)
# write_rds(scott_bb_geom_sf, "scott_bb_geom_sf.RDS")

#plot raster data on NDVI ####---------------------------------

paddock_data <- vector("list", length = dim(image_metadata)[1])


# loop for map and data from each image ####---------------------------------------------

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

# plot NDVI over time with facet for each paddock ####-----------------------

# pull together all paddock data from list to tibble
paddock_data_all <- bind_rows(paddock_data)

paddock_data_summarise <- paddock_data_all %>% 
  group_by(date, PAD_NAME) %>% 
  summarise(NDVI = mean(NDVI, na.rm = TRUE))

ggplot(paddock_data_summarise) +
  geom_line(aes(x=date, y = NDVI))+
  geom_point(aes(x=date, y = NDVI, colour = PAD_NAME))+
  facet_wrap(~PAD_NAME)+
  theme(legend.position="none")

ggsave("Scott Farm facet by paddock plot of NDVI by paddock.png", height = 12, width = 12)

# Calculate differences between dates ####-----------------------------------


#Ensure dates are ordered, summarise and calculate difference relative to previous image with lag()

paddock_data_summarise <- paddock_data_summarise %>% 
  group_by(PAD_NAME) %>% 
  arrange(date) %>% 
  mutate(difference = NDVI-lag(NDVI))
  
ggplot(paddock_data_summarise) +
  geom_point(aes(x=difference, y=PAD_NAME))+
  facet_wrap(~date, nrow = 1)

ggsave("Scott Farm facet by date plot of paddock NDVI difference by paddock.png", height = 12, width = 16)

# plot paddock differences from last image on map  for each date ####--------

# Take difference, join to Scott farm shapes, and plot for each time

# Probability grazed, rather than threshold?