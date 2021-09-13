## Supervised classification 60m bands+ ndvi ##
###############################################
wd <- "C:/Users/micci/Documents/Internship/sen2r_safe/S2A_MSIL2A_20210120T115221_N0214_R123_T28RCS_20210121T162058.SAFE/GRANULE/L2A_T28RCS_A029149_20210120T115219/IMG_DATA/R60m"
setwd(wd)

library(raster)
library(sp)
library(sf)
ndvi <- raster("C:/Users/micci/Documents/Internship/sen2r_out/NDVI/5S2A2A_20210120_123_Tenerife_NDVI_10.tif")
list <-  list.files(wd, pattern= "T28RCS_20210120T115221_B")
import <- lapply(list, raster)
stack <- stack(import)
# change dimensions and extent of the ndvi in order to stack with the bands
ndvi <- resample(ndvi, stack)
stack_ndvi <- addLayer(stack, ndvi)

myextent <- st_read("C:/Users/micci/Documents/internship/TEN.shp") #loading my shp
myextent <- st_transform(myextent," +proj=utm +zone=28 +datum=WGS84 +units=m +no_defs") #transforming the crs

stack_ndvi <- mask(stack_ndvi, myextent) 
stack_ndvi <- crop(stack_ndvi, myextent)
names(stack_ndvi) <- c("Ultra Blue", "Blue", "Green", "Red", "VNIR5","VNIR6","VNIR7",
                       "SWIR9", "sWIR11", "SWIR12", "VNIR8a", "NDVI")
# B1	60 m	443 nm	Ultra Blue (Coastal and Aerosol)
# B2	10 m	490 nm	Blue
# B3	10 m	560 nm	Green
# B4	10 m	665 nm	Red
# B5	20 m	705 nm	Visible and Near Infrared (VNIR)
# B6	20 m	740 nm	Visible and Near Infrared (VNIR)
# B7	20 m	783 nm	Visible and Near Infrared (VNIR)
# B8a	20 m	865 nm	Visible and Near Infrared (VNIR)
# B9	60 m	940 nm	Short Wave Infrared (SWIR)
# B11	20 m	1610 nm	Short Wave Infrared (SWIR)
# B12	20 m	2190 nm	Short Wave Infrared (SWIR)

# The class names and colors for plotting
classn <- c("Cardonal-tabaibal", "Bosque Termófilo", "Laurisilva", "Fayal-brezal", "Pianar", "Alta montaña", "Azonal")
classdf <- data.frame(classvalue1 = c(1,2,3,4,5,6,7), classnames1 = classn) #create a df with a vector of values and a vector of names
classcolor <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#00008B") #vector of color that I will use for the classification

# load a shp of random poligons within Tenerife created with QGIS
samp <- shapefile("C:/Users/micci/Documents/Internship/tenerife_classification.shp")
# generate 1000 point samples from the polygons
ptsamp <- spsample(samp, 1000, type='regular')
# add the land cover class to the points
ptsamp$Class <- over(ptsamp, samp)$Class
# extract values with points
ptsamp <- spTransform(ptsamp, "+proj=utm +zone=28 +datum=WGS84 +units=m +no_defs")
df <- raster::extract(stack_ndvi, ptsamp)

library(rasterVis)

#plot the stack with the points
plt <- levelplot(stack_ndvi, col.regions = classcolor, main = 'Distribution of Training Sites')
print(plt + layer(sp.points(ptsamp, pch = 3, cex = 0.5, col = 1)))

### extract values for sites
# Extract the layer values for the locations
sampvals <- extract(stack_ndvi, ptsamp, df = TRUE)

# drop the ID column
sampvals <- sampvals[, -1]
# combine the class information with extracted values
classvalue <- ptsamp$Class
sampdata <- data.frame(classvalue, sampvals)

## train the classifier
library(rpart)
# Train the model
cart <- rpart(as.factor(classvalue)~., data=sampdata, method = 'class', minsplit = 6)
# print(model.class)
# Plot the trained classification tree
plot(cart, uniform=TRUE, main="Classification Tree")
text(cart, cex = 0.8)

### Classify
# Now predict the subset data based on the model; prediction for entire area takes longer time
pr2020 <- predict(stack_ndvi, cart, type='class')
pr2020

