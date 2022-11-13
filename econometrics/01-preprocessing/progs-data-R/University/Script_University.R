################################################
#### Step 1 : import and clean data

# ------------------------------------------------------------------------------
# IMPORT AND SETUP

#import data
# data are in csv format
data <- read.csv2("./../01-preprocessing/progs-data-R/University/University1.csv", stringsAsFactors = TRUE)

# verify data import

head(data,4)
tail(data,4)
View (data)


# verify data structure 
str(data)


# recode Name in text
data$Name = as.character(data$Name)
class(data$Name) #check the recoding



## verify data outliers

# ------------------------------------------------------------------------------
# QUALITATIVE VARIABLES

# ----------------------------------
# Barplot of variables
table(data$Higher.degree)
prop.table(table(data$Higher.degree))

# http://rfunction.com/archives/1302
# https://statisticsglobe.com/display-all-x-axis-labels-of-barplot-in-r

barplot(table(data$Higher.degree),horiz = F,las=2, cex.names=0.6,col="blue",main="Higher degree",ylab="Frequency", plot=TRUE)
barplot(table(data$Type),horiz = F,cex.names=0.8,col="blue",main="Higher degree",ylab="Frequency", plot=TRUE)

# las options: always parallel to the axis (the default, 0), 
# always horizontal (1), 
# always perpendicular to the axis (2), 
# and always vertical (3).


# ----------------------------------
# Merging variables
# group together categories with low frequency -> all doctors together
str(data)

data$Higher.degree.rec[data$Higher.degree=="Bachelor's degree"] <- "Bachelor's degree"
data$Higher.degree.rec[data$Higher.degree=="Doctor's degree practice"] <- "Doctor's degree"
data$Higher.degree.rec[data$Higher.degree=="Doctor's degree other"] <- "Doctor's degree"
data$Higher.degree.rec[data$Higher.degree=="Doctor's degree research"] <- "Doctor's degree"
data$Higher.degree.rec[data$Higher.degree=="Doctor's degree research and practice"] <- "Doctor's degree"
data$Higher.degree.rec[data$Higher.degree=="Master's degree"] <- "Master's degree"

class(data$Higher.degree.rec)
# affect the right type

data$Higher.degree.rec <- as.factor(data$Higher.degree.rec)
barplot(table(data$Higher.degree.rec), col="blue") # now they are grouped

class(data$Higher.degree.rec)

# order the categories so doctors after masters
data$Higher.degree.rec <- factor(data$Higher.degree.rec, order = T, levels =c("Bachelor's degree", "Master's degree", "Doctor's degree"))
# now the categories are ordered:
table(data$Higher.degree.rec)
barplot(table(data$Higher.degree.rec), col="aquamarine")




# ------------------------------------------------------------------------------
# QUANTITATIVE VARIABLES

# ----------------------------------
# Histograms
# they seem to form a logarithmic distribution 
# (students has destructive outliers)
par(mfrow = c(2,2))
hist(data$Total.applicants, col="aquamarine",main="Total applicants")
hist(data$Total.eligibles, col="aquamarine",main="Total eligibles")
hist(data$Total.qualified, col="aquamarine",main="Total qualified")
hist(data$Total.students, col="aquamarine",main="Total students")
hist(data$Tuition.fees, col="aquamarine",main="Tuition fees")

par(mfrow = c(1,1))

# ----------------------------------
# Boxplot
# the outliers are even more evident when seeing the boxplot
par(mfrow = c(2,2))
boxplot(data$Total.applicants, col="aquamarine",main="Total applicants")
boxplot(data$Total.eligibles, col="aquamarine",main="Total eligibles")
boxplot(data$Total.qualified, col="aquamarine",main="Total qualified")
boxplot(data$Total.students, col="aquamarine",main="Total.students")
boxplot(data$Tuition.fees, col="aquamarine",main="Tuition.fees")
par(mfrow=c(1,1))

