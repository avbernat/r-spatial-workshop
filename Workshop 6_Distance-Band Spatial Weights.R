# Workshop 6 Distance-Band Spatial Weights
# install.packages("spDataLarge",repos='https://nowosad.github.io/drat/', type='source')
install.packages("units")
library(geodaData)
library(sf)
library(spdep)
library(tmap)

#package in R called units


head(clev_pts)
dim(clev_pts)
str(clev_pts) # x and y look like coordinates because look big
names(clev_pts)
st_crs(clev_pts) # check if projected and good! says +proj=lcc so yes! "Lambert Conformal Conic — PROJ 6.2.1 documentation"
plot(clev_pts)
plot(clev_pts["geometry"])

tmap_mode("view")

tm_shape(clev_pts) +
  tm_dots()

# Find any neighbors within a certain distance within a point

?dnearneigh # looking at neighbourhood contiguity by distance

# can set a fixed distance 

dis_1000_nb <- dnearneigh(clev_pts, 0, 1000) 

# get an output of '55 regions with no links' which means there are points with no neighbors

# plot(nb_object, coordinates of spatial data)

clev_coords <- st_coordinates(clev_pts) #if just need the coordinates of the data without any of the attributes
plot(dis_1000_nb, clev_coords)

# or can set a fixed number of neighbors

?knearneigh

knn6_matrix <- knearneigh(clev_pts, k = 6) # returns a matrix 
k6nb <- knn2nb(knn6_matrix)
plot(k6nb, clev_coords, cex = 0.5, lwd = 0.2)

knn_matrix <- knearneigh(clev_pts, 1) # this returns a matrix but need nb object
k1nb <- knn2nb(knn_matrix) # convert knn matrix to knn nb object, get a none symmetric object 
plot(k1nb, clev_coords)

# can get a listing of all the distances for each of these points

?nbdists

k1dists <- unlist(nbdists(k1nb, clev_coords)) # this is a nested list, so let's unlist

# what is the average distances?

summary(k1dists) # these are distances in feet

# can throw these into dnearneigh! 

# Go ahead and see if you can experiment to max and min

max <- max(k1dists) # setting a threshold that's really large gets you lots of neighbors
min <- min(k1dists)

dis_max_nb <- dnearneigh(clev_pts, 0, max) # average number of links: 12.6439
dis_min_nb <- dnearneigh(clev_pts, 0, min) # no links!

plot(dis_max_nb, clev_coords)
plot(dis_min_nb, clev_coords)

# what is the distribution of my neighbors - connectivity histogram
# use 'card' stands for cardinality

num_neighbors <- card(dis_max_nb)

# make a ggplots!
# histogram with number of neighbors 

summary(num_neighbors)
hist(num_neighbors)

#library(ggplot2)
#num_neigh <- card(dis_max_nb) # need to turn into a data frame to use ggplot
# ggplot(num_neigh)

# Next: neighbors will be put in a spatial weights matrix, e.g. house salesprice, each of those 6 neighbors will be given a 6th of that weight?

