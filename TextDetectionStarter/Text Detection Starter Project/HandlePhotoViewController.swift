//
//  HandlePhotoViewController.swift
//  Text Detection Starter Project
//
//  Created by Jack Wong on 2018/08/17.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit
import Vision

final class HandlePhotoViewController: UIViewController {
    // MARK: - Factory
    class func make(photo: UIImage
                    ) -> HandlePhotoViewController {
        
        let className = "HandlePhotoViewController"
        guard let handleVC = UIStoryboard(name: className, bundle: nil).instantiateViewController(withIdentifier: className) as? HandlePhotoViewController else {
            fatalError("no new booking VC")
        }
        handleVC.image = photo
        return handleVC
    }
    var image = UIImage()
    @IBOutlet weak private var businessCardImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupImageView()
        setupVision()
    }
    private func setupImageView() {
        businessCardImageView.contentMode = .scaleAspectFit
    }
}

// MARK: - Vision func
extension HandlePhotoViewController {
    private func setupVision() {
        
        guard let cgImage = image.cgImage else { return }
        let request = VNDetectRectanglesRequest { (req, err) in
            if let err = err {
                print("failed to detect", err)
                return
            }
            req.results?.forEach({ res in
                guard let observation = res as? VNRectangleObservation else { return }
                
                let ciImage = self.extractPerspectiveRect(observation, from: cgImage)
                let observedImage = self.convert(cmage: ciImage)
                
                DispatchQueue.main.async {
                    
                    self.businessCardImageView.image = observedImage
                    
                }
                
            })
        }
        request.maximumObservations = 1
        request.minimumConfidence = 0.6
        request.minimumAspectRatio = 0.3
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch let reqErr {
                print("request Error", reqErr)
            }
            
        }
    }
    
    func extractPerspectiveRect(_ observation: VNRectangleObservation, from cgImage: CGImage) -> CIImage {
        // get the pixel buffer into Core Image
        let ciImage = CIImage(cgImage: cgImage)
        
        // convert corners from normalized image coordinates to pixel coordinates
        let topLeft = observation.topLeft.scaled(to: ciImage.extent.size)
        let topRight = observation.topRight.scaled(to: ciImage.extent.size)
        let bottomLeft = observation.bottomLeft.scaled(to: ciImage.extent.size)
        let bottomRight = observation.bottomRight.scaled(to: ciImage.extent.size)
        print("bbbb", topLeft, topRight, bottomLeft, bottomRight)
        // pass those to the filter to extract/rectify the image
        return ciImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: topLeft),
            "inputTopRight": CIVector(cgPoint: topRight),
            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
            "inputBottomRight": CIVector(cgPoint: bottomRight),
            ]).applyingFilter("CIColorControls", parameters: [
                kCIInputSaturationKey: 0,
                kCIInputContrastKey: 32]).applyingFilter("CIColorInvert")
    }
    
    private func convert(cmage:CIImage) -> UIImage {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
}
