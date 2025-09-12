import UIKit
import SideMenu

class ReportUserVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var reasonTF: UITextField!
    @IBOutlet weak var detailsTV: UITextView!
    @IBOutlet weak var screenshot: UIImageView!
    @IBOutlet weak var bottomTabsView: UIView!
    @IBOutlet weak var reasonIcon: UIButton!
    @IBOutlet weak var adsCollectionView: UICollectionView! {
        didSet {
            adsCollectionView.registerCellFromNib(cellID: AdsCell.identifier)
        }
    }
    
    // MARK: Variables
    private var viewModel = SharedVM()
    var id: String = ""
    var selectedSavedOption: SavedOptions?
    var delegateExchange: Exchange?
    fileprivate var pageNo = 1
    fileprivate var limit = 4
    fileprivate var ads = [UserDetails]()
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bindViewModel()
        getAds()
        PickerManager.shared.configurePicker(for: reasonTF,
                                             with: Constants.reportReasons,
                                             iconButton: reasonIcon)
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
    
    @IBAction func submit(_ sender: UIButton) {
        let reason = reasonTF.text ?? ""
        let details = detailsTV.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if reason.isEmpty || details.isEmpty {
            Toast.show(message: "Reason and Details both are required.")
        } else {
            let screenshotData = screenshot.image?.jpegData(compressionQuality: 0.1)
            viewModel.reportUser(params: ["id": id,
                                          "reason": reason,
                                          "additionalDetails": details,
                                          "type": selectedSavedOption?.type ?? ""],
                                 screenshotData: screenshotData)
        }
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func uploadScreenshot(_ sender: UIButton) {
        MediaPicker.shared.browsedImage() { [weak self] image, _ in
            self?.screenshot.image = image
        }
    }
    
    @IBAction func exchange(_ sender: UIButton) {
        SharedMethods.shared.pushToWithoutData(destVC: ExchangeVC.self, storyboard: .menus, isAnimated: true)
    }
    
    @IBAction func ecosystem(_ sender: UIButton) {
        SharedMethods.shared.pushToWithoutData(destVC: EcosystemVC.self, storyboard: .menus, isAnimated: true)
    }
    
    // MARK: Shared Methods
    private func bindViewModel() {
        viewModel.$requestResponse.sink { [weak self] resp in
            if resp.isSuccess == true {
                if
                    let delegate = self?.delegateExchange,
                    let option = self?.selectedSavedOption,
                    let id = self?.id {
                    delegate.updateReportStatus(for: option, id: id)
                }
                
                Toast.show(message: resp.message ?? "") {
                    self?.navigationController?.popViewController(animated: true)
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

extension ReportUserVC: UICollectionViewDataSource,
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

