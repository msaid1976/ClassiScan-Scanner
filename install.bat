@echo off
setlocal enabledelayedexpansion

REM Add error handling to prevent crashes
if "%~1"=="ERRORHANDLER" goto :error_handler
if not defined CMDCMDLINE set CMDCMDLINE=%CMDCMDLINE%
echo %CMDCMDLINE% | find /i "%~0" >nul
if %ERRORLEVEL% neq 0 (
    cmd /k "%~f0" ERRORHANDLER
    exit /b
)

:error_handler

echo ========================================
echo   ClassiScan Installation Script
echo ========================================
echo.
echo This script will automatically:
echo - Install Python if not found
echo - Create a virtual environment
echo - Install all required dependencies
echo - Download and install ZBar library
echo - Download and extract dataset from stable server
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

REM Install requirements including requests
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
    pip install opencv-python numpy pandas pyzbar openpyxl tqdm requests
    if !ERRORLEVEL! neq 0 (
        echo ERROR: Failed to install basic packages.
        pause
        exit /b 1
    )
)

REM Install additional download packages
pip install requests urllib3 >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo WARNING: Failed to install additional download packages.
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

echo Downloading dataset from stable server...
echo Source: http://58.26.41.115:7698/XBRL/Versions/dataset.zip
echo.

REM Create temp directory for download
if not exist "temp_dataset" mkdir temp_dataset

echo Downloading dataset...
curl -L -o temp_dataset\dataset.zip "http://58.26.41.115:7698/XBRL/Versions/dataset.zip"

if !ERRORLEVEL! neq 0 (
    echo ERROR: Download failed. Please check your internet connection.
    echo You can manually download from: http://58.26.41.115:7698/XBRL/Versions/dataset.zip
    echo Save it as: !SCRIPT_DIR!\temp_dataset\dataset.zip
    echo Then re-run this script.
    pause
    goto :test_imports
)

REM Verify download
if not exist "temp_dataset\dataset.zip" (
    echo ERROR: Dataset file not found after download.
    goto :test_imports
)

echo Download completed successfully!
echo.

echo Extracting dataset using Python...
echo Removing any existing Dataset folder...
if exist "Dataset" rmdir /s /q Dataset

echo Running Python extraction...
python -c "import zipfile, sys, os; zip_path = 'temp_dataset/dataset.zip'; print(f'Checking ZIP file: {zip_path}'); print(f'ZIP exists: {os.path.exists(zip_path)}'); print(f'ZIP size: {os.path.getsize(zip_path) if os.path.exists(zip_path) else 0} bytes'); zip_ref = zipfile.ZipFile(zip_path, 'r'); files = zip_ref.namelist(); print(f'ZIP contains {len(files)} items'); print('First 5 items:'); [print(f'  {f}') for f in files[:5]]; print('Extracting...'); zip_ref.extractall('.'); zip_ref.close(); print('Extraction completed'); print(f'Dataset folder exists: {os.path.exists(\"Dataset\")}'); sys.exit(0)"

if !ERRORLEVEL! neq 0 (
    echo Python extraction failed. Trying PowerShell...
    powershell -Command "Expand-Archive -Path 'temp_dataset\dataset.zip' -DestinationPath '.' -Force"
    
    if !ERRORLEVEL! neq 0 (
        echo Both extraction methods failed.
        echo Please extract manually: Right-click temp_dataset\dataset.zip and select "Extract All"
        pause
    )
)

echo.
echo Checking extraction results...
if exist "Dataset" (
    echo SUCCESS: Dataset folder found!
) else (
    echo WARNING: Dataset folder not found
)

echo Extraction completed!

echo.
echo Verifying dataset structure...
call :verify_dataset_structure

echo.
echo Cleaning up...
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

