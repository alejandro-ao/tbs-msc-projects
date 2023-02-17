''' Streamlit AIBA-APDS application

Author: Samia Drappeau
Version: v1.0
'''
# Build-in Libraries

# Third-party Libraries
import streamlit as st
import pandas as pd

# Custom Libraries

def main():
    '''Streamlit main function
    
    '''
    st.write(
        """
        # My first app
        Tweet sentiment!
        """
    )
    df_tweet = pd.read_csv('../../data/tweet-sentiment.csv', encoding="ISO-8859-1")

    st.write(df_tweet.head())


if __name__ == '__main__':
    main()
