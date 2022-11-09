################################################
####Step 1 : import and clean data #############
################################################


#import data
# data are in csv format


data <- read.csv2("University1.csv", stringsAsFactors = TRUE)

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

# qualitative variables

table(data$Higher.degree)
prop.table(table(data$Higher.degree))

# http://rfunction.com/archives/1302
# https://statisticsglobe.com/display-all-x-axis-labels-of-barplot-in-r

barplot(table(data$Higher.degree),horiz = F,las=2, cex.names=0.6,col="blue",main="Higher degree",ylab="Frequency", plot=TRUE)
barplot(table(data$Higher.degree),horiz = F, cex.names=0.6,col="blue",main="Higher degree",ylab="Frequency")

barplot(table(data$Higher.degree),horiz = TRUE,las=2,cex.names=0.5,col="blue",main="Higher degree",ylab="Frequency", plot=TRUE)
barplot(table(data$Type),horiz = TRUE,cex.names=0.8,col="blue",main="Higher degree",ylab="Frequency", plot=TRUE)


# las options: always parallel to the axis (the default, 0), 
# always horizontal (1), 
# always perpendicular to the axis (2), 
# and always vertical (3).

# group together categories with low frequency
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
class(data$Higher.degree.rec)

# order the categories
data$Higher.degree.rec <- factor(data$Higher.degree.rec, order = T, levels =c("Bachelor's degree", "Master's degree", "Doctor's degree"))

table(data$Higher.degree.rec)






# quantitatives variables

# Histograms

par(mfrow = c(2,2))
hist(data$Total.applicants, col="blue",main="Total applicants")
hist(data$Total.eligibles, col="blue",main="Total eligibles")
hist(data$Total.qualified, col="blue",main="Total qualified")
hist(data$Total.students, col="blue",main="Total students")
hist(data$Tuition.fees, col="blue",main="Tuition fees")

par(mfrow = c(1,1))

# We observe extreme values for all quantitative variables
# In particular, for Total.students and Tuition.fees, there seems
# to be one outlier very far from the other values

# Boxplot


par(mfrow = c(2,2))
boxplot(data$Total.applicants, col="blue",main="Total applicants")
boxplot(data$Total.eligibles, col="blue",main="Total eligibles")
boxplot(data$Total.qualified, col="blue",main="Total qualified")
boxplot(data$Total.students, col="blue",main="Total.students")
boxplot(data$Tuition.fees, col="blue",main="Tuition.fees")
par(mfrow=c(1,1))

# manage outliers
# delete observations where Total students > 400000 or Total Tuition.fees >150000


data.wo <- data[data$Total.students < 400000  & data$Tuition.fees <150000,]
boxplot(data.wo$Total.students, col="blue",main="Total.students")
boxplot(data.wo$Tuition.fees, col="blue",main="Tuition.fees")



# transform variables

data.wo$log.Total.applicants=log(data.wo$Total.applicants)
data.wo$log.Total.eligibles=log(data.wo$Total.eligibles)
data.wo$log.Total.qualified=log(data.wo$Total.qualified)
data.wo$log.Total.students=log(data.wo$Total.students)
data.wo$log.Tuition.fees=log(data.wo$Tuition.fees)

summary(data)

hist(data.wo$log.Total.applicants, col="blue",main="log Total applicants")
hist(data.wo$log.Total.eligibles, col="blue",main="log Total eligibles")
hist(data.wo$log.Total.qualified, col="blue",main="log Total qualified")
hist(data.wo$log.Total.students, col="blue",main="log Total.students")
hist(data.wo$log.Tuition.fees, col="blue",main="log Tuition.fees")


boxplot(data.wo$log.Total.applicants, col="blue",main="Log Total applicants")
boxplot(data.wo$log.Total.eligibles, col="blue",main="Log Total eligibles")
boxplot(data.wo$log.Total.qualified, col="blue",main="Log Total qualified")
boxplot(data.wo$log.Total.students, col="blue",main="Log Total.students")
boxplot(data.wo$log.Tuition.fees, col="blue",main="Log Tuition.fees")


