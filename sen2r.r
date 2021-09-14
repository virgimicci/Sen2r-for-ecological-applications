setwd("C:/internship")
wd<- setwd("C:/internship")

install.packages("sen2r")
install.packages("geojsonlint")
# Error: 
# Some missing packages are needed to run the GUI; please install them with
# the command
# > install.packages(c("leaflet", "leafpm", "mapedit", "shiny", "shinyFiles", "shinydashboard", "shinyjs", "shinyWidgets")) 
install.packages(c("leaflet", "leafpm", "mapedit", "shiny", "shinyFiles", "shinydashboard", "shinyjs", "shinyWidgets"))

library(sen2r)
library(raster)
library(sf)
library(ggplot2)

# Check shihub credentials
write_scihub_login("name", "password") # save new username and password
read_scihub_login() # returns a matrix of credentials, in which username is in the first column, password in the second
check_scihub_login("name", "password") #  returns TRUE if credentials are valid, FALSE elsewhere
check_scihub_connection() #  returns TRUE if internet connection is available and SciHub is accessible, FALSE otherwise.

### SOME imp FUNCTIONS 
# check_sen2r_deps()  The function allows to graphically check that all the optional runtime dependencies are installed
# external dependencies in order to run specific actions, I think for L1C that are not corrected 
# • Sen2Cor for atmospheric correction;
# • GDAL for cloud mask smoothing and buffering;
# • aria2 to download SAFE images with an alternative downloader

# safe_getMetadata() returns a data.table, a data.frame or a list (depending on argument format)
# with the output metadata

##### TAKING DATA FROM senr2 ######
# First method
myextent <- st_read("TEN.shp") # created by QGIS
# chek on copernicus hub my images: how they are, which are online and which not
# if there are images that I need, which are offline, I order them (they will be online for me for a delimited time, then they will return offline)
time_window <-as.Date(c("2020-10-01","2021-05-27"))

### Now I have to create my code to download them with the sen2r()
# Show index names within the package
list_indices(c("name","longname"))  

# Return the NDVI formula, can be done for each indices to see the formula 
list_indices("s2_formula", "NDVI")

# I created two folder in order to save my files: sen2r_safe (for SAFE products) and sen2r_out (for the modified products)
out_paths_1 <- sen2r(gui= FALSE, extent = myextent, extent_name = "Tenerife", timewindow = time_window, 
                     timeperiod = "full", list_prods = c("BOA"), 
                     list_indices = c("NDVI", "NDWI"), mask_type = "cloud_and_shadow",
                     max_mask = 30, max_cloud_safe = 20, list_rgb = c("RGB432B", "RGBb84B"), 
                     path_l2a = "C:/internship/sen2r_safe", path_l1c = "C:/internship/sen2r_safe", path_out ="C:/internship/sen2r_out" )

# I don't have a good Dic for the clouds, so I take the one of the previous year 
time_window2 <-as.Date(c("2019-12-01","2019-12-31"))
out_paths_1 <- sen2r(gui= FALSE, extent = myextent, extent_name = "Tenerife", timewindow = time_window2, 
                     timeperiod = "full", list_prods = c("BOA"), 
                     list_indices = c("NDVI", "NDWI"), mask_type = "cloud_and_shadow",
                     max_mask = 30, max_cloud_safe = 5, list_rgb = c("RGB432B", "RGBb84B"), 
                     path_l2a = "C:/internship/sen2r_safe", path_l1c = "C:/internship/sen2r_safe", path_out ="C:/internship/sen2r_out" )
   
##### Multitemporal NDVI Oct 2020 - May 2021 10m resolution (dec 2019)
setwd("C:/internship/sen2r_out/NDVI")
wd1 <-setwd("C:/internship/sen2r_out/NDVI")
list <- list.files(pattern=".tif")
raster <- lapply(list, raster)
ndvi <- stack(raster)
shp <- st_transform(myextent, CRS("+proj=utm +zone=28 +datum=WGS84 +units=m +no_defs")) # setting the same CRS
ndvi_m <- mask(ndvi, shp)
names(ndvi_m) <- c("NDVIOct7","NDVIOct12","NDVINov01","NDVINov21","NDVIDec27","NDVIJan20","NDVIJan30","NDVIFeb14","NDVIFeb19","NDVIMar26", "NDVIApr10", "NDVIMay20")# I change the names of the images for an easly reading
plot(ndvi_m)



