import UIKit
import SideMenu

class AdvertiseVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var company: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var website: UITextField!
    @IBOutlet weak var planTF: UITextField!
    @IBOutlet weak var uploadedFilename: UITextField!
    @IBOutlet weak var successPopUpView: UIView!
    @IBOutlet weak var choosePlanBtn: UIButton!
    @IBOutlet weak var adsCollectionView: UICollectionView! {
        didSet {
            adsCollectionView.registerCellFromNib(cellID: AdsCell.identifier)
        }
    }
    
    // MARK: Variables
    private var viewModel = SharedVM()
    private var mediaData: Data?
    fileprivate var pageNo = 1
    fileprivate var limit = 4
    fileprivate var ads = [UserDetails]()
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bindViewModel()
        getAds()
        PickerManager.shared.configurePicker(for: planTF,
                                             with: Constants.adsPlan,
                                             iconButton: choosePlanBtn)
    }
    
    // MARK: IB Actions
    @IBAction func menu(_ sender: UIButton) {
        let storyboard = AppStoryboards.menus.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "SideMenuNavigationController") as? SideMenuNavigationController
        else { return }
        destVC.settings = SharedMethods.shared.sideMenuSettings()
        SharedMethods.shared.presentVC(destVC: destVC)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func closeSuccessPopUpView(_ sender: UIButton) {
        successPopUpView.isHidden = true
        navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func previewSuccessPopUpView(_ sender: UIButton) {
        successPopUpView.isHidden = false
    }
    
    @IBAction func submit(_ sender: UIButton) {
        let name = nameTF.text ?? ""
        let company = company.text ?? ""
        let email = email.text ?? ""
        let website = website.text ?? ""
        if name.isEmpty || company.isEmpty || email.isEmpty || website.isEmpty {
            Toast.show(message: "Name, Company, Email and Website fields are required")
        } else {
            if email.isEmail {
                let params = ["name": name, "company": company, "email": email, "website": website]
                viewModel.createAds(params: params, mediaData: mediaData)
            } else {
                Toast.show(message: "Please enter valid email")
            }
        }
    }
    
    @IBAction func uploadFile(_ sender: UIButton) {
        MediaPicker.shared.browsedImage() { [weak self] image, imageURL in
            let data = image.jpegData(compressionQuality: 0.1)
            self?.mediaData = data
            self?.uploadedFilename.text = imageURL?.lastPathComponent
        }
    }
    
    // MARK: Shared Methods
    private func bindViewModel() {
        viewModel.$requestResponse
            .receive(on: DispatchQueue.main)
            .sink { [weak self] resp in
                if let err = resp.error, !err.isEmpty {
                    Toast.show(message: err)
                }
                
                if resp.isSuccess == true {
                    self?.successPopUpView.isHidden = false
                }
            }.store(in: &viewModel.cancellables)
        
        viewModel.$ads.sink { [weak self] resp in
            guard let self = self, !resp.isEmpty else { return }
            let oldCount = self.ads.count
            self.ads = resp
            // Update collection view without animation
            UIView.performWithoutAnimation {
                self.adsCollectionView.reloadData()
                self.adsCollectionView.layoutIfNeeded()
            }
            
            // Scroll to the position where new items were added (if any)
            if resp.count > oldCount {
                self.adsCollectionView.safeScrollToItem(at: oldCount)
            }
        }.store(in: &viewModel.cancellables)
    }
    
    private func getAds() {
        viewModel.getAds(params: ["page": pageNo, "limit": limit], limit: limit)
    }
}

// MARK: Delegates and DataSources

extension AdvertiseVC: UICollectionViewDataSource,
                       UICollectionViewDelegate,
                       UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        ads.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 320, height: 204.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdsCell.identifier, for: indexPath) as! AdsCell
        SharedMethods.shared.setImage(imageView: cell.adsImage, url: ads[indexPath.item].file ?? "")
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == adsCollectionView {
            let offsetX = scrollView.contentOffset.x
            let contentWidth = scrollView.contentSize.width
            let frameWidth = scrollView.frame.width
            guard !self.viewModel.isAdsListLoading, !self.viewModel.isAdsListLastPage else { return }
            if offsetX > contentWidth - frameWidth - 100 { // For horizontal scroll
                self.viewModel.isAdsListLoading = true
                self.pageNo += 1
                self.getAds()
            }
        }
    }
}
