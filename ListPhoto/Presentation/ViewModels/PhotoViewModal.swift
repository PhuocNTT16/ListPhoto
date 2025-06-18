//
//  PhotoViewController.swift
//  ListPhoto
//
//  Created by Phuoc's MAc on 17/6/25.
//

import Foundation

class PhotoViewModel {
    
    private let getPhotosUseCase: GetPhotosUseCase
    var photos: [Photo] = []
    var reloadData: (() -> Void)?
    
    init(getPhotosUseCase: GetPhotosUseCase) {
        self.getPhotosUseCase = getPhotosUseCase
    }
    
    func fetchPhotos(page: Int, limit: Int) {
        getPhotosUseCase.execute(page: page, limit: limit) { [weak self] result in
            switch result {
            case .success(let photos):
                self?.photos = photos
                DispatchQueue.main.async{                    
                    self?.reloadData?()
                }
            case .failure(let error):
                print("Error fetching photos: \(error)")
            }
        }
    }
}
