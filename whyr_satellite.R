# Satellite imagery analysis in R @ Why R? 2020
# https://github.com/WhyR2020/workshops/tree/master/satellite #workshop code
# https://www.youtube.com/watch?v=k1K6nqgtRL8&feature=youtu.be #webinar code not exact match for workshop
# Ewa's workshop code is modified below to be a self-contained RStudio project/Github Repo

#edit

#install.packages("devtools")
#devtools::install_github("16EAGLE/getSpatialData")
#install.packages("sen2r")
##two more packages to install (with our ML methods for classification): 
#install.packages(c("randomForest","kernlab"))

library(getSpatialData)
library(sen2r)
library(raster)
library(RStoolbox)
library(tidyr)
library(dplyr)
library(rlang)
library(ggplot2)
library(RColorBrewer)
library(viridis)
library(caret)
library(sf)

services()
check_scihub_connection()


#PART 1: DOWNLOADING & PRE-PROCESSING DATA ------------------------------------------------------------------------------------

# using getSpatialData package
# an alternative would be to use google earth engine with rgee(), though it requires python installation

get_products() #list of available products

#set and view the area of interest (aoi) interactively
# set_aoi() 
# view_aoi()
# get_aoi()

#You can save the aoi for future use:
#research_farm_aoi <- get_aoi(type = "sf") # to create aoi as an object
#saveRDS(research_farm_aoi,"research_farm_aoi.RDS") #save aoi as RDS file
research_farm_aoi <- readRDS("research_farm_aoi.RDS") #read it in if you don't want to do it interactively
set_aoi(research_farm_aoi) #set aoi from saved data
view_aoi()
class(research_farm_aoi)

time_range =  c("2020-11-01", "2020-11-30") #set time range
products = "Sentinel-2" #choose product (platform), some other example further below

# For sentinel data please create an account on the ESA sci-hub website: https://scihub.copernicus.eu/dhus/#/home
#login to Esa SCI-HUB, with manual password entry
#login_CopHub(username = "markbnealfile.edit("~/.Renviron")") #password hint sid+Alpha <- this is not the password!

#login to Esa SCI-HUB, getting password from environment
# to store passwords see "Environment variables" section at this link 
# (https://cran.r-project.org/web/packages/httr/vignettes/secrets.html) for storing passwords
login_CopHub(username = "markbneal", password = Sys.getenv("ESA_PW")) 

# For Landsat data please create an account on the USGS website: https://earthexplorer.usgs.gov/
#login to USGS for Landsat, with manual password entry
#login_USGS(username = "markbneal") #password hint (sid+Alpha)*2  <- this is not the password!

#login to USGS, getting password from environment
login_USGS(username = "markbneal", password = Sys.getenv("USGS_PW"))

# For some other data please create an account on the earthdata website: https://urs.earthdata.nasa.gov/users/new
#login to earthdata, with manual password entry
#login_earthdata(username = "markbneal") #password hint sid+Alpha+alpha <- this is not the password!

#login to earthdata, getting password from environment
login_earthdata(username = "markbneal", password = Sys.getenv("NASA_PW"))

#get a Sentinel-2 query with specified parameters 
#?getSentinel_records
query = getSentinel_records(time_range, products)

str(query)

#examine query dataframe
query$cloudcov
query$tile_id # 1 tile = 100x100km2

#you can also specify level of processing - level 1C is before correction, 2A after correction
#query10 = query[query$cloudcov < 10 & query$tile_id == "T34UCA" & query$level == "Level-1C",] 
query10 <- query %>% filter(cloudcov < 10 & level == "Level-2A") #tidyverse approach

##or for landsat
# products = "LANDSAT_8_C1"
# query = getLandsat_records(time_range, products)
# query10 <- query %>% filter(cloudcov < 10) #tidyverse approach

##or for elevation data
# products = "SRTM_global_1arc_V001" #elevation data, 1 arc second (<=30m resolution)
# query = getSRTM_records(time_range, products)
# query10 <- query

query10$record_id

#set archive, view preview and download data
set_archive("~/satellite/") #this is in this project, though for big data sets, 
#                            you may not want to put it here, especially if using github, 
#                            though you could use gitignore to not push it to github

get_archive()
plot_records(query10)
records <- get_previews(query10)
length(records)
view_previews(records[1,])

for(i in 1:length(records)){
  p <- view_previews(records[i,])
  print(p)
} # I wouldn't do this if there is heaps of data

