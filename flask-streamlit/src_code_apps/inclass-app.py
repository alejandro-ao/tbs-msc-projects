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
    df = pd.read_csv(
        '/Users/samiadrappeau/Documents/TBS/PYTHON-102/campus/ue33-parttime/data/tweet-sentiment-withDay.csv')
    df['day_utc'] = pd.to_datetime(df['day_utc'], infer_datetime_format=True)
    return df


@st.cache
def get_users(data):
    return sorted(data['user'].unique().tolist())[:10]

def get_timeline(data, col_name_groupby, col_name_count):
    data_timeline = data.groupby(col_name_groupby).count()[col_name_count].reset_index()
    return data_timeline

def create_plot(data):
    fig, ax = plt.subplots()
    ax = sns.scatterplot(x='day_utc', y='target', data=data)
    plt.xlabel('day')
    plt.xticks(rotation=45)
    plt.xlim(
        data['day_utc'].min() -
        datetime.timedelta(
            days=1),
        data['day_utc'].max() +
        datetime.timedelta(
            days=1))
    plt.ylabel('number of tweets')
    plt.title(f"Timeline of number of tweets")
    st.pyplot(fig)

def create_barplot(data):
    st.bar_chart(data=data, x='target', y='id')


def main():
    '''Streamlit main function

    '''
    st.title("Advanced Python for Data Science")
    st.header("Super awesome data app")

    # Load the data
    df_tweet = load_data()


    with st.sidebar:
        st.title("Menu")
        page_list = ['Home', 'Tweet Analysis', 'Data Analysis']

        selected_value = st.selectbox('Choose a Page', page_list)
        #st.write(selected_value)


    if selected_value == "Home":
        st.subheader("Welcome to our awesome Homepage!")
    elif selected_value == "Data Analysis":
        st.subheader("A Data analysis")
        df_tweet_distribution = df_tweet.groupby('target').count()['id'].reset_index()
        st.write(df_tweet_distribution.head())

        # Plot bar chart of df_tweet_distribution
        create_barplot(df_tweet_distribution)

    else:
        st.subheader("A tweet sentiment analysis")
        # get user unique set
        users_list = ['All'] + get_users(df_tweet)
        selected_user = st.selectbox('Choose a user', users_list)

        col1, col2 = st.columns(2)

        with col1:
            if selected_user == 'All':
                st.write(f'You want to see all data')
                tweet_user = df_tweet
                st.write(tweet_user.head())
            else:
                st.write(f'You selected {selected_user}')
                tweet_user = df_tweet[df_tweet['user'] == selected_user]
                st.write(tweet_user)

        with col2:
            # Plot number of tweets per day
            df_timeline = get_timeline(tweet_user, 'day_utc', 'target')

            create_plot(df_timeline)


if __name__ == '__main__':
    main()
