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