records$download_available
getSentinel_data(records) #doesn't work, either on work network, or at home, or rstudio cloud.

records$download_available <- TRUE #https://github.com/16EAGLE/getSpatialData/issues/76#issuecomment-732314445

getSentinel_data(records) #this gives me a zip file, with bands as separate .jp2 files
#see resolution and band data here: https://sentinel.esa.int/web/sentinel/user-guides/sentinel-2-msi/resolutions/spatial

#getLandsat_data(records)
#check_availability(records)

#use this for SRTM elevation data
# get_data(records, verbose = TRUE)
# # read file
# elevation <- raster("_datasets/SRTM_global_1arc_V001/S38E175.hgt")
# # view image
# image(elevation)
# saveRDS(elevation, "S38E175.RDS")
# elevation2 <- readRDS("S38E175.RDS")
# image(elevation2)

#trying to read jp2 files with sf
library(sf)
st_drivers() #JPEG2000 and JP2OpenJPEG drivers available
data <- st_read('_datasets/Sentinel-2/R10m/T60HUD_20201119T222549_B02_10m.jp2', drivers='JP2OpenJPEG') #no success

#trying to read jp2 with rdgal 
library(rgdal) 
library(gdalUtils) #necessary? https://www.researchgate.net/post/How_to_work_with_Sentinel-2_jp2_files_in_R
gdal_chooseInstallation('JP2OpenJPEG')

gdalDrivers()
s2a <- readGDAL('_datasets/Sentinel-2/R10m/T60HUD_20201119T222549_B02_10m.jp2') #success
summary(s2a)

?s2_rgb
#some interesting tools from sen2r package - very good package for processing Sentinel-2 images; also tools for downloading data
?s2_translate #enables to create one stack (one, multi-band, geotiff image)
?s2_calcindices #many many indices 
?s2_mask #masking clouds

s2_translate('C:/sen2r/S2B_MSIL2A_20201119T222549_N0214_R029_T60HUD_20201120T001425.SAFE', bigtiff = TRUE)
# produces a vrt file - and now what?

#s2_translate('C:/sen2r/S2B_MSIL2A_20201119T222549_N0214_R029_T60HUD_20201120T001425.SAFE/GRANULE/L2A_T60HUD_A019360_20201119T222544/IMG_DATA/R10m/')
# error



# Trying workflow from sen2r vignette ####--------------------------------------------------
# http://sen2r.ranghetti.info/articles/sen2r_cmd.html

# Set paths
dir.create("C:/sen2r/sen2r_out_1_")
dir.create("C:/sen2r/sen2r_safe_")
out_dir_1  <- "C:/sen2r/sen2r_out_1_" # output folder
safe_dir_1 <- "C:/sen2r/sen2r_safe_"  # folder to store downloaded SAFE

# myextent_1 <- system.file("extdata/vector/barbellino.geojson", package = "sen2r") 
# class(myextent_1)

#use my preferred extent
library(geojsonsf)
research_farm_aoi_sf <- st_sf(research_farm_aoi)
myextent_1 <- sf_geojson(research_farm_aoi_sf)
class(myextent_1)

#library(sen2r)
out_paths_1 <- sen2r(
  gui = FALSE,
  step_atmcorr = "l2a",
  extent = myextent_1,
  extent_name = "researchfarm",
  timewindow = time_range,
  list_prods = c("BOA","SCL"),
  list_indices = c("NDVI","MSAVI2"),
  list_rgb = c("RGB432B"),
  mask_type = "cloud_and_shadow",
  max_mask = 10, 
  path_l2a = safe_dir_1,
  path_out = out_dir_1
)

#PART 2: READING AND VISUALIZATION USING RASTER PACKAGE ------------------------------------------------------------------------

#Sentinel-2 acquires data in 13 spectral bands, however, we will not use all of them, 
#as not all of them are designed for analysis of land areas. There are 10 bands for land applications - 
#3 visible bands, 3 red-edge bands (located at the edge between red light and infrared) two near-infrared (NIR), 
#and we also have two short-wave infrared bands (SWIR).

#setwd("C:/04_R/preliminary_analysis") #I'm led to believe this is not a good habit

list.files("preliminary_analysis/")

#I already prepared one .tif file which is a multi-band image, now you can read bands separately or in one stack

r1 = raster("preliminary_analysis/20190825_crop.tif") #only single band will be read (the first one)
band4 = raster("preliminary_analysis/20190825_crop.tif", band = 4) #here you can specify which band do you want to read
s1 = stack("preliminary_analysis/20190825_crop.tif") #this is an image composed of 6 bands in order: visible blue, visible green, visible red, NIR, SWIR1, SWIR2

