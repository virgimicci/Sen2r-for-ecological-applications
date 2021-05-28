
# # RStoolbox::unsuperClass
wd1
ndvi_m
tf_2111ndvi<- raster("S2A2A_20201121_123_Tenerife_NDVI_10.tif")
shp <- st_transform(myextent, CRS("+proj=utm +zone=28 +datum=WGS84 +units=m +no_defs")) # setting the same CRS
tf_2111ndvi <- mask( tf_2111ndvi, shp)
plot(tf_2111ndvi)

set.seed(42)
cl <- viridis(6)

#tenerife
tenerifer <- aggregate(tf_2111ndvi, fact= 10)
tenerife <-  unsuperClass(tf_2111ndvi, nClasses = 6)
plot(tenerife$map, col=cl)

# anaga
extent <- c( 370000, 390560, 3140000, 3163080 )
anagandvi <- crop(tenerifer, extent)
anagandvic <- unsuperClass(anagandvi, nClasses = 4)

plot(anagandvic$map, col=cl, main = "Anaga piani vegetazionali")

par(mfrow=c(1,2))
plot(anagandvic$map, col=cl, main = "unsupervised classification (6)")
plot(anagandvi, main= "NDVI")

## teide
extent2 <- c(330000, 355000, 3117000, 3135000)
teidendvi <- crop(tenerifer, extent2)
teidendvic <- unsuperClass(teidendvi, nClasses = 3)
plot(teidendvic$map, col=cl, main = "Teide piani vegetazionali")

## teno

plot(tenerifer)
extent3 <- c(310000, 330000, 3130000, 3145000)
tenondvi <- crop(tenerifer, extent3)
tenondvic <- unsuperClass(tenondvi, nClasses = 4)
plot(tenondvic$map, col=cl, main = "Teide piani vegetazionali")

par(mfrow=c(1,3))
plot(tenondvic$map, col=cl, main = "Teide piani vegetazionali")
plot(anagandvic$map, col=cl, main = "Anaga piani vegetazionali")
plot(tenerife$map, col=cl)
