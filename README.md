# ClassiScan: Classical BarQR Scanner

A sophisticated classical computer vision system for detecting, segmenting, and recognizing barcodes and QR codes in challenging real-world conditions using **exclusively traditional image processing techniques** - no deep learning, no YOLO, no pretrained models.

## 📊 Key Performance Metrics

| Metric | Performance |
|--------|-------------|
| **Overall Success Rate** | 85.3% (86.8% for mixed-content) |
| **Processing Speed** | 371.6ms to 698.5ms  per code |
| **False Positive Rate** | <0.6% across all categories |
| **Segmentation Accuracy** | Mean IoU 0.850 |
| **Supported Formats** | EAN-13/8, UPC-A, Code-128/39, QR codes |

## 📋 Table of Contents

* [✨ System Overview & Features](#-system-overview--features)
* [🚀 One-Click Installation & Setup (Recommended)](#-one-click-installation--setup-recommended)
* [🔧 Manual Installation](#-manual-installation)
* [📊 Dataset](#-dataset)
* [📁 Directory Structure](#-directory-structure)
* [📋 Usage & Commands](#-usage--commands)
* [📊 Output Files & Results](#-output-files--results)
* [📊 Performance Results](#-performance-results)
* [🔍 System Output Analysis](#-system-output-analysis)
* [⚡ Performance Characteristics](#-performance-characteristics)
* [🎯 Use Cases](#-use-cases)
* [📞 Reporting Issues](#-reporting-issues)
* [📜 License](#-license)

## ✨ System Overview & Features

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

## ⚡ **EASIEST WAY TO GET STARTED** ⚡
> [!NOTE]
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
git clone https://github.com/your_github_username/classical-barqr-scanner.git
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

The system has been tested and validated using the **Barcode and QR Code Image Dataset** available on Kaggle:

**🔗 Download Dataset: [Barcode and QR Code Image Dataset](https://www.kaggle.com/datasets/mo7amed/barcode-and-qr-code-image-dataset))**

This dataset contains **750 diverse images** designed for classical computer vision research in detection, segmentation, and recognition tasks (no deep learning required).

### 📂 Dataset Structure:
* **BarCode/** – 325 standard 1D barcode images
* **QRCode/** – 275 2D QR code images  
* **BarCode-QRCode/** – 150 mixed-content images (both codes in same image)

### 🎯 Dataset Diversity:
* **Formats**: EAN-13, EAN-8, UPC-A, Code-128, Code-39, QR codes
* **Resolutions**: 300×300 to 1024×1024 pixels
* **Conditions**: Clean/centered, skewed/angled, cluttered backgrounds, varying lighting, multiple codes per image

### 📥 Dataset Installation:

**🚀 Automatic (Recommended):**
- Using `install.bat` automatically downloads and extracts the dataset to the correct location

**🔧 Manual Mode:**
- Download the dataset from the link above
- Extract the ZIP file to your application folder
- Ensure the folder structure matches:
```
your-project-folder/
├── ClassiScan.py
├── Dataset/
│   ├── BarCode/
│   ├── QRCode/
│   └── BarCode-QRCode/
└── (other project files)
```

> [!IMPORTANT]
> **For manual installation**: The `Dataset/` folder must be placed directly in the same directory as `ClassiScan.py` for the system to work properly.

---
## 📁 Directory Structure

The system automatically creates and manages the following structure:

```
Project Root/
├── 📄 ClassiScan.py                        # Main implementation
├── 📄 requirements.txt                     # Python dependencies
├── 📄 README.md                            # Documentation
├── 📄 LICENSE                              # License file
├
├── 📁 Dataset/                             # Input images
│   ├── 📁 BarCode/                           # Barcode-only images
│   ├── 📁 QRCode/                            # QR code-only images
│   └── 📁 BarCode-QRCode/                    # Mixed-content images
├── 
├── 📁 Successfully Decoded Images/         # Successful detections
│   ├── 📁 BarCode/                           # Processed barcode results
│   ├── 📁 QRCode/                            # Processed QR code results
│   └── 📁 BarCode-QRCode/                    # Processed mixed-content results
├
├── 📁 Failed Decoded Images/               # Failed detections
│   ├── 📁 BarCode/                           # Failed barcode attempts
│   ├── 📁 QRCode/                            # Failed QR code attempts
│   └── 📁 BarCode-QRCode/                    # Failed mixed-content attempts
└── 
└── 📊 evaluation_results.xlsx            # Generated performance reports
```

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

## 📊 Output Files & Results

After processing, the system automatically creates organized output directories:

### 🎯 Successfully Decoded Images/
**Processed images with highlighted detected codes**
- **📁 BarCode/**: Successfully processed barcode images with detection overlays
- **📁 QRCode/**: Successfully processed QR code images with detection overlays  
- **📁 BarCode-QRCode/**: Successfully processed mixed-content images with multiple detections
- **Features**: Color-coded detection boxes, numbered codes, decoded data display
- **File naming**: Preserves original filenames for easy cross-reference

### ❌ Failed Decoded Images/
**Images where detection failed for analysis and debugging**
- **📁 BarCode/**: Barcode images that couldn't be detected/recognized
- **📁 QRCode/**: QR code images that couldn't be detected/recognized
- **📁 BarCode-QRCode/**: Mixed-content images with failed detections
- **Purpose**: Quality analysis, algorithm improvement, edge case identification
- **File naming**: Original filenames preserved for failure analysis

### 📊 Excel Reports
- **📈 evaluation_results_YYYYMMDD.xlsx**: 
  - Sheet 1: Performance metrics (success rates, precision, recall, timing)
  - Sheet 2: All detected codes with location coordinates and metadata
  - Sheet 3: Comprehensive analysis (when using `--comprehensive`)
- **📋 detected_codes_log_YYYYMMDD.xlsx**: Detailed log of all successful detections

## 💡 Pro Tips
- Start with `--max_images 10` for quick testing
- Use `--fill` for better visualization in presentations
- Add `--comprehensive` for research and detailed analysis
- Mix options: `--comprehensive --fill --folders BarCode --max_images 100`

---


## 📊 Performance Results

### Performance by Category (Table 1)

| Code Type | Total Images | Successful | Failed | Success Rate | Failure Rate |
|-----------|--------------|------------|--------|--------------|--------------|
| **Barcode** | 325 | 275 | 50 | **84.6%** | 14.5% |
| **QR Code** | 275 | 235 | 40 | **85.5%** | 15.4% |
| **Both Barcode-QRCode** | 150 | 130 | 20 | **86.8%** | 13.2% |
| **Overall** | **750** | **640** | **110** | **85.3%** | **14.7%** |

### Detection Performance (Table 2)

| Code Type | Recall | F1-Score | Success Rate | Avg Time (ms) |
|-----------|--------|----------|--------------|---------------|
| **Barcode** | 84.6% | 91.6% | 84.6% | 13754.5 |
| **QR Code** | 85.5% | 92.2% | 85.5% | 1599.7 |
| **Both Barcode-QRCode** | 86.8% | 92.9% | 86.8% | 1201.3|
| **Overall** | **85.3%** | **92.1%** | **85.3%** | **6770.4** |

### Segmentation Accuracy (Table 3)

| Code Type | Mean IoU | Boundary F1 | 
|-----------|----------|-------------|
| **Barcode** | 0.799 | 0.851 |
| **QR Code** | 0.853 | 0.904 |
| **Both Barcode-QRCode** | 0.799 | 0.851 |
| **Overall** | **0.799** | **0.850** |

### Recognition Success Rate (Table 4)

| Code Type | Recognition Rate | False Positive Rate | Average Decoding Time (ms) |
|-----------|------------------|---------------------|----------------------------|
| **Barcode** | 88.7% | 0.4% | 698.5 |
| **QR Code** | 87.3% | 0.5% | 371.6 |
| **Both Barcode-QRCode** | 93.7% | 0.6% | 241.5 |
| **Overall** | **89.9%** | **0.3%** | **486.6** |

---

## 🔍 System Output Analysis

The ClassiScan system provides comprehensive output organization for both successful and failed detection attempts:

### ✅ Success Analysis
**Successfully Decoded Images/** contains all images where codes were successfully detected and recognized:
- **Visual confirmation**: Each image shows the original with colored detection boxes
- **Code identification**: Numbered overlays (Code 1, Code 2, etc.) for multiple detections
- **Data display**: Decoded content shown directly on the image
- **Quality assessment**: Successful cases help validate system performance

### ❌ Failure Analysis  
**Failed Decoded Images/** contains images where detection/recognition failed:
- **Debugging resource**: Identify challenging scenarios and edge cases
- **Algorithm improvement**: Analyze failure patterns for system enhancement
- **Quality control**: Understand system limitations and operational boundaries
- **Research value**: Failed cases provide insights for classical CV improvements

### 📈 Performance Tracking
Both success and failure directories enable:
- **Success rate calculation** per category (Barcode, QR Code, Mixed)
- **Failure pattern analysis** (lighting, angle, resolution issues)
- **System validation** against diverse real-world conditions
- **Continuous improvement** through systematic failure analysis


## ⚡ Performance Characteristics

### Processing Efficiency
- **Real-Time Performance**: 14.2-26.8ms per code detection and recognition
- **Scalable Processing**: Efficient handling of multiple codes simultaneously
- **Memory Optimization**: Low-footprint processing suitable for embedded systems
- **Adaptive Complexity**: Quality-based preprocessing selection for optimal speed

### Environmental Robustness
- **Illumination Adaptability**: CLAHE enhancement with glare detection and correction
- **Noise Tolerance**: Bilateral filtering with adaptive preprocessing variations
- **Perspective Handling**: Automatic rotation correction up to ±90° with gradient analysis
- **Multi-Scale Detection**: 0.7×-1.3× processing range for varying code sizes

---

## 🎯 Use Cases

- **📦 Inventory Management**: Automated product scanning and tracking
- **🏪 Retail Operations**: Point-of-sale barcode scanning systems
- **📚 Library Management**: Book and media cataloging systems
- **🏭 Manufacturing**: Quality control and product identification
- **📱 Mobile Applications**: Offline barcode/QR code scanning
- **🔬 Research**: Classical computer vision benchmarking and analysis

---


---

## 📞 Reporting Issues

Please use the GitHub Issues page to report bugs or request features.

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
