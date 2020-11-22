//
//  MovieDetailViewController.swift
//  Din Din Demo
//
//  Created by jeet_gandhi on 15/11/20.
//

import UIKit
import Alamofire
import AlamofireImage
import Hero

class MovieDetailViewController: UIViewController, MenuViewControllerProtocol {

    var viewModel: MovieDetailViewModel!

    @IBOutlet weak var bannerImageView: UIImageView!

    @IBOutlet weak var bannerTitle: UILabel!
    @IBOutlet weak var bannerDescription: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(onTap))
        swipe.direction = .down
        
        view.addGestureRecognizer(swipe)
    }

    private func setupUI() {
        if let url = self.viewModel.movieUrl {
            bannerImageView.setImage(withURL: url)
        }
        self.bannerImageView.hero.isEnabled = true
        self.bannerTitle.text = self.viewModel.movie.title
        self.bannerDescription.text = self.viewModel.movie.overview
    }

    @objc func back() {
        dismiss(animated: true, completion: nil)
    }

    @objc func onTap() {
        back() // default action is back on tap
    }
    
}
