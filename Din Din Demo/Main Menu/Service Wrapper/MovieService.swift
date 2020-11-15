//
//  MovieService.swift
//  Din Din Demo
//
//  Created by jeet_gandhi on 9/11/20.
//

import RxSwift
import Moya

public protocol MovieServiceType {
    func getMoviesByPopularity(for page: Int) -> Observable<NetworkingUIEvent<MovieResult>>
    func getMoviesByTopRatings(for page: Int) -> Observable<NetworkingUIEvent<MovieResult>>
}
public struct MovieService: MovieServiceType {

    let provider: MoyaProvider<MovieTarget>
    let disposeBag = DisposeBag()

    public init(provider: MoyaProvider<MovieTarget>) {
        self.provider = provider
    }

    public func getMoviesByPopularity(for page: Int) -> Observable<NetworkingUIEvent<MovieResult>> {
        return self.getMovies(by: MovieTarget.getMoviesByPopularity(urlParameters: appendQueryString(page: page)))
    }

    public func getMoviesByTopRatings(for page: Int) -> Observable<NetworkingUIEvent<MovieResult>> {
        return self.getMovies(by: MovieTarget.getMoviesByTopRatings(urlParameters: appendQueryString(page: page)))
    }

    private func getMovies(by requestType: MovieTarget) -> Observable<NetworkingUIEvent<MovieResult>> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return self.provider.rx
            .request(requestType)
            .map(MovieResult.self, using: decoder, failsOnEmptyData: true)
            .map({ (result) -> NetworkingUIEvent<MovieResult> in
                return NetworkingUIEvent.succeeded(result)
            })
            .asObservable()
            .startWith(.waiting)
            .catchError { (error) -> Observable<NetworkingUIEvent<MovieResult>> in
                return Observable.just(NetworkingUIEvent.failed(error))
            }
    }

    private func appendQueryString(page: Int) -> [String : Any] {

        var urlParameters = [String : Any]()

        urlParameters.updateValue(Constants.ApiKey, forKey: "api_key")
        urlParameters.updateValue("en-US", forKey: "language")
        urlParameters.updateValue(page, forKey: "page")

        return urlParameters

    }

}
