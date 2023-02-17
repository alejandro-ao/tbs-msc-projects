''' Streamlit AIBA-APDS application

Author: Samia Drappeau
Version: v1.0
'''
# Build-in Libraries

# Third-party Libraries
import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import datetime

# Custom Libraries

@st.cache
def load_data():
    df = pd.read_csv('../../data/tweet-sentiment-withDay.csv')
    df['day_utc'] = pd.to_datetime(df['day_utc'],  infer_datetime_format=True)
    return df

@st.cache
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

    # get user unique set
    users_list = ['All'] + get_users(df_tweet)
    selected_user = st.selectbox('Choose a user', users_list)

    if selected_user == 'All':
        st.write(f'You want to see all data')
        st.write(df_tweet.head())
    else:
        st.write(f'You selected {selected_user}')
        tweet_user = df_tweet[df_tweet['user']==selected_user]
        st.write(tweet_user)
    
    # Plot number of tweets per day
    df_timeline = df_tweet.groupby('day_utc').count()['target'].reset_index()
    fig, ax = plt.subplots()
    ax = sns.scatterplot(x = 'day_utc', y = 'target', data=df_timeline)
    plt.xlabel('day')
    plt.xticks(rotation=45)
    plt.xlim(df_timeline['day_utc'].min()-datetime.timedelta(days=1), df_timeline['day_utc'].max()+datetime.timedelta(days=1))
    plt.ylabel('number of tweets')
    plt.title(f"Timeline of number of tweets")
    st.pyplot(fig)

if __name__ == '__main__':
    main()