#print information about rasters
r1
band4
s1

names(s1) = c("blue", "green", "red", "nir", "swir1", "swir2") #change band names in a raster stack 

plot(r1) 
plot(s1) #all bands plotted seperately 

#extracting one element (band) from the raster stack 
s1[[1]]
s1$blue
blue_band = s1[[1]]

plot(s1[[1]]) #and plot single band from stack

#compositions - plot bands in color compostion 
plotRGB(s1, stretch = "lin") #default one (1,2,3)
plotRGB(s1, r = 3, g = 2, b = 1, stretch = "lin")


#compare different compositions
par(mfrow = c(1,4)) #plot 4 compositions at once
plotRGB(s1, r = 3, g = 2, b = 1, stretch = "lin") #true-color compositions
plotRGB(s1, r = 4, g = 3, b = 2, stretch = "lin") #false color compositions
plotRGB(s1, r = 5, g = 4, b = 3, stretch = "lin") #SWIR false-color
plotRGB(s1, r = 6, g = 5, b = 4, stretch = "lin") #two SWIR false-color

dev.off() #remove all plots

#another option to plot images
image(s1)


#PART 3: PROCESSING DATA -----------------------------------------------------------

#cropping image to smaller extent
extent(s1)
e = extent(360000, 380000, 7800000, 7810000)
s1_crop = crop(s1, e)

plot(s1_crop)
plotRGB(s1_crop, r=6, g=4, b =2, stretch = "lin")

#writing data
writeRaster(s1_crop, "preliminary_analysis/20190805_crop2.tif")
writeFormats()

#checking values distribution - histograms, scatterplots and correlations
dev.off()
hist(s1_crop)
pairs(s1_crop, maxpixels = 5000) #remember to use maxpixels values because if you take all of the pixel values it will take a lot of time to produce
pairs(s1_crop[[c(4,6)]], maxpixels = 10000) #note how high values the burning areas have in SWIR



#mathematical operations 
s2 = stack("preliminary_analysis/20190805_crop.tif")
e = extent(360000, 380000, 7800000, 7810000)
s2_crop = crop(s2, e)
plotRGB(s2_crop, r = 4, g= 3, b = 2, stretch = "lin")


ndvi = (s2_crop[[4]] - s2_crop[[3]])/(s2_crop[[4]] + s2_crop[[3]]) #normalized difference vegetation index - it uses NIR and visible red bands
plot(ndvi)
plot(ndvi, col=brewer.pal(n = 6, name = "PiYG"))

mndwi = (s2_crop[[2]] - s2_crop[[5]])/(s2_crop[[2]] + s2_crop[[5]]) #modified normalized difference water index - uses visible green and swir
plot(mndwi, col=brewer.pal(n = 10, name = "RdBu"))

ind_stack = stack(mndwi, ndvi) #you can create a stack of indices, you can also create a stack of bands and indices
plot(ind_stack)
pairs(ind_stack, maxpixels = 1000)


#exercise - pre-fire and post-fire NBR (Normalized Burn Ratio)

s3 = stack("preliminary_analysis/20190830_crop.tif") #image from after fire 
s3_crop = crop(s3, e)
plotRGB(s3_crop, r = 3, g = 2, b = 1, stretch = "lin")

#Typically, Tto estimate the severity of burnt areas, delta NBR is calculated – the difference between pre-fire and post-fire NBR. 
nbr_pre = (s2_crop[[4]] - s2_crop[[6]])/(s2_crop[[4]] + s2_crop[[6]])
nbr_post = (s3_crop[[4]] - s3_crop[[6]])/(s3_crop[[4]] + s3_crop[[6]])


dev.off()
delta_nbr = nbr_pre - nbr_post
hist(delta_nbr, col = "red")
plot(delta_nbr, col=brewer.pal(n = 6, name = "YlOrRd"))

#determine areas with high severity burn - e.g. areas with values of delta NBR > 0.66 are high severity burnt areas
burnt = reclassify(delta_nbr, c(-1, 0.1, 0, 0.1, 0.27, 1, 0.27, 0.44, 2, 0.44, 0.66, 3, 0.66, 1, 4))
plot(burnt, col=brewer.pal(n = 5, name = "YlOrRd"))


#PART 4: CLASSIFICATION --------------------------------------------------------------------------------