# ----------------------------------
# Manage outliers
# delete observations where Total students > 400000 or Total Tuition.fees >150000
data.wo <- data[data$Total.students < 400000  & data$Tuition.fees <150000,]

boxplot(data.wo$Total.students, col="aquamarine",main="Total.students")
boxplot(data.wo$Tuition.fees, col="aquamarine",main="Tuition.fees")

# ----------------------------------
# Transform variables
# Use log to convert them to normal distribution, since they follow 
# a logarithmic distribution
# https://medium.com/@kyawsawhtoon/log-transformation-purpose-and-interpretation-9444b4b049c9
data.wo$log.Total.applicants=log(data.wo$Total.applicants)
data.wo$log.Total.eligibles=log(data.wo$Total.eligibles)
data.wo$log.Total.qualified=log(data.wo$Total.qualified)
data.wo$log.Total.students=log(data.wo$Total.students)
data.wo$log.Tuition.fees=log(data.wo$Tuition.fees)

summary(data.wo)

# ----------------------------------
# Now the variables are more normal -> hist
hist(data.wo$log.Total.applicants, col="blue",main="log Total applicants") # normal
hist(data.wo$log.Total.eligibles, col="blue",main="log Total eligibles") # normal
hist(data.wo$log.Total.qualified, col="blue",main="log Total qualified") # normal-ish
hist(data.wo$log.Total.students, col="blue",main="log Total.students") # skewed
hist(data.wo$log.Tuition.fees, col="blue",main="log Tuition.fees") # not normal

# -> boxplots
boxplot(data.wo$log.Total.applicants, col="blue",main="Log Total applicants")
boxplot(data.wo$log.Total.eligibles, col="blue",main="Log Total eligibles")
boxplot(data.wo$log.Total.qualified, col="blue",main="Log Total qualified")
boxplot(data.wo$log.Total.students, col="blue",main="Log Total.students")
boxplot(data.wo$log.Tuition.fees, col="blue",main="Log Tuition.fees")

# ----------------------------------
# Missing values
summary(data.wo)
sum(is.na(data.wo))

dim(data.wo)

library(mice)
# plot the missing data
md.pattern(data.wo, rotate.names=TRUE) # Only 10 rows affected by missing values


# create a database without missing values
data.wo.complete <- na.omit(data.wo)
summary(data.wo.complete)
dim(data.wo.complete)

# ------------------------------------------------------------------------------
# Normality study - Graphical tests

# ----------------------------------
# Skewness and the kurtosis
install.packages("moments")
library(moments)

# when the variable is normally distributed
# Skewness is close to 0
# Kurtosis is close to 3

# ------------------
# Total applicants
# data without transformation (not normal, logarithmic):
hist(data.wo.complete$Total.applicants, col="aquamarine2")
skewness(data.wo.complete$Total.applicants)
kurtosis(data.wo.complete$Total.applicants)
# data with transformation (normal):
hist(data.wo.complete$log.Total.applicants, col="aquamarine2")
skewness(data.wo.complete$log.Total.applicants) # 0.06906843
kurtosis(data.wo.complete$log.Total.applicants) # 2.679279
# ------------------
# Tuition fees
# data without transformation (not normal, not logarithmic)
hist(data.wo.complete$Tuition.fees, col="aquamarine2")
skewness(data.wo.complete$Tuition.fees) 
kurtosis(data.wo.complete$Tuition.fees) 
# data with transformation (NOT normal, NOT logarithmic)
hist(data.wo.complete$log.Tuition.fees, col="aquamarine2")
skewness(data.wo.complete$log.Tuition.fees) # -0.3642279
kurtosis(data.wo.complete$log.Tuition.fee)  # 1.716641

# ----------------------------------
# QQ Plot
# when the variable is normally distributed
# points are aligned on the first bisector

# ------------------
# Total applicants

# without transformation
qqnorm(data.wo.complete$Total.applicants,main="Normality study Total Applicants")
qqline(data.wo.complete$Total.applicants)
# with transformation
qqnorm(data.wo.complete$log.Total.applicants,main="Normality study log Total Applicants")
qqline(data.wo.complete$log.Total.applicants)

