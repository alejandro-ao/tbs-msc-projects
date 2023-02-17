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
    # Write a welcome message, explaining what the app does
    pass


def sentiment_analysis():
    # Get user text input 
    # <INSERT CODE HERE>

    # Provide a button to execute the analysis
    # <INSERT CODE HERE>

    pass

def tweet_sentiment(text):
    # Request the ML model server
    # <INSERT CODE HERE>

    # Check response status and act accordingly
    # <INSERT CODE HERE>
    
    # If statut_code is 200, provide the sentiment of the tweet to user
    # <INSERT CODE HERE>
    pass

def main():
    # Set App title
    # <INSERT CODE HERE>

    # Set App header
    # <INSERT CODE HERE>

    # Set App subheader
    # <INSERT CODE HERE>

    # Set Sidebar title
    # <INSERT CODE HERE>

    # Create Nagivation menu with two choices
    # 1- Home
    # 2- Sentiment analysis

    # <INSERT CODE HERE>
    menu_action = None

    if menu_action == 'Home':
        home_msg()
    elif menu_action == 'Sentiment analysis':
        sentiment_analysis()
    else:
        st.write('Error: selection invalid')


if __name__ == '__main__':
    main()