###################################
# Regression models: linear, polynomial, splines, GAMs
# Wage data
# Default data
####################################

install.packages("ISLR2")
library("ISLR2")
?Wage
data <- Wage
summary(data)
View(data)
quantile(data$age)

#--------------------------
# Data Structure
# missing values, outliers
#--------------------------

str(data)
attach(data)

#missing values
summary(data)
# no missing value

# variable of interest: wage (or log wage)

hist(wage) # fat tail on the right of the distribution
boxplot(wage)

hist(logwage)
boxplot(logwage)
# Tails on both sides of the distribution
# But for logwage, mean=median, 
# the distribution is centered around the mean

# Y = logwage
# Explain logwage wrt age, year, education, 
# +additional factor variables like jobclass, health, health_ins

####################################################
# Linear regression logwage  wrt age, year education
#####################################################

plot(age, logwage)
plot(year, wage)
plot(education, logwage, las=2)

# Year could be defined as a factor??
data$year <- as.numeric(year)

# Linear fit
#-----------

fit1 <- lm(logwage~age+year+education, data=data)
summary(fit1)
names(fit1)

# All coefficients are significants (pvalue << 5%)
# All coefficients are positive: the predictors all have a positive impact
# on the logwage

# Residuals analysis
plot(predict(fit1), residuals(fit1))
plot(predict(fit1), rstudent(fit1)) #standardized residuals
abline(a=-2,b=0,col="red")
abline(a=2,b=0,col="red")


########################
# Polynomial regression
########################

# polynomial transformation age^2 using I(X^2)
fit2 <-lm(logwage~age+I(age^2)+year +education, data=data)
summary(fit2)
?I

# All significant coefficients
# Inverted U-shape between logwage and age^2



# ANOVA test between the 2 nested models
#--------------------------------------
anova(fit1, fit2)
# Ho: no significant change between the 2 models
# H1: there is a significant difference (model 2 fits better)
# pvalue <<< 5%, the model has significantly improved

# Compare various nested models 
#------------------------------

fit3 <- lm(logwage~poly(age,3)+year +education, data=data)
fit4 <- lm(logwage~poly(age,4)+year +education, data=data)
fit5 <- lm(logwage~poly(age,5)+year+education, data=data)

anova(fit1, fit2, fit3, fit4, fit5)
# The best model seems to be model 3 since pvalues after model 3 are larger
# than 5%

# LOOCV parameter to compare models
#----------------------------------

install.packages("boot")
library("boot")
cv.error <- rep(0,3)
for (i in 1:3) {
  glm.fit <- glm(logwage~poly(age,i)+year+education,data=data)
  cv.error[i] <- cv.glm(data,glm.fit)$delta[1]
}
cv.error
# wrt CV statistics, model 2 seems already very good 
# the difference with model 3 is very small

install.packages("gam")
library(gam)
par(mfrow=c(1,3))
plot.Gam(fit3)


##########
# Splines
##########

install.packages("splines")
library("splines")

#---------------
# Cubic splines
#---------------
quantile(age)

fit.lin <- lm(logwage~age, data=data)
fit.quad <- lm(logwage~poly(age,2), data=data)
fit.cubic <- lm(logwage~poly(age,3), data=data)
fit.bs <- lm(logwage~bs(age, knots=c(25,40,60)), data=data)
# bs: basis splines
# By default, degree = 3 cubic splines
# equivalent writing: fit.bs <- lm(logwage~bs(age, degree =3, knots=c(25,40,60)), data=data)


#-------------
# Parenthesis
#-------------

# Alternatively, we can choose the degrees of freedom 
# and the knots will be automatically chosen as quantiles of the explanatory variable.

splinesfit2 <- lm(logwage ~ bs(age,df = 6), data = Wage )
# Here df = 6 does not include the intercept so effective degreees of freedom = 7
summary(splinesfit2) 
 
par(mfrow=c(1,1))
#Plotting the Regression Line to the scatterplot   
plot(age, logwage,  col = "grey", pch = "x",
     xlab = "Age", ylab = "LogWage")

agegrid <- seq(from = min(age), to =max(age), length=200)
points(agegrid, predict(splinesfit2,newdata = list(age=agegrid)),
       col="darkgreen", lwd = 2, type = "l")
#adding knots
abline(v = quantile(age, probs = c(0.25,0.5,0.75)), lty = 2, 
       col = "darkgreen")


