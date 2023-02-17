import pandas as pd
import streamlit as st
import requests

HOME_MSG = 'This app will help you get the overall sentiment of a tweet.'
SENTIMENT_TEXT_INPUT_MSG = 'Insert your tweet here'
SENTIMENT_BUTTON_MSG = 'Make sentiment analysis'
SENTIMENT_ELSE_MSG = "Please provide me with a tweet to analyse"

# TWEET_REQUEST_ADDRESS = f"http://127.0.0.1:5000/predict?text={text}"
# TWEET_SENTIMENT_MSG1 = 'Tweet successfully analysed'
# TWEET_SENTIMENT_MSG2 = f'Your tweet was *{text}*.'
# TWEET_SENTIMENT_MSG3 = f"Its sentiment is **{sentiment}**."
# TWEET_SENTIMENT_ERROR_MSG = 'Error: something bad happend'

APP_TITLE = 'Sentiment extractor'
APP_HEADER = 'helping understanding irony in tweets'
APP_SUBHEADER = 'made by me'
SIDEBAR_TITLE = 'Navigation'

MENU_MSG = 'Choose your next action'
MENU_CHOICES = ['Home', 'Sentiment analysis']

def home_msg():
    st.write(HOME_MSG)


def sentiment_analysis():
    tweet = st.text_input(SENTIMENT_TEXT_INPUT_MSG)
    run_analysis = st.button(SENTIMENT_BUTTON_MSG)

    if run_analysis:
        tweet_sentiment(tweet)
    else:
        st.write(SENTIMENT_ELSE_MSG)

def tweet_sentiment(text):
    # this is where we are requesting the ML model server
    r = requests.get(f"http://127.0.0.1:5000/predict?text={text}")
    if r.status_code == 200:
        polarity = r.json()['polarity']
        if polarity >= 0:
            sentiment = 'Positive'
        else:
            sentiment = 'Negative'
        st.write('Tweet successfully analysed')
        st.write(f'Your tweet was *{text}*.')
        st.write(f"Its sentiment is **{sentiment}**.")
    else:
        st.write('Error: something bad happend')


def main():
    st.title(APP_TITLE)
    st.header(APP_HEADER)
    st.subheader(APP_SUBHEADER)

    st.sidebar.title(SIDEBAR_TITLE)

    menu_action = st.sidebar.selectbox(MENU_MSG, MENU_CHOICES)

    if menu_action == 'Home':
        home_msg()
    elif menu_action == 'Sentiment analysis':
        sentiment_analysis()
    else:
        st.write('Error: selection invalid')


if __name__ == '__main__':
    main()