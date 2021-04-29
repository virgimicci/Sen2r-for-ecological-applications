
install.packages("sen2r")
# Error: 
# Some missing packages are needed to run the GUI; please install them with
# the command
# > install.packages(c("leaflet", "leafpm", "mapedit", "shiny", "shinyFiles", "shinydashboard", "shinyjs", "shinyWidgets")) 
install.packages(c("leaflet", "leafpm", "mapedit", "shiny", "shinyFiles", "shinydashboard", "shinyjs", "shinyWidgets"))

install.packages("remotes")

setwd("C:/internship/")
library(sen2r)
library(remotes)
library(sp)
library(raster)

### Installing Sen2Cor
## is used to perform atmospheric correction of Sentinel-2 Level-1C products

library(sen2r)
check_sen2r_deps() #from this GUI a new Sen2Cor installation can be performed, or an existing environment can be linked to Sen2Cor.
# the check_sen2r_deps() can be used to install other dependencies as GDAL and aria2 (their installation is generally unrequired (they do not add relevant
# improvements to the package) and discouraged (errors could occur).)


### Sentinel bands
# 1. Band 1 -- Aerosol (443 nm)
# 2. Band 2 -- Blue (490 nm)
# 3. Band 3 -- Green (560 nm)
# 4. Band 4 -- Red (665 nm)
# 5. Band 5 -- Red-edge 1 (705 nm)
# 6. Band 6 -- Red-edge 2 (740 nm)
# 7. Band 7 -- Red-edge 3 (783 nm)
# 8. 
#    - on rasters with an output resolution < 20m:
#       Band 8 -- NIR (842 nm)
#   - on rasters with an output resolution >= 20m:
#        Band 8A -- narrow NIR (865 nm)
# 9. Band 9 -- Water vapour (940 nm)
# - on raster TOA (Top of Atmosphere)
# 10. Band 10 -- Cirrus (1375 nm)
# 11. Band 11 -- SWIR1 (1610 nm)
# 12. Band 12 -- SWIR2 (2190 nm)
# - on raster BOA (Bottom of atmosphere)
# 10. Band 11 -- SWIR1 (1610 nm)
# 11. Band 12 -- SWIR2 (2190 nm)



### Run sen2r interactively ###
sen2r()
# HTML interface
###### sempre stesso errore: dati sci hub incorretti ma sono corretti ######
# risolto reinstallando geojson

### Using sen2r() from the command line ###

# 1. The Normalized Difference Vegetation Index (NDVI) is an indicator of the greenness of the biomes.
# NDVI = (REF_nir – REF_red)/(REF_nir + REF_red)
# where REF_nir and REF_red are the spectral reflectances measured in the near infrared and red wavebands respectively, makes it widely used for ecosystems monitoring.
# 2. BOA (bottom of atmosphere) or surface radiance: Atmospheric correction is then a method how to try to remove influence of just that portion 
# of light reflected off atmosphere on the image and preserve the part reflected off the surface below.


# My AOI
library(sf)
myextent_1 <- st_read("tenerife.shp") #created by QGIS

# View of my shp
library(ggplot2)
ggplot() + geom_sf(data=myextent_1, size=3, color= "green", fill= "green") + ggtitle("Tenerife") + coord_sf()

time_window <-as.Date(c("2015-04-01","2020-05-31"))

##### Download with the s2_download function #####

# list of safe file available for my AOI, when I have images with max cloudiness of 5% i pick that ones otherwise the ones with 10/20%
L2A_list_20 <- s2_list(spatial_extent= myextent_1, time_interval= time_window, max_cloud=20, level= "L2A")
L2A_list_10 <- s2_list(spatial_extent= myextent_1, time_interval= time_window, max_cloud=10, level= "L2A")
L2A_list_5 <- s2_list(spatial_extent= myextent_1, time_interval= time_window, max_cloud=5, level= "L2A")

# I don't have L2A files before 2017, so if I want images of 2015 and 2016 I have to take L1C files and then use sen2cor()
L1C_list_10 <- s2_list(spatial_extent= myextent_1, time_interval= time_window, max_cloud=10, level= "L1C")
         
# View of the list of SAFE files, in order to see which are available 
names(L2A_list_20) # L2A_list_20[c(49,48)] # 2019
names(L2A_list_10)  #L2A_list_10[c(1,6)] # 2017
names(L2A_list_5) # L2A_list_5[c(4,22,23)] # 2018 2020
names(L1C_list_10) #L1C_list_10[c(4)] # 2016

# I want images in spring (April/May) for each year, so I create a vector with the SAFE files i need 
L2A_list <- c(L2A_list_20[c(49,48)],L2A_list_10[c(1,6)],L2A_list_5[c(4,22,23)])

# Check which are available online for the download and which ones from the LTA
safe_is_online(L2A_list) # 2 out of 7 products are online.                   
s2_download(L2A_list, outdir= "L2A") # download the safe files                      

###### Let's do it with the sen2r() function #####
                      
out_paths_1 <- sen2r(gui= FALSE, extent = myextent_1, extent_name = "Tenerife", timewindow = time_window, 
                     timeperiod = "seasonal", list_prods = c("BOA", "SCL"), 
                     list_indices = c("NDVI"), mask_type = "cloud_and_shadow",
                     max_mask = 20, list_rgb = c("RGB432B", "RGBb84B"), 
                     path_l2a = "C:/internship/sen2r_safe", path_l1c = "C:/internship/sen2r_safe", path_out ="C:/internship/sen2r_out" )  

# See what we have
list.files(file.path("C:/internship/sen2r_safe"))
# [1] "S2A_MSIL2A_20200405T115221_N0214_R123_T28RCS_20200405T125826.SAFE.zip"
# [2] "S2A_MSIL2A_20200415T115221_N0214_R123_T28RCS_20200415T155439.SAFE"    
# [3] "S2A_MSIL2A_20200425T115221_N0214_R123_T28RCS_20200425T141633.SAFE"  
# ... etc

# NDVI visualisation 
list.files(file.path("C:/internship/sen2r_out", "NDVI"))
# [1] "S2A2A_20200505_123_Tenerife_NDVI_10.tif" "S2A2A_20200525_123_Tenerife_NDVI_10.tif"
# [3] "S2B2A_20200420_123_Tenerife_NDVI_10.tif" "S2B2A_20200430_123_Tenerife_NDVI_10.tif"
# [5] "S2B2A_20200510_123_Tenerife_NDVI_10.tif" "S2B2A_20200520_123_Tenerife_NDVI_10.tif"
#[7] "thumbnails"  
setwd("C:/internship/sen2r_out/NDVI")
NDVI <- stack("S2B2A_20200420_123_Tenerife_NDVI_10.tif","S2B2A_20200430_123_Tenerife_NDVI_10.tif","S2A2A_20200505_123_Tenerife_NDVI_10.tif",
              "S2B2A_20200510_123_Tenerife_NDVI_10.tif", "S2B2A_20200520_123_Tenerife_NDVI_10.tif", "S2A2A_20200525_123_Tenerife_NDVI_10.tif")
plot(NDVI)

shp <-shapefile("C:/thesis work/tenerife.shp")
shp <- spTransform(shp, CRS(" +proj=utm +zone=28 +datum=WGS84 +units=m +no_defs"))
NDVI_shp<- mask(NDVI, shp)
plot(NDVI_shp)

cl <- colorRampPalette(c('lightpink4','light blue','darkorchid3'))(100) 
plot(NDVI_shp, col= cl)                
                   
