setwd("C:/internship")
wd<- setwd("C:/internship")

library(sen2r)
library(raster)
library(sf)

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
ordered from the Long Term Archive

# safe_getMetadata() returns a data.table, a data.frame or a list (depending on argument format)
with the output metadata

myextent <- st_read("TEN.shp") #created by QGIS
time_window <-as.Date(c("2020-01-01","2020-12-31"))

# Show index names within the package
list_indices(c("name","longname"))  

# Return the NDVI formula, can be done for each indices to see the formula used
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

wd_ndvi <- setwd("C:/internship/sen2r_out/NDVI")
list.files(wd_ndvi)
tf_07 <- raster("S2B2A_20200719_123_Tenerife_NDVI_10.tif")

# mask tf
shp <- st_transform(myextent, CRS("+proj=utm +zone=28 +datum=WGS84 +units=m +no_defs")) # setting the same CRS
tf_07 <- mask( tf_07, shp)
plot(tf_07)
tf_07r<- aggregate(tf_07, fact=5)

## raster div
library(rasterdiv)
sha <- Shannon(tf_07r, window=9, rasterOut=TRUE, np=3,na.tolerance=0.9, cluster.type="SOCK", debugging=FALSE)
# error :  unused argument (rasterOut = TRUE)
sha <- Shannon(tf_07r, window=9, np=3,na.tolerance=0.9, cluster.type="SOCK", debugging=FALSE)
## needed "snow" packages
rao <- Rao(tf_07r, dist_m="euclidean", window=9, mode="classic",lambda=0, shannon=FALSE, rescale=FALSE, na.tolerance=0.9, simplify=3, np=3, cluster.type="SOCK", debugging=FALSE)



