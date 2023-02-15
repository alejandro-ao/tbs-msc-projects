##############################################
# Toulouse airport traffic: complete analysis
##############################################

#package tseries: unit root tests; Jarque Bera tests
#package TSA: McLeod.li.test; fitted
#package zoo: index
#package forecast: accuracy; checkresiduals; autoarima; autoplot


#-----------------
# Import Data
#----------------

Tlsetraf <- read.csv2('TlseAirport2019.csv')
View(Tlsetraf)

#Define the ts object
traf <- ts(Tlsetraf[,3], start=c(1982,1), frequency=12)
time(traf)

#--------------------
# Stationarity issue
#--------------------

# 3 plots: data; acf; pacf

#'''''''''
# raw data
#''''''''''
plot.ts(traf)
# Several patterns of non stationarity: 
#increasing variance, non constant trend, potential seasonal effects

acf(ts(traf, frequency=1), main="Autocorrelogram main series")
#patterns of non stationarity:
#persistence of significant coefficients, no fast decay to 0

pacf(ts(traf, frequency=1), main="Partial autocorrelogram main series")

# The main series is non stationary

#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# 1st transformation: log to remove for increasing variance effect
#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
ltraf <- log(traf)

plot.ts(ltraf)
#No more increasing variance effect
#still: non constant trend, potential seasonal effect

acf(ts(ltraf, frequency=1), main="Autocorrelogram  log(series)")
#same patterns of non stationarity:
#persistence of significant coefficients, no fast decay to 0

pacf(ts(ltraf, frequency=1), main="Partial autocorrelogram log(series)")

# The log(series) is still non stationary

#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# 2nd transformation: 1st order difference to remove the trend
#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
dltraf <- diff(ltraf,1)

plot.ts(dltraf, xlim=c(2000,2010))
#no more increasing variance and no more trend
#still potential seasonal effects

acf(ts(dltraf, frequency=1), main="Autocorrelogram  1st difference of log(series)")
#persistence of significant coefficients with seasonality s=12

pacf(ts(dltraf, frequency=1), main="Partial autocorrelogram 1st difference of log(series)")
# strong significant coefficients around lag 12

# The series is still non stationary

#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
#3rd transformation: difference of order 12 to remove seasonality
#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
dltraf_12 <- diff(dltraf,12)

plot.ts(dltraf_12)
# no more seasonal effects
#We can identify some perturbations in the trafic before 1990

acf(ts(dltraf_12, frequency=1), main="Autocorrelogram  1st difference of log(series) wo seasonality")
# significant coefficients at lags 1, 12, 13

pacf(ts(dltraf_12, frequency=1), main="Partial autocorrelogram 1st difference of log(series) wo seasonality")
# significant coefficients at lags 1, 11, 12, 23, 24

# We can try and fit a multiplicative SARIMA on log(traffic)

#---------------------------------
# Identification of orders p and q
#---------------------------------
# d=D=1, s=12
# p=q=1
# P=Q=1 as a starting point
# Then try P=2 to identify effects at lag 24

#------------------------------------------------------------------------
# Estimation of a multiplicative SARIMA(1,1,1)(1,1,1) with seasonality 12 
#------------------------------------------------------------------------
mod1 <- arima(ltraf, c(1,1,1), seasonal=list(order=c(1,1,1), period=12), method='ML')
mod1

#AIC = -1528.81

#plot of the fitted value
install.packages("TSA")
library("TSA")
fit1 <- fitted(mod1)
fit1
plot.ts(cbind(ltraf,fit1), plot.type='single', col=c('black','red'))

#--------------------
# Validation of mod1
#--------------------

#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# Significance of coefficients: pvalue of Student test on each coeff
#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

# Student test to check for the significance of coeffs
#'''''''''''''''''''''''''''''''''''''''''''''''''''''
# Ho: coeff=0 against H1: coeff#0
# pvalue< 5%, we accept H1

mod1$coef  #value of coefficients
mod1$var.coef #variance of coefficients
tstat <- mod1$coef/sqrt(diag(mod1$var.coef)) # test statistic of the Student test
pvalue <- 2*(1-pnorm(abs(tstat))) #pvalue of the test 
tstat
pvalue
# the pvalues of AR1 and SAR1 are larger than 5%
# So we could remove these coefficients from the model

#'''''''''''''''''''''''''''''''''''''''''''''''''''''''
# Residuals analysis: assumption of Gaussian White Noise
#'''''''''''''''''''''''''''''''''''''''''''''''''''''''
res1 <- mod1$residuals
plot(res1)
# We can identify one extreme value: the residuals are less than -0.2

