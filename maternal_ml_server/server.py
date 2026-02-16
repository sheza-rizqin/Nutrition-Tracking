from flask import Flask, request, jsonify
import joblib, os, json, numpy as np
BASE = os.path.dirname(os.path.abspath(__file__))
rf = joblib.load(os.path.join(BASE, "rf_calibrated.joblib"))
et = joblib.load(os.path.join(BASE, "et_calibrated.joblib"))
gb = joblib.load(os.path.join(BASE, "gb_calibrated.joblib"))
scaler = joblib.load(os.path.join(BASE, "scaler.joblib"))
imputer = joblib.load(os.path.join(BASE, "imputer.joblib"))
labelencoder = joblib.load(os.path.join(BASE, "labelencoder.joblib"))
weights = {"rf": 0.3344914083333779, "et": 0.33623049029173746, "gb": 0.3292781013748845}
classes = labelencoder.classes_.tolist()

def ensemble_predict_proba(X):
    p_rf = rf.predict_proba(X)
    p_et = et.predict_proba(X)
    p_gb = gb.predict_proba(X)
    return weights["rf"]*p_rf + weights["et"]*p_et + weights["gb"]*p_gb

from flask import Flask, request, jsonify
app = Flask(__name__)

@app.route("/predict", methods=["POST"])
def predict():
    data = request.json
    feature_order = ["Age","SystolicBP","DiastolicBP","BS","BodyTemp","HeartRate"]
    X = np.array([[data.get(f, np.nan) for f in feature_order]])
    X = imputer.transform(X)
    X = scaler.transform(X)
    probs = ensemble_predict_proba(X)[0]
    pred_idx = int(np.argmax(probs))
    pred_label = classes[pred_idx]
    return jsonify({"predicted_label": pred_label, "probabilities": {classes[i]: float(probs[i]) for i in range(len(classes))}})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
