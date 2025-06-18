//
//  UserCase.swift
//  ListPhoto
//
//  Created by Phuoc's MAc on 17/6/25.
//

protocol GetPhotosUseCase {
    func execute(page: Int, limit: Int, completion: @escaping (Result<[Photo], Error>) -> Void)
}

class GetPhotosUseCaseImpl: GetPhotosUseCase {
    private let photoRepository: PhotoRepository
    
    init(photoRepository: PhotoRepository) {
        self.photoRepository = photoRepository
    }
    
    func execute(page: Int, limit: Int, completion: @escaping (Result<[Photo], Error>) -> Void) {
        photoRepository.getPhotos(page: page, limit: limit, completion: completion)
    }
}