# General overview of residuals
checkresiduals(mod1)

# Autocorrelation of the residuals
#'''''''''''''''''''''''''''''''''

acf(ts(res1,frequency=1))
# only one significant coeff at lag 6

# Box-Pierce test ou Ljung-Box test
#Ho: no autocorrelation against H1: autocorrelation

Box.test(res1, lag=20, type="Ljung-Box")
# Ho: all correlations up to lag 20 are =0 
# H1: at least one is different from 0
# pvalue=16% > 5%, we accept HO: no autocorrelation

# Normal Distribution assumption
#'''''''''''''''''''''''''''''''

res_norm <- res1/sqrt(mod1$sigma2) # normalized residuals
summary(res_norm)

# If the residuals follow a Normal distribution, the values of res_norm
# should lie in between -2 and 2, with 95% of chance

plot(res_norm)
abline(a=2,b=0,col="red")
abline(a=-2, b=0, col="red")

out1 <- which(res_norm < -4) # identification number of the outlier
out1 # the outlier corresponds ot observation n°50

install.packages("zoo")
library("zoo")
index(res_norm)[out1] #date of the outlier
# the outlier occurs at date 1986.083 (1 month= 1/12)
traf[out1] # value of the outlier
traf[(out1-2):(out1+2)] # values around the outlier
traf[(out1-14):(out1-10)] # values 12 months before the outlier

#QQplot 
# check whether the points are close to the line
qqnorm(res1)
qqline(res1)

#Shapiro test
shapiro.test(res1)
# pvalue < 5% so we reject the normality assumption

# Jarque-Bera test
install.packages('tseries')
library(tseries)
jarque.bera.test(res1)


# Constant variance assumption
#'''''''''''''''''''''''''''''
sq.res <- (res1)^2
acf(ts(sq.res, frequency=1))
# 2 highly significant coeffs: lag 1 and lag 12
# There is an issue of non constant variance

# TSA package to apply McLeod Li test
Htest <- McLeod.Li.test(mod1, plot=FALSE)
Htest
# The analysis of the 1st pvalue is enough
#pvalue=1.77 e-05 < 5% so we reject the constant variance assumption

#------------
# Prediction
#-----------

# Check of the quality of the fit wrt confidence bounds
#-------------------------------------------------------

cb80 <- mod1$sigma2^.5*qnorm(0.9) # confidence bound of security 80%
plot(cbind(ltraf, fit1-cb80, fit1+cb80), plot.type='single', 
     lty=c(1,2,2), xlim=c(2000,2010))

# Proportion of points in the confidence interval
indi <- (ltraf-(fit1-cb80))>0&(fit1+cb80-ltraf)>0
prop <- 100*sum(indi)/length(indi)
prop
#prop = 85%

# if prop > 80%, then the fit is considered good

# Validation set approach
#'''''''''''''''''''''''''

#Idea: split the sample into 2 subsamples: training set and test set

data.train <- window(ltraf, start=c(1982,1), end=c(2018,1))
# 277 obs for data.train
data.test <- window(ltraf, start=c(2018,2), end=c(2019,7))
# 174 obs for data.test

mod1.train <- arima(data.train, c(1,1,1), seasonal=list(order=c(1,1,1), period=12), method='ML')
pred1.test <- predict(mod1.train, n.ahead=174)

install.packages("forecast")
library("forecast")
accuracy(pred1.test$pred,data.test)

#      ME      RMSE        MAE        MPE      MAPE      ACF1    Theil's U
#-0.0428181 0.0872974 0.06712551 -0.3253468 0.5054401 0.6566793 0.9709756

#The best model has the lowest values for the accuracy parameters

# plot comparing observed values and prediction of the traffic
ts.plot(traf, xlim=c(2016,2020))
lines(2.718^(pred1.test$pred), col="red")
lines(2.718^(pred1.test$pred-1.96*pred1.test$se), col=4, lty=2)
lines(2.718^(pred1.test$pred+1.96*pred1.test$se), col=4, lty=2)



#--------------------------
# Estimation of a 2nd model
#--------------------------

# 1st idea: remove the non significant coeff AR1 and SAR1

# Without SAR1
mod2 <- arima(ltraf, c(1,1,1), seasonal=list(order=c(0,1,1), period=12), method='ML')
mod2

#AIC_mod1 = -1528.81
#AIC_mod2 = -1531.1, mod2 is a little bit better sice AIC_mod2 < AIC_mod1


