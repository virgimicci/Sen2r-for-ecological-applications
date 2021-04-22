
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



## Run sen2r interactively ##
sen2r()
# HTML interface
### First trial ###
# Type pf prpcessing: RAW files
#RAW Level-2A (Sentinel 2A and 2B)

###### sempre stesso errore: dati sci hub incorretti ma sono corretti ######
# risolto reinstallando geojeson

## Using sen2r() from the command line ##
out_dir_1  <- tempfile(pattern = "sen2r_out_1_") # output folder

safe_dir_1 <- tempfile(pattern = "sen2r_safe_")  # folder to store downloaded SAFE

myextent_1 <-"tenerife.shp" #spatial polygons needed to select tiles extent

# 1. The Normalized Difference Built-up Index (NDBI) uses the NIR and SWIR bands to emphasize manufactured built-up areas. 
# It is ratio based to mitigate the effects of terrain illumination differences as well as atmospheric effects.
# NDBI = (SWIR - NIR) / (SWIR + NIR)
# 2. The Normalized Difference Vegetation Index (NDVI) is an indicator of the greenness of the biomes.
# NDVI = (REF_nir – REF_red)/(REF_nir + REF_red)
# where REF_nir and REF_red are the spectral reflectances measured in the near infrared and red wavebands respectively, makes it widely used for ecosystems monitoring.
# 3. BOA (bottom of atmosphere) or surface radiance: Atmospheric correction is then a method how to try to remove influence of just that portion 
# of light reflected off atmosphere on the image and preserve the part reflected off the surface below.

out_paths_1 <- sen2r(gui = FALSE, preprocess = TRUE,
                     
                      s2_levels = "l2a",  sel_sensor = c("s2a", "s2b"),

                     step_atmcorr = "auto",

                     extent = myextent_1,

                     extent_name = "Tenerife",

                     timewindow = c(as.Date("2020-06-01"), as.Date("2020-08-31")),

                     timeperiod = "full",

                     list_prods = c("BOA"),

                     list_indices = c("NDVI","NDBI"),

                     mask_type = "cloud_and_shadow",

                     max_mask = 10,

                     res_s2 = "10m",

                     path_l2a = safe_dir_1,

                     path_out = out_dir_1,

                     parallel = 6,

                     resampling = "bilinear")
# sen2r Processing Report
#¦----------------------------------------------------------------------------------------------
#¦ Dates to be processed based on processing parameters: 18
#¦ Processing completed for: 8 out of 18 expected dates.
#¦ WARNING: Outputs for: 10 out of 18 expected dates not created because of unexpected reasons."
#¦ These files will be skipped during next executions from the current JSON parameter file. To
#¦ try again to build them, remove their file names in the text file
#¦ "C:\Users\Virginia\AppData\Local\Temp\RTMPMP~1\SEN2R_~3\IGNORE~1.TXT".
#¦ Outputs for: 10 out of 18 expected dates not created because cloudiness over the spatial
#¦ extent is above 10%.
#¦ The list of these files was written in a hidden file, so to be skipped during next executions
#¦ from the current JSON parameter file.
#¦ To process them again (e.g., because you changed the "max_mask" setting) delete their dates
#¦ in the text file "C:\Users\Virginia\AppData\Local\Temp\RTMPMP~1\SEN2R_~3\IGNORE~1.TXT".

#S2 original SAFE images are stored in the folder specified by `safe_dir_1`, 
#and are not deleted after processing (unless the user sets also the argument 
#`rm_safe` to `TRUE`).


list.files(safe_dir_1)
#[1] "S2A_MSIL2A_20200604T115231_N0214_R123_T28RCS_20200604T125727.SAFE"
#[2] "S2A_MSIL2A_20200614T115221_N0214_R123_T28RCS_20200614T155214.SAFE"
#[3] "S2A_MSIL2A_20200624T115221_N0214_R123_T28RCS_20200624T141538.SAFE"
#[4] "S2A_MSIL2A_20200704T115221_N0214_R123_T28RCS_20200704T125229.SAFE"
#[5] "S2A_MSIL2A_20200714T115221_N0214_R123_T28RCS_20200714T191310.SAFE"
#[6] "S2A_MSIL2A_20200724T115221_N0214_R123_T28RCS_20200724T142720.SAFE"
#[7] "S2A_MSIL2A_20200803T115221_N0214_R123_T28RCS_20200803T125216.SAFE"
#[8] "S2A_MSIL2A_20200813T115221_N0214_R123_T28RCS_20200813T130020.SAFE"
#[9] "S2A_MSIL2A_20200823T115221_N0214_R123_T28RCS_20200823T160612.SAFE"
#[10] "S2B_MSIL2A_20200609T115219_N0214_R123_T28RCS_20200609T154949.SAFE"
#[11] "S2B_MSIL2A_20200619T115219_N0214_R123_T28RCS_20200619T155214.SAFE"
#[12] "S2B_MSIL2A_20200629T115219_N0214_R123_T28RCS_20200629T155137.SAFE"
#[13] "S2B_MSIL2A_20200709T115219_N0214_R123_T28RCS_20200709T141705.SAFE"
#[14] "S2B_MSIL2A_20200719T115219_N0214_R123_T28RCS_20200719T155303.SAFE"
#[15] "S2B_MSIL2A_20200729T115219_N0214_R123_T28RCS_20200729T160543.SAFE"
#[16] "S2B_MSIL2A_20200808T115219_N0214_R123_T28RCS_20200808T142451.SAFE"
#[17] "S2B_MSIL2A_20200818T115219_N0214_R123_T28RCS_20200818T174433.SAFE"
#[18] "S2B_MSIL2A_20200828T115219_N0214_R123_T28RCS_20200828T132940.SAFE"

