//
//  DiscountCollectionViewCell.swift
//  Din Din Demo
//
//  Created by jeet_gandhi on 8/11/20.
//

import UIKit

class DiscountCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    public func configure(discount: UIColor) {
        self.backgroundColor = discount
    }

}
