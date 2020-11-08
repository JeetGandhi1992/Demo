//
//  MovieTarget.swift
//  Din Din Demo
//
//  Created by jeet_gandhi on 9/11/20.
//

import Moya
import Alamofire

public enum MovieTarget {
    case getMoviesByPopularity(urlParameters: [String : Any])
    case getMoviesByTopRatings(urlParameters: [String : Any])
}

extension MovieTarget: TargetType {

    public var baseURL: URL {
        return Constants.BaseURL
    }

    public var path: String {
        switch self {
            case .getMoviesByPopularity:
                return "3/movie/popular"
            case .getMoviesByTopRatings:
                return "3/movie/top_rated"
        }
    }

    public var method: Moya.Method {
        .post
    }

    public var sampleData: Data {
        Data()
    }

    public var task: Task {
        switch self {
            case .getMoviesByPopularity(urlParameters: let urlParameters):
                return .requestCompositeData(bodyData: Data(),
                                             urlParameters: urlParameters)
            case .getMoviesByTopRatings(urlParameters: let urlParameters):
                return .requestCompositeData(bodyData: Data(),
                                             urlParameters: urlParameters)
        }
        
    }

    public var headers: [String : String]? {
        return nil
    }

    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }

}
