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
    return df

@st.cache
def get_users(data):
    return sorted(data['user'].unique().tolist())[:10]

@st.cache
def get_timeline(data):
    return data.groupby('day_utc').count()['target'].reset_index()


def create_plot(data, user):
    fig, ax = plt.subplots()
    ax = sns.scatterplot(x = 'day_utc', y = 'target', data=data)
    plt.xlabel('day')
    plt.xticks(rotation=45)
    plt.xlim(data['day_utc'].min()-datetime.timedelta(days=1), data['day_utc'].max()+datetime.timedelta(days=1))
    plt.ylabel('number of tweets')
    plt.title(f"Timeline of number of tweets: {user}")
    st.pyplot(fig)

def main():
    '''Streamlit main function
    
    '''
    st.title("Advanced Python for Data Science")
    st.header("My First app")
    st.subheader("A tweet sentiment analysis")
    
    df_tweet = load_data()

    # get user unique set
    users_list = ['All'] + get_users(df_tweet)
    selected_user = st.selectbox('Choose a user', users_list)

    if selected_user == 'All':
        st.write(f'You want to see all data')
        st.write(df_tweet.head())
        tweet_timeline = get_timeline(df_tweet)
    else:
        st.write(f'You selected {selected_user}')
        tweet_user = df_tweet[df_tweet['user']==selected_user]
        st.write(tweet_user)
        tweet_timeline = get_timeline(tweet_user)
    
    create_plot(tweet_timeline, selected_user)


if __name__ == '__main__':
    main()
