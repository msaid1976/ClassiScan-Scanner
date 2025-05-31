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
python ClassiScan.py --folders BarCode QRCode BarCode-QRCode

# With additional options
python ClassiScan.py --folders BarCode --fill --max_images 50
```

## Quick Testing
```bash
# Ultra-fast testing
python ClassiScan.py --max_images 10
python ClassiScan.py --folders BarCode --max_images 5
```

## ⚙️ Command Options

| Option | Description |
|--------|-------------|
| *(no options)* | Process all datasets with border visualization |
| `--comprehensive` | Enable detailed reporting and performance tables |
| `--fill` | Use semi-transparent highlighting instead of borders |
| `--folders [names]` | Process specific dataset folders only |
| `--max_images [number]` | Limit number of images processed per folder |
| `--help` | Show all available options |

## 📊 Output Files

After processing, you'll find:
- **📁 Successfully Decoded Images/**: Processed images with highlighted codes
- **📁 Failed Decoded Images/**: Images where detection failed
- **📊 evaluation_results_YYYYMMDD.xlsx**: 
  - Sheet 1: Performance metrics (success rates, timing)
  - Sheet 2: All detected codes (folder, image, code data)
- **📈 Comprehensive reports** (when using `--comprehensive`)

## 💡 Pro Tips
- Start with `--max_images 10` for quick testing
- Use `--fill` for better visualization in presentations
- Add `--comprehensive` for research and detailed analysis
- Mix options: `--comprehensive --fill --folders BarCode --max_images 100`

---

## 🔧 Manual Installation

For manual setup or non-Windows systems:
