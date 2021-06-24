 library(rasterdiv)

#Jan = NDVI 
rao <- Rao(Jan,dist_m="euclidean",mode="classic", shannon= TRUE)
accrao <- accRao(janr, method="classic", dist_m= "euclidean", window=3)

par(mfrow=(1,3))
plot(Jan, main= "NDVI Jan 2021", axes= F)
plot(shannonmatrix, main="Shannon's"

