#######################################################
###                 Regression                #########
#######################################################



# Define a project called "Regression" and store it in a file called "Modelling Techniques"

# Download and store the dataset "data_logit" and the script "Regression_Script" into the file "Modelling Techniques"


# Import the dataset

if(!require(devtools)) install.packages("devtools")

devtools::install_github("kassambara/datarium", force=TRUE)

# Datarium package provides a list of data set for statistical analysis and visualization


# Install others packages

install.packages('lattice')



#  Load packages

library('datarium')
library('lattice')

# Load and inspect the marketing data

data("marketing", package = "datarium")
head(marketing, 5)

# A summary of the dataset

summary(marketing)


# Pair-wise relationships of the variables: the scatterplot matrix

splom(~marketing[c(1:4)], groups=NULL,data=marketing,axis.line.tck=0,axis.text.alpha=0)

#Give matrix with scatter plot between the var 2 by 2
#Look if line shape on scatter plot btw Y= sales and each X = youtube, fb and newspaper
#If the shape is not good, the coefficient of the explicative variable will not be significant
#Btw X variables : no shape beacuse no correlation

#----------------------------------------------------------
# Linear relationship between sales, youtube and  facebook.
#----------------------------------------------------------

# Estimation of the model

results <- lm(sales~youtube + facebook + newspaper, marketing)
summary(results)

#R-SQUARED : 89% of the variations of the sales are explained by our model

#As predicted, newspaper is not significant (p value is higher than 5% and no stars)
#We can remove it if we want 

results <- lm(sales~youtube + facebook, marketing)
summary(results)

# Confidence Intervals on the Parameters

confint(results, level = .95)

#Interval inside the one the true value is, with a risk of 5%
#This give us the upper and the lower limit

# Prediction: 95% confidence interval on the expected sales

youtube <- 160
facebook <- 30
newspaper <- 20
news_budget<-data.frame(youtube, facebook, newspaper)

#Store the information of a new company into a data frame 

# Prediction: 95% confidence interval on the expected sales

conf_int_sales <- predict(results,news_budget,leve1=.95,interval="confidence")
conf_int_sales

#Give us the predicted value of sales with the upper value and the lower one

# Diagnostics: Evaluating the Residuals: centered on zero with a constant variance

with(results, {plot(fitted.values,residuals,ylim=c(-40,40)) 
  points(c(min(fitted.values),max(fitted.values)), c(0,0), type="l")})

### FIRST HYPOTHESIS OF RESIDUALS : MEAN EQUAL TO 0 ###

#All the residuals are around the min 0 value on the graph 
#So the first assumption is validated (need to have a residuals' mean equal to 0)

### 2ND HYPOTHESIS OF RESIDUALS : VARIANCE IS CONSTANT ###

#As all the residuals are bounded around zero (inside a kind of rectangle around the mean), the variance is constant

### 3RD HYPOTHESIS OF RESIDUALS : RESIDUALS ARE NORMALY DISTRIBUTED ###

# Diagnostics: Evaluating the Normality Assumption of residuals

hist(results$residuals, main="")

# Evaluating the Normality Assumption of residuals

qqnorm(results$residuals, ylab="Residuals", main="")
qqline(results$residuals)

#------------------------
#  Logistic Regression
#------------------------
    
# Load the dataset and have a view

Bankdata<-read.csv("data_logit.csv", stringsAsFactors = TRUE)[,-1]
summary(Bankdata)

  
# The dataset is divided in two: a training set and a test set

Bankdata_training<-Bankdata[1:(dim(Bankdata)[1]-500),]
Bankdata_test<-Bankdata[(dim(Bankdata)[1]-500+1):dim(Bankdata)[1],]

#The first par is to create the regression model, and the second part is to verify if our model is good or not

  
# Estimation
  
logit_model <- glm (default~., data=Bankdata_training,binomial(link="logit")) #glm fit a large amount of model, even if it's not the linear one
summary(logit_model)

#Categorical variable with N possible values, one will be out of the set of the model because it will be redundant 
  
# Interpretation an increase in balance of one unit is associated with an increase of 5.820e-03 in the log odds of default; being student reduces the the log odds of default by -7.113e-01. Students are less likely to default than non-students (Intuitive??)
  
# Which variable is the most important?
    
install.packages("caret")
install.packages("timeDate")

#Package that give us the possibility to mesure the importance of each variable
  
library("caret")

varImp(logit_model)

#Here, the variable Balance has the most impact on our model 
  
#-------------
# Diagnostics
#-------------
  
# Pseudo-R2: how well the fitted model explains the data as compared to the default model of no predictor variables and only an intercept term; values closer to one indicating that the model has good predictive power

#  Pseudo-R^2=1-\frac{Residual \ \ deviance}{Null \ \ deviance}=1-\frac{1473.0}{2758.8}=0.466

###Classification Rate: how well the model does in predicting the dependent variable on out-of-sample observations?
    
prediction_test <- predict(logit_model, newdata = Bankdata_test, type = "response")

prop.table(table(Bankdata_test$default, prediction_test > 0.5))

# The results show 95.6% of the predicted observations are true negatives and about 1.4% are true positives; 
# Type II error is 2.4%: in those cases, the model predicts customers will not default but they did; 
# Type I error is 0.006%: in those cases, the models predicts customers will default but they never did.
