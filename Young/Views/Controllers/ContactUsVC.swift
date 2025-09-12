import UIKit
import SideMenu

class ContactUsVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var subjectTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var companyTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var browsedFilename: UITextField!
    @IBOutlet weak var policiesAndAgreementsView: UIView!
    @IBOutlet weak var messageTV: UITextView!
    @IBOutlet weak var adsCollectionView: UICollectionView! {
        didSet {
            adsCollectionView.registerCellFromNib(cellID: AdsCell.identifier)
        }
    }
    
    // MARK: Variables
    private var browsedFileData: Data?
    private var viewModel = SharedVM()
    fileprivate var pageNo = 1
    fileprivate var limit = 4
    fileprivate var ads = [UserDetails]()
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bindViewModel()
        let firstname = UserDefaults.standard[.loggedUserDetails]?.firstName ?? ""
        let lastname = UserDefaults.standard[.loggedUserDetails]?.lastName ?? ""
        let completeName = "\(firstname) \(lastname)"
        nameTF.text = completeName
        companyTF.text = UserDefaults.standard[.loggedUserDetails]?.company ?? ""
        emailTF.text = UserDefaults.standard[.loggedUserDetails]?.email ?? ""
        getAds()
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
        PopupUtil.popupAlert(title: "Young",
                             message: "Are you sure you want to leave this page?",
                             actionTitles: ["Yes", "No"],
                             actions: [ { _, _ in
            self.navigationController?.popViewController(animated: true)
        }])
    }
    
    @IBAction func closePoliciesAndAgreementsView(_ sender: UIButton) {
        policiesAndAgreementsView.isHidden = true
    }
    
    @IBAction func previewPoliciesAndAgreementsView(_ sender: UIButton) {
        policiesAndAgreementsView.isHidden = false
    }
    
    @IBAction func browseFile(_ sender: UIButton) {
        MediaPicker.shared.browsedImage() { [weak self] image, imageURL in
            let name = imageURL?.lastPathComponent ?? ""
            self?.browsedFilename.text = name
            self?.browsedFileData = image.jpegData(compressionQuality: 0.1)
        }
    }
    
    @IBAction func saveChanges(_ sender: UIButton) {
        let params = [
            "subject": subjectTF.text ?? "",
            "name": nameTF.text ?? "",
            "company": companyTF.text ?? "",
            "email": emailTF.text ?? "",
            "message": messageTV.text ?? ""
        ]
        
        viewModel.contactUs(params: params, fileData: browsedFileData)
    }
    
    // MARK: Shared Methods
    private func bindViewModel() {
        viewModel.$requestResponse.sink { resp in
            if let err = resp.error, !err.isEmpty {
                Toast.show(message: err)
            }
            
            if resp.isSuccess == true {
                Toast.show(message: resp.message ?? "") {
                    self.navigationController?.popViewController(animated: true)
                }
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

extension ContactUsVC: UICollectionViewDataSource,
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
