//
//  MainMenuCoordinator.swift
//  Din Din Demo
//
//  Created by jeet_gandhi on 12/11/20.
//

import UIKit
import RxSwift
import RxCocoa
import Hero

class MainMenuCoordinator {

    public static let shared = MainMenuCoordinator(providerFactory: ConcreteProviderFactory.shared)
    let disposeBag = DisposeBag()

    var mainRootController: UIViewController!
    var providerFactory: ProviderFactory

    init(providerFactory: ProviderFactory) {
        self.mainRootController = MainMenuCoordinator.getMainMenuViewController(providerFactory: providerFactory)
        self.providerFactory = providerFactory
    }

    private static func getMainMenuViewController(providerFactory: ProviderFactory) -> UIViewController {
        let viewModel = MainMenuViewModel(provider: providerFactory.movieProvider)
        guard let viewController = Router().viewController(forViewModel: viewModel) as? MainMenuViewController else {
            fatalError("MainMenuViewController not found")
        }
        viewController.menuCardViewController = MainMenuCoordinator.getMenuCardViewController(providerFactory: providerFactory)
        viewModel.selectedMovie
            .asDriver(onErrorJustReturn: Movie())
            .drive(onNext: { [weak viewController] (movie) in
                let cardHeroId = "\(movie.id ?? 0)"
                weak var detailsViewController = getMovieDetail(for: movie) as? MovieDetailViewController
                detailsViewController?.hero.isEnabled = true
//                detailsViewController?.view.hero.isEnabledForSubviews = true
                detailsViewController?.hero.modalAnimationType = .zoom

                detailsViewController?.view.hero.id = cardHeroId
                detailsViewController?.view.hero.modifiers = [.useScaleBasedSizeChange]

                viewController?.present(detailsViewController!, animated: true, completion: {
                    detailsViewController?.hero.modalAnimationType = .autoReverse(presenting: .zoom)
                })
            })
            .disposed(by: viewModel.disposeBag)
        return viewController
    }

    private static func getMenuCardViewController(providerFactory: ProviderFactory) -> MenuCardViewController {
        let viewModel = MenuCardViewModel(provider: providerFactory.movieProvider)

        guard let viewController = Router().viewController(forViewModel: viewModel) as? MenuCardViewController else {
            fatalError("MainMenuViewController not found")
        }
        viewModel.selectedMovie
            .asDriver(onErrorJustReturn: Movie())
            .drive(onNext: { [weak viewController] (movie) in
                viewController?.present(getMovieDetail(for: movie), animated: true, completion: nil)
            })
            .disposed(by: viewModel.disposeBag)
        return viewController
    }


    private static func getMovieDetail(for movie: Movie) -> UIViewController {
        let viewModel = MovieDetailViewModel(movie: movie)

        let viewController = Router().viewController(forViewModel: viewModel)
        return viewController
    }
}
