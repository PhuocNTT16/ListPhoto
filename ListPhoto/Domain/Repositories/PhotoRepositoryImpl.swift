//
//  PhotoRepository.swift
//  ListPhoto
//
//  Created by Phuoc's MAc on 17/6/25.
//

import Foundation

class PhotoRepositoryImpl: PhotoRepository {
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func getPhotos(page: Int, limit: Int, completion: @escaping (Result<[Photo], Error>) -> Void) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30  // Thời gian chờ request
        configuration.timeoutIntervalForResource = 200 // Thời gian chờ tải resource
        
        let session = URLSession(configuration: configuration)
        
        var components = URLComponents(string: "https://picsum.photos/v2/list")!
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        guard let url = components.url else {
            print("URL không hợp lệ")
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
            return
        }
        
        networkManager.fetchData(urlString: url.absoluteString) { (result: Result<[Photo], Error>) in
            print("Result", result)
            completion(result)
        }
        
//        let task = session.dataTask(with: url) { data, response, error in
//
//            if let error = error {
//                print("getPhotos - Error: \(error.localizedDescription)")
//                completion(.failure(error))
//                return
//            }
//
//
//            guard let data = data, !data.isEmpty else {
//                print("getPhotos - Error: Dữ liệu trả về rỗng")
//                completion(.failure(NSError(domain: "EmptyData", code: 0, userInfo: nil)))
//                return
//            }
//
//
//            do {
//                let decodedData = try JSONDecoder().decode([Photo].self, from: data)
//                print("getPhotos - Success:\(decodedData)")
//                completion(.success(decodedData))
//            } catch {
//                print("getPhotos - Error decode JSON: \(error.localizedDescription)")
//                completion(.failure(error))
//            }
//        }
//        task.resume()
        
//        let jsonString = """
//        [{"id":"0","author":"Alejandro Escamilla","width":5000,"height":3333,"url":"https://unsplash.com/photos/yC-Yzbqy7PY","download_url":"https://picsum.photos/id/0/5000/3333"},
//        {"id":"1","author":"Alejandro Escamilla","width":5000,"height":3333,"url":"https://unsplash.com/photos/LNRyGwIJr5c","download_url":"https://picsum.photos/id/1/5000/3333"},
//        {"id":"2","author":"Alejandro Escamilla","width":5000,"height":3333,"url":"https://unsplash.com/photos/N7XodRrbzS0","download_url":"https://picsum.photos/id/2/5000/3333"},
//        {"id":"3","author":"Alejandro Escamilla","width":5000,"height":3333,"url":"https://unsplash.com/photos/Dl6jeyfihLk","download_url":"https://picsum.photos/id/3/5000/3333"},
//        {"id":"4","author":"Alejandro Escamilla","width":5000,"height":3333,"url":"https://unsplash.com/photos/y83Je1OC6Wc","download_url":"https://picsum.photos/id/4/5000/3333"},
//        {"id":"5","author":"Alejandro Escamilla","width":5000,"height":3334,"url":"https://unsplash.com/photos/LF8gK8-HGSg","download_url":"https://picsum.photos/id/5/5000/3334"},
//        {"id":"6","author":"Alejandro Escamilla","width":5000,"height":3333,"url":"https://unsplash.com/photos/tAKXap853rY","download_url":"https://picsum.photos/id/6/5000/3333"},
//        {"id":"7","author":"Alejandro Escamilla","width":4728,"height":3168,"url":"https://unsplash.com/photos/BbQLHCpVUqA","download_url":"https://picsum.photos/id/7/4728/3168"},
//        {"id":"8","author":"Alejandro Escamilla","width":5000,"height":3333,"url":"https://unsplash.com/photos/xII7efH1G6o","download_url":"https://picsum.photos/id/8/5000/3333"},
//        {"id":"9","author":"Alejandro Escamilla","width":5000,"height":3269,"url":"https://unsplash.com/photos/ABDTiLqDhJA","download_url":"https://picsum.photos/id/9/5000/3269"},
//        {"id":"10","author":"Paul Jarvis","width":2500,"height":1667,"url":"https://unsplash.com/photos/6J--NXulQCs","download_url":"https://picsum.photos/id/10/2500/1667"},
//        ]
//        """
//        if let jsonData = jsonString.data(using: .utf8) {
//            do {
//                let decodedData = try JSONDecoder().decode([Photo].self, from: jsonData )
//                print("getPhotos - Success:\(decodedData)")
//                completion(.success(decodedData))
//            } catch {
//                print("getPhotos - Error decode JSON: \(error.localizedDescription)")
//                completion(.failure(error))
//            }
//        }
    }
}
