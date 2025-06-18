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
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private var lblAuthor: UILabel = {
        let lblAuthor = UILabel()
        lblAuthor.translatesAutoresizingMaskIntoConstraints = false
        return lblAuthor
    }()
    private var lblSize: UILabel = {
        let lblSize = UILabel()
        lblSize.translatesAutoresizingMaskIntoConstraints = false
        return lblSize
    }()
    
    private var loadingView: UIActivityIndicatorView = {
        let loadingView = UIActivityIndicatorView()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        return loadingView
    }()
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        setupView()
//    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
          super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
      }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotParseResponse)
        }
        
        return image
    }
    
    func configure(with photo: Photo) {
//        contentView.backgroundColor = .cyan
//        if let url = URL(string: photo.download_url) {
//            let data = try? Data(contentsOf: url)
//            if let data = data {
//                img_photo.image = UIImage(data: data)
//            }
//        }
                
        lblAuthor.text = photo.author
        lblSize.text = "Size: \(photo.width)x\(photo.height)"
        loadingView.isHidden = false
//        img_photo.image = nil
        
//        imageView.heightAnchor.constraint(equalToConstant: (CGFloat)(photo.height)).isActive = true
        
        Task {
           do {
               let url = URL(string: photo.download_url)!//let url = URL(string: "https://picsum.photos/200/300")!
               let image = try await loadImage(from: url)
//               img_photo.image = image
               DispatchQueue.main.async{
                   self.img_photo.image = image
                   
                   self.loadingView.isHidden = true
               }
//               lblAuthor.text = photo.author
//               lblSize.text = "Size: \(photo.width)x\(photo.height)"
           } catch {
               print("Error loading image: \(error)")
               
               DispatchQueue.main.async{
                   self.img_photo.image = nil
                   
                   self.loadingView.isHidden = true
               }
           }
            
//           loadingView.isHidden = true
        }
    }
    
    private func setupView() {
        contentView.addSubview(lblSize)
        NSLayoutConstraint.activate([
            lblSize.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            lblSize.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            lblSize.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -20),
            lblSize.heightAnchor.constraint(equalToConstant: 20),
        ])
        
        contentView.addSubview(lblAuthor)
        NSLayoutConstraint.activate([
            lblAuthor.leadingAnchor.constraint(equalTo: lblSize.leadingAnchor),
            lblAuthor.trailingAnchor.constraint(equalTo: lblSize.trailingAnchor),
            lblAuthor.bottomAnchor.constraint(equalTo: lblSize.topAnchor, constant: -20),
            lblAuthor.heightAnchor.constraint(equalToConstant: 20),
        ])
        
        contentView.addSubview(img_photo)
        NSLayoutConstraint.activate([
            img_photo.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 20),
            img_photo.leadingAnchor.constraint(equalTo: lblAuthor.leadingAnchor),
            img_photo.trailingAnchor.constraint(equalTo: lblAuthor.trailingAnchor),
            
            img_photo.bottomAnchor.constraint(equalTo: lblAuthor.topAnchor, constant: -20)
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
    }

}
