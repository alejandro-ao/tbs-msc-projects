################################################################
################ Logistic regressions with GAMS ################
################################################################

install.packages("ISLR2")
library("ISLR2")
# Wage
# Default

data <- Wage
View(data)
str(data)
summary(data)

# -------------------------------------------------------------
# Create Target Variable
# -------------------------------------------------------------
attach(data)

par(mfrow=c(1,1))
hist(wage)
median(wage)
boxplot(wage)

# Create 0/1 variable
highwage <- factor(ifelse(wage > 150,1,0))
# Choice of breakpoint= 105(=median) ou 150....
# highwage <- factor(ifelse(wage>105,1,0)) # 105: median of wage

data.lr <- data.frame(data,highwage)
View(data.lr)
str(data.lr)
summary(data.lr)

# -------------------------------------------------------------
# EDA
# -------------------------------------------------------------
# Descriptive statistics
library(ggplot2)
ggplot(data.lr, aes(x=highwage, age)) +
  geom_boxplot()
# r returns a boxplot by default
plot(highwage,age)
table(highwage, education)

# too few observations in the 1st category for Education
# merge the two lowest education categories
data.res <- data.lr[(education != "1. < HS Grad"),]


# -------------------------------------------------------------
# Classical logistic regression
# -------------------------------------------------------------

# --------------------------
# Try a linear regression
# --------------------------

# we need a continuous target for linear regression
data.res$highwage <- as.numeric(data.res$highwage)
lm.fit.1 <- lm(highwage~age, data=data.res)
summary(lm.fit.1)

ggplot(data.res, aes(x=age, y=highwage)) +
  geom_point()
plot(age, highwage)
abline(lm.fit.1, col="red")

# not an amazing model to to use for classification. 
# Let's use logistic model instead!

# --------------------------
# Estimate logistic model
# --------------------------

# turn target back to factor
data.res$highwage <- as.factor(data.res$highwage)
attach(data.res)
# mod.1 <- glm(highwage~age+education+year,family=binomial, data=data.res)
mod.1 <- glm(highwage~year,family=binomial, data=data.res)
summary(mod.1)

data.res$highwage <- as.numeric(data.res$highwage)
plot(data.res$age, data.res$highwage)


#-----------------
# Model accuracy
#----------------

# Training set and test set
set.seed(1)
row.number <- sample(1:nrow(data.res), 0.8*nrow(data.res))
train=data.res[row.number,]
test=data.res[-row.number,]
dim(train)
dim(test)
View(train)
View(test)

#model evaluation on the training set
mod.train <- glm(highwage~age+education+year,family=binomial, data=train)

# prediction on the test set
pred.hw <- predict(mod.train, newdata=test, type='response')
head(pred.hw)

#prediction accuracy
pred.hw <- ifelse(pred.hw>0.5,1,0)
# replace probabilities by 0/1 coding

misclass.err <- mean(pred.hw != test$highwage)
# != stands for not equal to
misclass.err
print(paste('Prediction accuracy =', 1-misclass.err))

# Condusion matrix
pred.hw <- factor(pred.hw, levels=c(0,1), labels=c("Predicted low wage", "Predicted high wage"))
test$highwage <- factor(test$highwage, levels=c(0,1), labels=c("Low wage","High wage" ))
View(test)

table(pred.hw, test$highwage)
prop.table(table(pred.hw, test$highwage),2)

## with the cut at 150:
# almost all low wages have been correctly assessed
# Regarding the High wage, the model performs very bad
## with the cut at 105:
# Almost 80% of the low wages have been correctly predicted
# And 65% of the high wage have been correctly predicted

# reason 1: the breakpoint of 150 to define high wage is not good
  # Maybe a lower could give better results
# reason 2: a linear model is too simple, 
  # We should use splines and GAMs instead
# reason 3: we should add more explanatory variables
# reason 4: change the definition of traning set/ test set (70%, 30%)


##########################
# GAM logistic regression
##########################

library("splines") # to use bs or ns functions
library("gam") # to use gam.plot or gam function
View(data.res)

# natural cubic splines and GAMs
mod.gam <- glm(highwage~ns(age,knots=c(30,45,60))+ns(year,df=5)+education, family=binomial,data=data.res)
summary(mod.gam)
par(mfrow=c(1,3))
plot.Gam(mod.gam, se=TRUE, col="red")

# We can either fix the number of knots or the degrees of fredom
# the higher the number of knots, the more flexible the solution


# smoothing splines
#mod.gam2 <- gam(highwage~s(age,4)+s(year, 5)+education, family=binomial, data=data.res)
#par(mfrow=c(1,1))
#plot.Gam(mod.gam2, se=TRUE, col="red")

#--------------------------------
# Prediction accuracy for mod.gam
#--------------------------------
mod.gamt <- glm(highwage~ns(age,knots=c(30,45,60))+ns(year,df=5)+education, family=binomial,data=train)


# prediction on the test set
pred.hw <- predict(mod.gamt, newdata=test, type='response')
head(pred.hw)

#prediction accuracy
pred.hw <- ifelse(pred.hw>0.5,1,0)
# replace probabilities by 0/1 coding
head(pred.hw)
View(test)

test$highwage <- ifelse(test$highwage=="High wage",1,0)

View(test)
misclass.err <- mean(pred.hw != test$highwage)
# != stands for not equal to
misclass.err
print(paste('Prediction accuracy =', 1-misclass.err))

# Confusion matrix
pred.hw <- factor(pred.hw, levels=c(0,1), labels=c("Predicted low wage", "Predicted high wage"))
test$highwage <- factor(test$highwage, levels=c(0,1), labels=c("Low wage","High wage" ))
View(test)

table(pred.hw, test$highwage)
prop.table(table(pred.hw, test$highwage),2)

# The two models have almost the same prediction accuracy of 88%
# However, the second model performs better to predict high wages correctly
































