# ---------------------------------------------------------------------------
# setup
# ---------------------------------------------------------------------------

# import the data
bank_data <- read.csv("./data/data_logit.csv", stringsAsFactors = TRUE)[,-1]
View(bank_data)

# define training and testing sets
train <- bank_data[1:(dim(bank_data)[1]-500), ]
test <- bank_data[(dim(bank_data)[1]-500+1):dim(bank_data)[1], ]

# ---------------------------------------------------------------------------
# fit the model to training data set
# ---------------------------------------------------------------------------

logit_model <- glm(default ~ ., family=binomial(link="logit"), data=train)
# check the coefficients
summary(logit_model)

# ---------------------------------------------------------------------------
# diagnostics: evaluate the model with test data set
# ---------------------------------------------------------------------------

# check the importance of the variables
library(caret)
varImp(logit_model)

prediction_test <- predict(logit_model, new_data=test, type ="response")
table(test$default, prediction_test > 0.5)