pr2020 <- ratify(pr2020)
rat <- levels(pr2020)[[1]]
rat$legend <- c("Alta montaña","Azonal", "Bosque Termófilo","Cardonal-tabaibal","Fayal-brezal", "Laurisilva", "Pinar")  
levels(pr2020) <- rat
levelplot(pr2020, maxpixels = 1e6,
          col.regions = classcolor,
          att = "legend",
          scales=list(draw=FALSE),
          main = "Decision Tree classification of Tenerife")

##### Supervised classification 10m bands+ ndvi ##
###############################################

wd <- "C:/Users/micci/Documents/Internship/sen2r_safe/S2A_MSIL2A_20210120T115221_N0214_R123_T28RCS_20210121T162058.SAFE/GRANULE/L2A_T28RCS_A029149_20210120T115219/IMG_DATA/R10m"
setwd(wd)

list2 <-  list.files(wd, pattern= "T28RCS_20210120T115221_B")
import2 <- lapply(list2, raster)
stack2 <- stack(import2)
# change dimensions and extent of the ndvi in order to stack with the bands
ndvi2 <- resample(ndvi, stack2)
stack_ndvi2 <- addLayer(stack2, ndvi2)

stack_ndvi2 <- mask(stack_ndvi2, myextent) 
stack_ndvi2 <- crop(stack_ndvi2, myextent)
names(stack_ndvi2) <- c( "Blue", "Green", "Red", "VNIR", "NDVI")

# B2	10 m	490 nm	Blue
# B3	10 m	560 nm	Green
# B4	10 m	665 nm	Red
# B8	10 m	842 nm	Visible and Near Infrared (VNIR)


# The class names and colors for plotting
classn <- c("Cardonal-tabaibal", "Bosque Termófilo", "Laurisilva", "Fayal-brezal", "Pianar", "Alta montaña", "Azonal")
classdf <- data.frame(classvalue1 = c(1,2,3,4,5,6,7), classnames1 = classn) #create a df with a vector of values and a vector of names
classcolor <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#00008B") #vector of color that I will use for the classification

# load a shp of random poligons within Tenerife created with QGIS
samp <- shapefile("C:/Users/micci/Documents/Internship/tenerife_classification.shp")
# generate 1000 point samples from the polygons
ptsamp <- spsample(samp, 1000, type='regular')
# add the land cover class to the points
ptsamp$Class <- over(ptsamp, samp)$Class
# extract values with points
ptsamp <- spTransform(ptsamp, "+proj=utm +zone=28 +datum=WGS84 +units=m +no_defs")
df2 <- raster::extract(stack_ndvi2, ptsamp)

library(rasterVis)

#plot the stack with the points
plt <- levelplot(stack_ndvi2, col.regions = classcolor, main = 'Distribution of Training Sites')
print(plt + layer(sp.points(ptsamp, pch = 3, cex = 0.5, col = 1)))

### extract values for sites
# Extract the layer values for the locations
sampvals2 <- extract(stack_ndvi2, ptsamp, df = TRUE)

# drop the ID column
sampvals2 <- sampvals2[, -1]
# combine the class information with extracted values
classvalue <- ptsamp$Class
sampdata2 <- data.frame(classvalue, sampvals2)

## train the classifier
library(rpart)
# Train the model
cart2 <- rpart(as.factor(classvalue)~., data=sampdata2, method = 'class', minsplit = 8)
# print(model.class)
# Plot the trained classification tree
plot(cart2, uniform=TRUE, main="Classification Tree")
text(cart2, cex = 0.8)

### Classify
# Now predict the subset data based on the model; prediction for entire area takes longer time
pr2021_10m <- predict(stack_ndvi2, cart2, type='class')
pr2021_10m

pr2021_10m <- ratify(pr2021_10m)
rat2 <- levels(pr2021_10m)[[1]]
rat2$legend <- c("Alta montaña", "Azonal", "Bosque Termófilo","Cardonal-tabaibal","Fayal-brezal", "Laurisilva", "Pinar")  
levels(pr2021_10m) <- rat2
levelplot(pr2021_10m, maxpixels = 1e6,
          col.regions = classcolor,
          att = "legend",
          scales=list(draw=FALSE),
          main = "Decision Tree classification of Tenerife")
