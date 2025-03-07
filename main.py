from flask import Flask, request, jsonify
from flask_cors import CORS
import pickle
import numpy as np
import pandas as pd

# Load the trained LightGBM model
model = pickle.load(open("stroke_model.pkl", "rb"))

app = Flask(__name__)
CORS(app)  # Enable CORS for API access from Flutter

@app.route("/")
def home():
    return "Stroke Prediction API is Running!"

@app.route("/predict", methods=["POST"])
def predict():
    try:
        data = request.json  # Get JSON data from request
        df = pd.DataFrame([data])  # Convert to DataFrame
        
        # Ensure correct feature order (adjust column names as per training data)
        feature_columns = ['age', 'hypertension', 'heart_disease', 'ever_married', 
                           'work_type', 'Residence_type', 'avg_glucose_level', 
                           'bmi', 'smoking_status', 'gender_Male', 'gender_Other']
        
        df = df.reindex(columns=feature_columns, fill_value=0)

        prediction = model.predict(df)[0]  # Make prediction
        return jsonify({"prediction": int(prediction)})  # Return response

    except Exception as e:
        return jsonify({"error": str(e)})

if __name__ == "__main__":
    app.run(debug=True)
