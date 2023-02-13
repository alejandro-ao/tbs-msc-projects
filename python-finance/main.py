import requests
import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error


def get_data(symbol):
    # Request the data from Alpha Vantage API
    API_KEY = "M9HQZHSX91COM0QJ"
    url = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol={}&apikey={}&outputsize=full".format(
        symbol, API_KEY)
    response = requests.get(url)
    data = response.json()
    daily_data = data["Time Series (Daily)"]

    # Convert the data into a pandas DataFrame
    df = pd.DataFrame(daily_data)
    df = df.T
    df.index = pd.to_datetime(df.index)
    df = df.astype(float)

    return df


def train_model(df):
    # Split the data into training and testing sets
    train, test = train_test_split(df, test_size=0.2, shuffle=False)

    # Train a linear regression model on the training data
    X_train = np.array(range(len(train))).reshape(-1, 1)
    y_train = train["4. close"].values
    model = LinearRegression()
    model.fit(X_train, y_train)

    # Evaluate the model on the testing data
    X_test = np.array(range(len(train), len(train) + len(test))).reshape(-1, 1)
    y_test = test["4. close"].values
    y_pred = model.predict(X_test)
    mse = mean_squared_error(y_test, y_pred)

    return model, mse


def predict_price(model, date, df):
    # Predict the stock price on the given date
    date_index = np.where(df.index == date)[0][0]
    X_pred = np.array([[date_index]])
    y_pred = model.predict(X_pred)

    return y_pred[0]


if __name__ == "__main__":
    symbol = "AAPL"
    df = get_data(symbol)
    model, mse = train_model(df)
    date = "2022-12-31"
    price = predict_price(model, date, df)
    print("Predicted price on {}: {:.2f}".format(date, price))
