//
//  MapRouter.swift
//  Cars
//
//  Created by Ivan Murashov on 07.08.2020.
//  Copyright © 2020 Ivan Murashov. All rights reserved.
//

import UIKit

protocol MapRouter {
    func showDetails(_ target: UIViewController, _ car: Car, _ completion: @escaping (CGFloat) -> Void)
    func removeDetailsViewController(_ target: UIViewController)
}

class MapRouterImpl: MapRouter {
    
    var detailsViewController: UIViewController?
    
    func showDetails(_ target: UIViewController, _ car: Car, _ completion: @escaping (CGFloat) -> Void) {
        
        if self.detailsViewController != nil {
            self.removeDetailsViewController(target)
        }
        
        let detailsViewController = CarDetailsViewController(nibName: "CarDetailsViewController", bundle: nil)
        
        detailsViewController.presenter = CarDetailsPresenterImpl(car: car, interactor: CarDetailsInteractorIml(repository: Repository()))
        
        detailsViewController.onPresented = completion
        
        target.addChild(detailsViewController)
        target.view.addSubview(detailsViewController.view)
        detailsViewController.didMove(toParent: detailsViewController)
        
        let x: CGFloat = 0.0
        let y: CGFloat = target.view.frame.maxY
        let height = target.view.frame.height
        let width  = target.view.frame.width
        detailsViewController.view.frame = CGRect(x: x, y: y, width: width, height: height)
        
        self.detailsViewController = detailsViewController
    }
    
    func removeDetailsViewController(_ target: UIViewController) {
        guard let detailsViewController = self.detailsViewController as? CarDetailsViewController else  {
            return
        }
        
        self.detailsViewController = nil
        
        detailsViewController.dispose { _ in
            detailsViewController.view.removeFromSuperview()
            detailsViewController.dismiss(animated: true, completion: nil)
        }
    }
}
