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
    // MARK: - Properties
    var image = UIImage()
    private var correctedImageArray = [UIImage]()
    private let cardProvider = CardProvider()
    // MARK: - IBOutlet
    @IBOutlet weak var cardCollectionView: UICollectionView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCollectionView()
        setupVision()
    }
    private func setupCollectionView() {
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = cardProvider
    }
}
// MARK: - CollectionDelegate
extension HandlePhotoViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height = width * 3 / 4
        return CGSize(width: width, height: height)
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
            print("resssult", req.results?.count)
            req.results?.forEach({ res in
                guard let observation = res as? VNRectangleObservation else { return }
                
                let ciImage = self.extractPerspectiveRect(observation, from: cgImage)
                let observedImage = self.convert(cmage: ciImage)
                self.correctedImageArray.append(observedImage)
            })
            DispatchQueue.main.async {
                print("bbbb", self.correctedImageArray.count)
                self.cardProvider.getCardImage(imageArray: self.correctedImageArray)
                self.cardProvider.getCardImage(imageArray: self.correctedImageArray)
                self.cardCollectionView.reloadData()
                
            }
        }
        request.maximumObservations = 4
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
