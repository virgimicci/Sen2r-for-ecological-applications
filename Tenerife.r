setwd("C:/internship")
wd<- setwd("C:/internship")

install.packages("sen2r")
# Error: 
# Some missing packages are needed to run the GUI; please install them with
# the command
# > install.packages(c("leaflet", "leafpm", "mapedit", "shiny", "shinyFiles", "shinydashboard", "shinyjs", "shinyWidgets")) 
install.packages(c("leaflet", "leafpm", "mapedit", "shiny", "shinyFiles", "shinydashboard", "shinyjs", "shinyWidgets"))

library(sen2r)
library(raster)
library(sf)
library(RStoolbox)
library(viridis)

# Check shihub credentials
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

myextent <- st_read("TEN.shp") #created by QGIS
time_window <-as.Date(c("2020-01-01","2020-12-31"))

# Show index names within the package
list_indices(c("name","longname"))  

# Return the NDVI formula, can be done for each indices to see the formula 
list_indices("s2_formula", "NDVI")


out_paths_1 <- sen2r(gui= FALSE, extent = myextent, extent_name = "Tenerife", timewindow = time_window, 
                     timeperiod = "full", list_prods = c("BOA"), 
                     list_indices = c("NDVI"), mask_type = "cloud_and_shadow",
                     max_mask = 30, max_cloud_safe = 10, list_rgb = c("RGB432B", "RGBb84B"), 
                     path_l2a = "C:/internship/sen2r_safe", path_l1c = "C:/internship/sen2r_safe", path_out ="C:/internship/sen2r_out" )
                     
## Warning message:
## Processing was not completed because some required images are offline   

## Nessuna immagine è online quindi vado a scaricarle https://scihub.copernicus.eu/dhus/#/home
# riprovo

# NDVI 
# # RStoolbox::unsuperClass
wd_ndvi <- setwd("C:/internship/sen2r_out/NDVI")
list.files(wd_ndvi)
tf_2111ndvi<- raster("S2A2A_20201121_123_Tenerife_NDVI_10.tif")
shp <- st_transform(myextent, CRS("+proj=utm +zone=28 +datum=WGS84 +units=m +no_defs")) # setting the same CRS
tf_2111ndvi <- mask( tf_2111ndvi, shp)
plot(tf_2111ndvi)

set.seed(95)
cl <- viridis(6)

#tenerife
tenerifer <- aggregate(tf_2111ndvi, fact= 10)
tenerife <-  unsuperClass(tf_2111ndvi, nClasses = 6)
plot(tenerife$map, col=cl)

# anaga
extent <- c( 370000, 390560, 3140000, 3163080 )
anagandvi <- crop(tf_2111ndvi, extent)
anagandvic <- unsuperClass(anagandvi, nClasses = 6)


plot(anagandvic$map, col=cl)

par(mfrow=c(1,2))
plot(anagandvic$map, col=cl, main = "unsupervised classification (6)")
plot(anagandvi, main= "NDVI")


# Rstoolbox::unsuperClass
anagac <- unsuperClass(anaga, nClasses = 7)
cl <- colorRampPalette(c('yellow','black','red'))(100)
plot(anaga$map, col = cl)


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


