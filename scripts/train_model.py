"""
Train a TensorFlow model for risk prediction using real health datasets.

This script loads health and nutrition data from CSV files in assets/data/,
trains a classifier that predicts risk categories (0=Normal, 1=Moderate, 2=High, 3=Severe),
and exports as TensorFlow Lite format for mobile deployment.

Datasets combined:
- country-wise-average.csv
- malnutrition-estimates.csv
- Maternal Mortality Ratio.csv
- GDP per capita.csv
- etc.

Run in an environment with TensorFlow + pandas installed.
"""
import os
import numpy as np
import pandas as pd
import tensorflow as tf
from glob import glob

OUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'models')
DATA_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'data')
os.makedirs(OUT_DIR, exist_ok=True)

def load_real_data():
    """Load and combine all CSV datasets from assets/data/"""
    print("Loading real datasets from assets/data/...")
    
    all_data = []
    csv_files = glob(os.path.join(DATA_DIR, '*.csv'))
    
    print(f"Found {len(csv_files)} CSV files:")
    for f in csv_files:
        print(f"  - {os.path.basename(f)}")
    
    for csv_file in csv_files:
        try:
            df = pd.read_csv(csv_file)
            print(f"  ✓ Loaded {os.path.basename(csv_file)}: {len(df)} rows")
            all_data.append(df)
        except Exception as e:
            print(f"  ✗ Error loading {os.path.basename(csv_file)}: {e}")
    
    if not all_data:
        print("No CSV files found. Using synthetic data fallback...")
        return gen_synthetic_data(2000)
    
    # Combine all dataframes
    combined_df = pd.concat(all_data, ignore_index=True, sort=False)
    print(f"\nCombined dataset: {len(combined_df)} rows, {len(combined_df.columns)} columns")
    
    return extract_features_from_real_data(combined_df)

def extract_features_from_real_data(df):
    """Extract features from real health datasets and generate labels"""
    print("\nExtracting features from real data...")
    
    # Get numeric columns (these will be our features)
    numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
    
    if len(numeric_cols) < 5:
        print(f"Only {len(numeric_cols)} numeric columns found. Using synthetic data...")
        return gen_synthetic_data(2000)
    
    # Use first 5 numeric columns as features
    selected_cols = numeric_cols[:5]
    print(f"Selected features: {selected_cols}")
    
    X = df[selected_cols].dropna().values.astype(np.float32)
    
    # Normalize features to 0-20 range for consistency
    X_normalized = np.zeros_like(X)
    for i in range(X.shape[1]):
        col_min, col_max = X[:, i].min(), X[:, i].max()
        if col_max > col_min:
            X_normalized[:, i] = 1 + 19 * (X[:, i] - col_min) / (col_max - col_min)
        else:
            X_normalized[:, i] = 10
    
    # Generate labels based on feature patterns
    y = generate_labels_from_features(X_normalized)
    
    print(f"Generated X: {X_normalized.shape}, y: {y.shape}")
    print(f"Label distribution: {np.bincount(y)}")
    
    return X_normalized, y

def generate_labels_from_features(X):
    """Generate risk labels from feature values"""
    n = X.shape[0]
    y = np.zeros(n, dtype=np.int32)
    
    # Use statistical distribution: lower feature values = higher risk
    for i in range(n):
        feature_avg = np.mean(X[i])
        
        if feature_avg < 5:
            y[i] = 3  # Severe
        elif feature_avg < 8:
            y[i] = 2  # High
        elif feature_avg < 12:
            y[i] = 1  # Moderate
        else:
            y[i] = 0  # Normal
    
    return y

def gen_synthetic_data(n=2000):
    """Fallback: Generate synthetic example data"""
    print("Generating synthetic training data...")
    # features: weight (kg), height (cm), muac (cm), hemoglobin (g/dL), meals (per day)
    weight = np.random.normal(10.0, 2.5, size=n)
    height = np.random.normal(80.0, 8.0, size=n)
    muac = np.random.normal(13.0, 1.5, size=n)
    hb = np.random.normal(11.5, 1.5, size=n)
    meals = np.random.randint(2, 6, size=n)

    X = np.stack([weight, height, muac, hb, meals], axis=1).astype(np.float32)

    # Rule-based labels for synthetic training
    y = np.zeros((n,), dtype=np.int32)
    for i in range(n):
        if muac[i] < 11.5 or hb[i] < 7.0:
            y[i] = 3  # Severe
        elif muac[i] < 12.5 or (weight[i] / (height[i]/100) < 10):
            y[i] = 2  # High
        elif hb[i] < 11.0 or meals[i] < 3:
            y[i] = 1  # Moderate
        else:
            y[i] = 0  # Normal

    return X, y

def build_model(input_shape):
    model = tf.keras.Sequential([
        tf.keras.layers.Input(shape=(input_shape,)),
        tf.keras.layers.Dense(32, activation='relu'),
        tf.keras.layers.Dense(24, activation='relu'),
        tf.keras.layers.Dense(4, activation='softmax')
    ])
    model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])
    return model

def main():
    print("=" * 60)
    print("NutriTrack ML Model Training")
    print("=" * 60)
    
    # Load real data from datasets
    X, y = load_real_data()
    
    print(f"\nTraining set: X shape {X.shape}, y shape {y.shape}")
    print(f"Risk distribution: Normal={np.sum(y==0)}, Moderate={np.sum(y==1)}, High={np.sum(y==2)}, Severe={np.sum(y==3)}")
    
    # Build and train model
    model = build_model(X.shape[1])
    print("\nModel architecture:")
    model.summary()
    
    print("\nTraining model...")
    history = model.fit(X, y, epochs=20, batch_size=32, validation_split=0.15, verbose=1)
    
    # Evaluate
    train_loss, train_acc = model.evaluate(X, y, verbose=0)
    print(f"\nTrain Accuracy: {train_acc:.2%}")
    
    # Save TF SavedModel then convert to TFLite
    print("\nConverting to TensorFlow Lite...")
    saved = os.path.join(OUT_DIR, 'saved_model')
    model.save(saved, include_optimizer=False)

    converter = tf.lite.TFLiteConverter.from_saved_model(saved)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.target_spec.supported_ops = [
        tf.lite.OpsSet.TFLITE_BUILTINS,
        tf.lite.OpsSet.SELECT_TF_OPS
    ]
    
    try:
        tflite_model = converter.convert()
    except Exception as e:
        print(f"Conversion warning: {e}. Retrying with basic ops...")
        converter = tf.lite.TFLiteConverter.from_saved_model(saved)
        tflite_model = converter.convert()

    tflite_path = os.path.join(OUT_DIR, 'model.tflite')
    with open(tflite_path, 'wb') as f:
        f.write(tflite_model)
        
    model_size_kb = os.path.getsize(tflite_path) / 1024
    print(f'✓ Saved TFLite model: {tflite_path} ({model_size_kb:.1f} KB)')

    labels_path = os.path.join(OUT_DIR, 'labels.txt')
    with open(labels_path, 'w') as f:
        f.write('\n'.join(['Normal','Moderate','High','Severe']))
    print(f'✓ Saved labels: {labels_path}')
    
    print("\n" + "=" * 60)
    print("Training Complete! Ready for mobile deployment.")
    print("=" * 60)

if __name__ == '__main__':
    main()
