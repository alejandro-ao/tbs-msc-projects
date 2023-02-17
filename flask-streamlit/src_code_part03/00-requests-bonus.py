''' Streamlit AIBA-APDS application

Author: Samia Drappeau
Version: v1.0
'''
# Build-in Libraries
import datetime

# Third-party Libraries
import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import sqlalchemy as sa
import nltk
from nltk.corpus import stopwords
from nltk.tokenize import wordpunct_tokenize
from nltk.stem import WordNetLemmatizer
import re

# ================ Code change START HERE ===============
import requests
# ================ Code change END HERE ===============

# Custom Libraries

# Defining dictionary containing all emojis with their meanings.
emojis = {':)': 'smile', ':-)': 'smile', ';d': 'wink', ':-E': 'vampire', ':(': 'sad', 
          ':-(': 'sad', ':-<': 'sad', ':P': 'raspberry', ':O': 'surprised',
          ':-@': 'shocked', ':@': 'shocked',':-$': 'confused', ':\\': 'annoyed', 
          ':#': 'mute', ':X': 'mute', ':^)': 'smile', ':-&': 'confused', '$_$': 'greedy',
          '@@': 'eyeroll', ':-!': 'confused', ':-D': 'smile', ':-0': 'yell', 'O.o': 'confused',
          '<(-_-)>': 'robot', 'd[-_-]b': 'dj', ":'-)": 'sadsmile', ';)': 'wink', 
          ';-)': 'wink', 'O:-)': 'angel','O*-)': 'angel','(:-D': 'gossip', '=^.^=': 'cat'}

## Defining set containing all stopwords in english.
stopwordlist = ['a', 'about', 'above', 'after', 'again', 'ain', 'all', 'am', 'an',
             'and','any','are', 'as', 'at', 'be', 'because', 'been', 'before',
             'being', 'below', 'between','both', 'by', 'can', 'd', 'did', 'do',
             'does', 'doing', 'down', 'during', 'each','few', 'for', 'from', 
             'further', 'had', 'has', 'have', 'having', 'he', 'her', 'here',
             'hers', 'herself', 'him', 'himself', 'his', 'how', 'i', 'if', 'in',
             'into','is', 'it', 'its', 'itself', 'just', 'll', 'm', 'ma',
             'me', 'more', 'most','my', 'myself', 'now', 'o', 'of', 'on', 'once',
             'only', 'or', 'other', 'our', 'ours','ourselves', 'out', 'own', 're',
             's', 'same', 'she', "shes", 'should', "shouldve",'so', 'some', 'such',
             't', 'than', 'that', "thatll", 'the', 'their', 'theirs', 'them',
             'themselves', 'then', 'there', 'these', 'they', 'this', 'those', 
             'through', 'to', 'too','under', 'until', 'up', 've', 'very', 'was',
             'we', 'were', 'what', 'when', 'where','which','while', 'who', 'whom',
             'why', 'will', 'with', 'won', 'y', 'you', "youd","youll", "youre",
             "youve", 'your', 'yours', 'yourself', 'yourselves']

@st.cache
def preprocess(textdata):
    processedText = []
    
    # Create Lemmatizer and Stemmer.
    wordLemm = WordNetLemmatizer()
    
    # Defining regex patterns.
    urlPattern        = r"((http://)[^ ]*|(https://)[^ ]*|( www\.)[^ ]*)"
    userPattern       = '@[^\s]+'
    alphaPattern      = "[^a-zA-Z0-9]"
    sequencePattern   = r"(.)\1\1+"
    seqReplacePattern = r"\1\1"
    
    for tweet in textdata:
        tweet = tweet.lower()
        
        # Replace all URls with 'URL'
        tweet = re.sub(urlPattern,' URL',tweet)
        # Replace all emojis.
        for emoji in emojis.keys():
            tweet = tweet.replace(emoji, "EMOJI" + emojis[emoji])        
        # Replace @USERNAME to 'USER'.
        tweet = re.sub(userPattern,' USER', tweet)        
        # Replace all non alphabets.
        tweet = re.sub(alphaPattern, " ", tweet)
        # Replace 3 or more consecutive letters by 2 letter.
        tweet = re.sub(sequencePattern, seqReplacePattern, tweet)

        tweetwords = ''
        for word in tweet.split():
            # Checking if the word is a stopword.
            #if word not in stopwordlist:
            if len(word)>1:
                # Lemmatizing the word.
                word = wordLemm.lemmatize(word)
                tweetwords += (word+' ')
            
        processedText.append(tweetwords)
        
    return processedText


