# Satellite imagery analysis in R. 

This repo is a grab bag of testing satellite imagery packages.


Packages include:
# Sen2r
An R Package accessing Sentinel data from ESA Scihub or Google Buckets. This works fairly well.

# rgee
An R package for accessing Google Earth Engine, not yet working for me with current google cloud authentication, and requires some items to be installed on workbench.

# openeo
Theoretically an open approach to eo, that could use various backends, including ESA and GEE. The gee backend isn't working, but after getting a trial account, the open eo backend is working.

Most of these options can have some painful installation issues - I recommend to install latest from Github where possible, and ensure all other CRAN packages are up to date. Restarting R is required often.


Also included are files from this repo, using sen2r:

Authors: Ewa Grabska
Original at https://github.com/WhyR2020/workshops/tree/master/satellite
This version with some edits/modifications by Mark Neal

Description
Satellite imagery, such as freely available data from Sentinel-2 mission, enable us to monitor the Earth's surface frequently (every 5 days), and with a high spatial resolution (10-20 meters). Furthermore, Sentinel-2 sensors, including 13 spectral bands in the visible and infrared wavelengths, provide very valuable information which can be used to automatically perform tasks such as classify crop types, assess forest changes, or monitor build-up area development. This is particularly important now, in the era of rapid changes in the environment related to climate change. In R, there are plenty of tools and packages which can be used for satellite images such as pre-processing, analyzing, and visualizing data in a simple and efficient way. Also, the variety of methods, such as machine learning algorithms, are available in R and can be applied in the analysis of satellite imagery. I would like to show the framework for acquiring, pre-processing and preliminary analysis of the Sentinel-2 time series in R. It includes the spectral indices calculation, the use of the machine learning algorithms in the classification of land cover, and, the analysis of time series of imagery, i.e. determining the changes in environment based on the spectral trajectories of pixels.

Download materials that are too big for github:
https://www.dropbox.com/s/pss5sto3wb3z4ny/whyr_satellite.zip?dl=0