##### Multitemporal NDWI Oct 2020 - May 2021 10m resolution (dec 2019)

setwd("C:/internship/sen2r_out/NDWI")
wd2 <-setwd("C:/internship/sen2r_out/NDWI")
list1 <- list.files(pattern=".tif")
raster1 <- lapply(list1, raster)
ndwi <- stack(raster1)
shp <- st_transform(myextent, CRS("+proj=utm +zone=28 +datum=WGS84 +units=m +no_defs")) # setting the same CRS
ndwi_m <- mask(ndwi, shp)
names(ndwi_m) <- c("NDWIOct7","NDWIOct12","NDWINov01","NDWINov21", "NDVIDec27", "NDWIJan20","NDWIJan30","NDWIFeb14","NDWIFeb19","NDWIMar26", "NDWIApr10", "NDWIMay20")# I change the names of the images for an easly reading
plot(ndwi_m)


#Second method

# list of available S2 products (both online and LTA files)
s2list <- s2_list(spatial_extent= myextent, time_interval= time_window, time_period= "full", max_cloud= 5, level= "L2A", availability= "ignore") 
# I check which files of my list are online and which are not (T/F)
safe_is_online(s2list) # at the time the documentation was updated, this list was containing 4
# archives already available online and 4 stored in the Long Term Archive)

# If I want SAFE files that aren't anymore online I have 
# to order them with the s2_order function 
ordered_prods <- s2_order(s2list)
# once ordered, 
# it takes some time before they go online. you can check in a second moment if they are online.
safe_is_online(ordered_prods)

# Once they are online you can continue with the download
# download my list
s2_download(
  s2list, outdir= "C:/internship/sen2r_safe")

# Check in a second time if the product was made available
order_path <- attr(ordered_prods, "path")
safe_is_online(order_path)
# 2 of 4 Sentinel-2 images were not correctly ordered (HTML
# status code: 200) because some invalid SAFE products were stored on the
# ESA API Hub. Please retry ordering them on DHUS (set argument 'service
# = "dhus"' in function s2_order())
ordered_prods <- s2_order(s2list, service= "dhus")

# download my list
s2_download(
  s2list, outdir= "C:Users/micci/Documents/internship/sen2r_safe")

# in this way I can download just RAW files (SAFE products)
# So, which functions can I use to modify these SAFE products?

#### s2_translate() build a virtual raster from a Sentinel2 SAFE product

s2_l2a_example <- file.path(
  "C:/Internship/sen2r_safe",
  "S2B_MSIL2A_20210326T115219_N0214_R123_T28RCS_20210326T141845.SAFE")

# Create three products (ENVI) in the same directory at 10m resolution
s2_translate(
  s2_l2a_example, 
  format = "ENVI", 
  prod_type = c("BOA","TCI","SCL"),
  res = "10m", 
  subdirs = TRUE)

####s2_rgb() Create RGB images from Sentinel-2 reflectances
# Define file names
ex_in <- system.file(
"C:/Internship/sen2r_safe/BOA/S2B2A_20210326_123_28RCS_BOA_10.dat",
package = "sen2r")

# Run function (RIVEDERE CHE NON VA)
ex_out <- s2_rgb(
infiles = ex_in,
rgb_bands = list(c(11,8,4),c(8,4,3)),
scaleRange = list(c(0,7500), matrix(c(rep(0,3),8500,6000,4000),ncol=2)),
outdir = tempdir())

ex_out
# Show output
oldpar <- par(mfrow = c(1,3), mar = rep(0,4))
image(stars::read_stars(ex_in), rgb = 4:2, maxColorValue = 3500)
image(stars::read_stars(ex_out[1]), rgb = 1:3)
image(stars::read_stars(ex_out[2]), rgb = 1:3)
par(oldpar)

s2_mask() # Apply a cloud mask to a Sentinel-2 product
s2_perc_masked() #computes the percentage of cloud-masked surface