@st.cache
def load_data():
    """Load the data

    """
    engine = sa.create_engine("sqlite:///../../data/tweet-sentiment-withDay.db", echo=False)
    sa_connection = engine.connect()
    tweets = pd.read_sql("tweets", sa_connection)
    tweets['day_utc'] = pd.to_datetime(
        tweets['day_utc'], infer_datetime_format=True)
    return tweets


@st.cache
def get_users(data):
    """Extract list of users from data

    """
    return sorted(data['user'].unique().tolist())[:10]


@st.cache
def get_timeline(data):
    """Create a timeline of number of tweets per day

    """
    return data.groupby('day_utc').count()['target'].reset_index()


def create_plot(data, user):
    """Create a timeline representation of the data

    """
    fig, _ = plt.subplots()
    _ = sns.scatterplot(x='day_utc', y='target', data=data)
    plt.xlabel('day')
    plt.xticks(rotation=45)
    plt.xlim(data['day_utc'].min() - datetime.timedelta(days=1),
             data['day_utc'].max() + datetime.timedelta(days=1))
    plt.ylabel('number of tweets')
    plt.title(f"Timeline of number of tweets: {user}")
    st.pyplot(fig)


def show_data(data):
    """Main function of menu item 'Show Data'

    """
    # get user unique set
    users_list = ['All'] + get_users(data)
    selected_user = st.selectbox('Choose a user', users_list)

    if selected_user == 'All':
        st.write('You want to see all data')
        st.write(data.head())
        tweet_timeline = get_timeline(data)
    else:
        st.write(f'You selected {selected_user}')
        tweet_user = data[data['user'] == selected_user]
        st.write(tweet_user)
        tweet_timeline = get_timeline(tweet_user)
    create_plot(tweet_timeline, selected_user)

def sentiment_distribution(data):
    # Replacing the values to ease understanding.
    data['target'] = data['target'].replace(4,1)

    # Plotting the distribution for dataset
    fig, ax = plt.subplots()
    ax = data.groupby('target').count()['id'].plot(kind='bar', title='Distribution of data',
                                                legend=False)
    ax.set_xticklabels(['Negative','Positive'], rotation=0)
    st.pyplot(fig)


def most_common(text):
    list_of_words = [i.lower() for i in wordpunct_tokenize(text) if i.lower() not in stopwordlist and i.isalpha()]
    wordfreqdist = nltk.FreqDist(list_of_words)
    mostcommon = wordfreqdist.most_common(30)
    st.write(mostcommon)
    return mostcommon

def wordcloud(mostcommonwords):
    fig, ax = plt.subplots()
    plt.barh(range(len(mostcommonwords)),[val[1] for val in mostcommonwords], align='center')
    plt.yticks(range(len(mostcommonwords)), [val[0] for val in mostcommonwords])
    st.pyplot(fig)

def data_analysis(data):
    sentiment_distribution(data)
    text_process_button = st.sidebar.button('Process the text?')

    if text_process_button:
        text_processed = preprocess(list(data['text']))
        data_neg = text_processed[:800000]
        data_pos = text_processed[800000:]

        st.write('Most common words in Neg and Pos sentiment tweets')
        col1, col2 = st.columns(2)
        with col1:
            neg_mostcommon = most_common(' '.join(data_neg))
            wordcloud(neg_mostcommon)
        with col2:
            pos_mostcommon = most_common(' '.join(data_pos))
            wordcloud(pos_mostcommon)

# ================ Code change START HERE ===============
def predict_tweet_sentiment():
    tweet = st.text_input('Write the tweet')
    r = requests.get(f"http://127.0.0.1:5000/predict?text={tweet}")
    st.write(f"""
    Your tweet `{tweet}` has a polarity of {r.json()['polarity']}
    """)
# ================ Code change END HERE ===============


def main():
    '''Streamlit main function

    '''
    st.title("Advanced Python for Data Science")
    st.header("Super awesome data app")
    st.subheader("A tweet sentiment analysis")

    df_tweet = load_data()

    st.sidebar.title('Menu')
    # ================ Code change START HERE ===============
    menu = st.sidebar.selectbox("Choose a menu", ['Show data', 'Data analysis', 'Sentiment Classifier'])
    # ================ Code change END HERE ===============
    
    if menu == 'Show data':
        show_data(df_tweet)
    elif menu == "Data analysis":
        data_analysis(df_tweet)
    # ================ Code change START HERE ===============
    elif menu == "Sentiment Classifier":
        predict_tweet_sentiment()
    # ================ Code change END HERE ===============
    else:
        pass


if __name__ == '__main__':
    main()
