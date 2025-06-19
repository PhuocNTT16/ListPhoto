//
//  NetworkManagerProtocol.swift
//  ListPhoto
//
//  Created by Phuoc's MAc on 19/6/25.
//

import Foundation

protocol NetworkManagerProtocol {
	func fetchData<T: Decodable>(urlString: String, completion: @escaping (Result<T, Error>) -> Void)
}
