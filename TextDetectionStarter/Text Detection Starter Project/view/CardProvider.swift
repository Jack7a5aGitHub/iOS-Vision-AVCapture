//
//  CardProvider.swift
//  Text Detection Starter Project
//
//  Created by Jack Wong on 2018/08/17.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit

final class CardProvider: NSObject {
    var cardImage = [UIImage]()
    
    func getCardImage(imageArray: [UIImage]) {
        self.cardImage = imageArray
    }
    
}

extension CardProvider: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardImage.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CardCell else {
            fatalError("no cell")
        }
        cell.correctedImage = cardImage[indexPath.item]
        return cell
    }
}
