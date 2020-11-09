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
    var discountSectionModel: BehaviorRelay<DiscountSectionModel> { get }
}

class MainMenuViewModel: MainMenuType {
    var events: PublishSubject<MainMenuViewModelEvents> = PublishSubject<MainMenuViewModelEvents>()
    var movies: BehaviorRelay<[Movie]> = BehaviorRelay<[Movie]>(value: [])

    public var discountSectionModel = BehaviorRelay(value: DiscountSectionModel(items: []))
    let service = MovieService(provider: MoyaProvider<MovieTarget>())
    let disposeBag = DisposeBag()

    init() {
        let discountCellModels = self.getDiscountCellModel()
        self.discountSectionModel.accept(DiscountSectionModel(header: "",
                                                              items: discountCellModels))
        setupBindMovies()
    }

    func getDiscountCellModel() -> [DiscountCellModel] {
        var discountCellModels = [DiscountCellModel]()

        for movie in self.movies.value {
            let discountCellModel = DiscountCellModel(movie: movie)
            discountCellModels.append(discountCellModel)
        }
        return discountCellModels
    }

    public func getMoviesByPopularity() {
        service.getMoviesByPopularity(for: 1)
            .map { MainMenuViewModelEvents.getMoviesByPopularity($0) }
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
            let discountCellModels = self.getDiscountCellModel()
            self.discountSectionModel.accept(DiscountSectionModel(header: "",
                                                                  items: discountCellModels))
        }).disposed(by: disposeBag)
    }
}
