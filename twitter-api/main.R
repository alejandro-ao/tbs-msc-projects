install.packages("twitteR")
install.packages("rtweet")
install.packages("tidytext")
install.packages("dplyr")
install.packages("maps")
install.packages("ggmap")
install.packages("ROAuth")

library(ROAuth)
library(twitteR)
library(rtweet)
library(tidytext)
library(maps)
library(ggmap)



my.key<-"080X2ef1ZQ97dVFkLuoqodnZW"
my.secret<-"OZgfcXDAj6lCnSx7CwHykm7ISZdu0T4pjkEeOAkYwBaxzEAzuR"
acces_token<-"1075704418346123267-LQIMGKenrF6IsfdK07mTaapAX8QFfP"
access_secret<-"TmyXYyWW3nOqsDM4NsCreaHjqhONSuX0LvUn2hWxSKwPs"

setup_twitter_oauth(my.key, my.secret, acces_token, access_secret)

Macrondata<-searchTwitter("Macron OR MACRON OR EMMANUEL MACRON OR Emmanuel Macron OR French President", n=100)
View(Macrondata)
class(Macrondata)

macron.df <- do.call(rbind, lapply(Macrondata, as.data.frame))
View(macron.df)

# --------------------------------------------------------------------

ts_plot(macron.df, "hours")+
  ggplot2::theme_minimal()+
  ggplot2::theme(plot.title=ggplot2::element_text(face="bold"))+
  ggplot2::labs(x=NULL,y=NULL,
                title="Frequency of Macron Twitter statuses",
                subtitle="Twitter status counts 1-hour intervals",
                caption="\nSource: Data collected from Twitter's API"
  )


install.packages("tm")
install.packages("stringi")
install.packages("stringr")
library("tm")
library("stringi")
library("stringr")

usableText <- iconv(macron.df$text, to = "ASCII", sub="")
Macrondata_corpus<-Corpus(VectorSource(usableText))
Macrondata_corpus<-tm_map(Macrondata_corpus,tolower)
Macrondata_corpus<-tm_map(Macrondata_corpus,removePunctuation)
Macrondata_corpus<-tm_map(Macrondata_corpus,removeNumbers)
Macrondata_corpus<-tm_map(Macrondata_corpus,function(x)removeWords(x,stopwords()))

## Corpus creation and data cleaning
Macrondata_corpus<-tm_map(Macrondata_corpus,
                          function(x)removeWords(x,
                                                 stopwords("french")))

Macrondata_corpus<-tm_map(Macrondata_corpus,
                          function(x)removeWords(x,
                                                 stopwords("italian")))

Macrondata_corpus<-tm_map(Macrondata_corpus,
                          function(x)removeWords(x,
                                                 stopwords("spanish")))

install.packages("wordcloud")
library("RColorBrewer")
library("wordcloud")

text_corpus <- tm_map(Macrondata_corpus,
                      content_transformer(function(x)
                        iconv(x,to='ASCII',sub='byte')))



