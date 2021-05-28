library(RStoolbox)
library(viridis)

Jan <-  ndvi_m$NDVIJan20
Nov <- ndvi_m$NDVINov01
# # RStoolbox::unsuperClass

set.seed(42)
cl <- viridis(6)

#tenerife Jan
Janr <- aggregate(Jan, fact= 10)
Janr_cl <-  unsuperClass(Janr, nClasses = 6)
plot(Janr_cl$map, col=cl, main= "Unsupervised classification Jan")

#tenerife nov
Novr <- aggregate(Nov, fact= 10)
Novr_cl <-  unsuperClass(Novr, nClasses = 6)
plot(Novr_cl$map, col=cl, main= "Unsupervised classification Nov")

# anaga
extent <- c( 370000, 390560, 3140000, 3163080 )


## teide
extent2 <- c(330000, 355000, 3117000, 3135000)


## teno

plot(tenerifer)
extent3 <- c(310000, 330000, 3130000, 3145000)

