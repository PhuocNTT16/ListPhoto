	//
	//  PhotoRepository.swift
	//  ListPhoto
	//
	//  Created by Phuoc's MAc on 17/6/25.
	//

import Foundation

class PhotoRepositoryImpl: PhotoRepository {
	
//	private let networkManager: NetworkManager
//	init(networkManager: NetworkManager) {
//		self.networkManager = networkManager
//	}
	
	private let networkManager: NetworkManagerProtocol
	
	init(networkManager: NetworkManagerProtocol) {
		self.networkManager = networkManager
	}
	
	
	func getPhotos(page: Int, limit: Int, completion: @escaping (Result<[Photo], Error>) -> Void) {
		
		var components = URLComponents(string: "https://picsum.photos/v2/list")!
		components.queryItems = [
			URLQueryItem(name: "page", value: String(page)),
			URLQueryItem(name: "limit", value: String(limit))
		]
		
		guard let url = components.url else {
			print("getPhotos - URL không hợp lệ")
			completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
			return
		}
		
		networkManager.fetchData(urlString: url.absoluteString) { (result: Result<[Photo], Error>) in
			switch result {
			case .success(let photos):
				print("getPhotos - Success: \(photos.count) photos")
				completion(.success(photos))
			case .failure(let error):
				if let urlError = error as? URLError, urlError.code == .timedOut {
					print("getPhotos - Timeout Error")
					let timeoutError = NSError(domain: "Timeout", code: URLError.timedOut.rawValue, userInfo: [
						NSLocalizedDescriptionKey: "Request timeout"
					])
					completion(.failure(timeoutError))
				} else {
					print("getPhotos - Other Error: \(error.localizedDescription)")
					completion(.failure(error))
				}
			}
		}
	}
}
