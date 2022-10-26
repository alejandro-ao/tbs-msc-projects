library(plyr)
library(ggplot2)
library(cluster)
library(lattice)
library(graphics)
library(grid)
library(gridExtra)

# import the data set
customers <- read.csv("./data/customers.csv")

View(customers)