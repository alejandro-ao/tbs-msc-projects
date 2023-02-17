from flask import Flask

app = Flask(__name__)

@app.route('/predict')
def predict():
    # Loading the saved model.pk
    model = load_model()
    # making a prediction
    prediction = model.predict(df)
