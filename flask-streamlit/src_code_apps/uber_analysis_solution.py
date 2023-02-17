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
ZOOM_LEVEL = 12

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
    col1, col2 = st.columns(2)

    with col1:
        st.header("Title Uber Rides")
        selected_hour = st.select_slider('Select hour of pickup:', [time for time in range(0, 24, 1)])

    with col2:
        st.write("some information on the app")
    
    # FILTERING DATA BY HOUR SELECTED
    selected_data = data[data[DATE_TIME].dt.hour == selected_hour]

    # LAYING OUT THE MIDDLE SECTION OF THE APP WITH THE MAPS
    row2_1, row2_2, row2_3, row2_4 = st.columns([2,1,1,1])

    # SETTING THE MIDPOINT LOCATIONS FOR THE AIRPORTS ON THE MAP
    ny_midpoint = (np.average(selected_data["lat"]), np.average(selected_data["lon"]))

    with row2_1:
        st.write("this is NY")
        map(selected_data, ny_midpoint[0], ny_midpoint[1], ZOOM_LEVEL)

    with row2_4:
        st.write("this is Newark")
        map(selected_data, NEWARK[0], NEWARK[1], ZOOM_LEVEL)

    with row2_2:
        st.write("this is La Guardia")
        map(selected_data, LA_GUARDIA[0], LA_GUARDIA[1], ZOOM_LEVEL)

    with row2_3:
        st.write("this is JFK")
        map(selected_data, JFK[0], JFK[1], ZOOM_LEVEL)


    # FILTERING DATA FOR THE HISTOGRAM
    
    hist_minutes, bin_minutes = np.histogram(selected_data[DATE_TIME].dt.minute, bins=60, range=(0,60))

    chart_data = pd.DataFrame({"minute": bin_minutes[:-1], "pickups": hist_minutes})
    
    st.write(chart_data.head())


    # LAYING OUT THE HISTOGRAM SECTION
    histogram_chart(chart_data)

    st.write(selected_data.groupby(DATE_TIME).count()['lat'].reset_index())



if __name__ == '__main__':
    main()