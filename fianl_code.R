## Unsupervised and supervised classification through Sentinelle images ##

## Download of sentinnelle images 
# sen2r

wd <- setwd("C:/Users/micci/Documents/internship")
wd
install.packages("sen2r")
install.packages("geojsonlint")
install.packages(c("leaflet", "leafpm", "mapedit", "shiny", "shinyFiles", "shinydashboard", "shinyjs", "shinyWidgets"))

library(sen2r)
library(raster)
library(sf)

sen2r() # for an interactive use
# Otherwise:
# Scihub_login
write_scihub_login("name", "password") # save new username and password
read_scihub_login() # returns a matrix of credentials, in which username is in the first column, password in the second
check_scihub_login("name", "password") #  returns TRUE if credentials are valid, FALSE elsewhere
check_scihub_connection() #  returns TRUE if internet connection is available and SciHub is accessible, FALSE otherwise.

### Taking data from sen2r of Tenerife in 2020-2021
# important: we can download just online images, so we have to check through Copernicus Hub if the images we want
# are availabe, otherwise we have to order them and they will be availabe for a limited time

# load the shp file for the area we want
myextent <- st_read("TEN.shp") # created by QGIS
# time window from which we want the images
time_window <-as.Date(c("2020-10-01","2021-05-27"))

# Code for the download
# Show index names within the package
list_indices(c("name","longname"))
# Return the NDVI formula, can be done for each indices to see the formula 
list_indices("s2_formula", "NDVI")

# I created two folder in order to save my files: sen2r_safe (for SAFE products) and sen2r_out (for the modified products)
out_paths_1 <- sen2r(gui= FALSE, extent = myextent, extent_name = "Tenerife", timewindow = time_window, 
                     timeperiod = "full", list_prods = c("BOA"), 
                     list_indices = c("NDVI"), mask_type = "cloud_and_shadow",
                     max_mask = 30, max_cloud_safe = 20, list_rgb = c("RGB432B", "RGBb84B"), 
                     path_l2a = "C:/Users/micci/Documents/internship/sen2r_safe", 
                     path_l1c = "C:/Users/micci/Documents/internship/sen2r_safe", 
                     path_out ="C:/Users/micci/Documents/internship/sen2r_out" )

## Multitemporal NDVI Oct 2020 - May 2021 10m resolution (dec 2019)
wd1 <- setwd("C:/Users/micci/Documents/internship/sen2r_out/NDVI")
wd1 
# import and stack the images
NDVI <- list.files(pattern=".tif") %>% lapply(raster) %>% stack()
# setting the same CRS
shp <- st_transform(myextent,"+proj=utm +zone=28 +datum=WGS84 +units=m +no_defs") 
NDVI_m <- mask(NDVI, shp) %>% crop(shp)
# Change the names of the images for an easly reading
names(NDVI_m) <- c("NDVIOct7","NDVIOct12","NDVINov01","NDVINov21","NDVIJan20","NDVIJan30","NDVIFeb14","NDVIFeb19","NDVIMar26", "NDVIApr10", "NDVIMay20")
plot(NDVI_m)

## Unsupervised classidication
## RStoolbox::unsperClass
library(RStoolbox)
library(viridis)
wd2 <- "C:/Users/micci/Documents/Internship/sen2r_safe/S2A_MSIL2A_20210120T115221_N0214_R123_T28RCS_20210121T162058.SAFE/GRANULE/L2A_T28RCS_A029149_20210120T115219/IMG_DATA/R10m"
setwd(wd2)
NDVI_Jan <- raster("C:/Users/micci/Documents/internship/sen2r_out/NDVI/5S2A2A_20210120_123_Tenerife_NDVI_10.tif")
# 10m bands resolution
stack10m_Jan <- list.files(pattern= "T28RCS_20210120T115221_B") %>% lapply(raster) %>% stack()

# they have different extent, so we have to set the same extent
NDVI_Jan_10m <- resample(NDVI_Jan, stack10m_Jan)
stack10m_ndvi_Jan <- addLayer(stack10m_Jan, NDVI_Jan_10m) %>% mask(shp) %>% crop(shp)
## Bands we have in the 10 m resolution
# B2	10 m	490 nm	Blue
# B3	10 m	560 nm	Green
# B4	10 m	665 nm	Red
# B8	10 m	842 nm	Visible and Near Infrared (VNIR)
names(stack10m_ndvi_Jan) <- c( "Blue", "Green", "Red", "VNIR", "NDVI")

set.seed(42)
cl <- viridis(6)
# Unsupervised clssification
class_10m <- unsuperClass(stack10m_ndvi_Jan, nClasses = 6)
plot(class_10m$map, col=cl, main= "Unsupervised classification 10m resolution", axes= FALSE)

# 60m band resolution 
wd3 <- "C:/Users/micci/Documents/Internship/sen2r_safe/S2A_MSIL2A_20210120T115221_N0214_R123_T28RCS_20210121T162058.SAFE/GRANULE/L2A_T28RCS_A029149_20210120T115219/IMG_DATA/R60m"
setwd(wd3)
stack60m_Jan <- list.files(pattern= "T28RCS_20210120T115221_B") %>% lapply(raster) %>% stack()
NDVI_Jan_60m <- resample(NDVI_Jan, stack60m_Jan)
stack60m_ndvi_Jan <- addLayer(stack60m_Jan, NDVI_Jan_60m) %>% mask(shp) %>% crop(shp)
names(stack60m_ndvi_Jan) <- c("Ultra Blue", "Blue", "Green", "Red", "VNIR5","VNIR6","VNIR7",
                       "SWIR9", "sWIR11", "SWIR12", "VNIR8a", "NDVI")

