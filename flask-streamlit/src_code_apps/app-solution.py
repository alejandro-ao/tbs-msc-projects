import time
import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go

HEADER_TITLE = "South Western Ambulance Service - Hospital Handover Report"
HEADER_INFO = " **tel:** 01392 451192 **| website:** https://www.swast.nhs.uk **| email:** mailto:data.science@swast.nhs.uk"
HELP_MSG = 'Filter report to show only one hospital'

@st.cache
def load_data(sheet_name):
    return pd.read_excel('DataforMock.xlsx',sheet_name = sheet_name)

def generate_plot(data, y, marker_color, title_text):
    if y == "Average Duration":
        fig = px.bar(
            data,
            x='Arrived Destination Resolved',
            y=y,
            color=y,
            template='seaborn',
            color_continuous_scale=px.colors.diverging.Temps
            )
        fig.add_scatter(
            x=data['Arrived Destination Resolved'],
            y=data['Target'],
            mode='lines', line=dict(color="black"),
            name='Target'
            )
        fig.update_layout(
            title_text="Average Completed Handover Duration by hour",
            title_x=0,
            margin= dict(
                l=0,r=10,b=10,t=30),
                yaxis_title=None,
                xaxis_title=None,
                legend=dict(orientation="h",
                yanchor="bottom",
                y=0.9,
                xanchor="right",
                x=0.99
                )
            )
    else:
        fig = px.bar(
            data,
            x = 'Arrived Destination Resolved',
            y=y,
            template = 'seaborn')
        fig.update_traces(marker_color=marker_color)
        fig.update_layout(
            title_text=title_text,
            title_x=0,
            margin=dict(
                l=0,
                r=10,
                b=10,
                t=30
                ),
            yaxis_title=None,
            xaxis_title=None
            )

    return fig

def main():
    # Set Page Configuration
    st.set_page_config(page_title='SWAST - Handover Delays',  layout='wide')

    # Set Header
    col1, col2 = st.columns((0.07, 1))

    with col1:
        st.image('./index.png', width=120)

    with col2:
        st.title(HEADER_TITLE)
        st.markdown(HEADER_INFO)


    with st.spinner('Updating Report...'):
        # Loading Hospital Names
        hospital_names = load_data('Hospitals')

        # Selecting Hospital
        selected_hospital = st.selectbox('Choose Hospital', hospital_names, help = HELP_MSG)

        # Loading Metrics Data
        metrics = load_data('metrics')
        hospital_metrics = metrics[metrics['Hospital Attended']==selected_hospital]

        # Loading Graphs
        graphs = load_data('Graph')
        hospital_graph = graphs[graphs['Hospital Attended']==selected_hospital]

        # Loading Forecast
        forcasts = load_data('Forecast')
        hospital_forcast = forcasts[forcasts['Hospital Attended']==selected_hospital]
        
        # Display metrics
        _, col2, col3, col4, _ = st.columns((1,1,1,1,1))
 
        with col2:
            df_total_outstanding = hospital_metrics[hospital_metrics['Metric']== 'Total Outstanding']  
            st.metric(label ='Total Outstanding Handovers',value = int(df_total_outstanding['Value']), delta = str(int(df_total_outstanding['Previous']))+' Compared to 1 hour ago', delta_color = 'inverse')
        with col3:
            df_current_handover = hospital_metrics[metrics['Metric']== 'Current Handover Average Mins']
            st.metric(label ='Current Handover Average',value = str(int(df_current_handover['Value']))+" Mins", delta = str(int(df_current_handover['Previous']))+' Compared to 1 hour ago', delta_color = 'inverse')
        with col4:
            df_hours_lost = hospital_metrics[metrics['Metric']== 'Hours Lost to Handovers Over 15 Mins']
            st.metric(label = 'Time Lost today (Above 15 mins)',value = str(int(df_hours_lost['Value']))+" Hours", delta = str(int(df_hours_lost['Previous']))+' Compared to yesterday')

        col1, col2, col3 = st.columns((1,1,1))

        with col1:
            fig = generate_plot(hospital_graph, 'Number of Handovers', '#264653', "Number of Completed Handovers by Hour")
            st.plotly_chart(fig, use_container_width=True)

        with col2:
            fig = generate_plot(hospital_forcast, 'y', '#7A9E9F', "Predicted Number of Arrivals")
            st.plotly_chart(fig, use_container_width=True)

        with col3:
            fig = generate_plot(hospital_graph, 'Average Duration', '#7A9E9F', "Average Completed Handover Duration by hour")
            
            st.plotly_chart(fig, use_container_width=True)

    # Contact Form
    with st.expander("Contact us"):
        with st.form(key='contact', clear_on_submit=True):
            email = st.text_input('Contact Email')
            st.text_area("Query","Please fill in all the information or we may not be able to process your request")  
            submit_button = st.form_submit_button(label='Send Information')
        
if __name__ == '__main__':
    main()