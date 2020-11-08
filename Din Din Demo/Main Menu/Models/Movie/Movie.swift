//
//  Movie.swift
//  Din Din Demo
//
//  Created by jeet_gandhi on 9/11/20.
//


import Foundation

public struct Movie: Codable, Equatable {

    var posterPath: String?
    var adult: Bool?
    var overview: String?
    var releaseDate: String?
    var genreIds: [Int]?
    var id: Int?
    var originalTitle: String?
    var originalLanguage: String?
    var title: String?
    var backdropPath: String?
    var popularity: Double?
    var voteCount: Int?
    var video: Bool?
    var voteAverage: Double?
    
}


enum MoviesSort {
    
    case getMoviesByPopularity
    case getMoviesByTopRatings
    
}

