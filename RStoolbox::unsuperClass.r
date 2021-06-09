setwd("C:/internship")
wd<- setwd("C:/internship")

library(raster)
library(RStoolbox)
library(viridis)

Jan <-  ndvi_m$NDVIJan20
Nov <- ndvi_m$NDVINov01
May <- ndvi_m$NDVIMay20
Jan1 <-  ndwi_m$NDWIJan20
Nov1 <- ndwi_m$NDWINov01

# # RStoolbox::unsuperClass

set.seed(42)
cl <- viridis(6)
library(scales)
show_col(viridis_pal()(20))


#tenerife Jan NDVI
Janr <- aggregate(Jan, fact= 10)
Janr20 <- aggregate(Jan, fact= 20)
Janr_cl <-  unsuperClass(Janr, nClasses = 6)
Janr_cl20 <-  unsuperClass(Janr, nClasses = 6)
plot(Janr_cl20$map, col=cl, main= "Unsupervised classification Jan", axes= FALSE)

#tenerife May NDVI
Mayr20 <- aggregate(May, fact= 20)
Mayr_cl20 <-  unsuperClass(Mayr, nClasses = 6)
plot(Mayr_cl20$map, col=cl, main= "Unsupervised classification May", axes= FALSE)


#tenerife nov NDVI
Novr <- aggregate(Nov, fact= 20)
Novr_cl20 <-  unsuperClass(Novr, nClasses = 6)
plot(Novr_cl20$map, col=cl, main= "Unsupervised classification Nov", axes= FALSE)


#tneerife Jan NDWI
Jan1r <- aggregate(Jan1, fact= 10)
Jan1r_cl <-  unsuperClass(Jan1r, nClasses = 6)
plot(Jan1r_cl$map, col=cl, main= "Unsupervised classification Jan", axes= FALSE)
# anaga
extent <- c( 370000, 390560, 3140000, 3163080 )


## teide
extent2 <- c(330000, 355000, 3117000, 3135000)


## teno

plot(tenerifer)
extent3 <- c(310000, 330000, 3130000, 3145000)


