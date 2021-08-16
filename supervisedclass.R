wd <- "C:/Internship/sen2r_safe/S2A_MSIL2A_20210120T115221_N0214_R123_T28RCS_20210121T162058.SAFE/60mbands_ndvi"
setwd(wd)

library(raster)
library(sp)
library(sf)

list <-  list.files(wd)
import <- lapply(list, raster)
stack <- stack(import)

myextent <- st_read("C:/internship/TEN.shp") #loading my shp
myextent <- st_transform(myextent,CRS(" +proj=utm +zone=28 +datum=WGS84 +units=m +no_defs")) #transforming the crs

stack <- mask(stack, myextent) 
stack <- crop(stack, myextent)
names(stack) <- c("B01", "B02", "B03", "B04", "B05", "B06", "B07", "B09", "B11", "B12", "B8a")
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
classn <- c("Cardonal-tabaibal", "Bosque Termófilo", "Laurisilva", "Fayal-brezal", "Pianar", "Alta montaña")
classdf <- data.frame(classvalue1 = c(1,2,3,4,5,6), classnames1 = classn) #create a df with a vector of values and a vector of names
classcolor <- c("#FEFEB1", "#40DFA0", "#006700", "#007373", "#905040", "#FFC2F5 ") #vector of color that I will use for the classification

# load a shp of random poligons within Tenerife created with QGIS
samp <- shapefile("C:/Internship/tenerife_classification.shp")
# generate 1000 point samples from the polygons
ptsamp <- spsample(samp, 1000, type='regular')
# add the land cover class to the points
ptsamp$Class <- over(ptsamp, samp)$Class
# extract values with points
df <- raster::extract(stack, ptsamp)

library(rasterVis)

#plot the stack with the points
plt <- levelplot(stack, col.regions = classcolor, main = 'Distribution of Training Sites')
print(plt + layer(sp.points(ptsamp, pch = 3, cex = 0.5, col = 1)))

### extract values for sites
# Extract the layer values for the locations
sampvals <- extract(stack, ptsamp, df = TRUE)

# drop the ID column
sampvals <- sampvals[, -1]
# combine the class information with extracted values
classvalue <- ptsamp$Class
sampdata <- data.frame(classvalue, sampvals)

## train the classifier
library(rpart)
# Train the model
cart <- rpart(as.factor(classvalue)~., data=sampdata, method = 'class', minsplit = 5)
# print(model.class)
# Plot the trained classification tree
plot(cart, uniform=TRUE, main="Classification Tree")
text(cart, cex = 0.8)

### Classify
# Now predict the subset data based on the model; prediction for entire area takes longer time
pr2020 <- predict(stack, cart, type='class')
pr2020

pr2020 <- ratify(pr2020)
rat <- levels(pr2020)[[1]]
rat$legend <- c("Alta montañ±a","Bosque Termófilo","Cardonal-tabaibal","Fayal-brezal", "Laurisilva", "Pinar")  
levels(pr2020) <- rat
levelplot(pr2020, maxpixels = 1e6,
          col.regions = classcolor,
          att = "legend",
          scales=list(draw=FALSE),
          main = "Decision Tree classification of Tenerife")

