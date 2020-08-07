//
//  AppDelegate.swift
//  Cars
//
//  Created by Ivan Murashov on 07.08.2020.
//  Copyright © 2020 Ivan Murashov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let mapInteractor = MapInteractorImpl(repository: Repository())
        let mapRouter = MapRouterImpl()
        let mapPresenter = MapPresenterImpl(interactor: mapInteractor, router: mapRouter)
        let mapViewController = MapViewController(presenter: mapPresenter)
        let navigationController = UINavigationController(rootViewController: mapViewController)
       
        navigationController.setNavigationBarHidden(true, animated: false)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = navigationController
        return true
    }
}