# ------------------
# Tuition fees

# without transformation
qqnorm(data.wo.complete$Tuition.fees,main="Normality study Tuition fees")
qqline(data.wo.complete$Tuition.fees)
# with transformation -> still NOT normal
qqnorm(data.wo.complete$log.Tuition.fees,main="Normality study log Tuition.fees")
qqline(data.wo.complete$log.Tuition.fees)

# ------------------------------------------------------------------------------
# Normality study - Analytical tests

# pvalue: probability to do wrong by rejecting Ho
# if P-value < 5%, then we reject Ho
# If pvalue > 5%, we accept Ho

# ----------------------------------
# Shapiro test
# Even log is not normally distributed???
# H0 : normality agains H1 : non normality
shapiro.test(data.wo.complete$Total.applicants) # p-value < 2.2e-16
shapiro.test(data.wo.complete$log.Total.applicants) # p-value = 0.002941


# ----------------------------------
# Jarque Bera test (based on Skewness and Kurtosis)
# H0 : normality agains H1 : non normality
install.packages("tseries")
library(tseries)


jarque.bera.test(data.wo.complete$Total.applicants)
jarque.bera.test(data.wo.complete$log.Total.applicants)

# ----------------------------------
# create the variable Acceptance.rate
str(data)

data.wo.complete$Acceptance.rate <- data.wo.complete$Total.qualified/data.wo.complete$Total.applicants
class(data.wo.complete$Acceptance.rate)

hist(data.wo.complete$Acceptance.rate, col="aquamarine2") # a bit skewed
boxplot(data.wo.complete$Acceptance.rate)

jarque.bera.test(data.wo.complete$Acceptance.rate)


################################################
#### STEP 2: TESTS

# ------------------------------------------------------------------------------
# Are there relatively more private universities awarding doctorates? 


tab <- table(data.wo.complete$Type,data.wo.complete$Higher.degree.rec)
tab

#raw percentages
prop.table(tab,1)
#column percentages
prop.table(tab,2)



#Graphic
mosaicplot(tab,color=hcl(c(360,240,120)),las=1, xlab="Highest degree", ylab="Type",cex=0.5)


# ----------------------------------
#Chi squared test
# 2 Categorical variables, so chi-squared to test for significance
# study the relationship between two qualitative or categorical variables
# H0 : the two variables are independent against H1 : the two variables are linked

# p-value < 5% by a lot!! so we reject Ho: there is a significant
# difference between private and public universities
chisq.test(tab)



# you can also use the function CrossTable from the package "gmodels"
install.packages("gmodels")
library(gmodels)
CrossTable(data.wo.complete$Type,data.wo.complete$Higher.degree.rec,prop.r=T,prop.c=T,prop.t=F, prop.chisq=F, chisq=T)



# ------------------------------------------------------------------------------
# Can we conclude that private universities have higher tuition fees ? 
# (statistics, graph and test)

# Statistics
tapply(data.wo.complete$Tuition.fees, data.wo.complete$Type, summary)

#Graph
boxplot(data.wo.complete$Tuition.fees~data.wo.complete$Type,
        col = "aquamarine2", border = "grey", las=2,
        main = "Tuition fees",
        xlab="",
        ylab = "Type")

# Test
# Crossing of a continuous (quantitative) and categorical variable (qualitatives) with 2 categories
# Two means comparison Student t(test

# the statistic of test is quite different according to the fact that variances are comparable or not

# Two variances comparison test
# H0 : Var1 = Var2 against H1 : Var1 # Var2
var.test(data.wo.complete$Tuition.fees~data.wo.complete$Type)

# Student t-test
# H0 : m1 = m2 against H1 : m1 # m2
hist(data.wo.complete$Tuition.fees)
t.test (data.wo.complete$Tuition.fees~data.wo.complete$Type, var.equal=FALSE)


