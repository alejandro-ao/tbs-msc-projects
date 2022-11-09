#### Training exercise for missing values

install.packages("mlbench")
library("mlbench")

# initialize the data
data("BostonHousing", package="mlbench")
original<- BostonHousing # backup original data
datatest<- BostonHousing #data with missing values

str(datatest)

# introduce missing values in the dataset
set.seed(100) # to set the seed for the random number generator
datatest[sample(1:nrow(datatest),40), "rad"]<-NA
datatest[sample(1:nrow(datatest),40), "ptratio"]<-NA

View(datatest)

# Check for number of complete cases
sum(complete.cases(datatest))

# Check for number of missing values
sum(is.na(datatest))

# Pattern of missing values
install.packages("mice")
library(mice)
md.pattern(datatest, rotate.names=TRUE) #pattern of missing values in data

#-----------------------------------
# How to deal with missing values
#-----------------------------------

# 1- delete the observations
cleandata <- datatest[complete.cases(datatest),]
dim(cleandata)

# example using na.omit
lm(medv~ptratio+rad, data=datatest, na.action=na.omit)

# linear regression with Y=medv; X1=ptratio; X2=rad

# 2- delete the variables
# If one variable contains all the missing values and these missing values are
# affecting most of the rows, then you  should delete the variable

# 3- Impute mean or median or mode, or a fixed value
dataimp <- datatest # data with imputation

summary(datatest) #descriptive statistics like mean and median
sd(datatest$ptratio, na.rm=T) #standard deviation

# When comparing standard deviation wrt mean, we see that on average, there
# is 2/18= 10% of variation around the average value
# So the dispersion of the variable is low and we could replace the missing value
# either by the mean or the median

# We prefer the median (compared to the mean) when there are outliers 
# in the dataset

dataimp$ptratio[is.na(datatest$ptratio)] <- median(datatest$ptratio, na.rm=T)
# na.rm=T means to remove all NA values for the computation of the median

# compute the accuracy when missing value is replaced by median
actual <- original$ptratio[is.na(datatest$ptratio)]
predicted <- rep(median(datatest$ptratio, na.rm=T), length(actual))
error <- actual-predicted

#RMSE: root mean square error
sqrt(mean(error^2))

#MAE: mean absolute error
mean(abs(error))

# MAPE: mean absolute proportion error
mean(abs(error/actual))

# Both RMSE and MAPE values can only be used as a benchmark to compare
# with the accuracy of another method

# MAPE has an easier interpretation: it shows on average the % of deviation
# with respect to the true value


# 4- More sophisticated imputation methods using mice package
imp <- mice(datatest) # function used to impute missing values
datatest_imputed <- complete(imp) 
# complete dataset where missing values have been replaced by 
# imputed values


actual <- original$ptratio[is.na(datatest$ptratio)]
predicted <- datatest_imputed[is.na(datatest$ptratio), "ptratio"]
error2 <- actual-predicted

#RMSE: root mean square error
sqrt(mean(error2^2))

#MAE: mean absolute error
mean(abs(error2))

# MAPE: mean absolute proportion error
mean(abs(error2/actual))

# The gain using more sophisticated methods is not very large here: 8% deviation
# instead of 10%




