warsaw = stack("classification/warsaw.tif")
plotRGB(warsaw, r =3, g = 2, b=1, stretch = "lin")
warsaw #note that this image is composed of all 10 bands (not only 6 as in Amazon case)


#we will take the "full" spectrum of Sentinel-2 to get more information for automatic classification
names(warsaw) = c("blue", "green", "red", "re1", "re2", "re3", "nir1", "nir2", "swir1", "swir2") #change the names again
pairs(warsaw, maxpixels = 1000)

ref = shapefile("classification/reference_utm.shp") #reading file with reference (training) samples 

unique(ref$class) #how many land cover classes it represents
plotRGB(warsaw, r =3, g = 2, b=1, stretch = "lin") #visualize rgb composition again and...
plot(ref, add =TRUE, col = "red") #the location of the reference samples

#before classification, in order to analyze spectral properties of land cover classes, 
#we firstly extract values from the image to sample polygons (mean values for each polygon)

#you can use extract function from raster package but it's extremely slow 
ref_values = raster::extract(warsaw, ref, fun = "mean") %>% as.data.frame()
ref_values$class = ref$class #add class attribute to a dataframe

#better choice for larger datasets is: 
#library(exactextractr)
#and the function called exact_extract :)
#the thing here is that exact_extract needs a sf object as an input so you have to read shapefile with st_read() function from sf package instead of shapefile() function

#some visualization with ggplot2 package - scatterplots:
ggplot(ref_values, aes(green, re2, color = class))+
  geom_point(size = 2)+
  stat_ellipse()


#we need to prepare the data to create spectral curves - there are many tools in r which can be used, 
#e.g. melt and dcast functions from reshape2, functions from dplyr, 
#tidyr; aggregate function etc. we can try this:

mean_spectra = group_by(ref_values, class) %>% #we group ref_values by class
  summarise_all(mean) %>% #calculate mean value for each class
  gather(key, value, -class) #transform the df to "long" format 

#we also need to specify order of bands: (if not they will be plotted in alphabetical order)
mean_spectra$key = factor(mean_spectra$key, levels=c("blue", "green", "red", "re1", "re2", "re3", "nir1", "nir2", "swir1", "swir2"))

#and plot sepctral curves:
ggplot(mean_spectra, aes(key, value, color = class, group = class))+
  geom_point()+
  geom_line(size = 1.8, alpha = 0.6)

#Image classification - there are 2 types of classification – unsupervised and supervised. 
#in unsupervised classification we don’t use reference data (training data), all pixels are grouped into clusters using for example k-means algorithm. 
#in supervised classification we use reference, training samples. For these training samples the land cover class and exact location is known. 
#we will use classification tools form RStoolbox package

#unsupervised classification
class1 = unsuperClass(warsaw, nSamples = 100, nclasses = 5)
class1$map
plot(class1$map, col = rainbow(5))

#supervised classification
?superClass

#additional calculation of two indices:
warsaw_mndwi = (warsaw[[2]] - warsaw[[9]])/(warsaw[[2]] + warsaw[[9]])
warsaw_ndvi = (warsaw[[7]] - warsaw[[3]])/(warsaw[[7]] + warsaw[[3]])
warsaw_all = stack(warsaw, warsaw_ndvi, warsaw_mndwi) #you can classify one stack with 10 bands and 2 indices and then check the variable importance!



#The function called superClass train the model and then validate it (we have to provide both training and validation datasets). 
#We will use the reference polygons and split them into train and validation samples with proportion of 70% for training, 30% for validation. 
#We can split the samples inside the superclass function. we can put set.seed() function inside to always get the same random partition. 
#remeber that two perform reliable classification you have to follow some rules regarding obtaining training and validation data (e.g. they should not be close to each other in order to avoid spatial autocorrelation)


classification_rf = superClass(warsaw_all, ref, set.seed(5), trainPartition = 0.7, responseCol = "class", #random forest classification
                                   model = "rf", mode = "classification", tuneLength = 5, kfold = 10)

classification_svm = superClass(warsaw_all, ref, set.seed(5), trainPartition = 0.7, responseCol = "class", #support vector machines classification
                               model = "svmLinear", mode = "classification", tuneLength = 5, kfold = 10)


classification_svm #the result is a list and it includes classification_svm$map that you can plot and save on your disc using writeRaster()
#the accuracy assessment is also available - if you print the classification result object, the first element is validation, 
#two most important measures of the classification are – confusion matrix bewteen reference and prediction and overall accuracy. 