mod2$coef  #value of coefficients
mod2$var.coef #variance of coefficients
tstat <- mod2$coef/sqrt(diag(mod2$var.coef)) # test statistic of the Student test
pvalue <- 2*(1-pnorm(abs(tstat))) #pvalue of the test 
tstat
pvalue
#         ar1          ma1         sma1 
#2.949681e-01 2.052156e-10 0.000000e+00 

# The pvalue of AR1 coeff is still > 5%, so the coeff is still non significant

# Check for residuals autocorrelation for model2
res2 <- mod2$residuals
acf(ts(res2,frequency=1)) 
# still no significant coefficients before lag 6
# removing SAR1 hasn't worsened the residuals ACF


# Let's try without AR1 coefficient
mod3 <- arima(ltraf, c(0,1,1), seasonal=list(order=c(0,1,1), period=12), method='ML')
mod3

#AIC_mod1 = -1528.81
#AIC_mod2 = -1531.1, mod2 is a little bit better sice AIC_mod2 < AIC_mod1
#AIC_mod3 = -1532.08, mod3 is a little bit better sice AIC_mod3 < AIC_mod2

mod3$coef  #value of coefficients
mod3$var.coef #variance of coefficients
tstat <- mod3$coef/sqrt(diag(mod3$var.coef)) # test statistic of the Student test
pvalue <- 2*(1-pnorm(abs(tstat))) #pvalue of the test 
tstat
pvalue
# both MA1 and SMA1 are highly significant!

# Check for residuals autocorrelation for model3
res3 <- mod3$residuals
plot.ts(res3)
acf(ts(res3,frequency=1)) 
# still no significant coefficients before lag 6
# removing SAR1 hasn't worsened the residuals ACF

# Check for residuals normality

res_norm3 <- res3/sqrt(mod3$sigma2) # normalized residuals
summary(res_norm3)

# If the residuals follow a Normal distribution, the values of res_norm
# should lie in between -2 and 2, with 95% of chance

plot(res_norm3)
abline(a=2,b=0,col="red")
abline(a=-2, b=0, col="red")

# Check for residuals constant variance
sq.res3 <- (res3)^2
acf(ts(sq.res3, frequency=1))
# 2 highly significant coeffs: lag 1 and lag 12
# The issue of non constant variance remains


# Check of the quality of the fit wrt confidence bounds
#-------------------------------------------------------
install.packages("TSA")
library("TSA")
fit3 <- fitted(mod3)
fit3

cb80 <- mod3$sigma2^.5*qnorm(0.9) # confidence bound of security 80%
plot(cbind(ltraf, fit3-cb80, fit3+cb80), plot.type='single', lty=c(1,2,2), xlim=c(2000,2010))

# Proportion of points in the confidence interval
indi <- (ltraf-(fit3-cb80))>0&(fit3+cb80-ltraf)>0
prop <- 100*sum(indi)/length(indi)
prop
#prop_mod1 = 85%
#prop_mod3 = 85,36%
# no big improvement


#------------------------------------------------------
# Let's add a dummy variable to correct for the bad fit
# at date February 1986
#------------------------------------------------------
# Adding an external variable X = fitting a SARIMAX model

out3 <- which(res_norm3 < -4) # identification number of the outlier
out3 # the outlier corresponds ot observation n°50

install.packages("zoo")
library("zoo")
index(res_norm3)[out3] #date of the outlier
# the outlier occurs at date 1986.083 (1 month= 1/12)

# Create a Dummy variable at date February 1986
#''''''''''''''''''''''''''''''''''''''''''''''
Tlsetraf$dum1 <- 0
Tlsetraf$dum1[out3] <- 1

mod4 <- arima(ltraf, c(0,1,1), seasonal=list(order=c(0,1,1), period=12), method='ML', xreg=Tlsetraf$dum1)
mod4

#AIC_mod4 = -1605.75
# Big improvement wrt the previous models

res4 <- mod4$residuals
par(mfrow=c(2,1))
plot(res3)
plot(res4)
par(mfrow=c(1,1))

# Remark in order to do predictions using model 4
#'''''''''''''''''''''''''''''''''''''''''''''''''


pred4 <- predict(mod4, n.ahead=12, newxreg=0)
ts.plot(traf, 2.718^pred4$pred,log="y", lty=c(1,3))

#----------------------------
# automatic choice of model
#--------------------------

library(forecast)
d.arima <- auto.arima(traf)
d.forecast <- forecast(d.arima, level = c(95), h = 50)
autoplot(d.forecast)





