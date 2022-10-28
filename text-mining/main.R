# ---------------------------------------------------------------------------
# setup
# ---------------------------------------------------------------------------

# install.packages("stringr")
# install.packages("stringi")

library(stringi)
library(stringr)

## usefull functions
# substring
?substr

# ---------------------------------------------------------------------------
# web scarpping
# ---------------------------------------------------------------------------
library(XML)
library(httr)
library(RCurl)

# get request html 
html <- GET("https://www.consumeraffairs.com/computers/apple_imac.html",
            followlocation = TRUE)

# doc html parse
doc = htmlParse(html, asText=TRUE)

# get only text in p tag
plain.text <- xpathSApply(doc, "//p", xmlValue)
plain.text[5]

# use a for loop to get all the pages

# find the last comment
tail(plain.text, 15)
plain.text[29]

# only the comments
plain.text<-as.vector(plain.text)[5:29]
plain.text

