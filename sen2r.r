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

# Check shihub credentials
write_scihub_login() # to write new credentials
read_scihub_login() # returns a matrix of credentials, in which username is in the first column, password in the second
check_scihub_login("name", "password") #  returns TRUE if credentials are valid, FALSE elsewhere
check_scihub_connection() #  returns TRUE if internet connection is available and SciHub is accessible, FALSE otherwise.

### SOME imp FUNCTIONS 
# check_sen2r_deps()  The function allows to graphically check that all the optional runtime dependencies are installed
# external dependencies in order to run specific actions, I think for L1C that are not corrected 
# • Sen2Cor for atmospheric correction;
# • GDAL for cloud mask smoothing and buffering;
# • aria2 to download SAFE images with an alternative downloader

# safe_is_online() if the required SAFE archives are available for download, or if they have to be
# ordered from the Long Term Archive

# safe_getMetadata() returns a data.table, a data.frame or a list (depending on argument format)
# with the output metadata

#### TAKING DATA FROM senr2 ######
myextent <- st_read("TEN.shp") #created by QGIS
# chek on copernicus hub my images: how they are, which are online and which not
# if i have images that I need that are offline I order it (they will be online for me for a delimited time, then they will return offline)
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


# # RStoolbox::unsuperClass
wd1
ndvi_m
tf_2111ndvi<- raster("S2A2A_20201121_123_Tenerife_NDVI_10.tif")
shp <- st_transform(myextent, CRS("+proj=utm +zone=28 +datum=WGS84 +units=m +no_defs")) # setting the same CRS
tf_2111ndvi <- mask( tf_2111ndvi, shp)
plot(tf_2111ndvi)

set.seed(42)
cl <- viridis(6)

#tenerife
tenerifer <- aggregate(tf_2111ndvi, fact= 10)
tenerife <-  unsuperClass(tf_2111ndvi, nClasses = 6)
plot(tenerife$map, col=cl)

# anaga
extent <- c( 370000, 390560, 3140000, 3163080 )
anagandvi <- crop(tenerifer, extent)
anagandvic <- unsuperClass(anagandvi, nClasses = 4)

plot(anagandvic$map, col=cl, main = "Anaga piani vegetazionali")

par(mfrow=c(1,2))
plot(anagandvic$map, col=cl, main = "unsupervised classification (6)")
plot(anagandvi, main= "NDVI")

## teide
extent2 <- c(330000, 355000, 3117000, 3135000)
teidendvi <- crop(tenerifer, extent2)
teidendvic <- unsuperClass(teidendvi, nClasses = 3)
plot(teidendvic$map, col=cl, main = "Teide piani vegetazionali")

## teno

plot(tenerifer)
extent3 <- c(310000, 330000, 3130000, 3145000)
tenondvi <- crop(tenerifer, extent3)
tenondvic <- unsuperClass(tenondvi, nClasses = 4)
plot(tenondvic$map, col=cl, main = "Teide piani vegetazionali")

par(mfrow=c(1,3))
plot(tenondvic$map, col=cl, main = "Teide piani vegetazionali")
plot(anagandvic$map, col=cl, main = "Anaga piani vegetazionali")
plot(tenerife$map, col=cl)

###################
# tenerife marzo-aprile-maggio # nuvolenuvolenuvoleeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee :/
time_window <-as.Date(c("2020-03-01","2020-05-31"))
L2A_list_5 <- s2_list(spatial_extent= myextent, time_interval= time_window, max_cloud=5, level= "L2A")
L2A_list_5
safe_is_online(L2A_list_5) # All 3 products are online
# S2B_MSIL2A_20200301T115219_N0214_R123_T28RCS_20200301T141311.SAFE 
#                                                             TRUE 
# S2B_MSIL2A_20200430T115219_N0214_R123_T28RCS_20200430T141757.SAFE 
#                                                             TRUE 
# S2A_MSIL2A_20200505T115221_N0214_R123_T28RCS_20200505T125034.SAFE 
#                                                             TRUE 
# in this way i'll just hace SAFE files 
s2_download(L2A_list, outdir= "sen2r_safe") # download the safe files 

# provo 2018
time_window <-as.Date(c("2018-03-01","2018-05-31"))
L2A_list <- s2_list(spatial_extent= myextent, time_interval= time_window, max_cloud=0, level= "L2A")
L2A_list_5


