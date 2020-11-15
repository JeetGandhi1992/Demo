//
//  MainMenuViewModel.swift
//  Din Din Demo
//
//  Created by jeet_gandhi on 8/11/20.
//

import UIKit
import RxSwift
import RxCocoa
import Moya

public enum MainMenuViewModelEvents {
    case getMoviesByPopularity(NetworkingUIEvent<MovieResult>)
    case getMoviesByTopRatings(NetworkingUIEvent<MovieResult>)
    case ignore

}

extension MainMenuViewModelEvents: Equatable {
    public static func == (lhs: MainMenuViewModelEvents, rhs: MainMenuViewModelEvents) -> Bool {
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

extension MainMenuViewModelEvents: MapsToNetworkEvent {
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

protocol MainMenuType: NetworkingViewModel {
    var movies: BehaviorRelay<[Movie]> { get }
    var events: PublishSubject<MainMenuViewModelEvents> { get  }
    var movieSectionModel: BehaviorRelay<MovieSectionModel> { get }
}

class MainMenuViewModel: MainMenuType {
    var events: PublishSubject<MainMenuViewModelEvents> = PublishSubject<MainMenuViewModelEvents>()
    var movies: BehaviorRelay<[Movie]> = BehaviorRelay<[Movie]>(value: [])

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

        for movie in self.movies.value {
            let movieCellModel = MovieCellModel(movie: movie)
            movieCellModels.append(movieCellModel)
        }
        return movieCellModels
    }

    public func getMoviesByPopularity() {
        service.getMoviesByPopularity(for: 1)
            .map { MainMenuViewModelEvents.getMoviesByPopularity($0) }
            .bind(to: self.events)
            .disposed(by: disposeBag)
    }

    public func getMoviesByRatings() {
        service.getMoviesByTopRatings(for: 1)
            .map { MainMenuViewModelEvents.getMoviesByTopRatings($0) }
            .bind(to: self.events)
            .disposed(by: disposeBag)
    }

    private func setupBindMovies() {
        self.events.subscribe(onNext: { [weak self] (event) in
            guard let self = self else { return }
            switch event {
                case .getMoviesByPopularity(.succeeded(let moviesResult)):
                    self.movies.accept(moviesResult.results ?? [])
                default:
                    break
            }
        }).disposed(by: disposeBag)

        self.movies.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            let movieCellModels = self.getMovieCellModel()
            self.movieSectionModel.accept(MovieSectionModel(header: "",
                                                                  items: movieCellModels))
        }).disposed(by: disposeBag)
    }
}
