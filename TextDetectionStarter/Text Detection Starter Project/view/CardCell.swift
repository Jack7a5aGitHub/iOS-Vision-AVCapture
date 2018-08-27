//
//  CardCell.swift
//  Text Detection Starter Project
//
//  Created by Jack Wong on 2018/08/17.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit

final class CardCell: UICollectionViewCell {
    
    @IBOutlet weak var cardImageView: UIImageView!
    
    var correctedImage: UIImage? {
        didSet {
            cardImageView.contentMode = .scaleAspectFit
            cardImageView.image = correctedImage
            print("orientation2", cardImageView.image?.flipsForRightToLeftLayoutDirection)
            
        }
    }
}
