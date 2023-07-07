# Workshop 4: Basic Mapping

remotes::install_github("spatialanalysis/geodaData")

# Work with New York burrows from 2008

library(geodaData)
library(sf)
library(tmap)


head(nyc_sf) # simple features dataset of the burrows 

# How many observations and variables are there? What data is stored? (dim(), str(), head(), summary())

dim(nyc_sf) # 55 observations and 35 variables (55 rows and 35 columns)

str(nyc_sf) # 55 observations and 35 variables - this is the structure 

# data stored is bor_subb, name, code, subborough, what percentage is white, kids, size?, 

# geometry is multipolygon

summary(nyc_sf) # if do ?nyc_sf can see what each column means --> this data is in feet

# What does the metadata tell you about this data? (?nyc_sf)

# What geometries are in this data? Can you make a quick map with plot()?

names(nyc_sf) # last column in geometry

plot(nyc_sf["geometry"]) #get just the shapes rather than all the attributes, get all attributes if do plot(nyc_sf)

# What coordinate reference system is there? Is this data projected? (st_crs()) 

st_crs(nyc_sf) # The data is NOT projected, 2263 is a different number have seen before and it's a new york reference system

# tells you the units are in feet! "+units=us-ft + no_defs"

# Can you Google the EPSG code and figure out what it means? 

# is it NAD83 for New York? https://www.spatialreference.org/ref/epsg/nad83-new-york-long-island-ftus/

# What data are we going to use? Add map layers on top of that, so use a plus sign 


tm_shape(nyc_sf) +
  tm_borders()

tm_shape(nyc_sf) +
  tm_fill()

# superset of the two above (get both):
tm_shape(nyc_sf) +
  tm_polygons() +
  tm_shape(st_centroid(nyc_sf)) +
  tm_dots(size = .2)

# it inherits till you get a new tm shape call. Adding dataset layers.

# st_centroid will calculate central point in polygons 

# Specify which attribute you want to plot
tm_shape(nyc_sf) +
  tm_polygons("rent2008")

tmap_mode("view") # a zoomable map! so cool! connects to a server called leaflet, map in JavaScript

tm_shape(nyc_sf) +
  tm_polygons("rent2008") +
  tm_basemap(server = "Stamen.Watercolor") # water color map! :) 

# Thunderforest.SpinalMap
# but no addresses or roads and can't see through my polygons. 
# so can change the basemap

leaflet::providers # shows us all the servers! 
# OpenStreetMap
# Stamen.Watercolor
# Thunderforest.SpinalMap

# Shiny app - interactive web application

# how to get out of the view mode?
tmap_mode("plot")

tm_shape(nyc_sf) +
  tm_fill("rent2008", title= "Rent in 2008", alpha = .5, palette = "Blues", legend.hist = TRUE) + 
  tm_borders() +
  tm_layout(main.title = "Rent in NYC Boroughs, 2008", 
            legend.hist.size = 1.5, 
            compass.type = "4star", 
            legend.outside = TRUE) +
  tm_compass(show.labels = 1, 
             cardinal.directions = c("N", "E", "S", "W"),
             position = c(0.03, 0.55), 
             size = 2.5, 
             color.light= "grey90",
             color.dark= "grey30") +
  tm_scale_bar(position = c("right", "bottom")) 
  #tm_style_cobalt()

main.title = ?tm_legend
# tm_layout makes the map pretty! changes font and adds compass, etc.
?tm_layout
# can also show a histogram!

?tm_polygons
# Which parameter controls transparency? Use 'alpha' transparency number between 0 and 1 
# How would you change the title of the legend to something else? Use 'title'
# if do comma and then tab can see all the arguments




  