# Non parametric version of the test
# useful is the continuous variable is not normally distributed

#Wilcoxon test
# This test no longer relates to the values, but to the ranks of the observations.
# The observations are listed in ascending order and numbered. 
# The rank is the sequence number of the classified observation.
# This is a test of comparison of medians.
# H0 M1=M1 agains H1 : M1#M2
wilcox.test(data.wo.complete$Tuition.fees~data.wo.complete$Type)                 


#9. Can we conclude that tuition fees increase with the level of the highest degree offered? (table/test and graph)

# Statistics

tapply(data.wo.complete$Tuition.fees, data.wo.complete$Higher.degree.rec, summary)

#Graph

boxplot(data.wo.complete$Tuition.fees~data.wo.complete$Higher.degree.rec,
        col = "aquamarine2", border = "black",
        main = "Tuition fees",las=2,xlab=" ",
        ylab = "Higher degree")

hist(data.wo.complete$log.Tuition.fees)

# Test
# Crossing of a continuous (quantitative) and categorical variable (qualitatives) with k categories
# k means comparison anova test

# check if variance are comparable

#H0 : Var1=Var2= ...varK
#H1 : at least two variances are different
bartlett.test(data.wo.complete$Tuition.fees~data.wo.complete$Higher.degree.rec)

# check normally in  k sub samples

data.B <- data.wo.complete[data.wo.complete$Higher.degree.rec=="Bachelor's degree",]
data.M <- data.wo.complete[data.wo.complete$Higher.degree.rec=="Master's degree",]
data.D <- data.wo.complete[data.wo.complete$Higher.degree.rec=="Doctor's degree",]


par(mfrow = c(1,3))

qqnorm(data.B$Tuition.fees,main="Normality study Bachelor's sample")
qqline(data.B$Tuition.fees)

qqnorm(data.M$Tuition.fees,main="Normality study Master's sample")
qqline(data.M$Tuition.fees)

qqnorm(data.D$Tuition.fees,main="Normality study Doctor's sample")
qqline(data.D$Tuition.fees)

# if variances comparable and normallity ==> Anova test otherwize ==> Kruskall Wallis Test


# Anova test
test.aov<-lm(data.wo.complete$Tuition.fees~data.wo.complete$Higher.degree.rec)
anova(test.aov)

# to go further and compare the means two by two : Tuckey test

TukeyHSD(aov(test.aov))
      
# Kruskall Wallis test (same idea as Wilcoxon test)
# H0 : M1=M2= ...MK against H1:  at least two Mk are different


test.kw <- kruskal.test(data.wo.complete$Tuition.fees~data.wo.complete$Higher.degree.rec)

# to go further and compare medians two by two : pairwise Wilcoxon test

test.pw <- pairwise.wilcox.test(data.wo.complete$Tuition.fees,data.wo.complete$Higher.degree.rec, p.adjust.method = "BH")
        

# 10.	Can we conclude that tuition fees decrease with the total number of students? (table/test and graph)


# Statistics

cor(data.wo.complete$Tuition.fees, data.wo.complete$Total.students)

#Graph

par(mfrow = c(1,1))
plot(data.wo.complete$Total.students,data.wo.complete$Tuition.fees,
        ylab = "Tuition fees",
        xlab = "Total students")
str(data.wo.complete)


# 11.	Can we conclude that tuition fees increase with the acceptance rate? (table/test and graph)


# Statistics

cor(data.wo.complete$Tuition.fees, data.wo.complete$Acceptance.rate)

#Graph

par(mfrow = c(1,1))
plot(data.wo.complete$Acceptance.rate,data.wo.complete$Tuition.fees,
     ylab = "Tuition fees",
     xlab = "Acceptance rate")



# Test
# Crossing 2 continuous (quantitative) variables
# correlation matrix and pvalue of correlation tests
#H0 : cor=0 against H1 : corr#0


install.packages("Hmisc")
library(Hmisc)
rcorr(as.matrix(data.wo.complete[,c(4:8,15)]))


