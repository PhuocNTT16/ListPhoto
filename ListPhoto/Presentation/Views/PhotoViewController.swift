	//
	//  PhotoViewController.swift
	//  ListPhoto
	//
	//  Created by Phuoc's MAc on 17/6/25.
	//

import UIKit

class PhotoViewController: UIViewController
{
	var viewModel: PhotoViewModel!
	
	var isSearched: Bool = false
	var isLoading: Bool = false
	var isLoadMore: Bool = false
	var lstDisplayedPhotos = [Photo]()
	var offset: Int = 10
	var currenPage: Int = 1
	let loadMoreOffset: Int = 10
	var searchKey: String = ""
	var loadingView: UIView = UIView()
	
	@IBOutlet weak var tbl_photo: UITableView!
	@IBOutlet weak var tf_searchKey: UITextField!
	@IBOutlet weak var btn_search: UIButton!
	@IBOutlet weak var constraint_searchViewHeight: NSLayoutConstraint!
	@IBOutlet weak var constraint_tableContentTop: NSLayoutConstraint!
	
	@IBOutlet weak var lbl_noData: UILabel!
	
	private let footerView: UIView = {
		let footerView = UIView( frame: .zero)
		footerView.isHidden = true
		return footerView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.hideKeyboardWhenTappedAround()
		
		setUpView()
		
		SetTableViewConstraint()
		
		let networkManager = NetworkManager()
		let photoRepository = PhotoRepositoryImpl(networkManager: networkManager)
		let getPhotosUseCase = GetPhotosUseCaseImpl(photoRepository: photoRepository)
		viewModel = PhotoViewModel(getPhotosUseCase: getPhotosUseCase)
		
		viewModel.reloadData = { [weak self] in
			guard let self = self else {
				return
			}
			getDisplayedData ()
			
			self.tbl_photo.reloadData()
		}
		
		self.getData()
	}
	
	@IBAction func btnSearchTouchUpInSide(_ sender: Any) {
		isSearched = !isSearched
		if(isSearched){
			btn_search.tintColor = .orange
		}
		else{
			btn_search.tintColor = .black
			tf_searchKey.text = ""
			getDisplayedData()
		}
		
		SetTableViewConstraint()
	}
	
	@IBAction func handleTextChanged(_ sender: Any) {
		let original = tf_searchKey.text ?? ""
		let cleaned = original.removingDiacriticsAndEmoji
		
		if original != cleaned {
			tf_searchKey.text = cleaned
		}
	}
	
	func SetTableViewConstraint() {
		tf_searchKey.isHidden = !isSearched
		if(isSearched){
			constraint_tableContentTop.constant = 20 + constraint_searchViewHeight.constant + 20
		}
		else {
			constraint_tableContentTop.constant = 20
			searchKey = ""
		}
	}
	
	func setUpView() {
		tbl_photo.delegate = self
		tbl_photo.dataSource = self
		tbl_photo.register(PhotoCell.self, forCellReuseIdentifier: PhotoCell.reuseIdentifier)
		tbl_photo.showsVerticalScrollIndicator = false
		tbl_photo.showsHorizontalScrollIndicator = false
		tbl_photo.isSpringLoaded = true
		tbl_photo.separatorStyle = .none
		
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
		tbl_photo.refreshControl = refreshControl		
		tbl_photo.tableFooterView = createFooterView()
		tbl_photo.estimatedRowHeight = 400
		tbl_photo.rowHeight = UITableView.automaticDimension
		
		tf_searchKey.returnKeyType = .search
		tf_searchKey.delegate = self
		tf_searchKey.text = searchKey
		
		loadingView = createLoadingView(viewFrame: tbl_photo.frame)
		view.addSubview(loadingView)
		
		btn_search.setTitle("", for: .normal)
	}
	
