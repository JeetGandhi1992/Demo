//
//  MenuCardViewModel.swift
//  Din Din Demo
//
//  Created by jeet_gandhi on 12/11/20.
//

import UIKit
import RxSwift
import RxCocoa
import Moya

public enum MenuCardViewModelEvents {
    case getMoviesByPopularity(NetworkingUIEvent<MovieResult>)
    case getMoviesByTopRatings(NetworkingUIEvent<MovieResult>)
    case ignore

}

extension MenuCardViewModelEvents: Equatable {
    public static func == (lhs: MenuCardViewModelEvents, rhs: MenuCardViewModelEvents) -> Bool {
        switch (lhs, rhs) {
            case (.getMoviesByPopularity(let lMovieResult), .getMoviesByPopularity(let rMovieResult)):
                return lMovieResult == rMovieResult
            case (.getMoviesByTopRatings(let lMovieResult), .getMoviesByTopRatings(let rMovieResult)):
                return lMovieResult == rMovieResult
            case (.ignore, .ignore):
                return true
            default:
                return false
        }
    }
}

extension MenuCardViewModelEvents: MapsToNetworkEvent {
    public func toNetworkEvent() -> NetworkingUIEvent<()>? {
        switch self {
            case .getMoviesByPopularity(let event):
                return event.ignoreResponse()
            case .getMoviesByTopRatings(let event):
                return event.ignoreResponse()
            case .ignore:
                return nil
        }
    }
}

protocol MenuCardType: NetworkingViewModel {
    var topRatedMovies: BehaviorRelay<[Movie]> { get }
    var events: PublishSubject<MenuCardViewModelEvents> { get  }
    var movieSectionModel: BehaviorRelay<MovieSectionModel> { get }
}

class MenuCardViewModel: MenuCardType {
    var events: PublishSubject<MenuCardViewModelEvents> = PublishSubject<MenuCardViewModelEvents>()
    var topRatedMovies: BehaviorRelay<[Movie]> = BehaviorRelay<[Movie]>(value: [])

    public var movieSectionModel = BehaviorRelay(value: MovieSectionModel(items: []))
    let service: MovieService
    let disposeBag = DisposeBag()
    public let selectedMovie = PublishSubject<Movie>()

    init(provider: MoyaProvider<MovieTarget>) {
        self.service = MovieService(provider: provider)
        let movieCellModels = self.getMovieCellModel()
        self.movieSectionModel.accept(MovieSectionModel(header: "",
                                                              items: movieCellModels))
        setupBindMovies()
    }

    func getMovieCellModel() -> [MovieCellModel] {
        var movieCellModels = [MovieCellModel]()

        for movie in self.topRatedMovies.value {
            let movieCellModel = MovieCellModel(movie: movie)
            movieCellModels.append(movieCellModel)
        }
        return movieCellModels
    }

    public func getMoviesByPopularity() {
        service.getMoviesByPopularity(for: 1)
            .map { MenuCardViewModelEvents.getMoviesByPopularity($0) }
            .bind(to: self.events)
            .disposed(by: disposeBag)
    }

    public func getMoviesByRatings() {
        service.getMoviesByTopRatings(for: 1)
            .map { MenuCardViewModelEvents.getMoviesByTopRatings($0) }
            .bind(to: self.events)
            .disposed(by: disposeBag)
    }

    private func setupBindMovies() {
        self.events.subscribe(onNext: { [weak self] (event) in
            guard let self = self else { return }
            switch event {
                case .getMoviesByTopRatings(.succeeded(let moviesResult)):
                    self.topRatedMovies.accept(moviesResult.results ?? [])
                default:
                    break
            }
        }).disposed(by: disposeBag)

        self.topRatedMovies.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            let discountCellModels = self.getMovieCellModel()
            self.movieSectionModel.accept(MovieSectionModel(header: "",
                                                                  items: discountCellModels))
        }).disposed(by: disposeBag)
    }
}
