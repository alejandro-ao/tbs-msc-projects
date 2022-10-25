data <- read.csv("./data/university1.csv", sep = ";")
View(data)

# check data head and structure
head(data, 4)
str(data)
View (data)

# ------------------------------------------------------------
# check for outliers
# ------------------------------------------------------------

## qualitative variables
table(data$Higher.degree) # count per category
prop.table(table(data$Higher.degree))

barplot(table(data$Higher.degree), horiz=F, las=2, 
        cex.names=0.8, main="Higher education")

barplot(table(data$Type), horiz=F, las=2, 
        cex.names=0.8, main="Type")

# group together cats w low frequency
data$Higher.degree.rec[data$Higher.degree=="Bachelor's degree"] <- "Bacherlor's degree"

View(data)


## quantitative variables
hist(data$Total.applicants, main="Total applicants")
hist(data$Total.eligibles, main="Total eligibles")
hist(data$Total.qualified, main="Total qualified")
hist(data$Total.students, main="Total students")
hist(data$Tuition.fees, main="Tuition fees")

# observe extreme values for all quantitative
# this one is to delete, for example
boxplot(data$Total.applicants, main="Total students")
boxplot(data$Total.eligibles, main="Total eligibles")
boxplot(data$Total.qualified, main="Total qualified")
boxplot(data$Total.students, main="Total students")
boxplot(data$Tuition.fees, main="Total fees")

# without outliers
data.wo <- data[data$Total.students < 400000 & data$Tuition.fees < 150000, ]
View(data.wo)
boxplot(data.wo$Total.applicants, main="Total students")
boxplot(data.wo$Total.eligibles, main="Total eligibles")
boxplot(data.wo$Total.qualified, main="Total qualified")
boxplot(data.wo$Total.students, main="Total students")
boxplot(data.wo$Tuition.fees, main="Total fees")


# transform variables
data.wo$log.Total.applicants=log(data.wo$Total.applicants)
data.wo$log.Total.eligibles=log(data.wo$Total.eligibles)
data.wo$log.Total.qualified=log(data.wo$Total.qualified)
data.wo$log.Total.students=log(data.wo$Total.students)
data.wo$log.Tuition.fees=log(data.wo$Tuition.fees)

View(data.wo)

# transform variables
hist(data.wo$log.Total.applicants, main="Log Total Applicants")
hist(data.wo$log.Total.eligibles, main="Log Total Eligibles")
hist(data.wo$log.Total.qualified, main="Log Total Qualified")
hist(data.wo$log.Tuition.fees, main="Log Tuition Fees")















