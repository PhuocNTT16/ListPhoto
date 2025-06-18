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
    
//    override func viewDidLayoutSubviews() {
//        lbl_noData.isHidden = !lstDisplayedPhotos.isEmpty
//        footerView.isHidden = !isLoading
//    }
          
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
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tbl_photo.refreshControl = refreshControl
        
        tbl_photo.tableFooterView = createFooterView()
        
        tf_searchKey.returnKeyType = .search
        tf_searchKey.delegate = self
        tf_searchKey.text = searchKey
        
        loadingView = createLoadingView(viewFrame: tbl_photo.frame)
        view.addSubview(loadingView)
    }
    
    @objc func refreshData() {
       DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
		   self.lstDisplayedPhotos = []
           self.isSearched = false
           self.SetTableViewConstraint()
           self.tbl_photo.refreshControl?.endRefreshing()
           self.getData()
       }
   }
    
    func createFooterView() -> UIView {
        footerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
//        let activityIndicator = UIActivityIndicatorView(style: .medium)
//        activityIndicator.center = footerView.center
//        activityIndicator.startAnimating()
//        footerView.addSubview(activityIndicator)
        let lbl_loading = UILabel(frame: .zero)
        lbl_loading.text = "loading..."
        footerView.addSubview(lbl_loading)
		lbl_loading.frame = CGRect(x: 0, y: 0, width: footerView.frame.width, height: 50)
        return footerView
    }
    
    func loadMoreData() {
        if !isSearched{
            
//       guard !isLoading else { return }
       
            isLoading = true
            
            footerView.isHidden = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
    
    func getDisplayedData (){
        if !viewModel.photos.isEmpty {
            
            if isSearched && !searchKey.isBlank {
                print("search nè")
                let lstRes = viewModel.photos.filter({$0.author.lowercased().contains(searchKey.lowercased())
                    || $0.id.lowercased().contains(searchKey.lowercased())})
                lstDisplayedPhotos = []
                lstDisplayedPhotos.append(contentsOf: lstRes)
                
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
            lbl_noData.isHidden = true
            loadingView.isHidden = true
        }
        
//        lbl_noData.isHidden = !lstDisplayedPhotos.isEmpty
//        loadingView.isHidden = true
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
     
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
 //        let photo = viewModel.photos[indexPath.item]
         return 400//(CGFloat)(photo.height) + 30 + 40
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let photo = lstDisplayedPhotos[indexPath.item]//viewModel.photos[indexPath.item]
         
         let cell = tbl_photo.dequeueReusableCell(withIdentifier: PhotoCell.reuseIdentifier, for: indexPath) as! PhotoCell
         cell.backgroundColor = UIColor.white
         cell.configure(with: photo)
         cell.selectionStyle = .none
         
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
        print("Người dùng đã nhấn Return")
        textField.resignFirstResponder()
        
        getDisplayedData()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
			var updatedText: String = ""
			
			if let text = textField.text as NSString? {
				updatedText = text.replacingCharacters(in: range, with: string)
			}
			
			let regex = #"^[a-zA-Z0-9 !@#$%^&*():.,<>/\[\]\\?]*$"#
			let isValid = updatedText.range(of: regex, options: .regularExpression) != nil
			
				// Kiểm tra có chứa ký tự có dấu hoặc emoji không
			let folded = updatedText.folding(options: .diacriticInsensitive, locale: .current)
			let hasEmoji = updatedText != folded
		
			print ("updatedText là: \(updatedText), isValid là: \(isValid), hasEmoji là: \(hasEmoji)")
			
			if hasEmoji || !isValid {
				return false
			}
		
			if updatedText.count <= 15 {
				searchKey = updatedText
				return true
			}
			else{
				return false
			}
		
        }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = searchKey
        }
	
//	func textFieldDidChangeSelection(_ textField: UITextField) {
//		print("Text hiện tại: \(textField.text ?? "")")
//	}

}
