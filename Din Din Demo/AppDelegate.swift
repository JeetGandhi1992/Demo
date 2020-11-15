//
//  AppDelegate.swift
//  Din Din Demo
//
//  Created by jeet_gandhi on 8/11/20.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = MainMenuCoordinator.shared.mainRootController
        window!.makeKeyAndVisible()
        return true
    }

}