#-----------------
# End Parenthesis
#-----------------

# plot of solutions
#------------------

par(mfrow=c(1,1))
plot(age, logwage)
?abline

abline(fit.lin, col="red")

#abline function does not work for polynomials...
?seq
age.calc <- seq(min(age), max(age), length=50)
age.eval <- data.frame(age=seq(min(age), max(age), length=50))
predict.lin <- predict(fit.lin,newdata=age.eval)
predict.quad <- predict(fit.quad,newdata=age.eval)
predict.cubic <- predict(fit.cubic,newdata=age.eval)
predict.bs <- predict(fit.bs,newdata=age.eval)

plot(age, logwage, col="red")
lines(age.calc,predict.lin, col="darkgrey" ,lwd=3)
lines(age.calc,predict.quad, col="blue", lwd=3)
lines(age.calc, predict.cubic, col="green", lwd=3)
lines(age.calc, predict.bs, col="black", lty=2, lwd=3)
abline(v=c(25,40,60),lty=2)
legend("bottomright", legend=c("degree 1", "degree 2", "degree 3", "cubic splines", "sample"), 
                               cex=0.7, bty="n", lty=1, lwd=3,
                               col=c("darkgrey","blue", "green", "black", "red"))

# For fit.lin, fit.quad and fit.cubic, we fit one function 
# on the whole sample
# For fit.bs, we fit a cubic spline, with 3 knots: 
# piecewise polynomial fit on each segment with smoothness
# conditions at the border of the segments



#-----------------------
# Natural Cubic splines
#-----------------------

fit.ns <- lm(logwage~ns(age, knots=c(25,40,60)), data=data)
predict.ns <- predict(fit.ns, newdata=age.eval, se=T)
# computation of the standard errors se=T

plot(age, logwage, main="natural splines", col="gray")
lines(age.calc, predict.ns$fit, lwd=2)
lines(age.calc, predict.ns$fit+2*predict.ns$se, lty="dashed")
lines(age.calc, predict.ns$fit-2*predict.ns$se, lty="dashed")

#-------------------------------
#  Smoothing splines (optional)
#-------------------------------

#fit.s <- smooth.spline(age, logwage, cv=TRUE)
# CV=TRUE allows to fix automatically the tuning parameter lambda
#plot(age, logwage, col="gray")
#lines(fit.s, col="red", lwd=2)


#########
# GAMs
#########

# GAM with cubic splines
gam1 <- lm(logwage~bs(age, df=6)+bs(year, df=6)+education, data=data)
summary(gam1)

par(mfrow=c(1,3))
plot.Gam(gam1, se=TRUE, col="red")

# GAM with natural splines
gam2 <- lm(logwage~ns(age, df=6)+ns(year, df=6)+education, data=data)

# GAM with smoothing splines (optional)
#gam3 <- gam(logwage~s(year,4)+s(age, 4)+education, data=data)

# Interaction effects
gam3 <- lm(logwage~ns(age, df=6)+ns(year, df=6)+ns(age, df=6):ns(year, df=6)+education, data=data)
summary(gam3)

#ns(age, df=6):ns(year, df=6) ou te (package mgcv)

##################################
# Model check - Residuals analysis
##################################

qqnorm(residuals(gam3))
qqline(residuals(gam3))

hist(residuals(gam3))
boxplot(residuals(gam3))

plot(predict(gam3),residuals(gam3))
plot(predict(gam3),rstudent(gam3))

#################
# Model selection
#################

gam.fit1 <- glm(logwage~ns(age, df=6)+ns(year, df=6)+ns(age, df=6):ns(year, df=6)+education,data=data)
summary(gam.fit1)
cv.error1 <- cv.glm(data,gam.fit1)$delta[1]
cv.error1

#-------------
# Using LOOCV
#-------------

#-----------------
# Using ANOVA test
#-----------------

anova(gam1, gam2, gam3,test="F")




#------------
# Parenthesis
#------------

install.packages("mgcv")
library('mgcv')

b1 <- mgcv::gam(logwage~s(age)+education,data=Wage)
mgcv::plot.gam(b1, pages=1, seWithMean =TRUE)

# Adding an interaction effect
b4 <- gam(logwage~s(age)+education+s(year,k=5)+te(age,year),data=Wage)
plot(b4,pages=2,seWithMean=TRUE) 

par(mfrow=c(2,2))
gam.check(b1)


# Autre package: mgcViz

