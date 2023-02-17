from flask import Flask, jsonify, request
from textblob import TextBlob

app = Flask(__name__)
 
@app.route("/predict", methods=['GET'])
def get_prediction():
    text = request.args.get('text')
    testimonial = TextBlob(text).sentiment.polarity
    return jsonify(polarity=testimonial)
 
if __name__ == '__main__':
    app.run()