# Outputs are automatically subsetted and masked over the study area, 
# and stored in appropriate subfolders of `out_dir_1`.

# Output images are named based on the following schema:
# S2mll_date_orb_aoi_prod_res.ext
# S2mll= mission ID ("S2A" or "S2B") and product level (1C or 2A)
# date= acquisition date
# orb= orbit number
# aoi= specified by user to describe the AOI
# prod= ouput type
# res= is the minimum spatial resolution in metres of the original S2 bands used to generate the product (10, 20 or 60)
# ext= is the file extension.

list.files(out_dir_1)
# [1] "BOA"  "NDBI" "NDVI"

list.files(file.path(out_dir_1, "NDVI"))
#[1] "S2A2A_20200614_123_Tenerife_NDVI_10.tif" "S2A2A_20200714_123_Tenerife_NDVI_10.tif"
#[3] "S2A2A_20200823_123_Tenerife_NDVI_10.tif" "S2B2A_20200709_123_Tenerife_NDVI_10.tif"
#[5] "S2B2A_20200719_123_Tenerife_NDVI_10.tif" "S2B2A_20200808_123_Tenerife_NDVI_10.tif"
#[7] "S2B2A_20200818_123_Tenerife_NDVI_10.tif" "S2B2A_20200828_123_Tenerife_NDVI_10.tif"
#[9] "thumbnails"       

list.files(file.path(out_dir_1, "BOA"))
#[1] "S2A2A_20200614_123_Tenerife_BOA_10.tif" "S2A2A_20200714_123_Tenerife_BOA_10.tif"
#[3] "S2A2A_20200823_123_Tenerife_BOA_10.tif" "S2B2A_20200709_123_Tenerife_BOA_10.tif"
#[5] "S2B2A_20200719_123_Tenerife_BOA_10.tif" "S2B2A_20200808_123_Tenerife_BOA_10.tif"
#[7] "S2B2A_20200818_123_Tenerife_BOA_10.tif" "S2B2A_20200828_123_Tenerife_BOA_10.tif"
#[9] "thumbnails"         

list.files(file.path(out_dir_1, "NDBI"))
#[1] "S2A2A_20200614_123_Tenerife_NDBI_10.tif" "S2A2A_20200714_123_Tenerife_NDBI_10.tif"
#[3] "S2A2A_20200823_123_Tenerife_NDBI_10.tif" "S2B2A_20200709_123_Tenerife_NDBI_10.tif"
#[5] "S2B2A_20200719_123_Tenerife_NDBI_10.tif" "S2B2A_20200808_123_Tenerife_NDBI_10.tif"
#[7] "S2B2A_20200818_123_Tenerife_NDBI_10.tif" "S2B2A_20200828_123_Tenerife_NDBI_10.tif"
#[9] "thumbnails" 

##NON HO I FILE SCARICATI: provo un altra maniera##

library(sf)
myextent_1 <- st_read("tenerife.shp")
time_window <-as.Date(c("2015-01-01","2020-09-30")
                      
L2A_list_20<- s2_list(spatial_extent= myextent_1, time_interval= time_window, max_cloud=20, level= "L2A")
L2A_list_10<- s2_list(spatial_extent= myextent_1, time_interval= time_window, max_cloud=10, level= "L2A")
L2A_list_5<- s2_list(spatial_extent= myextent_1, time_interval= time_window, max_cloud=5, level= "L2A")

# View of my shp
library(ggplot2)
ggplot() + geom_sf(data=myextent_1, size=3, color= "green", fill= "green") + ggtitle("Tenerife") + coord_sf()
              
                      
                      
                      
                      
                      
                      
