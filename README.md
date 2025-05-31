# ClassiScan: Classical BarQR Scanner

A sophisticated classical computer vision system for detecting, segmenting, and recognizing barcodes and QR codes in challenging real-world conditions using **exclusively traditional image processing techniques** - no deep learning, no YOLO, no pretrained models.

## 📊 Key Performance Metrics

| Metric | Performance |
|--------|-------------|
| **Overall Success Rate** | 81.9% (86.8% for mixed-content) |
| **Processing Speed** | 14.2-26.8ms per code |
| **False Positive Rate** | <0.6% across all categories |
| **Segmentation Accuracy** | Mean IoU 0.850 |
| **Supported Formats** | EAN-13/8, UPC-A, Code-128/39, QR codes |

## 📋 Table of Contents

* [Features](#features)
* [🚀 One-Click Installation & Setup (Recommended)](#one-click-installation--setup-recommended)
* [Manual Installation](#manual-installation)
* [Dataset](#dataset)
* [Usage & Commands](#usage--commands)
* [System Architecture](#system-architecture)
* [Performance Results](#performance-results)
* [Directory Structure](#directory-structure)
* [Technical Implementation](#technical-implementation)
* [Advanced Features](#advanced-features)
* [License](#license)

## ✨ Features

### 🎯 Multi-Pathway Detection Architecture
* **Edge-Based Detection**: Optimized Canny (40/120 thresholds) with morphological enhancement
* **Gradient-Based Detection**: Sobel operators with adaptive pattern recognition
* **Direct PyZBar Detection**: Fast path for high-quality images with silent error handling
* **Specialized QR Detection**: Grid-based search with finder pattern recognition
* **Multi-Scale Processing**: 0.7×, 1.0×, 1.3× scales for comprehensive size coverage

### 🔧 Advanced Preprocessing Pipeline
* **Adaptive Quality Assessment**: Blur detection (threshold 150) and glare analysis
* **CLAHE Enhancement**: Clip limit 2.5 with 6×6 grid for local contrast adaptation
* **Multi-Threshold Processing**: Block sizes [7, 11, 15, 19] for varying illumination
* **Bilateral Filtering**: Edge-preserving noise reduction with optimized parameters
* **Intelligent Path Selection**: Quality-based preprocessing complexity determination

### 🎨 Intelligent Visualization
* **Fill Mode**: Semi-transparent overlay (30% opacity) with border enhancement
* **Multi-Code Management**: Distinct HSV-based colors for simultaneous detection
* **Adaptive Text Display**: Font scaling based on code dimensions
* **Professional Output**: Content-based file naming with structured directories

### 📈 Comprehensive Evaluation Framework
* **Real-Time Metrics**: Precision, recall, F1-score calculation during processing
* **Multi-Table Analysis**: Detection, segmentation, recognition performance metrics
* **Excel Export**: Professional multi-sheet reports with timestamp integration
* **Category-Specific Assessment**: Barcode, QR code, and mixed-content analysis

---

# 🚀 One-Click Installation & Setup (Recommended)

> ## ⚡ **EASIEST WAY TO GET STARTED** ⚡
> ### Just double-click `install.bat` - Everything is automated!

## 🎯 What You Get Instantly:
- ✅ **Python 3.11 installed** (if needed)
- ✅ **Virtual environment created & activated**
- ✅ **All packages installed** from requirements.txt
- ✅ **ZBar library downloaded** (libzbar-64.dll)
- ✅ **Complete dataset downloaded** (332MB from Google Drive)
- ✅ **Dataset extracted** to proper folder structure
- ✅ **All imports tested** and verified
- ✅ **Ready-to-use terminal** with command examples
- ✅ **run.bat launcher** created for future use

## 🚀 Simple Steps:
1. **📥 Download** all project files to a folder
2. **🖱️ Double-click** `install.bat`
3. **⏳ Wait** for automatic setup (5-10 minutes)
4. **🎉 Start using** the opened terminal with pre-configured commands!

### 💻 After Installation:
The installer will open a terminal with **all commands ready to copy & paste**. Just pick any command and run it!

---

## 🔧 Manual Installation

For advanced users, developers, or non-Windows systems:

### Prerequisites
- Python 3.7+ (recommended: Python 3.11)
- Git (for cloning repository)

### Development Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/classical-barqr-scanner.git
cd classical-barqr-scanner

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# Linux/macOS:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### ZBar Library Installation

**Windows:**
- Download `libzbar-64.dll` from [PyZBar releases](https://github.com/NaturalHistoryMuseum/pyzbar/releases)
- Place it in your Python's `site-packages/pyzbar/` directory

**Linux:**
```bash
sudo apt-get install libzbar0
```

**macOS:**
```bash
brew install zbar
```

---

## 📊 Dataset

The system uses a comprehensive dataset with three categories:

### Dataset Structure:
```
Dataset/
├── BarCode/          # EAN-13, UPC-A, Code-128 barcodes
├── QRCode/           # QR codes with various content types
└── BarCode-QRCode/   # Mixed images with both types
```

### Dataset Download:
- **Automatic**: Using `install.bat` (recommended)
- **Manual**: Download from [Google Drive](https://drive.google.com/file/d/1h-I7kwS-VsWzydu3s-VNxb0cHIY9Cyd2/view) (332MB)
- **Extract**: Place in project root as `Dataset/` folder

---

# 📋 Usage & Commands

## 🎯 Most Common Commands

| Purpose | Command |
|---------|---------|
| **🔥 Quick Start** | `python ClassiScan.py` |
| **📊 Full Analysis** | `python ClassiScan.py --comprehensive` |
| **⚡ Fast Test** | `python ClassiScan.py --max_images 10` |
| **🎨 Visual Fill** | `python ClassiScan.py --fill` |
| **📦 Single Type** | `python ClassiScan.py --folders BarCode` |

## Standard Processing
```bash
# Basic processing with border visualization
python ClassiScan.py

# Semi-transparent fill highlighting
python ClassiScan.py --fill

# Limited images for faster testing
python ClassiScan.py --max_images 50
```

## Comprehensive Analysis
```bash
# Full analysis with detailed reporting
python ClassiScan.py --comprehensive

# Comprehensive with fill visualization
python ClassiScan.py --comprehensive --fill

# Comprehensive with limited images
python ClassiScan.py --comprehensive --max_images 50
```

## Dataset-Specific Processing
```bash
# Single dataset type
python ClassiScan.py --folders BarCode
python ClassiScan.py --folders QRCode
python ClassiScan.py --folders BarCode-QRCode

# Multiple dataset types
python ClassiScan.py --folders BarCode QRCode
python ClassiScan.py --folde# ClassiScan: Classical BarQR Scanner

A sophisticated classical computer vision system for detecting, segmenting, and recognizing barcodes and QR codes in challenging real-world conditions using **exclusively traditional image processing techniques** - no deep learning, no YOLO, no pretrained models.

## 📊 Key Performance Metrics

| Metric | Performance |
|--------|-------------|
| **Overall Success Rate** | 81.9% (86.8% for mixed-content) |
| **Processing Speed** | 14.2-26.8ms per code |
| **False Positive Rate** | <0.6% across all categories |
| **Segmentation Accuracy** | Mean IoU 0.850 |
| **Supported Formats** | EAN-13/8, UPC-A, Code-128/39, QR codes |

## 📋 Table of Contents

* [Features](#features)
* [One-Click Installation & Setup](#one-click-installation--setup)
* [Manual Installation](#manual-installation)
* [Usage](#usage)
* [System Architecture](#system-architecture)
* [Performance Results](#performance-results)
* [Directory Structure](#directory-structure)
* [Technical Implementation](#technical-implementation)
* [Advanced Features](#advanced-features)
* [License](#license)

## ✨ Features

### 🎯 Multi-Pathway Detection Architecture
* **Edge-Based Detection**: Optimized Canny (40/120 thresholds) with morphological enhancement
* **Gradient-Based Detection**: Sobel operators with adaptive pattern recognition
* **Direct PyZBar Detection**: Fast path for high-quality images with silent error handling
* **Specialized QR Detection**: Grid-based search with finder pattern recognition
* **Multi-Scale Processing**: 0.7×, 1.0×, 1.3× scales for comprehensive size coverage

### 🔧 Advanced Preprocessing Pipeline
* **Adaptive Quality Assessment**: Blur detection (threshold 150) and glare analysis
* **CLAHE Enhancement**: Clip limit 2.5 with 6×6 grid for local contrast adaptation
* **Multi-Threshold Processing**: Block sizes [7, 11, 15, 19] for varying illumination
* **Bilateral Filtering**: Edge-preserving noise reduction with optimized parameters
* **Intelligent Path Selection**: Quality-based preprocessing complexity determination

### 🎨 Intelligent Visualization
* **Fill Mode**: Semi-transparent overlay (30% opacity) with border enhancement
* **Multi-Code Management**: Distinct HSV-based colors for simultaneous detection
* **Adaptive Text Display**: Font scaling based on code dimensions
* **Professional Output**: Content-based file naming with structured directories

### 📈 Comprehensive Evaluation Framework
* **Real-Time Metrics**: Precision, recall, F1-score calculation during processing
* **Multi-Table Analysis**: Detection, segmentation, recognition performance metrics
* **Excel Export**: Professional multi-sheet reports with timestamp integration
* **Category-Specific Assessment**: Barcode, QR code, and mixed-content analysis

## 🚀 One-Click Installation & Setup

### Quick Start (Windows)

**Simply double-click `install.bat` and everything will be set up automatically!**

#### What install.bat Does:
- ✅ **Installs Python 3.11** (if not already installed)
- ✅ **Creates virtual environment** for isolated package management
- ✅ **Activates virtual environment** automatically
- ✅ **Installs all required packages** from requirements.txt
- ✅ **Downloads ZBar library** (libzbar-64.dll) for barcode recognition
- ✅ **Downloads complete dataset** (332MB) from Google Drive
- ✅ **Extracts dataset** to proper folder structure
- ✅ **Tests all imports** to ensure everything works
- ✅ **Creates run.bat launcher** with all necessary commands
- ✅ **Opens ready-to-use environment** with command examples

#### Installation Steps:
1. **Download** all project files to a folder
2. **Double-click** `install.bat` 
3. **Wait** for automatic setup to complete
4. **Use the opened terminal** with pre-configured commands

---

## 📋 Available Commands

After installation, use these commands in the opened terminal:

### Standard Processing
```bash
# Basic processing with border visualization
python ClassiScan.py

# Basic processing with semi-transparent fill
python ClassiScan.py --fill

# Process limited number of images (faster testing)
python ClassiScan.py --max_images 50
python ClassiScan.py --fill --max_images 50
```

### Comprehensive Analysis
```bash
# Full analysis with detailed reporting and performance tables
python ClassiScan.py --comprehensive

# Comprehensive analysis with fill visualization
python ClassiScan.py --comprehensive --fill

# Comprehensive analysis with limited images
python ClassiScan.py --comprehensive --max_images 50
python ClassiScan.py --comprehensive --fill --max_images 50
```

### Process Specific Dataset Types
```bash
# Process multiple dataset types
python ClassiScan.py --folders BarCode QRCode
python ClassiScan.py --folders BarCode QRCode --fill
python ClassiScan.py --folders BarCode QRCode --max_images 50
python ClassiScan.py --folders BarCode QRCode --fill --max_images 50

# Process all three dataset types
python ClassiScan.py --folders BarCode QRCode BarCode-QRCode
python ClassiScan.py --folders BarCode QRCode BarCode-QRCode --fill
python ClassiScan.py --folders BarCode QRCode BarCode-QRCode --max_images 50
python ClassiScan.py --folders BarCode QRCode BarCode-QRCode --fill --max_images 50

# Process single dataset type
python ClassiScan.py --folders BarCode
python ClassiScan.py --folders BarCode --fill
python ClassiScan.py --folders BarCode --max_images 50
python ClassiScan.py --folders BarCode --fill --max_images 50

# (Replace BarCode with QRCode or BarCode-QRCode for other single types)
```

### Quick Testing Commands
```bash
# Fast testing with limited images
python ClassiScan.py --max_images 10
python ClassiScan.py --max_images 10 --fill
python ClassiScan.py --folders BarCode --max_images 10
```

### Help & Information
```bash
# Show all available options
python ClassiScan.py --help
```

---

## 🎯 Most Common Commands

| Purpose | Command |
|---------|---------|
| **Standard Processing** | `python ClassiScan.py` |
| **Comprehensive Analysis** | `python ClassiScan.py --comprehensive` |
| **Quick Test (50 images)** | `python ClassiScan.py --max_images 50` |
| **BarCode Analysis Only** | `python ClassiScan.py --folders BarCode` |
| **Custom Example** | `python ClassiScan.py --comprehensive --fill --folders BarCode QRCode --max_images 100` |

---

## ⚙️ Command Options Reference

| Option | Description |
|--------|-------------|
| *(no options)* | Process all datasets with border visualization |
| `--comprehensive` | Enable detailed reporting and advanced analysis |
| `--fill` | Use semi-transparent highlighting instead of borders |
| `--folders [names]` | Process specific dataset folders only |
| `--max_images [number]` | Limit number of images processed |
| `--help` | Show help and available options |

---

## 💡 Tips & Customization

- **Mix and match options** as needed (e.g., `--comprehensive --fill --max_images 100`)
- **Change image limits** by modifying `--max_images` value
- **Add `--fill`** to any command for semi-transparent highlighting
- **Add `--comprehensive`** to any command for detailed analysis
- **Test with small numbers** first (e.g., `--max_images 10`)

---

## 📊 Output Files

After processing, you'll get:
- **Processed images** with detected codes highlighted
- **evaluation_results_YYYYMMDD.xlsx** with:
  - Sheet 1: Evaluation Results (success rates, processing times)
  - Sheet 2: Detected Codes (folder, image name, detected code)
- **Comprehensive analysis** (if using `--comprehensive`):
  - Detection performance tables
  - Method comparison analysis
  - Segmentation accuracy metrics
  - Recognition success rates

---

## 🔧 Manual Installation

For manual setup or non-Windows systems:
