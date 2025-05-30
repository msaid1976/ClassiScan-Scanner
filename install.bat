@echo off
setlocal enabledelayedexpansion

echo ========================================
echo   ClassiScan Installation Script
echo ========================================
echo.
echo This script will automatically:
echo - Install Python if not found
echo - Create a virtual environment
echo - Install all required dependencies
echo - Download and install ZBar library
echo - Download and extract dataset from Google Drive
echo ========================================
echo.

REM Store the current directory
set "SCRIPT_DIR=%CD%"
echo Script directory: !SCRIPT_DIR!

REM Check if Python is installed
echo [1/8] Checking Python installation...
python --version >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo Python not found. Installing Python automatically...
    goto :install_python
) else (
    for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
    echo Found Python !PYTHON_VERSION!
    
    REM Check if Python version is 3.7+
    for /f "tokens=1,2 delims=." %%a in ("!PYTHON_VERSION!") do (
        set MAJOR=%%a
        set MINOR=%%b
    )
    
    if !MAJOR! LSS 3 (
        echo ERROR: Python !PYTHON_VERSION! is too old. Python 3.7+ required.
        goto :install_python
    )
    if !MAJOR! EQU 3 if !MINOR! LSS 7 (
        echo ERROR: Python !PYTHON_VERSION! is too old. Python 3.7+ required.
        goto :install_python
    )
    
    echo Python version is compatible.
    goto :setup_venv
)

:install_python
echo.
echo [2/8] Installing Python 3.11...
echo Downloading Python installer...

REM Create temp directory
if not exist "temp_install" mkdir temp_install

REM Download Python installer
echo Downloading Python 3.11.9 installer...
curl -L -o temp_install\python-installer.exe https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe

if !ERRORLEVEL! neq 0 (
    echo WARNING: curl failed. Trying PowerShell...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe' -OutFile 'temp_install\python-installer.exe'"
)

if not exist "temp_install\python-installer.exe" (
    echo ERROR: Could not download Python installer.
    echo Please manually download and install Python 3.7+ from: https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation.
    pause
    exit /b 1
)

echo Installing Python... (This may take a few minutes)
echo IMPORTANT: Python will be installed with the following options:
echo - Add Python to PATH: YES
echo - Install for all users: YES
echo - Include pip: YES

REM Install Python silently with required options
temp_install\python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0

echo Waiting for Python installation to complete...
timeout /t 10 /nobreak >nul

REM Refresh PATH environment variable
call :refresh_path

REM Verify Python installation
python --version >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo ERROR: Python installation failed or PATH not updated.
    echo Please restart your computer and run this script again.
    echo Or install Python manually from: https://www.python.org/downloads/
    pause
    exit /b 1
)

echo Python installed successfully!
for /f "tokens=2" %%i in ('python --version 2^>^&1') do echo Installed version: %%i

:setup_venv
echo.
echo [3/8] Setting up virtual environment...

REM Ensure we're in the script directory
cd /d "!SCRIPT_DIR!"
echo Working from directory: !CD!

REM Remove existing venv if it exists
if exist "venv" (
    echo Virtual environment already exists. Skipping creation...
    goto :activate_venv
)

REM Create new virtual environment
echo Creating virtual environment...
python -m venv venv

if !ERRORLEVEL! neq 0 (
    echo ERROR: Failed to create virtual environment.
    echo Your Python installation might be incomplete.
    pause
    exit /b 1
)

echo Virtual environment created successfully!

:activate_venv
echo Virtual environment path: !SCRIPT_DIR!\venv

echo.
echo [4/8] Upgrading pip and installing requirements...

REM Stay in main directory and activate virtual environment
echo Staying in main directory: !SCRIPT_DIR!
cd /d "!SCRIPT_DIR!"

echo Activating virtual environment...
call "venv\Scripts\activate.bat"

REM Verify activation worked
echo Verifying virtual environment activation...
where python
echo Python location after activation:
python -c "import sys; print(sys.executable)"
echo Virtual environment activated: 
python -c "import sys; print('YES' if 'venv' in sys.executable else 'NO')"

