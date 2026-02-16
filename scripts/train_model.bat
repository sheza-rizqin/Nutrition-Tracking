@echo off
REM Batch script to train the ML model
REM Run: scripts\train_model.bat

echo.
echo ========================================
echo     NutriTrack ML Model Training
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found!
    echo Install Python 3.9+ from https://www.python.org/
    pause
    exit /b 1
)

echo Python installed: 
python --version
echo.

REM Check for required packages
echo Installing/checking dependencies...
pip install tensorflow numpy --upgrade --quiet 2>nul

if errorlevel 1 (
    echo ERROR: Failed to install dependencies!
    pause
    exit /b 1
)

echo.
echo Starting model training (this takes ~30 seconds)...
echo.

python scripts\train_model.py

if errorlevel 1 (
    echo ERROR: Model training failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo SUCCESS! Model trained.
echo ========================================
echo.
echo Files created:
echo   - assets/models/model.tflite
echo   - assets/models/labels.txt
echo   - assets/models/saved_model/
echo.
echo Next steps:
echo   1. flutter clean
echo   2. flutter pub get
echo   3. flutter run -d ^<device_id^>
echo.
pause
