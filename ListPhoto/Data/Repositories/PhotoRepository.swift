//
//  Untitled.swift
//  ListPhoto
//
//  Created by Phuoc's MAc on 17/6/25.
//

protocol PhotoRepository {
    func getPhotos(page: Int, limit: Int, completion: @escaping (Result<[Photo], Error>) -> Void)

}
