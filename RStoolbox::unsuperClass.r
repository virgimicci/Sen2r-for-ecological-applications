
library(raster)
library(RStoolbox)
library(viridis)

# # RStoolbox::unsuperClass

set.seed(42)
cl <- viridis(6)

# Unsupervised classification 20 Jan all the bands + NDVI 60m
wd <- "C:/Internship/sen2r_safe/S2A_MSIL2A_20210120T115221_N0214_R123_T28RCS_20210121T162058.SAFE/60mbands_ndvi"
setwd(wd)
list <-  list.files(wd)
import <- lapply(list, raster)

import[[1]] <- resample(import[[1]], import[[2]])
stack <- stack(import)

myextent <- st_read("C:/internship/TEN.shp")
myextent <- st_transform(myextent,CRS(" +proj=utm +zone=28 +datum=WGS84 +units=m +no_defs"))

stack <- mask(stack, myextent) 
stack <- crop(stack, myextent)
names(stack) <- c("B01", "B02", "B03", "B04", "B05", "B06", "B07", "B09", "B11", "B12", "B8a")
NDVI <- (stack$B8a -  stack$B04) / (stack$B8a + stack$B04)
stack_ndvi <- addLayer(stack,NDVI)

Jan20_multiband <-  unsuperClass(stack_ndvi, nClasses = 6)
plot(Jan20_multiband$map, col=cl, main= "Unsupervised classification Jan multiband", axes= FALSE)

# Unsupervised classification Jan NDVI
class_ndvi <- unsuperClass(NDVI, nClasses = 6)
plot(class_ndvi$map, col=cl, main= "Unsupervised classification NDVI", axes= FALSE)

# Compare them 
par(mfrow=c(1,2))
plot(Jan20_multiband$map, col=cl, main= "Unsupervised classification Jan multiband", axes= FALSE)
plot(class_ndvi$map, col=cl, main= "Unsupervised classification NDVI", axes= FALSE)
    
# anaga
extent <- c( 370000, 390560, 3140000, 3163080 )

importndvi 
## teide
extent2 <- c(330000, 355000, 3117000, 3135000)


## teno

plot(tenerifer)
extent3 <- c(310000, 330000, 3130000, 3145000)



