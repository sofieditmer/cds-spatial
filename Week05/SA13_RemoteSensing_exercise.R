##-----------------------------------------------##
##    Author: Adela Sobotkova                    ##
##    Institute of Culture and Society           ##
##    Aarhus University, Aarhus, Denmark         ##
##    adela@cas.au.dk                            ##
##-----------------------------------------------##

#### Goals ####

# - learn to work with satellite imagery in the landsat package
# - extract and create new data from images
# - segment features in satellite imagery

### 1. Start by installing the required packages first. 
# these are not on worker2, sorry!
install.packages(c("rasterVis", 
                   "RColorBrewer", 
                   "landsat",
                   "lattice",
                   "latticeExtra",
                   "rgl",
                   "itcSegment"))

### 2. Pre-processing Landsat datasets 
library(landsat)

##loading indvidual band image data from landsat package
?nov
# This is a sample landsat ETM+ data. It is a 300x300 subset. Each band is in its own file. 

#loading band#3 red channel of the image
data(nov3) # loading band 3
plot(nov3) # plotting band 3

data(nov4) # loading band 4
plot(nov4) # plotting band 4
# Colors have changed a bit. 
# Colors in plot vary from 0 (black) to 255 (white). Normal colors are between.

###   Libraries needed
library(raster)
library(lattice)
library(latticeExtra)
library(RColorBrewer)
library(rasterVis)
library(rgdal)
library(rgl)

# load and plot the dem in landsat package
data(dem)
plot(dem) # elevation values. High values = yellow
dem <- raster(dem) # converting spatial dataframe into raster layer

# this neat 3D viewer opens in a new window
plot3D(dem, rev=T, zfac=1)
# Now we get a 3D model of the dem object (elevation model)

### let's create an RGB image and drape it over the 3D model
# Loading all the different bands:
data("july1")
data("july2")
data("july3")
data("july4")

# Feeding the bands into different rasters
# Hence we are converting from spatial dataframe into raster layers
j1<-raster(july1) # blue
j2<-raster(july2) # green
j3<-raster(july3) # red
j4<-raster(july4) # near-infrared

## check out the image histogram	
plot(j1)
hist(j1, main="Band 1 - Blue of Landsat")	 # checking how the blue is distributed
boxplot(j1, main="Band 1 - Blue of Landsat")		


### Reorder to R - G - B and create a multi-layer rasterBrick !
myRGB <-	brick(j3,j2,j1) # brick creates new object
myCIR <-	stack(j4,j3,j2) # stack stores connections only


### let's see how the NIR, R, and G bands relate  (from lattice)
splom(myCIR, varname.cex=1) # scatter plot matrix

# let´s plot in full colour!
plot(myRGB)

## better
plotRGB(myRGB)
plotRGB(myCIR, stretch="lin") # here we see that the reds are mostly near-infra red vegetation

## different stretches - here histogram based
# Here we are adjusting the colors to the extent of the raster
plotRGB(myRGB, stretch="hist") 
plotRGB(myCIR, stretch="hist") # doing the same with the false color image (near infra-red)

## different stretches - here linear stretch 
plotRGB(myRGB, stretch="lin") 
plotRGB(myCIR, stretch="lin")  # in CIR red = green!

###finally...
plot3D(dem, col=rainbow(255)) ## you need to close RGL device manually first and then run this line!
plot3D(dem, drape=j1) ## drapes image j4 over DEM


##### histogram/color adjustments

data(nov3)
data(july3) # more cloud cover 
par(mfrow=c(2,2)) # the par() function let's us plot the images in two rows and two columns
image(nov3, main="nov")
image(july3,main="july")
plot(nov3, main="nov")
plot(july3, main="july")

# comparing images from two different periods. In order to do so we need to use histmatch() function
nov3.newH <- histmatch(master=july3, tofix=nov3) # matching the histograms of july and november
image(nov3.newH$newimage, main="new nov")

n3 <- raster(nov3)
j3 <- raster(july3)
n3new <- raster(nov3.newH$newimage) # converting the image into a raster for generation of histogram

par(mfrow=c(1,3))

# Comparing original november with newnovember
hist(n3, main="Nov"); hist(j3,main="July"); hist(n3new, main="new Nov")

####  most important corrections are atmospheric and topographic
####   however, these are too complex to cover here...see package help

par(mfrow=c(1,1))

### 3. Create new information from satellite imagery 

## lets calculate the Normalized Difference Vegetation Index (NDVI)
## and see where the vegetation grows best
### NDVI: (NIR - RED) / (NIR + RED)

# prep imagery
n3 <- raster(nov3) # RED. This is a single band
n4 <- raster(nov4) # NIR. This is a single band

# Creating a ndvi 
ndvi <-  (n4 - n3) / (n4 + n3)
ndvi # now we have a raster layer with the same resolution as the original images
plot(ndvi) # green: healthy vegetation. yellow: unhealthy vegetation

# plot 3D
plot3D(dem, drape=ndvi)

### remove values below zero
ndvi[ndvi <= 0] <- NA # negative values are converted to NAs
plot(ndvi)

## plot again
plot3D(dem, drape=ndvi)

## different way to plot in 2D
library(rasterVis)
levelplot(ndvi, col.regions=bpy.colors(100)) # Here we can see how the ndvi values are distribtued

## ---- skip to task 4 if short on time

### another index SAVI (soil adjusted vegetation index)
ndvi <-  (n4 - n3) / (n4 + n3)
savi <-  (n4 - n3) / ((n4 + n3)*0.25) # with L=1 -> similar to NDVI

