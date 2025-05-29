#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Visualization Script for Barcode and QR Code Detection System.
This script visualizes each step of the detection and recognition process.

Author: [Your Name]
Date: May, 2025
"""

import cv2
import numpy as np
import argparse
from pathlib import Path
from BarcodeQRDetector import CodeDetector, CodeRecognizer


class ProcessVisualizer:
    """A class for visualizing the barcode and QR code detection process."""
    
    def __init__(self, image_path, save_output=False, output_dir=None):
        """
        Initialize the visualizer with an image.
        
        Args:
            image_path: Path to the input image
            save_output: Whether to save visualization images
            output_dir: Directory to save output images
        """
        self.image_path = Path(image_path)
        self.save_output = save_output
        self.output_dir = Path(output_dir) if output_dir else self.image_path.parent / "visualization"
        
        # Create output directory if needed
        if self.save_output:
            self.output_dir.mkdir(exist_ok=True)
        
        # Load the image
        self.image = cv2.imread(str(self.image_path))
        if self.image is None:
            raise ValueError(f"Could not load image {image_path}")
        
        # Initialize detector and recognizer
        self.detector = CodeDetector()
        self.recognizer = CodeRecognizer()
    
    def save_image(self, name, image):
        """Save an image if save_output is enabled."""
        if self.save_output:
            output_path = self.output_dir / f"{self.image_path.stem}_{name}.jpg"
            cv2.imwrite(str(output_path), image)
            print(f"Saved {output_path}")
    
    def visualize_preprocessing(self):
        """Visualize the preprocessing steps."""
        print("Step 1: Preprocessing")
        
        # Convert to grayscale
        gray = cv2.cvtColor(self.image, cv2.COLOR_BGR2GRAY)
        self.save_image("1_grayscale", gray)
        
        # Apply Gaussian blur
        blurred = cv2.GaussianBlur(
            gray, (self.detector.blur_kernel_size, self.detector.blur_kernel_size), 0
        )
        self.save_image("2_blurred", blurred)
        
        # Apply adaptive thresholding
        thresh = cv2.adaptiveThreshold(
            blurred, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, 
            cv2.THRESH_BINARY_INV, 11, 2
        )
        self.save_image("3_thresholded", thresh)
        
        # Display or return
        if not self.save_output:
            cv2.imshow("1. Grayscale", gray)
            cv2.imshow("2. Blurred", blurred)
            cv2.imshow("3. Thresholded", thresh)
            cv2.waitKey(0)
            cv2.destroyAllWindows()
        
        return thresh, gray
    
    def visualize_edge_detection(self, preprocessed_img):
        """Visualize the edge detection steps."""
        print("Step 2: Edge Detection")
        
        # Apply Canny edge detection
        edges = cv2.Canny(
            preprocessed_img, 
            self.detector.canny_threshold1, 
            self.detector.canny_threshold2
        )
        self.save_image("4_edges", edges)
        
        # Apply morphological operations
        kernel = np.ones(
            (self.detector.morph_kernel_size, self.detector.morph_kernel_size), np.uint8
        )
        closed_edges = cv2.morphologyEx(edges, cv2.MORPH_CLOSE, kernel)
        self.save_image("5_closed_edges", closed_edges)
        
        # Display or return
        if not self.save_output:
            cv2.imshow("4. Edges", edges)
            cv2.imshow("5. Closed Edges", closed_edges)
            cv2.waitKey(0)
            cv2.destroyAllWindows()
        
        return closed_edges
    
    def visualize_gradient_detection(self, gray_img):
        """Visualize the gradient-based detection."""
        print("Step 3: Gradient Analysis")
        
        # Calculate gradients in x and y directions
        grad_x = cv2.Sobel(gray_img, cv2.CV_64F, 1, 0, ksize=3)
        grad_y = cv2.Sobel(gray_img, cv2.CV_64F, 0, 1, ksize=3)
        
        # Visualize gradient magnitudes
        abs_grad_x = cv2.convertScaleAbs(grad_x)
        abs_grad_y = cv2.convertScaleAbs(grad_y)
        self.save_image("6_grad_x", abs_grad_x)
        self.save_image("7_grad_y", abs_grad_y)
        
        # Calculate gradient magnitude
        grad_mag = cv2.magnitude(grad_x, grad_y)
        grad_mag = cv2.normalize(grad_mag, None, 0, 255, cv2.NORM_MINMAX).astype(np.uint8)
        self.save_image("8_grad_magnitude", grad_mag)
        
        # Apply threshold to get regions with strong gradients
        _, binary_grad = cv2.threshold(grad_mag, 50, 255, cv2.THRESH_BINARY)
        self.save_image("9_binary_gradient", binary_grad)
        
        # Apply morphological operations
        kernel = np.ones((5, 5), np.uint8)
        morph_grad = cv2.morphologyEx(binary_grad, cv2.MORPH_CLOSE, kernel)
        self.save_image("10_morph_gradient", morph_grad)
        
        # Display or return
        if not self.save_output:
            cv2.imshow("6. Gradient X", abs_grad_x)
            cv2.imshow("7. Gradient Y", abs_grad_y)
            cv2.imshow("8. Gradient Magnitude", grad_mag)
            cv2.imshow("9. Binary Gradient", binary_grad)
            cv2.imshow("10. Morphological Gradient", morph_grad)
            cv2.waitKey(0)
            cv2.destroyAllWindows()
        
        return morph_grad
    
    def visualize_contour_filtering(self, edge_img, grad_img):
        """Visualize the contour filtering steps."""
        print("Step 4: Contour Analysis")
        
        # Find contours in edge image
        edge_contours, _ = cv2.findContours(
            edge_img, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE
        )
        
        # Find contours in gradient image
        grad_contours, _ = cv2.findContours(
            grad_img, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE
        )
        
        # Filter contours and visualize
        edge_filtered = self.image.copy()
        grad_filtered = self.image.copy()
        combined = self.image.copy()
        
        # Draw all contours for visualization
        cv2.drawContours(edge_filtered, edge_contours, -1, (0, 255, 0), 2)
        cv2.drawContours(grad_filtered, grad_contours, -1, (255, 0, 0), 2)
        
        self.save_image("11_all_edge_contours", edge_filtered)
        self.save_image("12_all_gradient_contours", grad_filtered)
        
        # Filter contours by area, aspect ratio, etc.
        filtered_edge_contours = []
        for contour in edge_contours:
            if cv2.contourArea(contour) < self.detector.min_contour_area:
                continue
            
            rect = cv2.minAreaRect(contour)
            box = cv2.boxPoints(rect)
            box = np.int0(box)
            
            rect_area = rect[1][0] * rect[1][1]
            contour_area = cv2.contourArea(contour)
            rectangularity = contour_area / rect_area if rect_area > 0 else 0
            
            width, height = rect[1]
            aspect_ratio = max(width, height) / min(width, height) if min(width, height) > 0 else 0
            
            if (rectangularity > self.detector.min_rect_ratio and 
                self.detector.aspect_ratio_range[0] <= aspect_ratio <= self.detector.aspect_ratio_range[1]):
                filtered_edge_contours.append(box)
        
        filtered_grad_contours = []
        for contour in grad_contours:
            if cv2.contourArea(contour) < self.detector.min_contour_area:
                continue
            
            rect = cv2.minAreaRect(contour)
            box = cv2.boxPoints(rect)
            box = np.int0(box)
            
            width, height = rect[1]
            aspect_ratio = max(width, height) / min(width, height) if min(width, height) > 0 else 0
            
            if self.detector.aspect_ratio_range[0] <= aspect_ratio <= self.detector.aspect_ratio_range[1]:
                filtered_grad_contours.append(box)
        
        # Create filtered contour visualization
        edge_filtered = self.image.copy()
        grad_filtered = self.image.copy()
        
        for box in filtered_edge_contours:
            cv2.drawContours(edge_filtered, [box], 0, (0, 255, 0), 2)
            cv2.drawContours(combined, [box], 0, (0, 255, 0), 2)
        
        for box in filtered_grad_contours:
            cv2.drawContours(grad_filtered, [box], 0, (255, 0, 0), 2)
            cv2.drawContours(combined, [box], 0, (255, 0, 0), 2)
        
        self.save_image("13_filtered_edge_contours", edge_filtered)
        self.save_image("14_filtered_gradient_contours", grad_filtered)
        self.save_image("15_combined_contours", combined)
        
        # Display or return
        if not self.save_output:
            cv2.imshow("11. All Edge Contours", edge_filtered)
            cv2.imshow("12. All Gradient Contours", grad_filtered)
            cv2.imshow("13. Filtered Edge Contours", edge_filtered)
            cv2.imshow("14. Filtered Gradient Contours", grad_filtered)
            cv2.imshow("15. Combined Contours", combined)
            cv2.waitKey(0)
            cv2.destroyAllWindows()
        
        return combined
    
    def visualize_recognition(self):
        """Visualize the complete detection and recognition process."""
        print("Step 5: Recognition")
        
        # Run the detector to get regions
        detected_regions = self.detector.detect(self.image)
        
        # Create a copy for visualization
        recognition_result = self.image.copy()
        
        # Process each region
        region_images = []
        for i, region in enumerate(detected_regions):
            warped = region['warped']
            box = region['box']
            
            # Try to decode
            decoded = self.recognizer.decode(warped)
            
            if decoded:
                # Draw the region on the result image (green for successful decode)
                cv2.drawContours(recognition_result, [box], 0, (0, 255, 0), 2)
                
                # Draw the decoded info
                text = f"{decoded['type']}: {decoded['data']}"
                
                # Calculate text position
                text_x = int(np.min(box[:, 0]))
                text_y = int(np.min(box[:, 1])) - 10
                if text_y < 20:
                    text_y = int(np.max(box[:, 1])) + 20
                
                # Draw white background for text
                text_size, _ = cv2.getTextSize(text, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 2)
                cv2.rectangle(
                    recognition_result, 
                    (text_x - 5, text_y - text_size[1] - 5), 
                    (text_x + text_size[0] + 5, text_y + 5), 
                    (255, 255, 255), 
                    -1
                )
                
                # Draw text
                cv2.putText(
                    recognition_result, text, (text_x, text_y),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 2
                )
                
                # Add a success indicator
                cv2.rectangle(warped, (0, 0), (20, 20), (0, 255, 0), -1)
            else:
                # Draw the region in red for failed decode (only for visualization)
                cv2.drawContours(recognition_result, [box], 0, (0, 0, 255), 2)
                
                # Add a failure indicator
                cv2.rectangle(warped, (0, 0), (20, 20), (0, 0, 255), -1)
            
            # Save the region image
            region_name = f"region_{i+1}"
            if decoded:
                region_name += f"_{decoded['type']}"
            self.save_image(region_name, warped)
            
            # Store for display
            region_images.append((f"Region {i+1}", warped))
        
        # Save final result
        self.save_image("16_recognition_result", recognition_result)
        
        # Display
        if not self.save_output:
            cv2.imshow("16. Recognition Result", recognition_result)
            
            # Display each region
            for name, img in region_images:
                cv2.imshow(name, img)
            
            cv2.waitKey(0)
            cv2.destroyAllWindows()
        
        return recognition_result20, 20), (0, 0, 255), -1)
            
            # Save the region image
            region_name = f"region_{i+1}"
            if decoded:
                region_name += f"_{decoded['type']}"
            self.save_image(region_name, warped)
            
            # Store for display
            region_images.append((f"Region {i+1}", warped))
        
        # Save final result
        self.save_image("16_recognition_result", recognition_result)
        
        # Display
        if not self.save_output:
            cv2.imshow("16. Recognition Result", recognition_result)
            
            # Display each region
            for name, img in region_images:
                cv2.imshow(name, img)
            
            cv2.waitKey(0)
            cv2.destroyAllWindows()
        
        return recognition_result
    
    def visualize_all(self):
        """Run the complete visualization pipeline."""
        print(f"Visualizing process for {self.image_path}")
        
        # Step 1: Preprocessing
        thresh, gray = self.visualize_preprocessing()
        
        # Step 2: Edge Detection
        edge_img = self.visualize_edge_detection(thresh)
        
        # Step 3: Gradient Analysis
        grad_img = self.visualize_gradient_detection(gray)
        
        # Step 4: Contour Filtering
        self.visualize_contour_filtering(edge_img, grad_img)
        
        # Step 5: Recognition
        self.visualize_recognition()
        
        print("Visualization complete!")
        if self.save_output:
            print(f"Output images saved to {self.output_dir}")


def main():
    """Main function for the visualization script."""
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='Visualize Barcode and QR Code Detection Process')
    parser.add_argument('--image', type=str, required=True,
                        help='Path to the input image')
    parser.add_argument('--save', action='store_true',
                        help='Save visualization images')
    parser.add_argument('--output', type=str, default=None,
                        help='Directory to save output images')
    
    args = parser.parse_args()
    
    # Check if image exists
    image_path = Path(args.image)
    if not image_path.exists():
        print(f"Error: Image {args.image} does not exist")
        return
    
    # Run visualization
    try:
        visualizer = ProcessVisualizer(image_path, args.save, args.output)
        visualizer.visualize_all()
    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    main()