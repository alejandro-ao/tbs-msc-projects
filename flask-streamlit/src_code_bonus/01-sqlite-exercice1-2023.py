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
# ================ Code change START HERE ===============
import sqlalchemy as sa
# ================ Code change END HERE ===============

# Custom Libraries

def open_connection():
    engine = sa.create_engine("sqlite:////Volumes/trappist1/missions/tbs/2022-2023/PYTHON-102/campus/ue33-parttime/data/tweet-sentiment-withDay.db", echo=False)
    sa_connection = engine.connect()
    return sa_connection

def load_data(sa_connection, sql_query):
    """Load the data

    """
    # ================ Code change START HERE ===============
    tweets = pd.read_sql(sql_query, sa_connection, index_col="id")
    tweets['day_utc'] = pd.to_datetime(
        tweets['day_utc'], infer_datetime_format=True)
    # ================ Code change END HERE ===============
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

def plot_sentiment_distribution(sa_connection):
    st.write('EMPLACEMENT PLOT DISTRIBUTION TWEET SENTIMENT')
    #chart_data = pd.DataFrame()
    sql_query = """
        SELECT target, COUNT(*) as nb_per_sentiment
        FROM tweets
        GROUP BY target
    """
    chart_data = pd.read_sql(sql_query, sa_connection)
    st.bar_chart(chart_data, x='target', y='nb_per_sentiment')

def main():
    '''Streamlit main function

    '''
    st.title("Advanced Python for Data Science")
    st.header("Super awesome data app")
    st.subheader("A tweet sentiment analysis")

    

    # Connection DB
    sa_connection = open_connection()

    sql_query = """
        SELECT *
        FROM tweets
    """
    df_tweet = load_data(sa_connection, sql_query)

    # get user unique set
    users_list = ['All'] + get_users(df_tweet)
    selected_user = st.selectbox('Choose a user', users_list)

    if selected_user == 'All':
        st.write('You want to see all data')
        st.write(df_tweet.head())
        tweet_timeline = get_timeline(df_tweet)
    else:
        st.write(f'You selected {selected_user}')
        tweet_user = df_tweet[df_tweet['user'] == selected_user]
        st.write(tweet_user)
        tweet_timeline = get_timeline(tweet_user)

    col1, col2 = st.columns(2)

    with col1:
        create_plot(tweet_timeline, selected_user)

    with col2:
        plot_sentiment_distribution(sa_connection)

    with col1:
        st.write("Some TEXT")


if __name__ == '__main__':
    main()