#check the importance of particular bands
varImp_rf = varImp(classification_rf$model)
varImp_svm = varImp(classification_svm$model)
 
#and print/plot the results of VI 
plot(varImp_rf)
varImp_rf
varImp_svm

#use only the important bands as input - for example:
classification_rf = superClass(warsaw_all[[c(9,10,11, 7)]], ref, set.seed(5), trainPartition = 0.7, responseCol = "class",
                               model = "rf", mode = "classification", tuneLength = 5, kfold = 10)

classification_rf

#VI using RFE (Recursive Feature Elimination) - with ref_values again (of course to do that in "proper" way you would need another dataset)
#RFE is a simple backwards selection, searching for the optimal subset of variables by performing optimization algorithms

ref_values$class = as.factor(ref_values$class) #we need class variable as a factor
control = rfeControl(functions=rfFuncs, method="cv", number=10) #create control object 
results = rfe(ref_values[,1:10], ref_values[,11], sizes=c(1:10), rfeControl=control) #run RFE algorithm

#print/plot results 
results
plot(results, type = "l") #line plot. as you can see, we not necessary need all of the bands to achieve high accuracy; as seen in scatterplots, 
#the correlation between some of the bands is very high and therefore they are redundant 
predictors(results) #the most important predictors


#Another way of avoiding redundancy is to reduce space - for example using very popular PCA (Principal Component Analysis)

#there is a tool rasterPCA in RStoolbox package:
?rasterPCA
warsaw_pca = rasterPCA(warsaw, nComp = 3) #usually the first 2-3 components have the most infromation  

#look at the results (we have a list again)
warsaw_pca$map
plot(warsaw_pca$map)
plotRGB(warsaw_pca$map, r=3, g=2, b = 1, stretch = "lin") #we can plot is as a color composite as well

#and perform classification on reduced space: 
class_PCA = superClass(warsaw_pca$map, ref, set.seed(5), trainPartition = 0.7, responseCol = "class",
                          model = "rf", mode = "classification", tuneLength = 5, kfold = 10)

class_PCA

# visualisation of classified map
plot(classification_rf$map, col=c("darkgreen", "brown3","chartreuse4", "chartreuse", "yellow", "cadetblue3"))

#PART 5: MULTI-TEMPORAL ANALYSIS----------------------------------------------------------------------------

#In the last part we will analyze multi-temporal imagery – i.e. dense time series of images from the same year. 
#Dense time series are used particularly in vegetation monitoring, for example in mapping small forest disturbances, or in crop monitoring. 
#In these part we will also analyze the vegetation - how the different species/types of vegetation reflectance changes during the growing season. 
#Again, there are some already prepared reference data and 17 cropped images from Senitnel-2. 

stacklist = lapply(list.files(pattern = "multi_temporal/*.tif$"), stack) #use lapply() function to read all of the images at once - i.e. all of the images with given pattern (.tif format)
#the result is a list of 17 stacks 

ref = shapefile("multi_temporal/ref_crops.shp")

#extract data again; use lapply
ref_values = lapply(stacklist, raster::extract, ref, fun = "mean") %>% as.data.frame() #it takes some time... 
ref_values$class = ref$class

colnames(ref_values) = sub("X", "", colnames(ref_values)) #removing unnecessary strings 
band = select(ref_values, ends_with(".7")) #select the band (e.g. 7 - NIR1)
band$class = ref$class #and add the class column again

means = band %>% #similarly as in previous part, we will calculate mean values for each class
  gather(key, value, -class) %>%
  as.data.frame

means$key = as.Date(means$key, format = "%Y%m%d") #change the key, i.e. a variable with date to date format

#and plot it:
ggplot(means, aes(key, value, color = class, group = class))+
  geom_point()+
  geom_line(size = 2, alpha = 0.6)

#Some simple conclusion from the NIR time series analysis are:
#In NIR region, healthy vegetation has a very high values (it is sensitive to scattering surfaces, such as leaves – Leaf Area Index). 
#Crops typically have the highest NIR values
#Conifers have lower values than broad-leaved forests, and they are relatively stable, as most of the conifers are evergreen species, 
  #but there are also some seasonal variations 
#RE1 region – lower values = more chlorophyll
#Rapeseed is a specific crop as it blooms intensively,here we can see that in April it starts to growth, while at the beginning of May the intensive  bloom starts, 
  #there is a peak in RE1 on May 

#Similarly, you can analyze other bands or calculate indices and analyze their trajectories during the growing season.

#THANK YOU!!! :)

