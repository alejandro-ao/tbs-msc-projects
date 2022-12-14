# Packages
#install.packages("ggplot2")
library(ggplot2)

#install.packages("dplyr")
library(dplyr)

#install.packages("tidytext")
library(tidytext)

#install.packages(c('ROAuth','RCurl'))
library(ROAuth)
library(RCurl)

#install.packages("rtweet")
library(rtweet)


## Authentification

# whatever name you assigned to your created app
appname <- "Serge_firstApp"

## api key 
key <- "080X2ef1ZQ97dVFkLuoqodnZW"

## api secret (example below is not a real key)
secret <- "OZgfcXDAj6lCnSx7CwHykm7ISZdu0T4pjkEeOAkYwBaxzEAzuR"


twitter_token <- create_token(app = appname,consumer_key = key, consumer_secret = secret, access_token = "1075704418346123267-LQIMGKenrF6IsfdK07mTaapAX8QFfP", access_secret = "TmyXYyWW3nOqsDM4NsCreaHjqhONSuX0LvUn2hWxSKwPs")


## Data collection (300 tweets)
Macrondata <- search_tweets("Macron OR MACRON OR EMMANUEL MACRON OR Emmanuel Macron OR French President OR Pr?sident Fran?ais", n=300)

class(Macrondata)

head(Macrondata, n = 2)


## Time series of tweets counts

library("ggplot2")


ts_plot(Macrondata, "hours")+
  ggplot2::theme_minimal()+
  ggplot2::theme(plot.title=ggplot2::element_text(face="bold"))+
  ggplot2::labs(x=NULL,y=NULL,
                title="Frequency of Macron Twitter statuses",
                subtitle="Twitter status counts 1-hour intervals",
                caption="\nSource: Data collected from Twitter's API"
  )



##  Install the text mining package 

#install.packages("tm", dependencies=TRUE)*

#install.packages("stringi")*
  
#install.packages("stringr")*
  
library("tm")
library("stringi")
library("stringr")


## Corpus creation and data cleaning

# Removing special characters in non latin language

usableText <- iconv(Macrondata$text, to = "ASCII", sub="")
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


# install.packages("wordcloud")
library("wordcloud")

text_corpus <- tm_map(Macrondata_corpus,
                      content_transformer(function(x)
                        iconv(x,to='ASCII',sub='byte')))

# The document-term matrix 
Macrondata.tdm <- TermDocumentMatrix(text_corpus)
m <- as.matrix(Macrondata.tdm)
m[1:2,1:5]


## Most frequent terms in our matrix

v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
head(d, 5)


## Word Frequency 

barplot(d[1:20,]$freq, las = 3, 
        names.arg = d[1:20,]$word,col ="lightblue", 
        main ="Most frequent words",
        ylab = "Word frequencies")


## Identify terms used at least 50 times

findFreqTerms(Macrondata.tdm, lowfreq=50)[1:10]


##  Wordcloud


wordcloud(words = d$word, freq = d$freq, min.freq = 40, 
          max.words=100, random.order=FALSE, 
          colors=brewer.pal(4,"Dark2"))


## Remove sparse terms from the term-document matrix

Macrondata.tdm<-removeSparseTerms(Macrondata.tdm, 
                                  sparse=0.95)


# Convert the term-document matrix to a data frame

Macrondata.df <- as.data.frame(as.matrix(Macrondata.tdm))


## scale the data since clustering is sensitive to the scale of the data used

Macrondata.df.scale <- scale(Macrondata.df)


# Create the distance matrix: each cell represents the distance between each pair of documents/tweets

Macrondata.dist <- dist(Macrondata.df.scale, 
                        method = "euclidean")


##  Cluster the data: tweets are grouped into classes

Macrondata.fit<-hclust(Macrondata.dist, method="ward.D2")


# Visualize the result

plot(Macrondata.fit, main="Cluster-Macron")


## Plotting clusters

groups <- cutree(Macrondata.fit, k=5)

plot(Macrondata.fit, main="Cluster-Macron")

rect.hclust(Macrondata.fit, k=5, border="red")


## Plotting clusters

groups <- cutree(Macrondata.fit, k=5)

plot(Macrondata.fit, main="Cluster-Macron")

rect.hclust(Macrondata.fit, k=5, border="red")


##  Define a tag extractor function

tags<-function(x) toupper(grep("#",strsplit(x,
                                            " +")[[1]],value=TRUE))
