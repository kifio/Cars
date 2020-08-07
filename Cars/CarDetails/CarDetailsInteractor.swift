//
//  CarDetailsInteractor.swift
//  Cars
//
//  Created by Ivan Murashov on 07.08.2020.
//  Copyright © 2020 Ivan Murashov. All rights reserved.
//

import UIKit

protocol CarDetailsInteractor {
    func downloadImage(_ urlString: String, completion: @escaping (UIImage) -> Void)
}

class CarDetailsInteractorIml: CarDetailsInteractor {
    
    private let repository: Repository
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    func downloadImage(_ urlString: String, completion: @escaping (UIImage) -> Void) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.repository.downloadImage(
                urlString: urlString,
                onImageDownloaded: { data in
                    if let image = UIImage(data: data) {
                        completion(image)
                    }
            })
        }
    }
}