# verify missing values
summary(data.wo)

sum(is.na(data.wo))

dim(data.wo)


library(mice)
md.pattern(data.wo, rotate.names=TRUE)
# Only 10 rows affected by missing values



# create a database without missing values
data.wo.complete <- na.omit(data.wo)
summary(data.wo.complete)
dim(data.wo.complete)


# Normality study


# study the skewness and the kurtosis
install.packages("moments")
library(moments)

# when the variable is normally distributed
# Skewness is close to 0
# Kurtosis is close to 3

skewness(data.wo.complete$Total.applicants)
kurtosis(data.wo.complete$Total.applicants)

skewness(data.wo.complete$log.Total.applicants)
kurtosis(data.wo.complete$log.Total.applicants)

skewness(data.wo.complete$Tuition.fees)
kurtosis(data.wo.complete$Tuition.fees)

skewness(data.wo.complete$log.Tuition.fees)
kurtosis(data.wo.complete$log.Tuition.fee)


# QQ Plot
# when the variable is normally distributed
# points are aligned on the first bisector

qqnorm(data.wo.complete$Total.applicants,main="Normality study Total Applicants")
qqline(data.wo.complete$Total.applicants)
qqnorm(data.wo.complete$log.Total.applicants,main="Normality study log Total Applicants")
qqline(data.wo.complete$log.Total.applicants)

qqnorm(data.wo.complete$Tuition.fees,main="Normality study Tuition fees")
qqline(data.wo.complete$Tuition.fees)
qqnorm(data.wo.complete$log.Tuition.fees,main="Normality study log Tuition.fees")
qqline(data.wo.complete$log.Tuition.fees)

# Normality tests 
# pvalue: probability to do wrong by rejecting Ho
# if P-value < 5%, then we reject Ho
# If pvalue > 5%, we accept Ho


# Shapiro test
# H0 : normality agains H1 : non normality
shapiro.test(data.wo.complete$Total.applicants)
shapiro.test(data.wo.complete$log.Total.applicants)


# Jarque Bera test (based on Skewness and Kurtosis)
# H0 : normality agains H1 : non normality
install.packages("tseries")
library(tseries)


jarque.bera.test(data.wo.complete$Total.applicants)
jarque.bera.test(data.wo.complete$log.Total.applicants)


# create the variable Acceptance.rate
str(data)

data.wo.complete$Acceptance.rate <- data.wo.complete$Total.qualified/data.wo.complete$Total.applicants
class(data.wo.complete$Acceptance.rate)

boxplot(data.wo.complete$Acceptance.rate)

jarque.bera.test(data.wo.complete$Acceptance.rate)


################################################
####Step 2 : Answer questions      #############
################################################

# 7.	Are there relatively more private universities awarding doctorates? 

tab <- table(data.wo.complete$Type,data.wo.complete$Higher.degree.rec)
tab

#raw percentages
prop.table(tab,1)
#column percentages
prop.table(tab,2)

#Graphic
mosaicplot(tab,color=hcl(c(360,240,120)),las=1, xlab="Highest degree", ylab="Type",cex=0.5)



#Chi squared test
#study the relationship between two qualitative or categorical variables
# H0 : the two variables are independent agains H1 : the two variabls are linked


chisq.test(tab)
# pvalue <<< 5% so we reject Ho: there is a significant 
# difference between private and public universities


# you can also use the fonction CrossTable from the package "gmodels"
install.packages("gmodels")
library(gmodels)
CrossTable(data.wo.complete$Type,data.wo.complete$Higher.degree.rec,prop.r=T,prop.c=T,prop.t=F, prop.chisq=F, chisq=T)




# 8. Can we conclude that private universities have higher tuition fees ? (statistics, graph and test)

# Statistics

tapply(data.wo.complete$Tuition.fees, data.wo.complete$Type, summary)

#Graph

boxplot(data.wo.complete$Tuition.fees~data.wo.complete$Type,
        col = "blue", border = "black", las=2,
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
        col = "blue", border = "black",
        main = "Tuition fees",las=2,xlab=" ",
        ylab = "Higher degree")

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


