
#######################################################
###                 Classification                #####
#######################################################



# Define a project called "Classification" and store it in a file called "Modelling Techniques"

# Download and store the dataset "bank_full" and the script "Classification_Script" into the file "Modelling Techniques"


# Import the dataset

Bank_data<-read.csv2("bank_full.csv")
summary(Bank_data)


# Packages

install.packages("rpart")
install.packages("rpart.plot")

library("rpart") 
library("rpart.plot")


# The rpart function is used to construct a decision tree

decision_tree <- rpart(y ~ job+marital+education+default+housing+loan+contact+poutcome+duration, method="class", data=Bank_data, control=rpart.control(minsplit=1), parms=list(split="information"))

summary(decision_tree)

rpart.plot(decision_tree, type=2, extra=1)


# Prediction of a new customer
  
# The following features are observed for a new customer: age=35; job='entrepreneur'; marital='married'; education ='secondary'; default= 'no'; housing='yes'; loan='yes'; contact='cellular'; month='jan'; duration=523; campaign=2; pdays=26; previous=120; poutcome='failure'; day_of_week=17.

# We want to predict if this new client will subscribe a term deposit.

new_customer<-data.frame(age=35, job="entrepreneur", marital="married", education ="secondary", default= "no", housing="yes", loan="yes", contact="cellular", month="jan", duration=523, campaign=2, pdays=26, previous=120, poutcome="failure", day_of_week=17)

new_customer

predict(decision_tree,newdata=new_customer,type="class")



# Naïve Bayes algorithm: It is a classification technique based on Bayes' Theorem.

# Naïve Bayes with R: Same example than previously

install.packages("e1071")

library("e1071") 


# Define the data frames for the Naïve Bayes classifier

# Discretizing the "duration" variable

Bank_data$duration2<-ifelse(Bank_data$duration<411,"<411",">411")

training_data <- as.data.frame(Bank_data[1:dim(Bank_data)[1]-1,]) 

test_data <- as.data.frame(Bank_data[dim(Bank_data)[1],])

test_data


# The package "e1071" in R has a built-in naiveBayes function

model <- naiveBayes(y ~ job + marital + education + default + housing + loan + contact + poutcome + duration2, training_data)

model



# Predict with test_data

results <- predict(model,test_data)
results

