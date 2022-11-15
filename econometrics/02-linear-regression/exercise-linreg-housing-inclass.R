###############################################
# Exercise linear regression - Boston Housing
###############################################

#-----------------------------------
# Import data
#-----------------------------------

#packages with datasets
install.packages("ISLR2")
library("ISLR2")

?Boston
data <- Boston

# Output variable Y = medv

#---------------------------------
# Data structure
#---------------------------------
str(data)

data$chas <- as.factor(data$chas)
str(data)


# rad:accessibility to radial highways (larger index denotes better accessibility).
# Check for the variable rad
summary(data$rad)
# Issue: should we consider it as quantitative or as factor....
# If the categories are ordered, then considering it as quantitative
# is not a too bad idea

unique(data$rad) # to have the list of all values


#----------------------------------
# Check for outliers and missing values
#-----------------------------------

summary(data)
# no missing values

hist(data$medv)
boxplot(data$medv)
# heavy tail on the right-hand side of the distribution

data$logmedv <- log(data$medv)
boxplot(data$logmedv)
hist(data$logmedv)

# the logvariable seems closer to a normal distribution...
#  With the log transformation, we observe a heavy tail
# in the left hand side
# the distribution seems still more centered around the mean...


###########################
# Simple linear regression
###########################

#----------------------------
# Link between medv and lstat
#----------------------------


?Boston
#-------------------------------
# Link between logmedv and lstat
#--------------------------------

#Graph
attach(data)  #to avoid reference to the dataset
plot(logmedv~lstat)

# Model estimation
lm.fit1 <- lm(logmedv~lstat) # logmedv = b_0 + b_1 * lstat
summary(lm.fit1)

# Interpretation:
# the pvalue (Pr(>|t|)) is very small (less than 5%)
# So we conclude that the coefficient beta_1 is significantly different from 0
# and we can interpret its value.
# beta_1 = -0.04 <0 so an increase by 1 unit of lstat impacts negatively logmedv 
# by a decrease of 0.04

# adjusted R2 = 65%
# This model explains 65% of the log price variations

names(lm.fit1) # all the results provided by the function lm

plot(lstat,logmedv, pch="+")
abline(lm.fit1, col="red")

#--------------------
# Residuals analysis
#--------------------

# Normality of residuals
# QQplot
qqnorm(residuals(lm.fit1))
qqline(residuals(lm.fit1))
# most of the points fit on the line (except for the extreme quantiles) which indicates that
# the residuals distribution is not too far from a Normal distribution

#Shapiro-Wilks test
#Ho: the distribution is Normal
#H1: the distribution is not Normal

shapiro.test(residuals(lm.fit1))
# p-value = 2.29e-08 <<<5% so we reject Ho !
# The distribution cannot be considered as Normal
# There must be potential outliers....
hist(residuals(lm.fit1))

# Homoscedasticity / Shape of residuals
par(mfrow=c(1,2))
plot(predict(lm.fit1),residuals(lm.fit1))
plot(predict(lm.fit1),rstudent(lm.fit1))
abline(a=2,b=0,col="red")
abline(a=-2,b=0,col="red")
# rstudent: standardized residuals (residuals/ stdev)
# For normally distributed variables, standardized values
# should lie between -2 and 2 (with 95% of chance)


#----------------------------------
# Evaluate the quality of the model
#----------------------------------

#''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# Fit on the training sample using the R? and adjusted R?
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# the closer R? to 1, the better 

#''''''''''''''''''''''''''''''''''''''
# Predictive power with Validation set 
#'''''''''''''''''''''''''''''''''''''
#Sample the dataset
set.seed(1)
row.number <- sample(1:nrow(data), 0.8*nrow(data))
train = data[row.number,]
test = data[-row.number,]
dim(train)
dim(test)

# Estimate the linear fit on the training set
lm.fit0.8 <- lm(logmedv~lstat, data=train) # data=train to estimate the model
summary(lm.fit0.8)

