#######################################################
###                 Clustering                #########
#######################################################



# Define a project called "Clustering" and store it in a file called "Modelling Techniques"

# Download and store the dataset "customers" and the script into the file "Modelling Techniques"


# Import the dataset

customers <- read.csv("customers.csv")


# Useful packages are installed

 install.packages('plyr')
 install.packages('ggplot2')
 install.packages('cluster')
 install.packages('lattice')
 install.packages('graphics')
 install.packages('grid')
 install.packages('gridExtra')

# Useful packages are loaded

library (plyr)
library(ggplot2)
library(cluster)
library(lattice)
library(graphics)
library(grid)
library(gridExtra)


#  The dataset is transformed into a matrix

customers2<-as.matrix(customers[, c("X", "CustomerID", "recency", "frequency", "monetary", "recency.log", "frequency.log", "monetary.log",  "recency.z", "frequency.z", "monetary.z")])



#  We keep into the analysis only z-scores

customers2 <- customers2[,9:11]


#  An overview of the dataset

customers2[1:10, ]


# To determine an appropriate value for k, the k-means algorithm is used to identify clusters for k = 1, 2, .. . , 30

wss <- numeric(30)
for(k in 1:30){
  wss[k]<-sum(kmeans(customers2, centers=k, nstart = 25, iter.max = 50)$withinss)
}


#  The option *nstart=25* specifies that the k-means algorithm will be repeated 25 times, each starting with k random initial centroids.

#  The Within Sum of Squares metric (wss) is plotted against the respective number of centroids

plot(1:30, wss, type="b", xlab="Number of Clusters" , ylab="Within Sum of Squares" )


#   The WSS is greatly reduced when k increases from one to two. Another substantial reduction in WSS occurs at k=5. However, the improvement in WSS is fairly linear for k>5. Therefore, the k-means analysis will be conducted for k = 5.

km<-kmeans(customers2,5,nstart=25)
km

#   The displayed contents of the variable km include the following:
  
#   The location of the cluster means
#   A clustering vector that defines the membership of each customer to a corresponding cluster 1,2,3,4 and 5
#   The WSS of each cluster
#   A list of all the available k-means components

#   The ggplot2 package is used to visualize the identified customer clusters and centroids

df=as.data.frame(customers2)
df$cluster=factor(km$cluster)
centers=as.data.frame(km$centers)

g1=ggplot(data=df, aes(x=customers$recency.z, y=customers$frequency.z, color=cluster)) + geom_point()+
  geom_point(data=centers, aes(x=centers$recency.z, y=centers$frequency.z), color=c("indianred1", "khaki3", "lightgreen", "lightskyblue", "plum2"), size=8, show.legend=FALSE)

g2=ggplot(data=df, aes(x=customers$recency.z, y=customers$monetary.z, color=cluster)) + geom_point()+
  geom_point(data=centers, aes(x=centers$recency.z, y=centers$monetary.z), color=c("indianred1", "khaki3", "lightgreen", "lightskyblue", "plum2"), size=8, show.legend=FALSE)

g3=ggplot(data=df, aes(x=customers$frequency.z, y=customers$monetary.z, color=cluster)) + geom_point()+
  geom_point(data=centers, aes(x=centers$frequency.z, y=centers$monetary.z), color=c("indianred1", "khaki3", "lightgreen", "lightskyblue", "plum2"), size=8, show.legend=FALSE)


grid.arrange(g1,g2,g3)


#   The large circles represent the location of the cluster means

#   The small dots represent the customers corresponding to the appropriate cluster by assigned color

#   Characterize each cluster