python -c "import requests; print('[OK] requests version:', requests.__version__)" 2>nul
if !ERRORLEVEL! neq 0 (
    echo [INFO] requests not available (not critical)
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

REM Function to verify download file size and integrity
:verify_download_size
set DOWNLOAD_VALID=0
if exist "temp_dataset\dataset.zip" (
    for %%I in (temp_dataset\dataset.zip) do (
        set FILE_SIZE=%%~zI
        if defined FILE_SIZE (
            set /a FILE_SIZE_MB=!FILE_SIZE!/1048576
            echo.
            echo Downloaded file: !FILE_SIZE! bytes ^(!FILE_SIZE_MB! MB^)
            
            REM Check if file size is reasonable (at least 1MB)
            if !FILE_SIZE! geq 1048576 (
                echo File size looks valid. Download successful!
                set DOWNLOAD_VALID=1
            ) else (
                echo File is too small - likely an error or incomplete download.
                del temp_dataset\dataset.zip >nul 2>&1
                set DOWNLOAD_VALID=0
            )
        ) else (
            echo ERROR: Could not determine file size
            set DOWNLOAD_VALID=0
        )
    )
) else (
    echo ERROR: Downloaded file does not exist
    set DOWNLOAD_VALID=0
)
goto :eof

REM Function to check if dataset exists and is complete
:check_dataset_exists
set DATASET_EXISTS=0
echo Checking for existing dataset...

if not exist "Dataset" (
    echo Dataset folder not found
    goto :eof
)

if not exist "Dataset\BarCode" (
    echo BarCode folder not found
    goto :eof
)

if not exist "Dataset\QRCode" (
    echo QRCode folder not found
    goto :eof
)

if not exist "Dataset\BarCode-QRCode" (
    echo BarCode-QRCode folder not found
    goto :eof
)

REM Simple existence check without complex counting
dir "Dataset\BarCode\*.*" >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo BarCode folder is empty
    goto :eof
)

dir "Dataset\QRCode\*.*" >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo QRCode folder is empty
    goto :eof
)

dir "Dataset\BarCode-QRCode\*.*" >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo BarCode-QRCode folder is empty
    goto :eof
)

echo Dataset appears complete
set DATASET_EXISTS=1
goto :eof

REM Function to verify dataset structure
:verify_dataset_structure
echo Checking dataset folder structure...

if not exist "Dataset" (
    echo [ERROR] Dataset folder not found after extraction!
    goto :eof
)

echo [OK] Dataset folder exists

REM Simple folder checks without complex counting
if exist "Dataset\BarCode" (
    echo [OK] BarCode folder exists
    REM Simple file check without counting
    dir "Dataset\BarCode\*.jpg" >nul 2>&1 && echo [OK] Found JPG files in BarCode folder
    dir "Dataset\BarCode\*.png" >nul 2>&1 && echo [OK] Found PNG files in BarCode folder
    dir "Dataset\BarCode\*.jpeg" >nul 2>&1 && echo [OK] Found JPEG files in BarCode folder
) else (
    echo [ERROR] BarCode folder missing
)

if exist "Dataset\QRCode" (
    echo [OK] QRCode folder exists
    REM Simple file check without counting
    dir "Dataset\QRCode\*.jpg" >nul 2>&1 && echo [OK] Found JPG files in QRCode folder
    dir "Dataset\QRCode\*.png" >nul 2>&1 && echo [OK] Found PNG files in QRCode folder
    dir "Dataset\QRCode\*.jpeg" >nul 2>&1 && echo [OK] Found JPEG files in QRCode folder
) else (
    echo [ERROR] QRCode folder missing
)

if exist "Dataset\BarCode-QRCode" (
    echo [OK] BarCode-QRCode folder exists
    REM Simple file check without counting
    dir "Dataset\BarCode-QRCode\*.jpg" >nul 2>&1 && echo [OK] Found JPG files in BarCode-QRCode folder
    dir "Dataset\BarCode-QRCode\*.png" >nul 2>&1 && echo [OK] Found PNG files in BarCode-QRCode folder
    dir "Dataset\BarCode-QRCode\*.jpeg" >nul 2>&1 && echo [OK] Found JPEG files in BarCode-QRCode folder
) else (
    echo [ERROR] BarCode-QRCode folder missing
)

echo.
echo [SUCCESS] Dataset structure check completed!
echo Note: File counting skipped to prevent crashes - use Windows Explorer to see exact counts
echo.
goto :eof

REM Function to display dataset status
:display_dataset_status
if exist "Dataset" (
    echo [OK] Dataset folder exists
    
    if exist "Dataset\BarCode" (
        echo [OK] BarCode folder exists
    ) else (
        echo [MISSING] BarCode folder
    )
    
    if exist "Dataset\QRCode" (
        echo [OK] QRCode folder exists
    ) else (
        echo [MISSING] QRCode folder
    )
    
    if exist "Dataset\BarCode-QRCode" (
        echo [OK] BarCode-QRCode folder exists
    ) else (
        echo [MISSING] BarCode-QRCode folder
    )
    
    echo [INFO] Image counting disabled to prevent crashes
    echo [INFO] Use Windows Explorer to view image counts
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