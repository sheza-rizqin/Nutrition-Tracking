import pandas as pd
import numpy as np
import joblib
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.impute import SimpleImputer
from sklearn.ensemble import RandomForestClassifier, ExtraTreesClassifier, GradientBoostingClassifier
from sklearn.calibration import CalibratedClassifierCV

# LOAD DATA
df = pd.read_csv("Maternal Health Risk Data Set.csv")

# FEATURES
X = df[["Age", "SystolicBP", "DiastolicBP", "BS", "BodyTemp", "HeartRate"]]
y = df["RiskLevel"]

# IMPUTATION
imputer = SimpleImputer(strategy="mean")
X = imputer.fit_transform(X)

# SCALING
scaler = StandardScaler()
X = scaler.fit_transform(X)

# LABEL ENCODER
le = LabelEncoder()
y = le.fit_transform(y)

# MODELS
rf = CalibratedClassifierCV(RandomForestClassifier(), cv=3)
et = CalibratedClassifierCV(ExtraTreesClassifier(), cv=3)
gb = CalibratedClassifierCV(GradientBoostingClassifier(), cv=3)

rf.fit(X, y)
et.fit(X, y)
gb.fit(X, y)

# SAVE ALL
joblib.dump(rf, "rf_calibrated.joblib")
joblib.dump(et, "et_calibrated.joblib")
joblib.dump(gb, "gb_calibrated.joblib")
joblib.dump(imputer, "imputer.joblib")
joblib.dump(scaler, "scaler.joblib")
joblib.dump(le, "labelencoder.joblib")

print("ALL MODELS SAVED SUCCESSFULLY!")
