data <- Boston

# ----------------------------------------------------------------
# data structure
str(data)
summary(data$rad)

# issue: should we consider it as a quantitative or as a factor ?

# only one variable is factor visualize the outliers
# heavy tail on the right hand side of the distribution
hist(data$medv)
boxplot(data$medv)

data$logmedv <- log(data$medv)
par(mfrow=(c(2,1)))
par(mfrow=(c(2,1)))

# with log transformation, heavy tail in the left hand side

# ----------------------------------------------------------------
# output variable 3 data structure
# ----------------------------------------------------------------

# ----------------------------------------------------------------
# outliers and missing values
# ----------------------------------------------------------------

# ----------------------------------------------------------------
# simple regression model
# ----------------------------------------------------------------

# link between logmedv and lstat

# graph
# model estimation
attach(data) # avoid reference to the dataset
plot(logmedv~lstat)

lm.fitl <- lm(logmedv~lstat) # logmedv = b_0 + b_1 * lstat

# interpretation
# residuals analysis
# evaluation of the quality of the model
