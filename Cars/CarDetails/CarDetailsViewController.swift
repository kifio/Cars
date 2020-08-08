//
//  CarDetailsViewController.swift
//  Cars
//
//  Created by Ivan Murashov on 07.08.2020.
//  Copyright © 2020 Ivan Murashov. All rights reserved.
//

import UIKit

class CarDetailsViewController: UIViewController {
    
    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var plateNumberLabel: UILabel!
    @IBOutlet weak var fuelPercentageLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeigh: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    
    var presenter: CarDetailsPresenter?
    var onPresented: ((CGFloat) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let presenter = self.presenter else {
            return
        }
        
        let viewModel = presenter.getCarDetailsViewModel()
        
        carNameLabel.text = viewModel.name
        plateNumberLabel.text = viewModel.plateNumber
        fuelPercentageLabel.text = viewModel.fuelPercentage
        
        presenter.downloadImage { image in
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let labelHeight = self.carNameLabel.intrinsicContentSize.height + 32.0
        let stackViewHeight = self.stackView.intrinsicContentSize.height + 16.0
        let imageViewHeight = self.imageViewHeigh.constant + 32.0
        let height = labelHeight + stackViewHeight + imageViewHeight
        let offset = UIScreen.main.bounds.height - height

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let frame = self?.view.frame else {
                return
            }
            
            self?.view.frame = CGRect(x: 0.0, y: offset, width: frame.width, height: height)
            }, completion: { [weak self]  _ in
                self?.onPresented?(height)
        })
    }
    
    func dispose(completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: 0.3, animations:  { [weak self] in
            guard let frame = self?.view.frame else {
                return
            }
            self?.view.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.height, width: frame.width, height: frame.height)
            }, completion: completion)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: true, completion: completion)
    }
}
