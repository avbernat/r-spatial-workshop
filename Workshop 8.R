# Workshop 8 (Last Workshop of the quarter)
# Chapter 16 Spatial Clustering
# this is great: https://spatialanalysis.github.io/tutorials/#spatial-weights-tutorials-new
# https://github.com/lixun910/rgeoda/issues

library(rgeoda)
library(sf)
library(geodaData) # because working with the guerry data

guerry_sf <- geodaData::guerry # save as sf because an sf object

# Convert into rgeoda ready object

guerry <- sf_to_geoda(guerry_sf, with_table=TRUE) # need to add the second argument otherwise will get 0 columns and 85 rows but 

# Look at methods

guerry$table

# Working with algorithm called skater - spatially constrained clustering
# REDCAP and Max P are other ones but not found in Rgeoda
# SKATER forms clusters by spatially partitioning data that has similar values for features of interest.
# arguments of skater: (num of clusters, weight, data,...)
?skater

queen_w <- queen_weights(guerry)

skater(4, queen_w, querry) # this doens't work, so 

# you want a list of numeric vectors 

names(guerry)

list(guerry$table$Crm_prp, guerry$table$Suicids) # this is a numeric vector of the length of the dataset

list(guerry_sf$Crm_prp, guerry_sf$Suicids)

data <- list(guerry$table$Crm_prs, guerry$table$Crm_prp, guerry$table$Litercy, 
             guerry$table$Donatns, guerry$table$Infants, guerry$table$Suicids)

# dollar signs just means 'create that list'

skater_clusters <- skater(4, queen_w, data) # the numbers spit out are the 'rows' e.g. the 49th thing (indexing)

betweenss <- between_sumofsquare(skater_clusters, data)

totalss <- total_sumofsquare(data)

ratio <- betweenss / totalss


# mutate(guerry_sf, cluster = "1" if...)
# would be nice to create a new column called cluster and append to cluster e.g. 1 and then cluster 2
# then use which()

as.character(skater_clusters[[1]])
skater_clusters[[2]]
guerry_sf$CODE_DE
?which

which(guerry_sf$CODE_DE == as.character())




