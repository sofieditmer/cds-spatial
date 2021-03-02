## ASSIGNMENT 2, EXERCISE 2 ## 

#### Goals ####
# - Understand the provided datasets
# - Learn how to reproject spatial data
# - Limit your data into an area of interest
# - Create a new map

#### Packages ####
library(sf)
library(raster)
library(tmap)
library(spData)
library(spDataLarge)

#### Data sets #### 

# We will use two data sets: `srtm` and `zion`.
# The first one is an elevation raster object for the Zion National Park area, and the second one is an sf object with polygons representing borders of the Zion National Park.

srtm <- raster(system.file("raster/srtm.tif", package = "spDataLarge"))
zion <- read_sf(system.file("vector/zion.gpkg", package = "spDataLarge"))

# Additionally, the last exercise (IV) will used the masked version of the `lc_data` dataset.
study_area <- read_sf("data/study_area.gpkg")
lc_data <- raster("data/example_landscape.tif")
lc_data_masked <- mask(crop(lc_data, study_area), study_area)

#### Exercise I ####

## 1. Display the `zion` object and view its structure.
# What can you say about the content of this file?
# What type of data does it store?
# What is the coordinate system used?
# How many attributes does it contain?
# What is its geometry?
# 2. Display the `srtm` object and view its structure.
# What can you say about the content of this file? 
# What type of data does it store?
# What is the coordinate system used? 
# How many attributes does it contain?
# How many dimensions does it have? 
# What is the data resolution?

# /Start Code/ #
# Displaying the structure of the zion object and viewing its structure
zion
view(zion)
class(zion)
# The zion object is an SF (simple features) object. This means that it is essentially a spatial data frame that 
# contains spatial information about the Zion National Park.

# Examining the coordinate system used for the zion object using the st_crs() function
st_crs(zion)
# The coordinate system used for the zion object is written in the "wkt" format which stands for "well-known text".
# From this we can see that the coordinate system used is a "GEOGCS" which stands for a "geographic coordinate system",
# which is based on latitude and longitude values. 
# The name of the coordinate system is "GRS 1980". "GRS" stands for "geodetic reference system" which means that the 
# distances are represented as curves between two points on the Earth's surface.

# Examining the attributes of the zion object
ncol(zion)
# Assuming the the number of attributes correspond to the number of columns in the dataframe apart from the geometry column
# the zion object contains 11 attributes

# Examining the geometry of the zion object
st_geometry(zion)
# The geometry of the zion object is stored as a list in the column "geometry", which represents the geometry type
# of the data.
# Since the geomtetry column consists of a list of coordinates, the zion object is said to contain polygons. 
# This can also be confirmed with the st_geometry() function that returns its particular geometry
st_geometry(zion)

# Now we will examine the srtm object.

# First we display the object and view its structure
srtm
class(srtm)
# Both from examining the srtm object and its class we see that it is a raster object. 
# It contains data about its dimensions (i.e. the number of rows and columns), which is more specifically its size,
# information about its resolution, which is the size of the individual pixels,
# information about the extent of the raster layer (its minimum and maximum values),
# and the coordinate system used
# From this we can conclude that the srtm object contains cell-based spatial data which in this case is continuous data
# regarding elevation measurements of the Zion National Park

# Examining the type of coordinate system used
crs(srtm)
# We get the coordinate system in the PROJ4 format  which consists of a list of parameters each with a + in front.
# Hence, we get information about the projection which is a "long-lat" projection (longitude and latitude), the datum which is the "WGS84" that 
# specifies the 0,0 reference of the coordinate system, and the ellipsoid which is the WGS84, which specifies how the Earth's roundedness is calculated.
# The WGS84 is the most common projection of the Earth. It is known as the "Web Mercator" and it is the standard for Google.

# Examining the number of dimensions in the srtm object
dim(srtm)
# The srtm object has three dimensions 

# Examning the resolution of the srtm object
res(srtm)
# The resolution of the data in the srtm object is 0.0008, 0.0008 which denotes the particular size of the individual pixels/cells in the data. 

# /End Code/ #


#### Exercise II ####

# 1. Reproject the `srtm` dataset into the coordinate reference system used in the `zion` object. 
# Create a new object `srtm2`
# Vizualize the results using the `plot()` function.
# 2. Reproject the `zion` dataset into the coordinate reference system used in the `srtm` object.
# Create a new object `zion2`
# Vizualize the results using the `plot()` function.

# /Start Code/ #
# Below I am reprojecting the srtm dataset into the CRS used in the zion object 

# First I creating a variable that stores the CRS of the zion object
crs_1 <- crs(zion)

# Then I reproject the srtm dataset into the CRS used in the zion object and save it as a new object 
srtm2 <- projectRaster(srtm, crs = crs_1, method = "ngb") # I use method = "ngb" to prevent distortion

# Now the CRS of the srtm2 object has been reprojected to the CRS used in the zion object

# Now I can visualize the results using the plot() function
plot(srtm2)

# Now I will reproject the zion dataset into the coordinate refence system used in the srtm object
crs_2 <- crs(srtm, asText = TRUE)
zion2 <- st_transform(zion, crs = crs_2)

# Visualize the results using plot()
plot(zion2)

# /End Code/ #