REM Upgrade pip first
echo Upgrading pip...
python -m pip install --upgrade pip

REM Install requirements including gdown
echo Installing Python packages...
if exist "requirements.txt" (
    echo Found requirements.txt, installing packages...
    pip install -r requirements.txt
    if !ERRORLEVEL! neq 0 (
        echo ERROR: Failed to install requirements.
        echo Please check requirements.txt file exists and is valid.
        pause
        exit /b 1
    )
) else (
    echo WARNING: requirements.txt not found. Installing basic packages...
    pip install opencv-python numpy pandas pyzbar openpyxl tqdm kagglehub
    if !ERRORLEVEL! neq 0 (
        echo ERROR: Failed to install basic packages.
        pause
        exit /b 1
    )
)

REM Install gdown for Google Drive downloads
pip install gdown >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo WARNING: Failed to install download package. Manual download will be required.
)

echo.
echo [5/8] Installing ZBar library (libzbar-64.dll)...

REM Get virtual environment Python path
for /f "tokens=*" %%i in ('python -c "import sys; print(sys.executable)"') do set VENV_PYTHON=%%i
for %%i in ("!VENV_PYTHON!") do set VENV_DIR=%%~dpi

echo Virtual environment Python: !VENV_DIR!

REM Install DLL to virtual environment
call :install_dll "!VENV_DIR!"

echo.
echo [6/8] Checking dataset...

REM Check if dataset already exists and is complete
call :check_dataset_exists
if !DATASET_EXISTS! equ 1 (
    echo [INFO] Dataset already exists and appears complete. Skipping download.
    goto :test_imports
)

echo [7/8] Downloading and extracting dataset...

echo Downloading dataset from Google Drive...
echo.

REM Create temp directory for download
if not exist "temp_dataset" mkdir temp_dataset

