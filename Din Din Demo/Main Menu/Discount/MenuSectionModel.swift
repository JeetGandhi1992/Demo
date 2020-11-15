//
//  DiscountSectionModel.swift
//  Din Din Demo
//
//  Created by jeet_gandhi on 8/11/20.
//

import UIKit
import RxDataSources

public struct MovieSectionModel {
    var header: String
    public var items: [MovieCellModel]

    init(header: String? = "", items: [MovieCellModel]) {
        self.header = header!
        self.items = items
    }
}

extension MovieSectionModel: SectionModelType {
    public typealias Item = MovieCellModel

    public init(original: MovieSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}

extension MovieSectionModel: Equatable {
    public static func == (lhs: MovieSectionModel, rhs: MovieSectionModel) -> Bool {
        return lhs.header == rhs.header
            && lhs.items == rhs.items

    }
}

public struct MovieCellModel {
    var movie: Movie
}

extension MovieCellModel: Equatable {
    public static func == (lhs: MovieCellModel, rhs: MovieCellModel) -> Bool {
        return lhs.movie == rhs.movie
    }
}



