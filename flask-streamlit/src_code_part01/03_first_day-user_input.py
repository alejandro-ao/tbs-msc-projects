''' Streamlit AIBA-APDS application

Author: Samia Drappeau
Version: v1.0
'''
# Build-in Libraries

# Third-party Libraries
import streamlit as st
import pandas as pd

# Custom Libraries

def load_data():
    df = pd.read_csv('../../data/tweet-sentiment-withDay.csv')
    return df

def get_users(data):
    return sorted(data['user'].unique().tolist())[:10]

def main():
    '''Streamlit main function
    
    '''
    st.write(
        """
        # My first app
        Tweet sentiment!
        """
    )
    df_tweet = load_data()
    st.write(df_tweet.head())

    # get user unique set
    users_list = get_users(df_tweet)
    selected_user = st.selectbox('Choose a user', users_list)
    st.write(f'You selected {selected_user}')


if __name__ == '__main__':
    main()
