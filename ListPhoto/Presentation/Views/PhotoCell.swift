	//
	//  PhotoCell.swift
	//  ListPhoto
	//
	//  Created by Phuoc's MAc on 17/6/25.
	//

import UIKit

class PhotoCell: UITableViewCell {
	static let reuseIdentifier = "PhotoCell"
	
	internal lazy var img_photo: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.clipsToBounds = true
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()
	private var lblAuthor: UILabel = {
		let lblAuthor = UILabel()
		lblAuthor.translatesAutoresizingMaskIntoConstraints = false
		lblAuthor.clipsToBounds = true
		return lblAuthor
	}()
	private var lblSize: UILabel = {
		let lblSize = UILabel()
		lblSize.translatesAutoresizingMaskIntoConstraints = false
		lblSize.clipsToBounds = true
		return lblSize
	}()
	
	private var loadingView: UIActivityIndicatorView = {
		let loadingView = UIActivityIndicatorView()
		loadingView.clipsToBounds = true
		loadingView.translatesAutoresizingMaskIntoConstraints = false
		return loadingView
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(with photo: Photo, tableView: UITableView ) {                
		lblAuthor.text = photo.author
		lblSize.text = "Size: \(photo.width)x\(photo.height)"
		img_photo.image = UIImage(named: "DefaultImage")
		loadingView.isHidden = false
		
		let imageURL = URL(string: photo.download_url)!
		let aspectRatio =  CGFloat(photo.height) / CGFloat(photo.width)
		print("aspectRatio nè: \(aspectRatio), height /(width): \(photo.height) / \(photo.width)")
		
		loadImageCompatible(from: imageURL) { result in
			switch result {
			case .success(let image):
				DispatchQueue.main.async {
					self.img_photo.image = image
					self.loadingView.isHidden = true
					
					self.img_photo.constraints.forEach { constraint in
						if constraint.firstAttribute == .height {
							self.img_photo.removeConstraint(constraint)
						}
					}
					
					let constraint = self.img_photo.heightAnchor.constraint(
						equalTo: self.img_photo.widthAnchor,
						multiplier: aspectRatio
					)
					
					constraint.priority = .required
					constraint.isActive = true
					
					tableView.beginUpdates()
					tableView.endUpdates()
				}
			case .failure(let error):
				print("Image downloading failed:", error.localizedDescription)
				DispatchQueue.main.async{
//					self.img_photo.image = nil
					self.loadingView.isHidden = true
				}
			}
		}	
	}
	
	private func setupView() {		
		contentView.addSubview(img_photo)
		NSLayoutConstraint.activate([
			img_photo.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 20),
			img_photo.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			img_photo.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			
//			img_photo.bottomAnchor.constraint(equalTo: lblAuthor.topAnchor, constant: -20)
		])
		
		let tempConstraint = img_photo.heightAnchor.constraint(equalToConstant: 400)
		tempConstraint.priority = .defaultLow
		tempConstraint.isActive = true
		
		contentView.addSubview(lblAuthor)
		NSLayoutConstraint.activate([
			lblAuthor.topAnchor.constraint(equalTo: img_photo.bottomAnchor, constant: 20),
			lblAuthor.leadingAnchor.constraint(equalTo: img_photo.leadingAnchor),
			lblAuthor.trailingAnchor.constraint(equalTo: img_photo.trailingAnchor),
			lblAuthor.heightAnchor.constraint(equalToConstant: 20),
		])
		
		contentView.addSubview(lblSize)
		NSLayoutConstraint.activate([
			lblSize.topAnchor
				.constraint(equalTo: lblAuthor.bottomAnchor, constant: 20),
			lblSize.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			lblSize.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			lblSize.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -20),
			lblSize.heightAnchor.constraint(equalToConstant: 20),
		])
		
		contentView.addSubview(loadingView)
			//        loadingView.startAnimating()
			//        loadingView.hidesWhenStopped = false
		NSLayoutConstraint.activate([
			loadingView.topAnchor.constraint(equalTo: img_photo.topAnchor),
			loadingView.leadingAnchor.constraint(equalTo: img_photo.leadingAnchor),
			loadingView.trailingAnchor.constraint(equalTo: img_photo.trailingAnchor),
			loadingView.bottomAnchor.constraint(equalTo: img_photo.bottomAnchor)
		])
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		img_photo.image = nil
		lblAuthor.text = ""
		lblSize.text = ""
	}
	
}
