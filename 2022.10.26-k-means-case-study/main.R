library(plyr)
library(ggplot2)
library(cluster)
library(lattice)
library(graphics)
library(grid)
library(gridExtra)

# ------------------------------------------------------------------------
# setup
# ------------------------------------------------------------------------
# import the data set
customers <- read.csv("./data/customers.csv")

# keep only z-scores
customers2 <- customers[, 9:11]
View(customers2)

# run many k-means to see how many clusters we create
# we get the choose the cluster that works best
wss <- numeric(30)
for (k in 1:30) {
  wss[k] <- sum(kmeans(customers2, centers = k, nstart=25, iter.max=50)$withinss)
}

# visualize the no of clusters
plot(1:30, 
     wss, 
     type="b",
     xlab="Number of clusters",
     ylab="Within sum of clusters"
     )

# choose k = 5 because that's the most significant
km <- kmeans(customers2, centers=5, nstart=25)
km

# ------------------------------------------------------------------------
# plot the clusters
# ------------------------------------------------------------------------
df <- as.data.frame(customers2)
# create a col with the cluster of each observation
df$cluster <- factor(km$cluster)
# create a df  with the cluster centers
centers = as.data.frame(km$centers)

# creating the plots
g1=ggplot(data=df, aes(x=customers$recency.z, y=customers$frequency.z, color=cluster)) + geom_point()+
  geom_point(data=centers, aes(x=centers$recency.z, y=centers$frequency.z), color=c("indianred1", "khaki3", "lightgreen", "lightskyblue", "plum2"), size=8, show.legend=FALSE)

g2=ggplot(data=df, aes(x=customers$recency.z, y=customers$monetary.z, color=cluster)) + geom_point()+
  geom_point(data=centers, aes(x=centers$recency.z, y=centers$monetary.z), color=c("indianred1", "khaki3", "lightgreen", "lightskyblue", "plum2"), size=8, show.legend=FALSE)

g3=ggplot(data=df, aes(x=customers$frequency.z, y=customers$monetary.z, color=cluster)) + geom_point()+
  geom_point(data=centers, aes(x=centers$frequency.z, y=centers$monetary.z), color=c("indianred1", "khaki3", "lightgreen", "lightskyblue", "plum2"), size=8, show.legend=FALSE)

grid.arrange(g1,g2,g3)

