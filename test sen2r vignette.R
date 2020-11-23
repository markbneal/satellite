# test sen2r vignette
# http://sen2r.ranghetti.info/articles/sen2r_cmd.html

# remotes::install_github("ranghetti/sen2r")
# installing updates of all cran
# then restarting R session

# Set paths
out_dir_1  <- tempfile(pattern = "sen2r_out_1_") # output folder
safe_dir_1 <- tempfile(pattern = "sen2r_safe_")  # folder to store downloaded SAFE

# dir.create("C:/sen2r/sen2r_out_1_")
# dir.create("C:/sen2r/sen2r_safe_")
# out_dir_1  <- "C:/sen2r/sen2r_out_1_" # output folder
# safe_dir_1 <- "C:/sen2r/sen2r_safe_"  # folder to store downloaded SAFE

myextent_1 <- system.file("extdata/vector/barbellino.geojson", package = "sen2r") 

library(sen2r)

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

sen2r()
#install.packages(c("shinyFiles"))
