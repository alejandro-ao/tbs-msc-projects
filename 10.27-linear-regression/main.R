library('datarium')
library('lattice')

# ----------------------------------------------------------------------------
# setup
# ----------------------------------------------------------------------------

# load and inspect the data
data("marketing", package = "datarium")
head(marketing, 5)
summary(marketing)

# ----------------------------------------------------------------------------
# visualize data to choose model
# ----------------------------------------------------------------------------
### are sales linearly correlated?
# youtube and facebook seem to have a linear correlation with sales
# news doesn't
splom(~marketing[c(1:4)], 
      groups=NULL, 
      data=marketing, 
      axis.line.tck=0, 
      axis.text.alpha=0)

# ----------------------------------------------------------------------------
# fit the linear regression model to the variables
# ----------------------------------------------------------------------------
results <- lm(sales~youtube + facebook + newspaper, marketing)
### summary
summary(results) 
# overall p value: is smaller than 0.05. so it's significant
# each coefficient estimate: first column 
# p-value per variable: last column
# R-squared: 89% are explained by the money explained by the model 

# find the confidence intervals for each variable
confint(results, level = .95)


# ----------------------------------------------------------------------------
# make a prediction
# ----------------------------------------------------------------------------
youtube <- 160
facebook <- 30
newspaper <- 20
news_budget<-data.frame(youtube, facebook, newspaper)
conf_int_sales <- predict(results,news_budget, level=0.95, interval="confidence")
conf_int_sales


# ----------------------------------------------------------------------------
# verify that the model prediction is reliable
# ----------------------------------------------------------------------------
### our assumptions:
# e: normally distributed. e ~N(0, sigma2)
# E(e) = 0
# var(e) = sigma2
# 

# plot the residuals (errors) to see if they turn around 0
with(results, {plot(fitted.values,residuals,ylim=c(-40,40)) 
  points(c(min(fitted.values),max(fitted.values)), c(0,0), type="l")})

# is it normally distributed?
hist(results$residuals, main="")

# plot the residuals
qqnorm(results$residuals, ylab="Residuals", main="")
qqline(results$residuals)

