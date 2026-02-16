@echo off
echo ======================================
echo    NutriTrack - Starting Application
echo ======================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Flutter not found in PATH!
    echo.
    echo Trying to use local Flutter installation...
    if exist "C:\Users\DELL\flutter\bin\flutter.bat" (
        set PATH=C:\Users\DELL\flutter\bin;%PATH%
        echo Flutter found at C:\Users\DELL\flutter
    ) else (
        echo ERROR: Flutter SDK not found!
        echo Please install Flutter or update the path in this script.
        pause
        exit /b 1
    )
)

echo Checking Flutter installation...
flutter doctor
echo.

echo Installing dependencies...
flutter pub get
echo.

echo ======================================
echo Select run mode:
echo 1. Run on Chrome (Web - Recommended for quick demo)
echo 2. Run on Android Emulator/Device
echo 3. Run on Windows Desktop
echo ======================================
set /p choice="Enter your choice (1-3): "

if "%choice%"=="1" (
    echo Starting on Chrome...
    flutter run -d chrome
) else if "%choice%"=="2" (
    echo Starting on Android...
    flutter run
) else if "%choice%"=="3" (
    echo Starting on Windows Desktop...
    flutter run -d windows
) else (
    echo Invalid choice. Defaulting to Chrome...
    flutter run -d chrome
)

pause
