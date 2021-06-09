 library(rasterdiv)

#Janr = NDVI resamples x10


accRao <- accRao(alphas=1:10, x=Janr, dist_m="euclidean", window=9,method = "multidimension")