### let´s compare the SAVI and the NDVI visually
par(mfrow=c(1,2))
plot(savi, main="SAVI");plot(ndvi, main="NDVI") # here there is less reflection of soil which is what we wanted
par(mfrow=c(1,1))


### Let´s make a new brick, including DEM and NDVI
data(nov2)
data(nov1)
n2 <- raster(nov2)
n1 <- raster(nov1)

# Creating a new brick that contains all four bands (green, blue, red, near infrared) and the ndvi band of the november image
myNewBrick <- brick(n4,n3,n2,n1,ndvi) # it contains 5 bands
splom(myNewBrick) # here we can see whether there is correlation between the bands

### Unsupervised Classification
# We want to categorize the ndvi image into groups depending on vegetation growth for instace
# The simplest classification method is the unsupervised classification
# run kmeans cluster analysis on image data to see the bands of growth better!
# read on Thresholding here:  https://rspatial.org/raster/rs/3-basicmath.html#vegetation-indices
ICE_df <- as.data.frame(myNewBrick) # convert the multi-band image into a dataframe
set.seed(99) # we set seed in order to not get random classification each time we run it
cluster_ICE <- kmeans(ICE_df, 4) ### kmeans, with 4 clusters. kmenas uses a particular algorithm. We are classifying the data from the 5 bands into four classes.
# The cluster_ICE object divides the data into four clusters. It gives us metrics on each cluster.
str(cluster_ICE)
cluster_ICE <- cluster::clara(ICE_df, 4) ### clara, with 4 clusters

# Converting it back into a raster file in order to be able to visualize it
# convert cluster information into a raster for plotting
clusters <- raster(myNewBrick)   ## create an empty raster with same extent than ICE
# Now we can feed the empty raster values
clusters <- setValues(clusters, cluster_ICE$cluster) # convert cluster values into raster
clusters # the values range from 1-4 because we asked it to make 4 clusters 
plot(clusters) # Here we see a four colored image because we have four clusters

# plot over the DEM
plot3D(dem, drape=clusters, col=c("red", "green", "blue", "yellow")) # we specify the colors categorically, because it does not make sense to use continuous colors since we are using categorical clusters

# calculate the average spectral signature of 1-4 bands of growth
ICE_mean <- zonal(myNewBrick, clusters, fun="mean")  
ICE_mean  # see the values for ndvi (layer) being most distinct



### 4. What is the trend in de-/afforestation?  - Individual tree crown segmentation 
# The ITC delineation approach finds local maxima within imagery, designates these as tree tops,
# then uses a decision tree method to grow individual crowns around the local maxima.
library(itcSegment)

data(imgData) 
plot(imgData) # the green colors are tree

se<-itcIMG(imgData,epsg=32632) # here we are segmenting the image into canopies on the basis of height
summary(se)
plot(se,axes=T) # now we get outlines of tree

### let´s overlay them
plot(imgData)
plot(se,axes=T,add=T)


### when we reproject the data to geographical coordinates...
se      # it is a Spatial object
crs(se) # what is its crs?
se.ll <- spTransform(se,CRS( "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0 "))

### ...then we can combine them with leaflet

library(leaflet)
leaflet() %>% 
  addTiles() %>% 
  addRasterImage(imgData) %>% 
  addPolygons(data=se.ll, weight = 1, color = "black" )   # Tadaa
# Here we can see that it is somewhere in Italy

##### a more demanding example! see content of folder...
r <- raster("data/myDem_subset.tif")
r
plot(r)

# Outlining the canopies
r.se<-itcIMG(r,epsg=25829, ischm=T) ### slow on my laptop (solid 2-3mins)!!!
summary(r.se)
plot(r);plot(r.se,axes=T, add=TRUE)

# Adjust 'th' argument for excessive capture of small growth
r.se5<-itcIMG(r,epsg=25829,th = 5, ischm=T) # th argument let's us specify how low should algorithm be looking for canopy
plot(r);plot(r.se5,axes=T, add=TRUE)

# Write the result to shapefile
library(rgdal)
?writeOGR
td <- getwd()
writeOGR(r.se,td,"itcTrees_subset",driver="ESRI Shapefile" )

# want to see it in Leaflet?
library(sf)
rse <- st_read("itcTrees_subset.shp")
rse.ll <- st_transform(rse, crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0 ")

# Control question: where is this landscape from?
leaflet() %>% 
  addTiles() %>% 
  addProviderTiles("Esri.WorldPhysical") %>% 
 # addProviderTiles("Esri.WorldImagery") %>% 
  addRasterImage(projectRaster(r, crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0 ")) %>% 
  addPolygons(data=rse.ll, weight = 1, color = "black" )   # Neat :)


### End.
# Similar approach can be used to the mapping of socio-cultural phenomena, such as burial mounds in the landscape, 
# growing urban sprawl, or tracing the outlines of scanned line drawings.
# (although in the latter two you may need to base the classification on reflectance or edge detection rather than elevation)

### interesting links
# https://geoscripting-wur.github.io/AdvancedRasterAnalysis/
# http://rspatial.org/spatial/rst/8-rastermanip.html
# http://neondataskills.org/R/Image-Raster-Data-In-R/
# https://geoscripting-wur.github.io/IntroToRaster/
# http://wiki.landscapetoolbox.org/doku.php/remote_sensing_methods:home
# https://rpubs.com/alobo/vectorOnraster