# Compute RMSE, MAPE
pred0.8 <- predict(lm.fit0.8,newdata=test) # data=test to predict 
err0.8 <- pred0.8-test$logmedv
rmse <- sqrt(mean(err0.8^2))
mape <- mean(abs(err0.8/test$logmedv))
c(RMSE=rmse,mape=mape,R2=summary(lm.fit0.8)$r.squared) # to print the 3 parameters

plot(test$logmedv,pred0.8) # plot of predicted values against test values
abline(a=0,b=1, col="red")


#'''''''''''''''''''''''''''''''''
# LOOCV method
#'''''''''''''''''''''''''''''''''

install.packages("boot")
library("boot")
glm.fit <- glm(logmedv~lstat, data=data)
cv.err <- cv.glm(data,glm.fit)
cv.err$delta[1]  # to print the cross-validation statistics
# The best model is the one with the smallest CV statistics

View(data)

#'''''''''''''''''''''''''''''''''''''''''''''
# Application of the predictive accuracy tools
# 2 models: logmedv vs age or lstat
#'''''''''''''''''''''''''''''''''''''''''''''

# Accuracy on the sample with R? and adjusted R?
lm.fit2 <- lm(logmedv~age, data=data)
summary(lm.fit2)

# the fit on the sample is not very good
# R? = 20% (against 65% with the previous model)

# validation set method
lm.fit2 <- lm(logmedv~age, data=train)
summary(lm.fit2)
names(lm.fit2)
pred2 <- predict(lm.fit2,newdata=test)
err2 <- pred2-test$logmedv
rmse <- sqrt(mean(err2^2))
mape <- mean(abs(err2/test$logmedv))
c(RMSE=rmse,mape=mape,R2=summary(lm.fit2)$r.squared) # to print the 3 parameters

# Results for the second model
# RMSE > the previous one # the predictive power with age as predictor is worse
# MAPE > the previous one

# CV method
glm.fit2 <- glm(logmedv~age, data=data)
cv.err2 <- cv.glm(data,glm.fit2)
cv.err2$delta[1]

# CV > the previous one: the predictive power of this second model is worse.


#######################################
# Multiple regression setting
#######################################

# Comments on the dataset: 
# 1) there are a lot of predictors...
# 2) There is a qualitative variable, type factor: we can directly include it in the model
# 3) Particular attention to multicolinearity
# 4) Stepwise variable selection


#lm.fit <- lm(logmedv~lstat+age,data=data)
lm.fit <- lm(logmedv~.-medv, data=data) # all remaining variables will be used as predictors
summary(lm.fit)
#contrasts(chas)  # gives details on the recoding of the qualitative variables used 

#--------------------
# Multicolinearity
#------------------
# = too strong link between predictors
# multicolinearity introduces unstability in the model estimation
# and issues in the interpretation of model coefficients

#correlations 2 by 2
# cor(data[c(1:3,5:13)]) or cor(data[,-4])
# pairs(data[c(1:3,5:13)])

# Variance Inflation factor (VIF)
install.packages("car")
library("car")
vif(lm.fit)

# The larger the VIF, the more correlated the variables
# the most highly correlated predictor is tax, but the vif is still less than 10....
# We can continue with all predictors and apply the stepwise selection

#------------------------------
# Variables stepwise selection
#------------------------------

# We remove first the least significant variable (with the largest pvalue)
lm.fit1 <- update(lm.fit,~.-age)
summary(lm.fit1)
# Alternative equivalent formulation with the function update
# lm.fit1 <- update(lm.fit,~.-chas)

lm.fit2 <- update(lm.fit1,~.-indus)
summary(lm.fit2)

#--------------------------------
# Interaction terms
#-------------------------------

# possible interact between age and lstat
# lstat:age includes only the interaction term
# lstat*age includes lstat, age and the interaction term


summary(lm(logmedv~lstat*age, data=data)) # 3 predictors: lstat, age and lstat x age

#--------------------------------
# comparison of nested models
#-------------------------------

fit1 <- lm(logmedv~lstat+age, data=data)
fit2 <- lm(logmedv~lstat+age+lstat:age, data=data)
anova(fit1, fit2, test='F')
























