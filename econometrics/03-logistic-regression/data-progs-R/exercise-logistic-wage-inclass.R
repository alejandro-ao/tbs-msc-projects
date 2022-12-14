################################################################
################ Logistic regressions with GAMS ################
################################################################

install.packages("ISLR2")
library("ISLR2")
?Wage
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
highwage <- factor(ifelse(wage > 105,1,0))
# Choice of breakpoint= 105(=median) or 150....
# highwage <- factor(ifelse(wage>105,1,0)) # 105: median of wage

# append target column to dataset
data.final <- data.frame(data,highwage)
View(data.final)
str(data.final)
summary(data.final)

# -------------------------------------------------------------
# EDA
# -------------------------------------------------------------
# Descriptive statistics
library(ggplot2)
ggplot(data.final, aes(x=highwage, age)) +
  geom_boxplot()
# r returns a boxplot by default
plot(highwage,age)
# high wage with
table(highwage, education)

# -------------------------------------------------------------
# Classical logistic regression
# -------------------------------------------------------------

# --------------------------
# Try a linear regression
# --------------------------

# we need a continuous target for linear regression
data.linear <- data.final
data.linear$highwage <- as.numeric(data.linear$highwage)
lm.fit.1 <- lm(highwage~age, data=data.linear)
summary(lm.fit.1)

ggplot(data.linear, aes(x=age, y=highwage)) +
  geom_point()
plot(age, highwage)
abline(lm.fit.1, col="red")

# not an amazing model to to use for classification. 
# Let's use logistic model instead!

# --------------------------
# Estimate logistic model
# --------------------------

# mod.1 <- glm(highwage~age+education+year,family=binomial, data=data.final)
mod.1 <- glm(highwage~year,family=binomial, data=data.final)
summary(mod.1)

data.final$highwage <- as.numeric(data.final$highwage)
plot(data.final$age, data.final$highwage)


#-----------------
# Model accuracy
#----------------

# Training set and test set
set.seed(1)
row.number <- sample(1:nrow(data.final), 0.8*nrow(data.final))
train=data.final[row.number,]
test=data.final[-row.number,]
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
View(data.final)

# natural cubic splines and GAMs
mod.gam <- glm(highwage~ns(age,knots=c(30,45,60))+ns(year,df=5)+education, family=binomial,data=data.final)
summary(mod.gam)
par(mfrow=c(1,3))
plot.Gam(mod.gam, se=TRUE, col="red")

# We can either fix the number of knots or the degrees of fredom
# the higher the number of knots, the more flexible the solution


# smoothing splines
#mod.gam2 <- gam(highwage~s(age,4)+s(year, 5)+education, family=binomial, data=data.final)
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
































