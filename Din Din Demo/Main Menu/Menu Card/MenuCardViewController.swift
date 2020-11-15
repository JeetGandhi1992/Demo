//
//  MenuCardViewController.swift
//  Din Din Demo
//
//  Created by jeet_gandhi on 8/11/20.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class MenuCardViewController: UIViewController, MenuNetworkingViewController {

    var alertPresenter: AlertPresenterType = AlertPresenter()
    var loadingSpinner: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    var viewModel: MenuCardViewModel!

    @IBOutlet weak public var handleArea: UIView!
    @IBOutlet weak var collectionView: UICollectionView!

    public var hasReachedAtTop = PublishSubject<Void>()

    let disposeBag = DisposeBag()
    var dataSource: RxCollectionViewSectionedReloadDataSource<MovieSectionModel>?

    var cardHeight: CGFloat {
        UIScreen.main.bounds.height - 75
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLoadingSpinner()
        setupNetworkingEventsUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCollectionView()
        viewModel.getMoviesByRatings()
    }

    private func setupCollectionView() {

        collectionView.register(UINib(nibName: "DiscountCollectionViewCell",
                                      bundle: .main),
                                forCellWithReuseIdentifier: "DiscountCollectionViewCell")

        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.center = CGPoint(x: self.view.frame.width, y: cardHeight/2)

        let dataSource = movieViewDataSource()
        self.dataSource = dataSource

        viewModel.movieSectionModel
            .map { [$0] }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        self.collectionView.rx.didScroll
            .filter({  [weak self] _ in
                guard let self = self else { return false }
                return self.collectionView.contentOffset.y <= -20
            })
            .bind(to: hasReachedAtTop)
            .disposed(by: disposeBag)

        self.collectionView.rx
            .modelSelected(MovieCellModel.self)
            .map { $0.movie }
            .bind(to: self.viewModel.selectedMovie)
            .disposed(by: disposeBag)
    }

}

extension MenuCardViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width,
                      height: cardHeight)
    }
}


extension MenuCardViewController {

    private func movieViewDataSource() -> RxCollectionViewSectionedReloadDataSource<MovieSectionModel> {
        return RxCollectionViewSectionedReloadDataSource<MovieSectionModel>(
            configureCell: configureDiscountCollectionViewCell
        )
    }

    private func configureDiscountCollectionViewCell(_: CollectionViewSectionedDataSource<MovieSectionModel>,
                                                     collectionView: UICollectionView,
                                                     indexPath: IndexPath,
                                                     discountCellModel: MovieCellModel) -> UICollectionViewCell {
        guard let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: "DiscountCollectionViewCell",
                                     for: indexPath) as? DiscountCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.configure(movie: discountCellModel.movie)
        return cell
    }

    
}
