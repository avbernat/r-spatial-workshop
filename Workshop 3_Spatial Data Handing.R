# Week 3

# List of spatial data sites: https://docs.google.com/document/d/12I9nLcBtG8fjxOxCbAt-4ifvMYuIUA0HHDIP7YFBULI/edit

install.packages("spData") # pull data sets onto computer from https://github.com/Nowosad/spData

library(spData)

library(sf)

us_states # pulls out the sf object as a dataframe so do library(sf) as did above

plot(us_states)

install.packages("tidycensus")
# tidycensus - Tidycensus R package: really useful for getting US boundaries, variables
# OpenStreetMap
# NYU Spatial Data Repository: https://geo.nyu.edu
# ICPSR  - see what publications done with social science spatial data: https://www.icpsr.umich.edu/icpsrweb/
# CDC GIS Data: 
# NEON Ecological data: https://data.neonscience.org/home
# look at GIS stack exchange
# Uchicago map librarian: Cecilia Smith (take digial maps and make them into shape files to work with), 475,000 maps 
# for sources of historical data, US of Congress Maps has tons of stuff online
# Parmanand Sinha for high level modeling: https://rcc.uchicago.edu/about-rcc/our-team

# Back into R! Spatial Datahandeling, scraping a PDF

install.packages("remotes")
remotes::install_github("spatialanalysis/geodaData") # install form github this new package that they have

# reason things went wrong is because there was a bug in the github, so now this should work?

library(geodaData)
library(sf)
data("chicago_comm")

head(chicago_comm)
str(chicago_comm)
plot(chicago_comm)
plot(chicago_comm["POP2010"]) # plot just population, don't put it in publication though
st_crs(chicago_comm)

chicago_comm <- st_transform(chicago_comm, 32616) # project to itself 
st_crs(chicago_comm)

data("vehicle_pts")
st_crs(vehicle_pts)
vehicle_pts <- st_transform(vehicle_pts, 32616)
st_crs(vehicle_pts)

# SPATIAL JOIN

# for each join, what community area is it in?

comm_pts <- st_join(vehicle_pts, chicago_comm) # Chicago data had 5 variables and vehicles had 11 variables, so have same number of points as vehicle pts

# Out put: Simple feature collection with 2635 features and 14 fields

head(comm_pts) # it should still be 'POINT' and not 'POLYGON'

# order matters! don't do this:
# comm_pts2 <- st_join(chicago_comm, vehicle_pts)
# comm_pts2 # attaching all the point attributes to the polygons, you don't want to end up with polygons

library(dplyr)
counts_by_area <- count(comm_pts, community) # count in each community how many points each community has

class(counts_by_area)
# counts by area is a geospatial object, but we don't need the geometry column at this point

counts_by_area <- st_drop_geometry(counts_by_area) %>%
  rename(number_vehicles = n)

counts_by_area <- filter(counts_by_area, !is.na(community))
counts_by_area

# Attribute join! 
chicago_comm <- left_join(chicago_comm, counts_by_area) # chicago_comm alreay has a geometry column
chicago_comm

# Let's plot a rate
str(chicago_comm) # problem here community is being read in as a Factor

library(tmap)
chicago_comm <- chicago_comm %>%
  mutate(community = as.character(community))

class(chicago_comm)
str(chicago_comm)
names(chicago_comm)
glimpse(chicago_comm)

# put in sf in tm_shape() and tm_polygons("vehpcap") fills in the colors of each polygon made by tm_shape(), keep adding layers with +
tm_shape(chicago_comm) +
  tm_polygons("number_vehicles")

tm_shape(chicago_comm) +
  tm_polygons("POP2010")

# count/populatin and plot that instead ==> go through the tutorial! https://spatialanalysis.github.io/workshop-notes/basic-mapping.html
# how take count and divide by population in each area and make a map?

num_vehicles_per_pop <- chicago_comm["number_vehicles"]/chicago_comm["POP2010"]
num_vehicles_per_pop

# Basic Mapping next time 


