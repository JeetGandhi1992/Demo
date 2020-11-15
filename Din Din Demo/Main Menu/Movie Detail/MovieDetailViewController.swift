//
//  MovieDetailViewController.swift
//  Din Din Demo
//
//  Created by jeet_gandhi on 15/11/20.
//

import UIKit
import Alamofire
import AlamofireImage

class MovieDetailViewController: UIViewController, MenuViewControllerProtocol {

    var viewModel: MovieDetailViewModel!

    @IBOutlet weak var bannerImageView: UIImageView!

    @IBOutlet weak var bannerTitle: UILabel!
    @IBOutlet weak var bannerDescription: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    private func setupUI() {
        if let url = self.viewModel.movieUrl {
            bannerImageView.setImage(withURL: url)
        }
        self.bannerTitle.text = self.viewModel.movie.title
        self.bannerDescription.text = self.viewModel.movie.overview
    }
}
