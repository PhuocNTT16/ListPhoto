	//
	//  NetworkManager.swift
	//  ListPhoto
	//
	//  Created by Phuoc's MAc on 17/6/25.
	//

import Foundation

class NetworkManager: NetworkManagerProtocol {
	private let session: URLSession
	
	init() {
		let config = URLSessionConfiguration.default
		config.timeoutIntervalForRequest = 15
		config.timeoutIntervalForResource = 30
		config.requestCachePolicy = .reloadIgnoringLocalCacheData  
		self.session = URLSession(configuration: config)
	}
	
	func fetchData<T: Decodable>(urlString: String, completion: @escaping (Result<T, Error>) -> Void) {
		guard let url = URL(string: urlString) else {
			completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
			return
		}
		
//		let task = URLSession.shared.dataTask(with: url) { data, response, error in
		let task = session.dataTask(with: url) { data, response, error in
			if let error = error as? URLError, error.code == .timedOut {
				completion(.failure(NSError(domain: "Timeout", code: URLError.timedOut.rawValue)))
				return
			}
			if let error = error {
				completion(.failure(error))
				return
			}
			
			guard let data = data else {
				completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
				return
			}
			
			do {
				let decodedData = try JSONDecoder().decode(T.self, from: data)
				completion(.success(decodedData))
			} catch {
				completion(.failure(error))
			}
		}
		
		task.resume()
	}
}
