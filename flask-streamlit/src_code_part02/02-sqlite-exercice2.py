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

# Custom Libraries

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

# ================ Code change START HERE ===============
def sentiment_distribution(data):
    # Replacing the values to ease understanding.
    data['target'] = data['target'].replace(4,1)

    # Plotting the distribution for dataset
    fig, ax = plt.subplots()
    ax = data.groupby('target').count()['id'].plot(kind='bar', title='Distribution of data',
                                                legend=False)
    ax.set_xticklabels(['Negative','Positive'], rotation=0)
    st.pyplot(fig)
# ================ Code change END HERE ===============

def main():
    '''Streamlit main function

    '''
    st.title("Advanced Python for Data Science")
    st.header("Super awesome data app")
    st.subheader("A tweet sentiment analysis")

    df_tweet = load_data()

    # get user unique set
    users_list = ['All'] + get_users(df_tweet)
    selected_user = st.selectbox('Choose a user', users_list)

    if selected_user == 'All':
        st.write('You want to see all data')
        st.write(df_tweet.head())
        tweet_timeline = get_timeline(df_tweet)
        sentiment_distribution(df_tweet)
    else:
        st.write(f'You selected {selected_user}')
        tweet_user = df_tweet[df_tweet['user'] == selected_user]
        st.write(tweet_user)
        tweet_timeline = get_timeline(tweet_user)
        sentiment_distribution(tweet_user)

    create_plot(tweet_timeline, selected_user)

    # ================ Code change START HERE ===============
    #sentiment_distribution(df_tweet)
    # ================ Code change END HERE ===============

if __name__ == '__main__':
    main()
