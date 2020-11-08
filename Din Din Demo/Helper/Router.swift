//
//  Router.swift
//  Din Din Demo
//
//  Created by jeet_gandhi on 9/11/20.
//

import UIKit

protocol RouterProtocol {
    func viewController(forViewModel viewModel: Any) -> UIViewController
}

struct Router: RouterProtocol {
    func viewController(forViewModel viewModel: Any) -> UIViewController {
        switch viewModel {

            // MARK: OTHERS
            case let viewModel as MainMenuViewModel:
                return UIViewController.make(viewController: MainMenuViewController.self, viewModel: viewModel)

            default:
                fatalError("Unable to find corresponding View Controller for \(viewModel)")
        }
    }

}
