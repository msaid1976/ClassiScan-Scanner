@echo off
setlocal enabledelayedexpansion

title ClassiScan Environment
cd /d "D:\WVB Work\09-06-2025\ClassiScan-Scanner-main"
call "venv\Scripts\activate.bat"
cls
echo ========================================
echo   ClassiScan Application Environment
echo ========================================
echo Application Path: D:\WVB Work\09-06-2025\ClassiScan-Scanner-main
echo Virtual Environment: ACTIVE
echo.
echo Dataset Status:
if exist "Dataset" (
  echo [OK] Dataset folder exists
  if exist "Dataset\BarCode" echo [OK] BarCode folder exists
  if exist "Dataset\QRCode" echo [OK] QRCode folder exists  
  if exist "Dataset\BarCode-QRCode" echo [OK] BarCode-QRCode folder exists
) else (
  echo [MISSING] Dataset folder not found
)
echo.
echo ========================================
echo   CLASSISCAN COMMANDS - COPY & PASTE
echo ========================================
echo.
echo [STANDARD PROCESSING]
echo python ClassiScan.py
echo python ClassiScan.py --fill
echo python ClassiScan.py --max_images 50
echo python ClassiScan.py --fill --max_images 50
echo.
echo [COMPREHENSIVE ANALYSIS]
echo python ClassiScan.py --comprehensive
echo python ClassiScan.py --comprehensive --fill
echo python ClassiScan.py --comprehensive --max_images 50
echo python ClassiScan.py --comprehensive --fill --max_images 50
echo.
echo [MULTIPLE DATASET TYPES]
echo python ClassiScan.py --folders BarCode QRCode
echo python ClassiScan.py --folders BarCode QRCode --fill
echo python ClassiScan.py --folders BarCode QRCode --max_images 50
echo python ClassiScan.py --folders BarCode QRCode --fill --max_images 50
echo.
echo python ClassiScan.py --folders BarCode QRCode BarCode-QRCode
echo python ClassiScan.py --folders BarCode QRCode BarCode-QRCode --fill
echo python ClassiScan.py --folders BarCode QRCode BarCode-QRCode --max_images 50
echo python ClassiScan.py --folders BarCode QRCode BarCode-QRCode --fill --max_images 50
echo.
echo [SINGLE DATASET TYPES]
echo python ClassiScan.py --folders BarCode
echo python ClassiScan.py --folders BarCode --fill
echo python ClassiScan.py --folders BarCode --max_images 50
echo python ClassiScan.py --folders BarCode --fill --max_images 50
echo.
echo (Replace BarCode with QRCode or BarCode-QRCode for other single types)
echo.
echo [ADDITIONAL TESTING LIMITS]
echo python ClassiScan.py --max_images 10
echo python ClassiScan.py --max_images 10 --fill
echo python ClassiScan.py --folders BarCode --max_images 10
echo.
echo [HELP & INFORMATION]
echo python ClassiScan.py --help
echo.
echo ========================================
echo   COMMAND OPTIONS REFERENCE
echo ========================================
echo (no options)         = Process all datasets with border visualization
echo --comprehensive      = Enable detailed reporting and advanced analysis
echo --fill               = Use semi-transparent highlighting instead of borders
echo --folders [names]    = Process specific dataset folders only
echo --max_images [number] = Limit number of images processed
echo --help               = Show help and available options
echo.
echo ========================================
echo   MOST COMMON COMMANDS
echo ========================================
echo Standard Processing:    python ClassiScan.py
echo Comprehensive Analysis: python ClassiScan.py --comprehensive
echo Quick Test (50 images): python ClassiScan.py --max_images 50
echo BarCode Analysis:       python ClassiScan.py --folders BarCode
echo Custom Example:         python ClassiScan.py --comprehensive --fill --folders BarCode QRCode --max_images 100
echo.
echo ========================================
echo   READY TO USE - COPY ANY COMMAND ABOVE
echo ========================================
echo.
echo TIP: You can modify any command before running:
echo - Change --max_images 50 to --max_images 100 (or any number)
echo - Add --fill for semi-transparent highlighting
echo - Add --comprehensive for detailed analysis
echo - Mix and match any options as needed
echo.
echo Type 'exit' to close this terminal
echo ========================================
echo.
cmd /k
