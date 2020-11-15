//
//  ProviderFactory.swift
//  Din Din Demo
//
//  Created by jeet_gandhi on 12/11/20.
//

import UIKit
import Moya

protocol ProviderFactory {
    var movieProvider: MoyaProvider<MovieTarget> { get }
}

struct ConcreteProviderFactory: ProviderFactory {
    static let shared = ConcreteProviderFactory()
    let movieProvider: MoyaProvider<MovieTarget> = MoyaProvider<MovieTarget>()
}
