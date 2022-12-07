base_url <- "https://www.consumeraffairs.com/computers/apple_imac.html"

for (i in 1:5) {
  download.file(url=paste(base_url, "?/page=",i, sep=""),
                destfile = paste("./imac_", i ,".html", sep=""))
}

# https://www.consumeraffairs.com/computers/apple_imac.html?page=2

#######################################################
###                 Text Analysis                   ###
#######################################################
# Define a project called "Text Analysis" and store it in a file called "Modelling Techniques"
# Download the script "Text Analysis_Script" into the file "Modelling Techniques"
# Packages

install.packages("XML")
install.packages("RCurl")
install.packages("httr")


library(XML)
library(RCurl)
library(httr)

# Download the html document 

html <- GET("https://www.consumeraffairs.com/computers/apple_imac.html", followlocation = TRUE)

# Parse html (Read the html document into an R object) 

doc = htmlParse(html, asText=TRUE)

# Extract only the text with the following structure <font color=red> "<p>  Text text text </p>" 
# The output is a vector of texts

plain.text <- xpathSApply(doc, "//p", xmlValue)

# xmlValue() extraction function

# Comments are stored into a vector 

plain.text<-as.vector(plain.text)[7:83]
plain.text
