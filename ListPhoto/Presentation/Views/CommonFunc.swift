//
//  CommonFunc.swift
//  ListPhoto
//
//  Created by Phuoc's MAc on 18/6/25.
//
import UIKit

extension String {
    var isBlank: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
	
	var removingDiacriticsAndEmoji: String {
		let noDiacritics = self.folding(options: .diacriticInsensitive, locale: .current)

		let filtered = noDiacritics.filter { char in
			return char.isLetter || char.isNumber || " !@#$%^&*():.,<>/\\[]?_+=-".contains(char)
		}

		return String(filtered.prefix(15))
	}
}

func createLoadingView(viewFrame: CGRect) -> UIView {
    let loadingView = UIView(frame: CGRect(x: 0, y: 0, width: viewFrame.width, height: viewFrame.height))
	loadingView.backgroundColor = .gray
	
	let activityIndicator: UIActivityIndicatorView
	
	if #available(iOS 13.0, *) {
		activityIndicator = UIActivityIndicatorView(style: .medium)
	} else {
		activityIndicator = UIActivityIndicatorView(style: .gray) // tương đương .medium trước iOS 13
	}
	
    activityIndicator.center = loadingView.center
    activityIndicator.startAnimating()
    loadingView.addSubview(activityIndicator)
    return loadingView
}

@available(iOS 15.0, *)
func loadImage(from url: URL) async throws -> UIImage {
	let (data, _) = try await URLSession.shared.data(from: url)
	
	guard let image = UIImage(data: data) else {
		throw URLError(.cannotParseResponse)
	}
	
	return image
}


func loadImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
	URLSession.shared.dataTask(with: url) { data, response, error in
		if let error = error {
			completion(.failure(error))
			return
		}

		guard let data = data, let image = UIImage(data: data) else {
			completion(.failure(URLError(.cannotParseResponse)))
			return
		}

		completion(.success(image))
	}.resume()
}


func loadImageCompatible (from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void){
	if #available(iOS 15.0, *) {
			Task {
				do {
					let image = try await loadImage(from: url)
					completion(.success(image))
				} catch {
					completion(.failure(error))
				}
			}
		} else {
			loadImage(from: url, completion: completion)
		}
}
