//
//  MenuNetworkingViewController.swift
//  Din Din Demo
//
//  Created by jeet_gandhi on 9/11/20.
//

import UIKit
import RxSwift
import RxCocoa

public protocol MenuViewControllerProtocol {
    associatedtype ViewModelT
    var viewModel: ViewModelT! { get set }

}

public protocol MenuNetworkingViewController: MenuViewControllerProtocol where Self: UIViewController, ViewModelT: NetworkingViewModel {
    var alertPresenter: AlertPresenterType { get }
    var disposeBag: DisposeBag { get }
    var loadingSpinner: UIActivityIndicatorView { get }

    func setupNetworkingEventsUI()
    func setupLoadingSpinner()
}

extension MenuNetworkingViewController {

    public func setupLoadingSpinner() {
        let height = (UIScreen.main.bounds.height/2) - 23
        let width = (UIScreen.main.bounds.width/2) - 23
        self.loadingSpinner.frame = CGRect(x: width, y: height, width: 46, height: 46)
        self.view.addSubview(self.loadingSpinner)
    }

    public func setupNetworkingEventsUI() {
        self.viewModel.events
            .compactMap { $0.toNetworkEvent() }
            .subscribe(onNext: { [weak self] event in
                guard let _self = self else { return }
                switch event {
                    case .waiting:
                        _self.loadingSpinner.startAnimating()
                    case .succeeded:
                        _self.loadingSpinner.stopAnimating()
                    case .failed(let error):
                        _self.loadingSpinner.stopAnimating()
                        _self.presentError(error: error)

                }
            })
            .disposed(by: self.disposeBag)
    }

    public func setupeErrorDisplayEvent() {
        self.viewModel.events
            .compactMap { $0.toNetworkEvent() }
            .subscribe(onNext: { [weak self] event in
                guard let _self = self else { return }
                switch event {
                    case .failed(let error):
                        _self.presentError(error: error)

                    default:
                        break
                }
            })
            .disposed(by: self.disposeBag)
    }

    func presentError(error: Error) {
        self.alertPresenter.presentAlertViewController(alert: error,
                                                       presentingVC: UIViewController.currentRootViewController)
    }

}