# Create a list of tag sets for each tweet

l <- nrow(Macrondata)
taglist <- vector(mode = "list", l)


# Create an empty vector to store the tweet texts

texts <- vector(mode = "character", length = l)


## Extract the tweet text from each tweet status

for (i in 1:l) texts[i] <- Macrondata$text[i]
texts <- iconv(texts, to = "ASCII", sub="")

# ... and populate it

j<-0
for(i in 1:l){
  if(is.na(str_match(texts[i],"#"))[1,1]==FALSE){
    j<-j+1
    taglist[[j]]<-str_squish(removePunctuation(tags(ifelse(is.na(str_match(texts[i],                                                               "[\n]")[1,1])==TRUE,texts[i],gsub("[\n]"," ",texts[i])))))
  }
}
alltags <- NULL
for (i in 1:l) alltags<-union(alltags,taglist[[i]])


## Create an empty graph

library(igraph)
hash.graph <- graph.empty(directed = T)

# Populate it with nodes
hash.graph <- hash.graph + vertices(alltags)


## Looking at Relationships Between Hashtags

# Populate it with edges

for (tags in taglist){
  if (length(tags)>1){
    for (pair in combn(length(tags),2,simplify=FALSE,
                       FUN=function(x) sort(tags[x]))){
      if (pair[1]!=pair[2]) {
        if (hash.graph[pair[1],pair[2]]==0) 
          hash.graph<-hash.graph+edge(pair[1],
                                      pair[2])
      }
    }
  }
}


## Looking at Relationships Between Hashtags

# Network construction

V(hash.graph)$color <- "black"
E(hash.graph)$color <- "black"
V(hash.graph)$name <- paste("#",V(hash.graph)$name,
                            sep = "")
V(hash.graph)$label.cex = 0.5
V(hash.graph)$size <- 15
V(hash.graph)$size2 <- 2
hash.graph_simple<-delete.vertices(simplify(hash.graph),
                                   degree(hash.graph)<=13)


## Looking at Relationships Between Hashtags

# Network construction

plot(hash.graph_simple, edge.width = 2, 
     edge.color = "black", vertex.color = "SkyBlue2",
     vertex.frame.color="black", label.color = "black",
     vertex.label.font=1, edge.arrow.size=0.05) 



##  Sentiment Analysis
# Packages

library("sentimentr")

plain.text<-vector()

for(i in 1:dim(Macrondata)[1]){
  plain.text[i]<-Macrondata_corpus[[i]][[1]]
}

sentence_sentiment<-sentiment(get_sentences(plain.text))

sentence_sentiment


## Sentiment Analysis 

average_sentiment<-mean(sentence_sentiment$sentiment)
average_sentiment
sd_sentiment<-sd(sentence_sentiment$sentiment)
sd_sentiment


## Sentiment terms 

extract_sentiment_terms(get_sentences(plain.text))



## Topic Modeling: LDA

# Used to explore through large bodies of captured text
# to detect dominant themes or topics;

# Packages to be installed and loaded
#install.packages(topicmodels)
library(tidytext)
library(topicmodels)
library(tidyverse)
library(rvest)
library(reshape2)


## Topic Modeling

text_corpus2<-text_corpus[1:200]
doc.lengths<-rowSums(as.matrix(DocumentTermMatrix(text_corpus2)))
dtm <- DocumentTermMatrix(text_corpus2[doc.lengths > 0])

# Pick a random seed for replication
SEED = sample(1:1000000, 1)  
# Let's start with 2 topics
k = 2  
Topics_results<-LDA(dtm, k = k, control = list(seed = SEED))


## Topic Modeling

terms(Topics_results,15)


## Topic Modeling

topics(Topics_results)


## Topic Modeling
tidy_model_beta<-tidy(Topics_results, matrix = "beta")

tidy_model_beta %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta) %>%
  ggplot(aes(reorder(term, beta),beta,fill=factor(topic)))+
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_fill_viridis_d() + 
  coord_flip() + 
  labs(x = "Topic", 
       y = "beta score", 
       title = "Topic modeling")

## Topic Modeling

tidy_model_beta<-tidy(Topics_results, matrix = "beta")

tidy_model_beta %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta) %>%
  ggplot(aes(reorder(term, beta),beta,fill=factor(topic)))+
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_fill_viridis_d() + 
  coord_flip() + 
  labs(x = "Topic", 
       y = "beta score", 
       title = "Topic modeling")

