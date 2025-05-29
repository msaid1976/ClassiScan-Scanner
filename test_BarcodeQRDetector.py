#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Test script for the Barcode and QR Code Detection, Segmentation, and Recognition System.
This script allows testing individual components of the system or the entire pipeline.

Author: [Your Name]
Date: May, 2025
"""

import os
import cv2
import argparse
import numpy as np
from pathlib import Path
from BarcodeQRDetector import CodeDetector, CodeRecognizer, CodeSystemProcessor


def test_detector(image_path):
    """Test the detector component on a single image."""
    print(f"Testing detector on {image_path}")
    
    # Load the image
    image = cv2.imread(str(image_path))
    if image is None:
        print(f"Error: Could not load image {image_path}")
        return
    
    # Initialize and run detector
    detector = CodeDetector()
    detected_regions = detector.detect(image)
    
    # Display results
    print(f"Detected {len(detected_regions)} potential code regions")
    
    # Create a copy of the image for visualization
    result_img = image.copy()
    
    # Draw all detected regions on the image
    for region in detected_regions:
        box = region['box']
        cv2.drawContours(result_img, [box], 0, (0, 255, 0), 2)
    
    # Show the result image with detected regions
    cv2.imshow("Detected Regions", result_img)
    
    # Show each detected region
    for i, region in enumerate(detected_regions):
        warped = region['warped']
        cv2.imshow(f"Region {i+1}", warped)
    
    cv2.waitKey(0)
    cv2.destroyAllWindows()


def test_recognizer(image_path):
    """Test the recognizer component on a single image."""
    print(f"Testing recognizer on {image_path}")
    
    # Load the image
    image = cv2.imread(str(image_path))
    if image is None:
        print(f"Error: Could not load image {image_path}")
        return
    
    # Initialize detector and recognizer
    detector = CodeDetector()
    recognizer = CodeRecognizer()
    
    # Detect regions
    detected_regions = detector.detect(image)
    
    # Create a copy of the image for visualization
    result_img = image.copy()
    
    # Try to recognize each region
    for i, region in enumerate(detected_regions):
        warped = region['warped']
        box = region['box']
        print(f"\nTesting recognition on region {i+1}:")
        
        # Display the region
        cv2.imshow(f"Region {i+1}", warped)
        
        # Try to decode
        decoded = recognizer.decode(warped)
        
        if decoded:
            print(f"Successfully decoded: {decoded['type']} - {decoded['data']}")
            # Mark the successful region in green
            cv2.drawContours(result_img, [box], 0, (0, 255, 0), 2)
            # Add decoded text
            text = f"{decoded['type']}: {decoded['data']}"
            text_x = int(np.min(box[:, 0]))
            text_y = int(np.min(box[:, 1])) - 10
            if text_y < 20:
                text_y = int(np.max(box[:, 1])) + 20
            cv2.putText(result_img, text, (text_x, text_y),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 2)
        else:
            print("Failed to decode this region")
            # Mark the failed region in red
            cv2.drawContours(result_img, [box], 0, (0, 0, 255), 2)
    
    # Show the result image
    cv2.imshow("Recognition Result", result_img)
    
    cv2.waitKey(0)
    cv2.destroyAllWindows()


def test_full_pipeline(image_path):
    """Test the complete pipeline on a single image."""
    print(f"Testing full pipeline on {image_path}")
    
    # Initialize processor
    processor = CodeSystemProcessor()
    
    # Process image
    result = processor.process_image(image_path)
    
    if result:
        # Display results
        print(f"\nProcessing completed in {result['processing_time']:.3f} seconds")
        print(f"Detected {result['detected_regions']} potential code regions")
        print(f"Successfully recognized {len(result['recognized_codes'])} codes")
        
        for i, code in enumerate(result['recognized_codes']):
            print(f"  Code {i+1}: {code['type']} - {code['data']}")
        
        # Show the result image
        cv2.imshow("Result", result['result_image'])
        cv2.waitKey(0)
        cv2.destroyAllWindows()
    else:
        print("Error processing image")


def main():
    """Main function for the test script."""
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='Test Barcode and QR Code System')
    parser.add_argument('--mode', choices=['detector', 'recognizer', 'full'], default='full',
                        help='Component to test (detector, recognizer, or full pipeline)')
    parser.add_argument('--image', type=str, required=True,
                        help='Path to the test image')
    
    args = parser.parse_args()
    
    # Check if image exists
    image_path = Path(args.image)
    if not image_path.exists():
        print(f"Error: Image {args.image} does not exist")
        return
    
    # Run appropriate test
    if args.mode == 'detector':
        test_detector(image_path)
    elif args.mode == 'recognizer':
        test_recognizer(image_path)
    else:  # full pipeline
        test_full_pipeline(image_path)


if __name__ == "__main__":
    main()