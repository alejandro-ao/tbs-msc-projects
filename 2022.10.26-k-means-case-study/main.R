library(plyr)
library(ggplot2)
library(cluster)
library(lattice)
library(graphics)
library(grid)
library(gridExtra)

# import the data set
customers <- read.csv("./data/customers.csv")

# keep only z-scores
customers2 <- customers[, 9:11]
View(customers2)

# run many kmeans to see how many clusters we create
# we get the choose the cluster that works best
wss <- numeric(30)
for (k in 1:30) {
  wss[k] <- sum(kmeans(customers2, centers = k, nstart=25, iter.max=50)$withinss)
}

# visualise the no of clusters
plot(1:30, 
     wss, 
     type="b",
     xlab="Number of clusters",
     ylab="Within sum of clusters"
     )
