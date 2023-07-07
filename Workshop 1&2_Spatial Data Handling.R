# Week 1
install.packages(c("tidyverse", "RSocrata", "sf", "tmap", "lubridate"))
install.packages("dplyr")
install.packages("sf")
library(tidyverse) #library pulls up a package for use
library(RSocrata) #Ctrl-Enter to run a line
library(sf) 
library(tmap) 
library(lubridate)

??read.socrata

vehicle_data <- read.socrata("https://data.cityofchicago.org/resource/suj7-cg3j.csv") #it's an API - government source data (application program interface)
head(vehicle_data)
dim(vehicle_data)
class(vehicle_data)

glimpse(vehicle_data) #tidyverse function - other ways to explore
str(vehicle_data) 

#tidyverse filter function
#group_by(select(filter(vehicle_data, year(creation_date) ==2005), x)) other way to do it 

vehicle_data %>% # 'the pipe'(do it each line...take one thing and pass to the next)
  filter(year(creation_date) == 2005) # pipe %% allows you to filter then this then that...easier to READ as a data analyst
# two equal signs because making a locial statement
year(vehicle_data$creation_date)

 
names(vehicle_data) # tells me the variables    
unique(month(vehicle_data$creation_date)) # give me all the unique values in a column 

?filter # filter function in base R and 'deplyer'? 

vehicle_sept16 <- vehicle_data %>% 
  filter(year(creation_date) == 2016, 
         month(creation_date) == 09) # use lubridate, which has 'year' 'month' and 'day' functions
head(vehicle_sept16)
dim(vehicle_sept16)
glimpse(vehicle_sept16)
str(vehicle_sept16)

# narrow down the attributes so can work with it now, we only need location and which community area in so use 'select' function

vehicle_final <- vehicle_sept16 %>% 
  select(location_address, zip_code)

# Fast filtering and selecting that saves you the step of coming up with a name 

vehicle_final <- vehicle_data %>% 
  filter(year(creation_date) == 2016,
         month(creation_date) == 9) %>% 
  select(location_address, zip_code)

# Need to geocode: 
# The columns I selected aren’t going to be that useful in terms of performing spatial analysis. 
# Why? Because they’re human understandings of where something is. 
# In order for a computer to understand how to map something. I need something a bit more specific.
#  If that’s all I had, I’d need to geocode my addresses, 
# but thankfully I already have two columns in there with the information I need.

# What columns am I interested in? Replace the column names with the proper ones.

# Want lat and long (polar coordinates) ! (x and y are not the same )

vehicle_final <- vehicle_sept16 %>% 
  select(longitude, latitude, community_area) # lat maps to y and long maps to x

vehicle_final <- vehicle_data %>% 
  filter(year(creation_date) == 2016,
         month(creation_date) == 9) %>% 
  select(comm = community_area,
         lon = longitude,
         lat = latitude) # can rename as can select, which will help when using these variables for faster use

# can now convert to a spatial point object! :) We have narrowed it down to selection of rows and colunns 

# To convert a table/CSV with latitude and longitude into an sf object, we use the st_as_sf() function, which has a few arguments.

# Get rid of NA values, use filter again 

vehicle_coord <- filter(vehicle_final, !is.na(lon), !is.na(lat)) # can also put this line underneath the select() above.

# all functions is sf package start with st

# CRAN comprehnsive R network = good for R help. sf - CRAN is the standard CRAN site, but git hub page is more helpful
# reference sites, cheat sheat for sf and trouble installing. sf is an interface library it works with GDAL and GEOS libraries.
# R openeded up functionalities in C++ libraries, but put into sf for R. (?)
# go to reference - that is nice, to have list (e.g. st_buffer and search on the postGIS website and it has the same functions)
# postGIS https://postgis.net/workshops/postgis-intro/geometry_returning.html
# https://r-spatial.github.io/sf/reference/geos_binary_ops.html

# st_as_sf() means 'take this dataframe of lat and long and turn into spatial'

vehicle_points <- st_as_sf(vehicle_coord, 
                           coords = c("lon", "lat"), 
                           crs = 4326,
                           agr = "constant") #c stands for 'cree a vector?', crs = 4326 means that this data is unprojected, agr - attribute geometry relationship
