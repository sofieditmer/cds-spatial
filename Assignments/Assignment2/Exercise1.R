## ASSIGNMENT 2, EXERCISE 1 ##

# Packages
library(sf)
library(raster)
library(tmap)
library(spData)
library(spDataLarge)

#### Data sets #### 

# We will use two data sets: `nz_elev` and `nz`. They are contained by the libraries
# The first one is an elevation raster object for the New Zealand area, and the second one is an sf object with polygons representing the 16 regions of New Zealand.

#### Existing code ####

# We wrote the code to create a new map of New Zealand.
# Your role is to improve this map based on the suggestions below.

tm_shape(nz_elev)  +
  tm_raster(title = "elev", 
            style = "cont",
            palette = "BuGn") +
  tm_shape(nz) +
  tm_borders(col = "red", 
             lwd = 3) +
  tm_scale_bar(breaks = c(0, 100, 200),
               text.size = 1) +
  tm_compass(position = c("LEFT", "center"),
             type = "rose", 
             size = 2) +
  tm_credits(text = "A. Sobotkova, 2020") +
  tm_layout(main.title = "My map",
            bg.color = "orange",
            inner.margins = c(0, 0, 0, 0))

#### Exercise I ####

# 1. Change the map title from "My map" to "New Zealand".
# 2. Update the map credits with your own name and today's date.
# 3. Change the color palette to "-RdYlGn". 
#    (You can also try other palettes from http://colorbrewer2.org/)
# 4. Put the north arrow in the top right corner of the map.
# 5. Improve the legend title by adding the used units (m asl).
# 6. Increase the number of breaks in the scale bar.
# 7. Change the borders' color of the New Zealand's regions to black. 
#    Decrease the line width.
# 8. Change the background color to any color of your choice.

# Your solution
# /Start Code/ #

tm_shape(nz_elev)  +
  tm_raster(title = "elev (units = m asl)", # changed the legend title to include the units
            style = "cont",
            palette = "RdYlGn") + # changed he color palette
  tm_shape(nz) +
  tm_borders(col = "black", # changed the border color to black
             lwd = 2) + # decreased the line width from 3 to 2
  tm_scale_bar(breaks = c(0, 100, 200, 300, 400), # increasing the number of breaks in the scale bar
               text.size = 1) +
  tm_compass(position = c("right", "top"), # changed the position of the North arrow to top-right corner
             type = "rose", 
             size = 2) +
  tm_credits(text = "Sofie Ditmer, February 9th 2020") + # updated the map credits
  tm_layout(main.title = "New Zealand", # changed title to "New Zealand" instead of "My Map"
            bg.color = "lightblue", # changed the background color from orange to blue
            inner.margins = c(0, 0, 0, 0))

# /End Code/ #

#### Exercise II ####

# 9. Read two new datasets, `srtm` and `zion`, using the code below to create a new map representing these datasets.

srtm = raster(system.file("raster/srtm.tif", package = "spDataLarge"))
zion = read_sf(system.file("vector/zion.gpkg", package = "spDataLarge"))

# Zion Map
tm_shape(zion) + 
  tm_borders() +
  tm_scale_bar(position = c("right", "bottom")) + 
  tm_compass(position = c("left", "top")) +
  tm_layout(main.title = "Zion National Park")

# SRTM Map
tm_shape(srtm) +
  tm_raster() +
  tm_layout(main.title = "Elevation: Zion National Park")

# Merging the two maps
tm_shape(srtm) + 
  tm_raster(drop.levels = TRUE,
            title = "Elevation") + 
  tm_shape(zion) +
  tm_borders(lwd = 3, col = "black") + 
  tm_scale_bar(position = c("right", "bottom")) + 
  tm_compass(position = c("left", "top")) +
  tm_layout(main.title = "Zion National Park", legend.outside = TRUE)  




