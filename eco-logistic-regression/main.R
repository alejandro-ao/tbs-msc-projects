############################################################################
# LOGISTIC REGRESSION WITH GAMS
############################################################################

install.packages("ISLR2")
library(ISLR2)

data <- Wage
?Wage

# -------------------------------------------------------------------------
# data structure
# -------------------------------------------------------------------------
attach(data)
summary(wage)
hist(wage) # right tailed distribution, maybe split the sample?

# -------------------------------------------------------------------------
# descriptive statistics
# -------------------------------------------------------------------------
# create dummy variable for high wage: 1 if wage > 150, 0 else
highwage <- factor(ifelse(wage>150, 1, 0))

# create new df with highwage variable
data.lr <- data.frame(data, highwage)
str(data.lr)
summary(data.lr)

# does high wage correlate with age? education?
attach(data.lr)
plot(highwage, age)
table(highwage, education) # too few obs. w low education & high wage

# restrict sample
data.res <- data.lr[(education != "1. < HS Grad"), ]
# other possibility: merge two lowest education cats

# -------------------------------------------------------------------------
# classical logistic regression
# -------------------------------------------------------------------------

# model estimation
mod1 <- glm(highwage~age+education+year, family=binomial, data=data.res)
summary(mod1)
# all the coefficients seem to have an impact on the log of odds, 
# and thus in the prediction. So there is no need to clean the model.

# create training set / test set
set.seed(1)
row.number <- sample(1:nrow(data.res), 0.8*nrow(data.res))
train=data.res[row.number, ]
test=data.res[-row.number,]
dim(train)
dim(test)

# model evaluation on the training set
mod.train <- glm(highwage~age+education+year, family=binomial, data=train)

# model prediction on the test set
pred.hw <- predict(mod.train, newdata=test, type="response")
head(pred.hw)

# make prediction yes/no
pred.hw <- ifelse(pred.hw > 0.5, 1, 0) # replace probs with 0/1 values

# -------------------------------------------------------------------------
# evaluate the prediction
# -------------------------------------------------------------------------

misclass.err <- mean(pred.hw != test$highwage)
misclass.err

print(paste("Prediction accuracy =", 1-misclass.err))

# confusion matrix
pred.hw <- factor(pred.hw, 
                  levels=c(0,1), 
                  labels=c("Predicted low wage", "Predicted high wage"))

test$highwage <- factor(test$highwage, 
                        levels=c(0,1), 
                        labels=c("Low wage", "High wage"))
table(pred.hw, test$highwage)
prop.table(table(pred.hw, test$highwage),2) # % by column

# almost all low wages were correctly assessed
# problem!!! : there was not a single high wage correct prediction
# reason 1: the breakpoint of 150 for high wage was not good
# --> maybe a lower breakpoint would be better
# reason 2: a linear model is too simple, use splice and GAMS instead
# reason 3: too few vars. add more explanatory variables?

# -------------------------------------------------------------------------
# GAMS logistic regression
# -------------------------------------------------------------------------

library(splines)
library(gam)

# natural cubic splines and GAMs
mod.gam <- glm(highwage~ns(age, knots=c(25, 40, 60)) +
                 ns(year, df=6) + 
                 education, 
               family="binomial",
               data=data.res)

par(nfrow=c(1,3))
plot.Gam(mod.gam, se=T, col="red")
par(nfrow=c(1,1))

# we can either fix the number of knots or the degrees of freedom
# the higher the number of knots, the more flexible the solution

# -------------------------------------------------------------------------
# Evaluating prediction accuracy for mod.gam
# -------------------------------------------------------------------------
mod.gamt <- glm(highwage~ns(age, knots=c(25, 40, 60)) +
                 ns(year, df=6) + 
                 education, 
               family="binomial",
               data=train)

# prediction on the test set
pred.hw <- predict(mod.gamt, newdata=test, type="response")
head(pred.hw)
pred.hw <- ifelse(pred.hw > 0.5, 1, 0)

test$highwage <- ifelse(test$highwage == "Highwage", 1, 0)

misclass.err <- mean(pred.hw != test$highwage)
misclass.err
print(paste("Prediction accuracy = ", 1-misclass.err))

# confusion matrix
pred.hw <- factor(pred.hw, 
                  levels=c(0,1), 
                  labels=c("Predicted low wage", "Predicted high wage"))

test$highwage <- factor(test$highwage, 
                        levels=c(0,1), 
                        labels=c("Low wage", "High wage"))
table(pred.hw, test$highwage)
prop.table(table(pred.hw, test$highwage),2) # % by column

