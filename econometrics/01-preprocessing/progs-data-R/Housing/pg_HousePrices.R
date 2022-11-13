#############################################################################
## DATA ANALYSIS

# ---------------------------------------------------------------------------
# Import data

data <- read.csv2("./progs-data-R/Housing/HousesPrices.csv")

# verify data import
head(data,4)
tail(data,4)
View (data)

# ---------------------------------------------------------------------------
# Verify data structure 
str(data)

# retype ID to character
data$ID = as.character(data$ID)
# if Town is not character, retype to character
data$Town = factor(data$Town)

# Identify factors
data$AirConditioned = as.factor(data$AirConditioned)
data$Heating = as.factor(data$Heating)


# ---------------------------------------------------------------------------
# Qualitative variables
# use barplots to display frequency of qualitative variables

table(data$AirConditioned)
prop.table(table(data$AirConditioned))

# plot air conditioned
barplot(
  table(data$AirConditioned),
  horiz = F,
  cex.names=0.8,
  col="cadetblue3",
  main="Air Conditioned",
  ylab="Frequency", 
  plot=TRUE)


table(data$Heating)
prop.table(table(data$Heating))

# plot heating
barplot(
  table(data$Heating),
  horiz = T,
  cex.names=0.8,
  col="cadetblue3",
  main="Heating",
  ylab="Frequency", 
  plot=TRUE)

# ---------------------------------------------------------------------------
# Quantitative variables

# Histograms (only work with quantitive variables)
# use hist and pass in the column to create a histogram
par(mfrow = c(2,2))
hist(data$HouseSize, col="cadetblue3",main="House Size")
hist(data$NumberOfRooms, col="cadetblue3",main="NumberOfRooms")
hist(data$GardenSize, col="cadetblue3",main="Garden Size")
hist(data$DistanceFromToulouseCenter, col="cadetblue3",main="Distance from Toulouse")
hist(data$Price, col="cadetblue3",main="Price")

par(mfrow = c(1,1))

# Boxplot
par(mfrow = c(2,2))
boxplot(data$HouseSize, col="cadetblue3",main="House Size")
boxplot(data$NumberOfRooms, col="cadetblue3",main="NumberOfRooms")
boxplot(data$GardenSize, col="cadetblue3",main="Garden Size")
boxplot(data$DistanceFromToulouseCenter, col="cadetblue3",main="Distance from Toulouse")
boxplot(data$Price, col="cadetblue3",main="Price")
par(mfrow=c(1,1))

 # no outliers, rather well distributed


# verify missing values
summary(data)


# No missing values

# ---------------------------------------------------------------------------
# Graphical Normality Tests

## Study the skewness and the kurtosis of the distribution
install.packages("moments")
library(moments)

# when the variable is normally distributed
# Skewness is close to 0
# Kurtosis is close to 3

skewness(data$HouseSize)
kurtosis(data$HouseSize)

skewness(data$Price)
kurtosis(data$Price)


## QQ Plot
# when the variable is normally distributed
# points are aligned on the first bisector
par(mfrow=c(1,1))

qqnorm(data$HouseSize,main="Normality study House Size")
qqline(data$HouseSize)
qqnorm(data$Price,main="Normality study Price")
qqline(data$Price)

# ---------------------------------------------------------------------------
# Analytical Normality Tests

# Shapiro test
# H0 : normality against H1 : non normality
shapiro.test(data$HouseSize)
shapiro.test(data$Price)


# Jarque Bera test (based on Skewness and Kurtosis)
# H0 : normality against H1 : non normality
install.packages("tseries")
library(tseries)

jarque.bera.test(data$HouseSize)
jarque.bera.test(data$Price)



#############################################################################
## EXERCISES

# 5.	Does AC increase the price of the house?
  
# Compare statistics of Yes and No AC against Price
tapply(data$Price, data$AirConditioned, summary)s

#Graph
boxplot(data$Price~data$AirConditioned,
        col = "cadetblue3", border = "black",
        main = "Price",
        xlab = "Air Conditioner",
        ylab = "Price")

# --> apparently, it does. But let's use the t-test to see if the difference is 
# significant

# Test
# Crossing of a continuous (quantitative) and categorical variable (qualitatives)
# with 2 categories two means comparison Student test

# the statistic of test is quite different according to the fact that variances are comparable or not

# Two variances comparison test
# H0 : Var1 = Var2 against H1 : Var1 # Var2
var.test(data$Price~data$AirConditioned)
?var.test
# Student t-test
# H0 : m1 = m2 against H1 : m1 # m2

t.test (data$Price~data$AirConditioned, var.equal=T)
?t.test

# Non parametric version of the test
# useful is the continuous variable is not normally distributed

#Wilcoxon test
# This test no longer relates to the values, but to the ranks of the observations.
# The observations are listed in ascending order and numbered. 
# The rank is the sequence numºber of the classified observation.
# This is a test of comparison of medians.
# H0 M1=M1 agains H1 : M1#M2
wilcox.test(data$Price~data$AirConditioned)                 


  
# 6.	Are solar heated houses more expensive?
  
#  7.	Can we conclude that the price of the house increases with the number of rooms?
#  8.	Has the garden size a big impact on the house price?
#  9.	Can we conclude that the greater the distance from Toulouse, the lower the price?
#  10.	Can we conclude that the greater the house size, the greater the price?



library(Hmisc)
matcor <- rcorr(as.matrix(data[,c(3:7,10)]))

#  11.	Do more houses with electric heating have air conditioning?
  
  

tab <- table(data$Heating,data$AirConditioned)
tab

#raw percentages
prop.table(tab,1)
#column percentages
prop.table(tab,2)

#Graphic
mosaicplot(tab,color=hcl(c(360,240,120)),xlab="Heating", ylab="Air Conditioned",cex=0.8)



#Chi squared test
#study the relation ship between two qualitative or categorical variables
# H0 : the two variables are independant agains H1 : the two variabls are linked


chisq.test(tab)

# you can also use the focntion CrossTable from the package "gmodels"

install.packages("gmodels")
library(gmodels)
CrossTable(data$Heating,data$AirConditioned,prop.r=T,prop.c=T,prop.t=F, prop.chisq=F, chisq=T)