	@objc func refreshData() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			self.lstDisplayedPhotos = []
			self.isSearched = true
			self.btnSearchTouchUpInSide(NSNull())
			self.tbl_photo.refreshControl?.endRefreshing()
			self.getData()
		}
	}
	
	func createFooterView() -> UIView {
		footerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
		let lbl_loading = UILabel(frame: .zero)
		lbl_loading.text = "loading..."
		footerView.addSubview(lbl_loading)
		lbl_loading.frame = CGRect(x: 0, y: 0, width: footerView.frame.width, height: 50)
		return footerView
	}
	
	func loadMoreData() {
		if !isSearched{
			
			isLoading = true
			
			footerView.isHidden = false
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
				self.getData()
				self.isLoading = false
				self.tbl_photo.reloadData()
				self.footerView.isHidden = true
			}
		}
		else{
			isLoadMore = true
		}
	}
	
	func getData() {
		if(isLoadMore && offset % 100 == 0 || (currenPage == 1 && offset == 10)){
			getDataFromServer()
		}
		else {
			offset += loadMoreOffset
		}
		
		getDisplayedData ()
	}
	
	func getDisplayedData () {
		if !viewModel.photos.isEmpty {
			if isSearched && !searchKey.isBlank {
				let lstRes = viewModel.photos.filter({$0.author.lowercased().contains(searchKey.lowercased())
					|| $0.id.lowercased().contains(searchKey.lowercased())})
				
				print("lstRes search: \(lstRes)")
				lstDisplayedPhotos = []
				
				if !lstRes.isEmpty {
					lstDisplayedPhotos.append(contentsOf: lstRes)
				}
				
				self.tbl_photo.reloadData()
				
				lbl_noData.isHidden = !lstDisplayedPhotos.isEmpty
				loadingView.isHidden = true
			}
			else{
				let startIndex = lstDisplayedPhotos.count
				var endIndex = startIndex + offset
				if(endIndex >= viewModel.photos.count){
					endIndex = viewModel.photos.count - 1
				}
				
				if(startIndex >= endIndex){
					getDataFromServer()
					return
				}
				
				let slice = viewModel.photos[startIndex...endIndex]
				
				lstDisplayedPhotos.append(contentsOf: slice)
			}
			
		}
		else{
			lbl_noData.isHidden = false
			loadingView.isHidden = true
		}
		
	}
	
	func getDataFromServer()  {
		currenPage = isLoadMore ?  currenPage + 1 : 1
		self.viewModel.fetchPhotos(page: currenPage, limit: 101)
	}
	
}

extension PhotoViewController: UITableViewDelegate,  UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return lstDisplayedPhotos.count//viewModel.photos.count
	}
	
//	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//			//        let photo = viewModel.photos[indexPath.item]
//		return 400//(CGFloat)(photo.height) + 30 + 40
//	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let photo = lstDisplayedPhotos[indexPath.item]//viewModel.photos[indexPath.item]
		
		let cell = tbl_photo.dequeueReusableCell(withIdentifier: PhotoCell.reuseIdentifier, for: indexPath) as! PhotoCell
		cell.backgroundColor = UIColor.white
		cell.selectionStyle = .none
		cell.separatorInset = .zero
		cell.configure(with: photo, tableView: tableView)		
		return cell
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if indexPath.row == offset {
			isLoadMore = true
			loadMoreData()
		}
	}
}

extension PhotoViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		
		getDisplayedData()
		return true
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		var updatedText: String = ""
		
		let currentText = textField.text ?? ""
		if let textRange = Range(range, in: currentText) {
			updatedText = currentText.replacingCharacters(in: textRange, with: string)
		}
		else {
			updatedText = "" 
		}				
		let cleaned = updatedText.removingDiacriticsAndEmoji
		print ("cleaned là: \(cleaned)")
		
		if cleaned.count <= 15 {
			searchKey = cleaned
			return true
		}
		else{
			return false
		}
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		textField.text = searchKey
	}
	
}
