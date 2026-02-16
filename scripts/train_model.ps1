# PowerShell script to train the ML model
# Run: .\scripts\train_model.ps1

Write-Host "🤖 NutriTrack ML Model Training Script" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check if Python is installed
Write-Host "Checking for Python..." -ForegroundColor Yellow
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue

if (-not $pythonCmd) {
    Write-Host "❌ Python not found! Install Python 3.9+ from https://www.python.org/" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Python found: $(python --version)" -ForegroundColor Green
Write-Host ""

# Check for required packages
Write-Host "Checking dependencies..." -ForegroundColor Yellow
$missingPackages = @()

foreach ($pkg in @("tensorflow", "numpy")) {
    $installed = python -c "import $pkg; print('OK')" 2>&1
    if ($LASTEXITCODE -ne 0) {
        $missingPackages += $pkg
    } else {
        Write-Host "✅ $pkg installed" -ForegroundColor Green
    }
}

# Install missing packages
if ($missingPackages.Count -gt 0) {
    Write-Host ""
    Write-Host "Installing missing packages: $($missingPackages -join ', ')" -ForegroundColor Yellow
    pip install $missingPackages --upgrade
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to install dependencies!" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "Starting model training..." -ForegroundColor Cyan
Write-Host "This will take ~30 seconds..." -ForegroundColor Yellow
Write-Host ""

# Run the training script
$trainScript = Join-Path $PSScriptRoot "train_model.py"
python $trainScript

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Model training completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Files created:" -ForegroundColor Cyan
    Write-Host "  📄 assets/models/model.tflite" -ForegroundColor Green
    Write-Host "  📄 assets/models/labels.txt" -ForegroundColor Green
    Write-Host "  📁 assets/models/saved_model/" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. flutter clean" -ForegroundColor White
    Write-Host "  2. flutter pub get" -ForegroundColor White
    Write-Host "  3. flutter run -d <device_id>  (Android/iOS)" -ForegroundColor White
} else {
    Write-Host "❌ Model training failed!" -ForegroundColor Red
    exit 1
}