# Unsupervised clssification
class_60m <-  unsuperClass(stack60m_ndvi_Jan, nClasses = 6)
plot(class_60m$map, col=cl, main= "Unsupervised classification 60m resolution", axes= FALSE)

par(mfrow=c(1,2))
plot(class_10m$map, col=cl, main= "Unsupervised classification 10m resolution", axes= FALSE)
plot(class_60m$map, col=cl, main= "Unsupervised classification 60m resolution", axes= FALSE)

## Supervised classification
# bioclimatic floors in Tenerife 
# Cardonal- tabaibal
# Bosque Termofilo 
# Laurisilva 
# Fayal- brezal
# Pinar
# Alta montaña

# 60m resolution 
setwd(wd3)

# The class names and colors for plotting
classn <- c("Cardonal-tabaibal", "Bosque Termófilo", "Laurisilva", "Fayal-brezal", "Pianar", "Alta montaña", "Azonal")
classdf <- data.frame(classvalue1 = c(1,2,3,4,5,6,7), classnames1 = classn) #create a df with a vector of values and a vector of names
classcolor <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#00008B") #vector of color that I will use for the classification

# load a shp of random poligons within Tenerife created with QGIS
samp <- shapefile("C:/Users/micci/Documents/Internship/tenerife_classification.shp")
# set the same crs between samp and stack
samp <- spTransform(samp, "+proj=utm +zone=28 +datum=WGS84 +units=m +no_defs")
# generate 1000 point samples from the polygons
ptsamp <- spsample(samp, 1000, type='regular')
# add the bioclimatic floors class to the points
ptsamp$Class <- over(ptsamp, samp)$Class
# extract values with points
df60m <- raster::extract(stack60m_ndvi_Jan, ptsamp)
head(df60m)

# Plot the training sites over the bands to visualize the sampling locations
library(rasterVis)
plt60m <- levelplot(stack60m_ndvi_Jan, col.regions = classcolor, main = 'Distribution of Training Sites')
print(plt60m + layer(sp.points(ptsamp, pch = 3, cex = 0.5, col = 1)))

# Extract values for sites
# Extract the layer values for the locations
sampvals60m <- extract(stack60m_ndvi_Jan, ptsamp, df = TRUE)
# drop the ID column
sampvals60m <- sampvals60m[, -1]
# combine the class information with extracted values
classvalue <- ptsamp$Class
sampdata60m <- data.frame(classvalue, sampvals60m)

# Now we will train the classification algorithm using training dataset
library(rpart)
# Train the model
cart60m <- rpart(as.factor(classvalue)~., data=sampdata60m, method = 'class', minsplit = 8)
# print(model.class)
# Plot the trained classification tree
par(mfrow=c(1,1))
plot(cart60m, uniform=TRUE, main="Classification Tree 60m resolution")
text(cart60m, cex = 0.8)

### Classify
# Now predict the subset data based on the model (cart60m) : classify all the cells in the stack
pr2021_60m <- predict(stack60m_ndvi_Jan, cart60m, type='class')
pr2021_60m

pr2021_60m <- ratify(pr2021_60m)
rat60m <- levels(pr2021_60m)[[1]]
# The names in the Raster object to be classified should exactly match those 
# expected by the model 
rat60m$legend <- c("Alta montaña", "Azonal", "Bosque Termófilo",
"Cardonal-tabaibal","Fayal-brezal", "Laurisilva", "Pinar")  
levels(pr2021_10m) <- rat60m
levelplot(pr2021_10m, maxpixels = 1e6,
          col.regions = classcolor,
          att = "legend",
          scales=list(draw=FALSE),
          main = "Decision Tree classification of Tenerife 60m resolution with NDVI")

# 10m band resolution 
setwd(wd2)

# extract values with points
df10m <- raster::extract(stack10m_ndvi_Jan, ptsamp)

# Plot the training sites over the bands to visualize the sampling locations
plt10m <- levelplot(stack10m_ndvi_Jan, col.regions = classcolor, main = 'Distribution of Training Sites')
print(plt10m + layer(sp.points(ptsamp, pch = 3, cex = 0.5, col = 1)))

# Extract values for sites
# Extract the layer values for the locations
sampvals10m <- extract(stack10m_ndvi_Jan, ptsamp, df = TRUE)
# drop the ID column
sampvals10m <- sampvals10m[, -1]
# combine the class information with extracted values
classvalue <- ptsamp$Class
sampdata10m <- data.frame(classvalue, sampvals10m)

# Now we will train the classification algorithm using training dataset
# Train the model
cart10m <- rpart(as.factor(classvalue)~., data=sampdata10m, method = 'class', minsplit = 10)
# print(model.class)
# Plot the trained classification tree
plot(cart10m, uniform=TRUE, main="Classification Tree 10m resolution")
text(cart10m, cex = 0.8)

### Classify
# Now predict the subset data based on the model (cart10m) : classify all the cells in the stack
pr2021_10m <- predict(stack10m_ndvi_Jan, cart10m, type='class')
pr2021_10m

pr2021_10m <- ratify(pr2021_10m)
rat10m <- levels(pr2021_10m)[[1]]
# The names in the Raster object to be classified should exactly match those 
# expected by the model 
rat10m$legend <- c("Alta montaña", "Azonal", "Bosque Termófilo",
"Cardonal-tabaibal","Fayal-brezal", "Laurisilva", "Pinar")  
levels(pr2021_10m) <- rat10m
levelplot(pr2021_10m, maxpixels = 1e6,
          col.regions = classcolor,
          att = "legend",
          scales=list(draw=FALSE),
          main = "Decision Tree classification of Tenerife 10m resolution with NDVI")
