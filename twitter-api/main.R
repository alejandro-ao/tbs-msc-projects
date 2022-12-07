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
default_cached_auth()
Macrondata<-searchTwitter("Macron OR MACRON OR EMMANUEL MACRON OR Emmanuel Macron OR French President", n=100)
View(Macrondata)
class(Macrondata)

macron.df <- do.call(rbind, lapply(Macrondata, as.data.frame))
View(macron.df)

