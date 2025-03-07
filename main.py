import pickle
from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd

app = Flask(__name__)
CORS(app)

# Try loading the model safely
try:
    with open("stroke_model.pkl", "rb") as f:
        model = pickle.load(f)
except Exception as e:
    model = None
    print(f"Error loading model: {e}")

@app.route("/")
def home():
    return "Stroke Prediction API is Running!"

@app.route("/predict", methods=["POST"])
def predict():
    if model is None:
        return jsonify({"error": "Model not loaded properly"})

    try:
        data = request.json  # Get JSON data from request
        df = pd.DataFrame([data])  # Convert to DataFrame

        # Ensure correct feature order
        feature_columns = ['age', 'hypertension', 'heart_disease', 'ever_married', 
                           'work_type', 'Residence_type', 'avg_glucose_level', 
                           'bmi', 'smoking_status', 'gender_Male', 'gender_Other']

        df = df.reindex(columns=feature_columns, fill_value=0)

        prediction = model.predict(df)[0]  # Make prediction
        return jsonify({"prediction": int(prediction)})

    except Exception as e:
        return jsonify({"error": str(e)})

if __name__ == "__main__":
    app.run(debug=True)
