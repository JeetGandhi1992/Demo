//
//  DiscountCollectionViewCell.swift
//  Din Din Demo
//
//  Created by jeet_gandhi on 8/11/20.
//

import UIKit
import Alamofire
import AlamofireImage

class DiscountCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    public func configure(movie: Movie) {
        let imgUrlStr1 = movie.posterPath ?? ""
        let url = URL(string: Constants.BaseImgURL + imgUrlStr1)!

        let imageView = UIImageView(frame: self.bounds)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(imageView)
        imageView.setImage(withURL: url)

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
