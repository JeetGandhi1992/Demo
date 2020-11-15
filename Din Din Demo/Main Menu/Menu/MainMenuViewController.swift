//
//  MainMenuViewController.swift
//  Din Din Demo
//
//  Created by jeet_gandhi on 8/11/20.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class MainMenuViewController: UIViewController, MenuNetworkingViewController {

    var alertPresenter: AlertPresenterType = AlertPresenter()
    var loadingSpinner: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    var viewModel: MainMenuViewModel!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var menuContainerView: UIView!
    var menuCardViewController: MenuCardViewController!

    enum MenuCardState {
        case expanded
        case collapsed
    }

    let disposeBag = DisposeBag()

    var dataSource: RxCollectionViewSectionedReloadDataSource<MovieSectionModel>?

    var cardVisible = false
    var nextState: MenuCardState {
        return cardVisible ? .collapsed : .expanded
    }

    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0

    var menuCardHeight: CGFloat {
        self.view.frame.height
    }
    let cardHandleAreaHeight: CGFloat = 250

    @IBOutlet weak var menuCardHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var discountMenuHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLoadingSpinner()
        setupNetworkingEventsUI()
        setupMenuCard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCollectionView()
        viewModel.getMoviesByPopularity()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.menuContainerView.roundCorners(corners: [.topLeft, .topRight], radius: 30)
    }

    private func setupCollectionView() {

        self.discountMenuHeightConstraint.constant = UIScreen.main.bounds.height - self.cardHandleAreaHeight + 30

        collectionView.register(UINib(nibName: "DiscountCollectionViewCell",
                                      bundle: .main),
                                forCellWithReuseIdentifier: "DiscountCollectionViewCell")

        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.center = CGPoint(x: self.view.frame.width, y: self.view.frame.height/2)

        let dataSource = discountViewDataSource()
        self.dataSource = dataSource

        viewModel.movieSectionModel
            .map { [$0] }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        self.pageControl.rx.controlEvent(.valueChanged)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.collectionView.scrollToItem(at: IndexPath(item: self.pageControl.currentPage, section: 0),
                                                 at: .centeredHorizontally,
                                                 animated: true)
            })
            .disposed(by: disposeBag)

        self.pageControl.numberOfPages = self.viewModel.movies.value.count

        self.viewModel.movieSectionModel
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.pageControl.numberOfPages = self.viewModel.movies.value.count
            })
            .disposed(by: disposeBag)

        self.collectionView.rx
            .modelSelected(MovieCellModel.self)
            .map { $0.movie }
            .bind(to: self.viewModel.selectedMovie)
            .disposed(by: disposeBag)
    }

    private func setupMenuCard() {

        self.addChild(menuCardViewController)
        self.menuContainerView.addSubview(menuCardViewController.view)
        menuCardViewController.view.frame = menuContainerView.bounds
        menuCardViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            menuCardViewController.view.leadingAnchor.constraint(equalTo: menuContainerView.leadingAnchor),
            menuCardViewController.view.trailingAnchor.constraint(equalTo: menuContainerView.trailingAnchor),
            menuCardViewController.view.topAnchor.constraint(equalTo: menuContainerView.topAnchor),
            menuCardViewController.view.bottomAnchor.constraint(equalTo: menuContainerView.bottomAnchor)
        ])
        menuCardViewController.view.backgroundColor = .black
        menuCardViewController.didMove(toParent: self)
        menuCardViewController.view.clipsToBounds = true

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainMenuViewController.handleCardTap(recogniser:)))

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MainMenuViewController.handleCardPan(recogniser:)))

        menuCardViewController.handleArea.addGestureRecognizer(tapGestureRecognizer)
        menuCardViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
        menuCardViewController.hasReachedAtTop
            .filter({ [weak self] _ -> Bool in
                guard let self = self else { return false }
                return self.nextState == .collapsed
            })
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self]_ in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.animateTransitionIfNeeded(state: self.nextState)
                }
            })
            .disposed(by: menuCardViewController.disposeBag)
    }
}

extension MainMenuViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width,
                      height: collectionView.frame.height)
    }
}

extension MainMenuViewController: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}

extension MainMenuViewController {

    private func discountViewDataSource() -> RxCollectionViewSectionedReloadDataSource<MovieSectionModel> {
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

extension MainMenuViewController {

    @objc
    func handleCardTap(recogniser: UITapGestureRecognizer) {
        switch recogniser.state {
            case .ended:
                animateTransitionIfNeeded(state: nextState)
            default:
                break
        }
    }

    @objc
    func handleCardPan (recogniser: UIPanGestureRecognizer) {
        switch recogniser.state {
            case .began:
                startInteractiveTransition(state: nextState)
            case .changed:
                let translation = recogniser.translation(in: self.menuCardViewController.view)
                var fractionComplete = translation.y / menuCardHeight
                fractionComplete = cardVisible ? fractionComplete : -fractionComplete
                updateInteractiveTransition(fractionCompleted: fractionComplete)
            case .ended:
                continueInteractiveTransition()
            default:
                break
        }
    }

    func animateTransitionIfNeeded (state: MenuCardState, duration: TimeInterval = 0.45) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) { [weak self] in
                guard let self = self else { return }
                switch state {
                    case .expanded:
                        self.menuCardHeightConstraint.constant = self.menuCardHeight
                        self.menuTopConstraint.constant = -self.menuCardHeight + self.cardHandleAreaHeight 
                    case .collapsed:
                        self.menuCardHeightConstraint.constant = self.cardHandleAreaHeight
                        self.menuTopConstraint.constant = 0
                }
                self.menuCardViewController.view.layoutIfNeeded()
                self.view.layoutIfNeeded()
            }

            frameAnimator.addCompletion { [weak self] _ in
                guard let self = self else { return }
                self.cardVisible = !self.cardVisible
                self.runningAnimations.removeAll()
            }

            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)

            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) { [weak self] in
                guard let self = self else { return }
                switch state {
                    case .expanded:
                        self.collectionView.alpha = 0
                    case .collapsed:
                        self.collectionView.alpha = 1
                }
            }

            blurAnimator.startAnimation()
            runningAnimations.append(blurAnimator)

        }
    }

    func startInteractiveTransition(state: MenuCardState, duration: TimeInterval = 0.45) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }

    func updateInteractiveTransition(fractionCompleted: CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }

    func continueInteractiveTransition() {
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil,
                                       durationFactor: 0)
        }
    }

}
