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
    var loadingSpinner: UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
    var viewModel: MainMenuViewModel!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var menuContainerView: UIView!
    var menuCardViewController: MenuCardViewController!

    enum MenuCardState {
        case expanded
        case collapsed
    }

    let colours: [UIColor] = [.systemRed, .systemYellow, .systemTeal, .systemBlue, .systemPink]
    let disposeBag = DisposeBag()

    var dataSource: RxCollectionViewSectionedReloadDataSource<DiscountSectionModel>?

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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLoadingSpinner()

        viewModel = MainMenuViewModel(discounts: [.systemRed, .systemYellow, .systemTeal, .systemBlue, .systemPink])
        
        setupNetworkingEventsUI()
        setupMenuCard()
        viewModel.getMoviesByPopularity()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCollectionView()
        self.pageControl.numberOfPages = colours.count
    }

    private func setupCollectionView() {
        collectionView
            .register(DiscountCollectionViewCell.self, forCellWithReuseIdentifier: "\(DiscountCollectionViewCell.self)")

        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.center = CGPoint(x: self.view.frame.width, y: self.view.frame.height/2)

        let dataSource = discountViewDataSource()
        self.dataSource = dataSource

        viewModel.discountSectionModel
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
    }

    private func setupMenuCard() {

        menuCardViewController = MenuCardViewController(nibName:"MenuCardViewController",
                                                        bundle:nil)
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

        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(MainMenuViewController.handleCardTap(recogniser:)))

        menuCardViewController.view.addGestureRecognizer(tapGestureRecognizer)
        menuCardViewController.view.addGestureRecognizer(panGestureRecognizer)
        self.view.addGestureRecognizer(tapGestureRecognizer2)
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

    private func discountViewDataSource() -> RxCollectionViewSectionedReloadDataSource<DiscountSectionModel> {
        return RxCollectionViewSectionedReloadDataSource<DiscountSectionModel>(
            configureCell: configureDiscountCollectionViewCell
        )
    }

    private func configureDiscountCollectionViewCell(_: CollectionViewSectionedDataSource<DiscountSectionModel>,
                                                     collectionView: UICollectionView,
                                                     indexPath: IndexPath,
                                                     discountCellModel: DiscountCellModel) -> UICollectionViewCell {
        guard let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: "\(DiscountCollectionViewCell.self)",
                                     for: indexPath) as? DiscountCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.configure(discount: discountCellModel.discount)
        return cell
    }
}

extension MainMenuViewController {

    @objc
    func handleCardTap(recogniser: UITapGestureRecognizer) {
        switch recogniser.state {
            case .ended:
                if recogniser.view == self.view {
                    if nextState == .collapsed {
                        animateTransitionIfNeeded(state: nextState)
                    }
                } else {
                    animateTransitionIfNeeded(state: nextState)
                }

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

    func animateTransitionIfNeeded (state: MenuCardState, duration:TimeInterval = 0.45) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) { [weak self] in
                guard let self = self else { return }
                switch state {
                    case .expanded:
                        self.menuCardHeightConstraint.constant = self.menuCardHeight
                    case .collapsed:
                        self.menuCardHeightConstraint.constant = self.cardHandleAreaHeight
                }
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