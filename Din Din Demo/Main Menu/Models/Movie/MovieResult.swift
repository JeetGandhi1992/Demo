//
//  Movie_Result.swift
//  Din Din Demo
//
//  Created by jeet_gandhi on 9/11/20.
//


import Foundation

public struct MovieResult: Codable, Equatable {
    
    var page: Int?
    var results: [Movie]?
    var totalResults: Int?
    var totalPages: Int?
    
}