# agr = "constant" means'the number of vehicles does not change where you are in this space/ this geometry'
# agr can have one of the following values: "constant" (for attributes that are constant throughout the geometry (e.g. land use))
# "aggregate" (where attribute is an aggregate value over the geometry e.g. pop count or pop density), 
# "identity" (when the attributes uniquely identifies the goemetry of particular "thing" e.g. a building ID or a city name). 

# make sure have an epsg and proj4string (if says NA NOT good)
# lon is x and lat is y
# crs - coordinate reference system....webstie: https://spatialreference.org
# +proj string --> https://spatialreference.org/ref/epsg/4326/proj4/: +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs (system of code for this spatial number 4326, which means still uprojected)

plot(vehicle_points)
class(vehicle_points)
st_crs(vehicle_points) # talk about next time, yup we did, it shows us the epsg and proj4string

# spatial join - have points and a polygon - have ony info on joints 1-4 and join will add on info based on a geometry 

# group map error - reinstall dplyr, restart r, run library

# xcrun - reinstall xcode (happens when upgrading mac)

# Week 2 

st_crs(vehicle_points) 

vehicle_points <- st_transform(vehicle_points, 32616) #32616 = espg for Illinois from this site: https://spatialreference.org

st_crs(vehicle_points)

#utm universal transverse mercator coordinate system: https://www.earthdatascience.org/courses/earth-analytics/lidar-raster-data-r/open-lidar-raster-r/
# we are using utm zone 16 for Chicago

vehicle_pts_buffer <- st_buffer(vehicle_points, 1000) # what if I'm interested in finding what is happening around this one thing, so we can buffer by 1 km

# so now we get a polygon and not a point = we get a circle instead of a point e.g. can do it on roads, "i want all the grocery stores from 1 mile from this bus route"

# now take a look at the geometry. before looked like point (-87, 41) ==> projected to meters instead of decimal degrees

head(vehicle_points)
dim(vehicle_points)

plot(vehicle_pts_buffer) # get 1 km circles 

# usually you want this in relation to something else: "how many grocery stores are in 1 mile radius in something" = called a spatial join

# Spatial Join: imagine have points in North side and South side of Chicago, want to attach to points which area in ==> add column in point dataset in which area is in.
# then can count how many in the north and in the south --> not attatched to the point data...attached info from the polygon 
# difference from an attribute join: diff cause can have a common key (dataset with teachers who teach R spatial workshops) common factor is that can link based on that data - common factor that both geographic and can link based on that)
# e.g. attribute join: can join by id if name and pop vs. spatial join which is based on where something is in an area

# in a spatial join you don't have a common column, you can't join on the geometries (if have polygons in one and points in the other they are not the common this)

# ArcGIS has a good online guide

# merge(x,y, by="id")) vs. st_join(x, y), just need two criteria because joining two spatial things, don't have a key like "id"

# community shapes

comm_areas <- read_sf("https://data.cityofchicago.org/resource/igwz-8jzy.geojson") 
# reads geospatial API, historical geospatial data in R has been stored as a shape file. 
# A shape file is 4 files, annoying! but it is the 1. projection (prj)), 2. shp, 3. shx, and 4. dbf)
# 77 communities in Chicago so 77 observations
st_crs(comm_areas)

# projected because says +proj=longlat

# st_join(vehicle_points, comm_areas) # error because don't have the same projections 

# project comm_areas is the right projection --> transform!

comm_areas <- st_transform(comm_areas, 32616)
comm_points <- st_join(vehicle_points, comm_areas)

head(comm_points)
names(comm_points)

count(comm_points, community) %>% # can count based on how geometries intersect with each other and not spatial data
  filter(community == "HYDE PARK") %>%
  plot()

# geometries went from points to multipoints, grouped by neighborhood all the points in e.g. Albany Park

# which community has most abandoned vehicles, arrange from low to high or use desc to get from high to low
count(comm_points, community) %>%
  arrange(desc(n))

# counts are not sufficient, why? why do we want to go beyond counts for this count/area...come back with a good quesiton 
# come back with something better than count/area


