//
//  MovieDetailViewModel.swift
//  Din Din Demo
//
//  Created by jeet_gandhi on 15/11/20.
//

import UIKit
import RxSwift
import RxCocoa
import Moya

protocol MovieDetailType {
    var movie: Movie { get }
    var movieUrl: URL? { get }
}

class MovieDetailViewModel: MovieDetailType {
    var movieUrl: URL? {
        if let imgUrlStr1 = movie.posterPath {
            return URL(string: Constants.BaseImgURL + imgUrlStr1)
        }
        return nil
    }

    let movie: Movie

    init(movie: Movie) {
        self.movie = movie
    }
}
