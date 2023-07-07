# Workshop 5 Spatial Autocorrelation

install.packages("spdep")

remotes::install_github("spatialanalysis/sfExtras")
remotes::install_github("spatialanalysis/geodaData")

library(geodaData)
library(sf)
library(tmap)
library(tidyverse) #library pulls up a package for use
library(RSocrata) #Ctrl-Enter to run a line
library(lubridate)

head(ncovr)
dim(ncovr) # 3085 observations (rows) and 70 variables 
str(ncovr) # look at the structure of ncovr
summary(ncovr) # MULTIPOLYGON, with epsg: 4326
names(ncovr)

# What does the metadata tell you about this data?

?ncovr # it's about Homicides & Socio_Economics (1960-90)

# HR is homocide rate per 100,000 (for each decade)
# HC is homocide count, three year average centered each decade 
# PO is country population
# DV is divorce rate
# UE unemployment rate

# Always start with this
plot(ncovr) # will plot every attribute here and not the most efficient way to do it 

plot(ncovr["geometry"]) # just get the geometry

# Look at crs
st_crs(ncovr) # It's unprojected because it's 4326. It's ok in this case 

tmap_mode("view")

tm_shape(ncovr) +
  tm_polygons("HR60")

# Spatial 

# Contiguity based weights - share border with another unit
# Rook (touch on edges so less things considered 'neighbors') 
# vs. Queen (touch on points and edges so more things considered 'neighbors') continuity
# Could ask questions who i my neighbor?

# Create a datastructure to say which polygon is my neighbor? So have a few 1's that are my neighbor and
# a ton of 0's that are not my neighbors so get spare matricies where have a ton of 0's and few 1's stored in the computer

# What spatial processes are happening? e.g. Is the spatial process happening in IL spill over to my neighbor?

# Can define contiguity for what you want.

library(sfExtras) 
library(spdep)

?st_rook
?st_queen

ncovr_rook <- sfExtras::st_rook(ncovr) # Spit's out the indexes of my neighbor, most have 3 neighbors, this is a list
ncovr_queen <- st_queen(ncovr) # list as well

rook_neighbors <- lengths(ncovr_rook)
queen_neighbors <- lengths(ncovr_queen) # get a list of lengths that tell you how many neighbors each has

mean(rook_neighbors) # tell you the mean number of neighbors for rook, 5.6
mean(queen_neighbors) # can see this is slightly higher mean because included more neighbors, 5.8 

# github on spdep (https://github.com/r-spatial/spdep)
# article about creating neighbors from sf objects (https://r-spatial.github.io/spdep/articles/nb_sf.html)

rook_nb <- st_as_nb(ncovr_rook) # convert list of neighbors into an nb object to make map
queen_nb <- st_as_nb(ncovr_queen)

summary(rook_nb)
summary(queen_nb)

# plot(rook_nb,) # need your polot(nb object, coordinates or polygon centroids)

centroid_coords <- st_centroid_coords(ncovr) # it calls st centroid a polygon, getting all coordinates of centroids of polygons

plot(queen_nb, centroid_coords, lwd = 0.2, cex = 0.5, col = "Blue") # lwd is line weight, cex is circle radius

# plot(ncovr, lwd = 0.2)

# Next time distant based weights - what's my neighbor is an important spatial quesiton 
# (all we did was create a weights list) 
# once know which are my neighbors will create weights 
