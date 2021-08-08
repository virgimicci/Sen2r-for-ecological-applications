wd <- "C:/Internship/sen2r_safe/S2A_MSIL2A_20210120T115221_N0214_R123_T28RCS_20210121T162058.SAFE/60mbands_ndvi"
setwd(wd)

library(raster)
library(sp)
list <-  list.files(wd)
import <- lapply(list, raster)

import[[1]] <- resample(import[[1]], import[[2]])
stack <- stack(import)

myextent <- st_read("C:/internship/TEN.shp")
myextent <- st_transform(myextent,CRS(" +proj=utm +zone=28 +datum=WGS84 +units=m +no_defs"))

stack <- mask(stack, myextent) 
stack <- crop(stack, myextent)
names(stack) <- c("B01", "B02", "B03", "B04", "B05", "B06", "B07", "B09", "B11", "B12", "B8a")

# The class names and colors for plotting
classn <- c("Cardonal-tabaibal", "B, Termófilo", "Laurisilva", "Fayal-brezal", "Pianar", "Alta montaña")
classdf <- data.frame(classvalue1 = c(1,2,3,4,5,6), classnames1 = classn)
classcolor <- c("#FEFEB1", "#40DFA0", "#006700", "#007373", "#905040", "#FFC2F5 ")

samp <- shapefile("C:/Internship/tenerife_classification.shp")
# generate 300 point samples from the polygons
ptsamp <- spsample(samp, 300, type='regular')
# add the land cover class to the points
ptsamp$Class <- over(ptsamp, samp)$Class
# extract values with points
df <- raster::extract(stack, ptsamp)


library(rasterVis)

plt <- levelplot(stack, col.regions = classcolor, main = 'Distribution of Training Sites')
print(plt + layer(sp.points(ptsamp, pch = 3, cex = 0.5, col = 1)))
