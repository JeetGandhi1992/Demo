//
//  DiscountCollectionViewCell.swift
//  Din Din Demo
//
//  Created by jeet_gandhi on 8/11/20.
//

import UIKit
import Alamofire
import AlamofireImage
import Hero

class DiscountCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bannerImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.bannerImageView.hero.isEnabled = true
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    public func configure(movie: Movie) {
        if let imgUrlStr1 = movie.posterPath, let url = URL(string: Constants.BaseImgURL + imgUrlStr1) {
            bannerImageView.setImage(withURL: url)
        }
    }

}


extension UIImageView {

    public func setImage(withURL: URL, placeholderImage: UIImage? = nil) {
        self.af.setImage(withURL: withURL, placeholderImage: placeholderImage)
    }

    public func setImage(withURLRequest urlRequest: URLRequest,
                                placeholderImage: UIImage? = nil) {
        self.af.setImage(withURLRequest: urlRequest, placeholderImage: placeholderImage)
    }
}
