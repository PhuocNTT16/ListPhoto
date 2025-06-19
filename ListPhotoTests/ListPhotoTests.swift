	//
	//  ListPhotoTests.swift
	//  ListPhotoTests
	//
	//  Created by Phuoc's MAc on 17/6/25.
	//

import XCTest
@testable import ListPhoto

class MockNetworkManager: NetworkManagerProtocol {
	var shouldReturnError = false
	var mockPhotos: [Photo] = []
	
	func fetchData<T>(urlString: String, completion: @escaping (Result<T, Error>) -> Void) where T : Decodable {
		if shouldReturnError {
			completion(.failure(NSError(domain: "MockError", code: 1, userInfo: nil)))
		} else {
				// Cast fake data về T
			if let photos = mockPhotos as? T {
				completion(.success(photos))
			} else {
				completion(.failure(NSError(domain: "MockDataTypeMismatch", code: 2, userInfo: nil)))
			}
		}
	}
}

final class ListPhotoTests: XCTestCase {
	
	func testGetPhotos_Success() {
			// Arrange
		let mockNetwork = MockNetworkManager()
		let expectedPhotos = [
			Photo(id: "1", author: "Test", width: 100, height: 100, url: "https://test.com", download_url: "https://test.com")
		]
		mockNetwork.mockPhotos = expectedPhotos
		
		let repository = PhotoRepositoryImpl(networkManager: mockNetwork)
		
		let expectation = XCTestExpectation(description: "Photos fetched")
		
			// Act
		repository.getPhotos(page: 1, limit: 10) { result in
				// Assert
			switch result {
			case .success(let photos):
				XCTAssertEqual(photos, expectedPhotos)
			case .failure:
				XCTFail("Expected success but got failure")
			}
			expectation.fulfill()
		}
		
		wait(for: [expectation], timeout: 2.0)
	}
	
	func testGetPhotos_Failure() {
			// Arrange
		let mockNetwork = MockNetworkManager()
		mockNetwork.shouldReturnError = true
		
		let repository = PhotoRepositoryImpl(networkManager: mockNetwork)
		
		let expectation = XCTestExpectation(description: "Photos fetch failed")
		
			// Act
		repository.getPhotos(page: 1, limit: 10) { result in
				// Assert
			switch result {
			case .success:
				XCTFail("Expected failure but got success")
			case .failure(let error):
				XCTAssertEqual((error as NSError).domain, "MockError")
			}
			expectation.fulfill()
		}
		
		wait(for: [expectation], timeout: 2.0)
	}

}
