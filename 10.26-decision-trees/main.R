# ---------------------------------------------------------------------------
# setup
# ---------------------------------------------------------------------------

# import data, use strings as factor to have categorical variables
bank_data <- read.csv("./data/bank_full.csv", sep=";", stringsAsFactors = TRUE)

# str(data)
summary(bank_data)

# ---------------------------------------------------------------------------
# create decision tree
# ---------------------------------------------------------------------------

### install packages for model
# install.packages("rpart") # to fit the model
# install.packages("rpart.plot") # to plot the tree

# we need to define an output variable and all the input variables 
library(rpart)
library(rpart.plot)
decision_tree <- rpart(y ~ job+marital+education+default+housing+loan+contact+poutcome+duration, 
                       method="class", # class for  "classification"
                       data=bank_data, 
                       control=rpart.control(minsplit=1), 
                       parms=list(split="information")
                       )

# plot the tree
rpart.plot(decision_tree, type=2, extra=1)
