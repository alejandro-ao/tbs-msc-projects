import streamlit as st
import pandas as pd
import numpy as np
import pydeck as pdk
import altair as alt


# LOADING DATA
DATE_TIME = "date/time"
DATA_URL = (
    "http://s3-us-west-2.amazonaws.com/streamlit-demo-data/uber-raw-data-sep14.csv.gz"
)
# SETTING THE ZOOM LOCATIONS FOR THE AIRPORTS
LA_GUARDIA= [40.7900, -73.8700]
JFK = [40.6650, -73.7821]
NEWARK = [40.7090, -74.1805]
ZOOME_LEVEL = 12

@st.cache(persist=True)
def load_data(nrows):
    data = pd.read_csv(DATA_URL, nrows=nrows)
    lowercase = lambda x: str(x).lower()
    data.rename(lowercase, axis="columns", inplace=True)
    data[DATE_TIME] = pd.to_datetime(data[DATE_TIME])
    return data


# Plot a map with Hexagonal grid
def map(data, lat, lon, zoom):
    st.write(pdk.Deck(
        map_style="mapbox://styles/mapbox/light-v9",
        initial_view_state={
            "latitude": lat,
            "longitude": lon,
            "zoom": zoom,
            "pitch": 50,
        },
        layers=[
            pdk.Layer(
                "HexagonLayer",
                data=data,
                get_position=["lon", "lat"],
                radius=100,
                elevation_scale=4,
                elevation_range=[0, 1000],
                pickable=True,
                extruded=True,
            ),
        ]
    ))

def histogram_chart(chart_data):
    st.altair_chart(alt.Chart(chart_data)
    .mark_area(
        interpolate='step-after',
    ).encode(
        x=alt.X("minute:Q", scale=alt.Scale(nice=False)),
        y=alt.Y("pickups:Q"),
        tooltip=['minute', 'pickups']
    ).configure_mark(
        opacity=0.2,
        color='red'
    ), use_container_width=True)


def main():
    # SETTING PAGE CONFIG TO WIDE MODE
    st.set_page_config(layout="wide")

    data = load_data(100000)

    # LAYING OUT THE TOP SECTION OF THE APP

    # FILTERING DATA BY HOUR SELECTED

    # LAYING OUT THE MIDDLE SECTION OF THE APP WITH THE MAPS

    # SETTING THE MIDPOINT LOCATIONS FOR THE AIRPORTS ON THE MAP
    midpoint = (np.average(data["lat"]), np.average(data["lon"]))

    # FILTERING DATA FOR THE HISTOGRAM

    # LAYING OUT THE HISTOGRAM SECTION



if __name__ == '__main__':
    main()