echo [STEP 1/4] Attempting to download dataset...
echo Progress: [##########] 0%% - Initializing download...

REM Try gdown first (most reliable for Google Drive)
python -c "import gdown" >nul 2>&1
if !ERRORLEVEL! equ 0 (
    echo Progress: [###-------] 30%% - Using gdown downloader...
    python -c "import gdown; gdown.download('https://drive.google.com/uc?id=1h-I7kwS-VsWzydu3s-VNxb0cHIY9Cyd2', 'temp_dataset/dataset.zip', quiet=True)" >nul 2>&1
    set DOWNLOAD_SUCCESS=!ERRORLEVEL!
    if !DOWNLOAD_SUCCESS! equ 0 (
        echo Progress: [##########] 100%% - Download completed successfully!
    )
) else (
    echo Progress: [###-------] 30%% - gdown not available, trying alternative...
    set DOWNLOAD_SUCCESS=1
)

REM If gdown failed, try curl
if !DOWNLOAD_SUCCESS! neq 0 (
    echo Progress: [#####-----] 50%% - Trying direct download...
    curl -L -o temp_dataset\dataset.zip "https://drive.google.com/uc?export=download&id=1h-I7kwS-VsWzydu3s-VNxb0cHIY9Cyd2" >nul 2>&1
    set DOWNLOAD_SUCCESS=!ERRORLEVEL!
    if !DOWNLOAD_SUCCESS! equ 0 (
        echo Progress: [##########] 100%% - Download completed!
    )
)

REM Check if we actually got the file
if exist "temp_dataset\dataset.zip" (
    for %%I in (temp_dataset\dataset.zip) do set FILE_SIZE=%%~zI
    set /a FILE_SIZE_MB=!FILE_SIZE!/1048576
    echo.
    echo Downloaded file: !FILE_SIZE! bytes ^(!FILE_SIZE_MB! MB^)
    
    REM If file is too small, it's probably an error page
    if !FILE_SIZE! LSS 10000000 (
        echo File is too small - likely a Google Drive error page.
        del temp_dataset\dataset.zip >nul 2>&1
        set DOWNLOAD_SUCCESS=1
    ) else (
        echo File size looks reasonable. Download successful!
        set DOWNLOAD_SUCCESS=0
    )
) else (
    set DOWNLOAD_SUCCESS=1
)

REM If automatic download failed, provide manual instructions
if !DOWNLOAD_SUCCESS! neq 0 (
    echo.
    echo ==========================================
    echo   AUTOMATIC DOWNLOAD FAILED
    echo ==========================================
    echo.
    echo Google Drive restricts automatic downloads of large files.
    echo Manual download is required.
    echo.
    echo STEP-BY-STEP MANUAL DOWNLOAD:
    echo.
    echo 1. Open this link in your web browser:
    echo    https://drive.google.com/file/d/1h-I7kwS-VsWzydu3s-VNxb0cHIY9Cyd2/view?usp=sharing
    echo.
    echo 2. Click the Download button ^(down arrow icon^)
    echo.
    echo 3. You will see a warning:
    echo    "Dataset.zip ^(332.1MB^) exceeds the maximum file size 
    echo     that Google can scan. This file might harm your computer..."
    echo.
    echo 4. Click "Download anyway" to continue
    echo.
    echo 5. Save the file to one of these locations:
    echo    - Recommended: !SCRIPT_DIR!\temp_dataset\dataset.zip
    echo    - Alternative: Your Downloads folder ^(we'll find it^)
    echo.
    echo 6. The file should be approximately 332 MB
    echo.
    echo ==========================================
    echo.
    echo Press any key when download is complete...
    pause
    
    REM Check for the file in expected locations
    call :find_downloaded_file
    
    if !DOWNLOAD_SUCCESS! neq 0 (
        echo.
        echo Cannot find dataset.zip. Installation will continue without dataset.
        echo You can download and extract it manually later.
        goto :test_imports
    )
)

echo.
echo [STEP 2/4] Extracting dataset...
echo Removing any existing Dataset folder...
if exist "Dataset" rmdir /s /q Dataset

echo Extracting dataset.zip...
powershell -Command "Expand-Archive -Path 'temp_dataset\dataset.zip' -DestinationPath '.' -Force"

if !ERRORLEVEL! neq 0 (
    echo ERROR: Failed to extract dataset.
    echo The ZIP file might be corrupted.
    echo You can try extracting manually using Windows Explorer.
    goto :test_imports
)

echo Extraction completed!

echo.
echo [STEP 3/4] Verifying dataset structure...
call :verify_dataset_structure

echo.
echo [STEP 4/4] Cleaning up...
if exist "temp_dataset" rmdir /s /q temp_dataset
echo Cleanup completed!

:test_imports
echo.
echo [8/8] Testing package imports...

REM Test all imports with proper error handling
echo Testing imports in virtual environment...
set IMPORT_FAILED=0

python -c "import cv2; print('[OK] OpenCV version:', cv2.__version__)" 2>nul
if !ERRORLEVEL! neq 0 (
    echo [FAIL] OpenCV import failed
    set IMPORT_FAILED=1
)

python -c "import numpy; print('[OK] NumPy version:', numpy.__version__)" 2>nul
if !ERRORLEVEL! neq 0 (
    echo [FAIL] NumPy import failed
    set IMPORT_FAILED=1
)

python -c "import pandas; print('[OK] Pandas version:', pandas.__version__)" 2>nul
if !ERRORLEVEL! neq 0 (
    echo [FAIL] Pandas import failed
    set IMPORT_FAILED=1
)

python -c "import pyzbar; print('[OK] PyZBar imported successfully')" 2>nul
if !ERRORLEVEL! neq 0 (
    echo [FAIL] PyZBar import failed
    set IMPORT_FAILED=1
)

python -c "import openpyxl; print('[OK] OpenPyXL version:', openpyxl.__version__)" 2>nul
if !ERRORLEVEL! neq 0 (
    echo [FAIL] OpenPyXL import failed
    set IMPORT_FAILED=1
)

python -c "import tqdm; print('[OK] tqdm version:', tqdm.__version__)" 2>nul
if !ERRORLEVEL! neq 0 (
    echo [FAIL] tqdm import failed
    set IMPORT_FAILED=1
)

python -c "import gdown; print('[OK] gdown version:', gdown.__version__)" 2>nul
if !ERRORLEVEL! neq 0 (
    echo [INFO] gdown not available (not critical)
)

if !IMPORT_FAILED! neq 0 (
    echo WARNING: Some imports failed. Installation may be incomplete.
    echo You may need to install missing packages manually.
    pause
) else (
    echo [SUCCESS] All critical packages imported successfully!
)

echo.
echo Testing ClassiScan availability...
if exist "ClassiScan.py" (
    echo Found ClassiScan.py, testing...
    python ClassiScan.py --help >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        echo [SUCCESS] ClassiScan is ready to use!
    ) else (
        echo WARNING: ClassiScan.py found but may have issues.
        echo You can still try to run it from the menu.
    )
) else (
    echo NOTE: ClassiScan.py not found in current directory.
    echo Please ensure ClassiScan.py is in the same folder as this script.
)

REM Cleanup
if exist "temp_install" rmdir /s /q temp_install >nul 2>&1
if exist "temp_libzbar" rmdir /s /q temp_libzbar >nul 2>&1

echo.
echo ========================================
echo   Installation Summary
echo ========================================
echo.
echo Virtual Environment: ACTIVE
echo Script Directory: !SCRIPT_DIR!
echo Python Location: 
python -c "import sys; print(sys.executable)"
echo.
echo Dataset Status:
call :display_dataset_status
echo.

echo ========================================
echo   Creating run.bat launcher...
echo ========================================

REM Create run.bat file
(
echo @echo off
echo setlocal enabledelayedexpansion
echo.
echo title ClassiScan Environment
echo cd /d "%SCRIPT_DIR%"
echo call "venv\Scripts\activate.bat"
echo cls
echo echo ========================================
echo echo   ClassiScan Application Environment
echo echo ========================================
echo echo Application Path: %SCRIPT_DIR%
echo echo Virtual Environment: ACTIVE
echo echo.
echo echo Dataset Status:
echo if exist "Dataset" ^(
echo   echo [OK] Dataset folder exists
echo   if exist "Dataset\BarCode" echo [OK] BarCode folder exists
echo   if exist "Dataset\QRCode" echo [OK] QRCode folder exists  
echo   if exist "Dataset\BarCode-QRCode" echo [OK] BarCode-QRCode folder exists
echo ^) else ^(
echo   echo [MISSING] Dataset folder not found
echo ^)
echo echo.
echo echo ========================================
echo echo   CLASSISCAN COMMANDS - COPY ^& PASTE
echo echo ========================================
echo echo.
echo echo [STANDARD PROCESSING]
echo echo python ClassiScan.py
echo echo python ClassiScan.py --fill
echo echo python ClassiScan.py --max_images 50
echo echo python ClassiScan.py --fill --max_images 50
echo echo.
echo echo [COMPREHENSIVE ANALYSIS]
echo echo python ClassiScan.py --comprehensive
echo echo python ClassiScan.py --comprehensive --fill
echo echo python ClassiScan.py --comprehensive --max_images 50
echo echo python ClassiScan.py --comprehensive --fill --max_images 50
echo echo.
echo echo [MULTIPLE DATASET TYPES]
echo echo python ClassiScan.py --folders BarCode QRCode
echo echo python ClassiScan.py --folders BarCode QRCode --fill
echo echo python ClassiScan.py --folders BarCode QRCode --max_images 50
echo echo python ClassiScan.py --folders BarCode QRCode --fill --max_images 50
echo echo.
echo echo python ClassiScan.py --folders BarCode QRCode BarCode-QRCode
echo echo python ClassiScan.py --folders BarCode QRCode BarCode-QRCode --fill
echo echo python ClassiScan.py --folders BarCode QRCode BarCode-QRCode --max_images 50
echo echo python ClassiScan.py --folders BarCode QRCode BarCode-QRCode --fill --max_images 50
echo echo.
echo echo [SINGLE DATASET TYPES]
echo echo python ClassiScan.py --folders BarCode
echo echo python ClassiScan.py --folders BarCode --fill
echo echo python ClassiScan.py --folders BarCode --max_images 50
echo echo python ClassiScan.py --folders BarCode --fill --max_images 50
echo echo.
echo echo ^(Replace BarCode with QRCode or BarCode-QRCode for other single types^)
echo echo.
echo echo [ADDITIONAL TESTING LIMITS]
echo echo python ClassiScan.py --max_images 10
echo echo python ClassiScan.py --max_images 10 --fill
echo echo python ClassiScan.py --folders BarCode --max_images 10
echo echo.
echo echo [HELP ^& INFORMATION]
echo echo python ClassiScan.py --help
echo echo.
echo echo ========================================
echo echo   COMMAND OPTIONS REFERENCE
echo echo ========================================
echo echo ^(no options^)         = Process all datasets with border visualization
echo echo --comprehensive      = Enable detailed reporting and advanced analysis
echo echo --fill               = Use semi-transparent highlighting instead of borders
echo echo --folders [names]    = Process specific dataset folders only
echo echo --max_images [number] = Limit number of images processed
echo echo --help               = Show help and available options
echo echo.
echo echo ========================================
echo echo   MOST COMMON COMMANDS
echo echo ========================================
echo echo Standard Processing:    python ClassiScan.py
echo echo Comprehensive Analysis: python ClassiScan.py --comprehensive
echo echo Quick Test ^(50 images^): python ClassiScan.py --max_images 50
echo echo BarCode Analysis:       python ClassiScan.py --folders BarCode
echo echo Custom Example:         python ClassiScan.py --comprehensive --fill --folders BarCode QRCode --max_images 100
echo echo.
echo echo ========================================
echo echo   READY TO USE - COPY ANY COMMAND ABOVE
echo echo ========================================
echo echo.
echo echo TIP: You can modify any command before running:
echo echo - Change --max_images 50 to --max_images 100 ^(or any number^)
echo echo - Add --fill for semi-transparent highlighting
echo echo - Add --comprehensive for detailed analysis
echo echo - Mix and match any options as needed
echo echo.
echo echo Type 'exit' to close this terminal
echo echo ========================================
echo echo.
echo cmd /k
) > run.bat

echo [SUCCESS] run.bat created successfully!
echo.
echo Opening ClassiScan environment in 3 seconds...
timeout /t 3 /nobreak >nul

start "ClassiScan Application" cmd /c run.bat

echo.
echo Installation complete! ClassiScan environment is opening.
echo You can close this installation window.
echo.
echo Press any key to exit...
pause >nul

goto :eof

REM Function to find downloaded file in common locations
:find_downloaded_file
echo.
echo Searching for downloaded dataset.zip...

REM Check target location first
if exist "temp_dataset\dataset.zip" (
    echo [FOUND] dataset.zip in correct location
    set DOWNLOAD_SUCCESS=0
    goto :eof
)

REM Check Downloads folder
if exist "%USERPROFILE%\Downloads\dataset.zip" (
    echo [FOUND] dataset.zip in Downloads folder
    echo Moving to correct location...
    move "%USERPROFILE%\Downloads\dataset.zip" "temp_dataset\dataset.zip" >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        echo File moved successfully!
        set DOWNLOAD_SUCCESS=0
    ) else (
        echo Failed to move file. Please move manually.
        set DOWNLOAD_SUCCESS=1
    )
    goto :eof
)

REM Check for Dataset.zip (capital D)
if exist "%USERPROFILE%\Downloads\Dataset.zip" (
    echo [FOUND] Dataset.zip in Downloads folder
    echo Moving to correct location...
    move "%USERPROFILE%\Downloads\Dataset.zip" "temp_dataset\dataset.zip" >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        echo File moved successfully!
        set DOWNLOAD_SUCCESS=0
    ) else (
        echo Failed to move file. Please move manually.
        set DOWNLOAD_SUCCESS=1
    )
    goto :eof
)

echo [NOT FOUND] dataset.zip not found in expected locations
echo Checked:
echo - !SCRIPT_DIR!\temp_dataset\dataset.zip
echo - %USERPROFILE%\Downloads\dataset.zip
echo - %USERPROFILE%\Downloads\Dataset.zip
set DOWNLOAD_SUCCESS=1
goto :eof

REM Function to check if dataset exists and is complete
:check_dataset_exists
set DATASET_EXISTS=0
if exist "Dataset" (
    if exist "Dataset\BarCode" (
        if exist "Dataset\QRCode" (
            if exist "Dataset\BarCode-QRCode" (
                REM Check if folders have content
                dir /b "Dataset\BarCode\*.jpg" >nul 2>&1 || dir /b "Dataset\BarCode\*.png" >nul 2>&1 || dir /b "Dataset\BarCode\*.jpeg" >nul 2>&1
                if !ERRORLEVEL! equ 0 (
                    dir /b "Dataset\QRCode\*.jpg" >nul 2>&1 || dir /b "Dataset\QRCode\*.png" >nul 2>&1 || dir /b "Dataset\QRCode\*.jpeg" >nul 2>&1
                    if !ERRORLEVEL! equ 0 (
                        dir /b "Dataset\BarCode-QRCode\*.jpg" >nul 2>&1 || dir /b "Dataset\BarCode-QRCode\*.png" >nul 2>&1 || dir /b "Dataset\BarCode-QRCode\*.jpeg" >nul 2>&1
                        if !ERRORLEVEL! equ 0 (
                            set DATASET_EXISTS=1
                        )
                    )
                )
            )
        )
    )
)
goto :eof

REM Function to verify dataset structure
:verify_dataset_structure
echo Checking dataset folder structure...

if not exist "Dataset" (
    echo [ERROR] Dataset folder not found after extraction!
    goto :eof
)

echo [OK] Dataset folder exists

REM Check subfolders and count files
if exist "Dataset\BarCode" (
    for /f %%i in ('dir /b "Dataset\BarCode\*.jpg" "Dataset\BarCode\*.png" "Dataset\BarCode\*.jpeg" 2^>nul ^| find /c /v ""') do set BARCODE_COUNT=%%i
    if !BARCODE_COUNT! gtr 0 (
        echo [OK] BarCode folder: !BARCODE_COUNT! images
    ) else (
        echo [WARNING] BarCode folder is empty
    )
) else (
    echo [ERROR] BarCode folder missing
)

if exist "Dataset\QRCode" (
    for /f %%i in ('dir /b "Dataset\QRCode\*.jpg" "Dataset\QRCode\*.png" "Dataset\QRCode\*.jpeg" 2^>nul ^| find /c /v ""') do set QRCODE_COUNT=%%i
    if !QRCODE_COUNT! gtr 0 (
        echo [OK] QRCode folder: !QRCODE_COUNT! images
    ) else (
        echo [WARNING] QRCode folder is empty
    )
) else (
    echo [ERROR] QRCode folder missing
)

if exist "Dataset\BarCode-QRCode" (
    for /f %%i in ('dir /b "Dataset\BarCode-QRCode\*.jpg" "Dataset\BarCode-QRCode\*.png" "Dataset\BarCode-QRCode\*.jpeg" 2^>nul ^| find /c /v ""') do set MIXED_COUNT=%%i
    if !MIXED_COUNT! gtr 0 (
        echo [OK] BarCode-QRCode folder: !MIXED_COUNT! images
    ) else (
        echo [WARNING] BarCode-QRCode folder is empty
    )
) else (
    echo [ERROR] BarCode-QRCode folder missing
)

if defined BARCODE_COUNT if defined QRCODE_COUNT if defined MIXED_COUNT (
    set /a TOTAL_IMAGES=!BARCODE_COUNT!+!QRCODE_COUNT!+!MIXED_COUNT!
    echo.
    echo [SUCCESS] Dataset structure verified!
    echo Total images: !TOTAL_IMAGES!
)
goto :eof

REM Function to display dataset status
:display_dataset_status
if exist "Dataset" (
    echo [OK] Dataset folder exists
    if exist "Dataset\BarCode" (
        for /f %%i in ('dir /b "Dataset\BarCode\*.jpg" "Dataset\BarCode\*.png" "Dataset\BarCode\*.jpeg" 2^>nul ^| find /c /v ""') do echo [OK] BarCode: %%i images
    ) else (
        echo [MISSING] BarCode folder
    )
    if exist "Dataset\QRCode" (
        for /f %%i in ('dir /b "Dataset\QRCode\*.jpg" "Dataset\QRCode\*.png" "Dataset\QRCode\*.jpeg" 2^>nul ^| find /c /v ""') do echo [OK] QRCode: %%i images
    ) else (
        echo [MISSING] QRCode folder
    )
    if exist "Dataset\BarCode-QRCode" (
        for /f %%i in ('dir /b "Dataset\BarCode-QRCode\*.jpg" "Dataset\BarCode-QRCode\*.png" "Dataset\BarCode-QRCode\*.jpeg" 2^>nul ^| find /c /v ""') do echo [OK] BarCode-QRCode: %%i images
    ) else (
        echo [MISSING] BarCode-QRCode folder
    )
) else (
    echo [MISSING] Dataset folder not found
)
goto :eof

:install_dll
set TARGET_PATH=%~1\Lib\site-packages\pyzbar
if not exist "!TARGET_PATH!" (
    echo PyZBar package directory not found in !TARGET_PATH!
    echo This is normal if PyZBar installation failed.
    goto :eof
)

if exist "!TARGET_PATH!\libzbar-64.dll" (
    echo [OK] libzbar-64.dll already exists in !TARGET_PATH!
    goto :eof
)

echo Downloading libzbar-64.dll for virtual environment...
if not exist "temp_libzbar" mkdir temp_libzbar

echo Trying to download with curl...
curl -L -o temp_libzbar\libzbar-64.dll https://github.com/NaturalHistoryMuseum/pyzbar/releases/download/v0.1.8/libzbar-64.dll

if !ERRORLEVEL! neq 0 (
    echo WARNING: curl failed. Trying PowerShell...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/NaturalHistoryMuseum/pyzbar/releases/download/v0.1.8/libzbar-64.dll' -OutFile 'temp_libzbar\libzbar-64.dll'"
)

if exist "temp_libzbar\libzbar-64.dll" (
    copy "temp_libzbar\libzbar-64.dll" "!TARGET_PATH!\" >nul
    if !ERRORLEVEL! equ 0 (
        echo [SUCCESS] Successfully installed libzbar-64.dll to virtual environment
    ) else (
        echo ERROR: Failed to copy libzbar-64.dll to target directory
    )
) else (
    echo ERROR: Could not download libzbar-64.dll
    echo Please download manually from: https://github.com/NaturalHistoryMuseum/pyzbar/releases
    echo And place it in: !TARGET_PATH!
)
goto :eof

:refresh_path
REM Refresh PATH environment variable
for /f "skip=2 tokens=3*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH 2^>nul') do set SYS_PATH=%%a %%b
for /f "skip=2 tokens=3*" %%a in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set USER_PATH=%%a %%b
if defined SYS_PATH if defined USER_PATH (
    set "PATH=!SYS_PATH!;!USER_PATH!"
) else if defined SYS_PATH (
    set "PATH=!SYS_PATH!"
) else if defined USER_PATH (
    set "PATH=!USER_PATH!"
)
goto :eof