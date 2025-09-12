import UIKit
import SideMenu

class StreamConfirmationVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var interfaceTitleLbl: UILabel!
    @IBOutlet weak var bottomTabsView: UIView!
    @IBOutlet weak var symbolView: UIView!
    @IBOutlet weak var scheduledView: UIView!
    @IBOutlet weak var readyToLaunchBtn: UIButton!
    @IBOutlet weak var readyToLaunchBottomSpaciousView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var topicLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var mediaThumbnail: UIImageView!
    @IBOutlet weak var symbolLbl: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var confirmBtnBottomSpaciousView: UIView!
    @IBOutlet weak var scheduledTitleLbl: UILabel!
    @IBOutlet weak var scheduledDateTimeLbl: UILabel! // April 10, 2025 – 4:00 PM EST
    @IBOutlet weak var scheduledUsernameLbl: UILabel!
    @IBOutlet weak var attachedMediaHeight: NSLayoutConstraint!
    @IBOutlet weak var symbolTitleLbl: UILabel!
    @IBOutlet weak var adsCollectionView: UICollectionView! {
        didSet {
            adsCollectionView.registerCellFromNib(cellID: AdsCell.identifier)
        }
    }
    
    // MARK: Variables
    let footerView = VCFooterView()
    var events: SavedOptions = .share
    var params = [String : Any]()
    var shareImage: UIImage?
    var isLaunch = false
    private var viewModel = SharedVM()
    fileprivate var isLaunchTriggered: Bool = false
    fileprivate var pageNo = 1
    fileprivate var limit = 4
    fileprivate var ads = [UserDetails]()
    var scheduleDate = ""
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //footerViewSetup()
        scheduledView.isHidden = true
        footerView.isHidden = false
        interfaceTitleLbl.text = "\(events.rawValue) Confirmation"
        switch events {
        case .share:
            symbolView.isHidden = false
            readyToLaunchBtn.isHidden = true
            readyToLaunchBottomSpaciousView.isHidden = true
            
        case .stream:
            symbolView.isHidden = true
            if isLaunch {
                readyToLaunchBtn.isHidden = false
                readyToLaunchBottomSpaciousView.isHidden = false
                confirmBtn.isHidden = true
                confirmBtnBottomSpaciousView.isHidden = true
            } else {
                readyToLaunchBtn.isHidden = true
                readyToLaunchBottomSpaciousView.isHidden = true
                confirmBtn.isHidden = false
                confirmBtnBottomSpaciousView.isHidden = false
            }
            
        case .vault:
            symbolView.isHidden = true
            readyToLaunchBtn.isHidden = true
            readyToLaunchBottomSpaciousView.isHidden = true
            
        default: break
        }
        
        titleLbl.text = params["title"] as? String ?? ""
        topicLbl.text = params["topic"] as? String ?? ""
        descLbl.text = params["description"] as? String ?? ""
        
        if let shareImage {
            mediaThumbnail.image = shareImage
            attachedMediaHeight.constant = 345.0
        } else {
            mediaThumbnail.image = nil
            attachedMediaHeight.constant = 0.0
        }
        
        let symbol = params["symbolValue"] as? String ?? ""
        symbolLbl.text = symbol //Symbols.title(for: symbol)
        
        let symbolTitle = params["symbol"] as? String ?? ""
        symbolTitleLbl.text = Symbols(rawValue: symbolTitle)?.title ?? ""
        
        bindViewModel()
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
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func readyToLaunch(_ sender: UIButton) {
        let mediaData = mediaThumbnail.image?.jpegData(compressionQuality: 0.1)
        isLaunchTriggered = true
        viewModel.createPost(params: params, mediaData: mediaData, event: events)
    }
    
    @IBAction func confirmStreamSchedule(_ sender: UIButton) {
        if events == .share {
            let mediaData = mediaThumbnail.image?.jpegData(compressionQuality: 0.1)
            viewModel.createPost(params: params, mediaData: mediaData, event: events)
        } else {
            if events == .stream {
                let mediaData = mediaThumbnail.image?.jpegData(compressionQuality: 0.1)
                isLaunchTriggered = false
                viewModel.createPost(params: params, mediaData: mediaData, event: events)
            }
        }
    }
    
    @IBAction func confirm(_ sender: UIButton) {
        if events == .share {
            
        } else {
            scheduledView.isHidden = true
            footerView.isHidden = false
            if events == .stream {
                self.navigationController?.popToRootViewController(animated: false)
            }
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
                if self?.events == .stream {
                    
                } else {
                    NotificationCenter.default.post(name: .reloadContent, object: nil)
                    Toast.show(message: resp.message ?? "") {
//                        if let targetVC = self?.navigationController?.viewControllers.first(where: { $0 is ExchangeVC }) {
//                            self?.navigationController?.popToViewController(targetVC, animated: true)
//                        }
                        
                        self?.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
            
            if let error = resp.error {
                Toast.show(message: error)
            }
        }.store(in: &viewModel.cancellables)
        
        viewModel.$createdStreamingDetails
            .receive(on: DispatchQueue.main)
            .sink { details in
                if let details {
                    if self.isLaunchTriggered {
                        let storyboard = AppStoryboards.menus.storyboardInstance
                        guard let destVC = storyboard.instantiateViewController(withIdentifier: "LiveStreamingVC") as? LiveStreamingVC
                        else { return }
                        destVC.isProducer = true
                        destVC.roomName = details._id ?? ""
                        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
                    } else {
                        //self.navigationController?.popToViewController(ofClass: ExchangeVC.self, animated: false)
                        
                        self.scheduledView.isHidden = false
                        self.footerView.isHidden = true
                        
                        self.scheduledTitleLbl.text = self.params["title"] as? String ?? ""
                        self.scheduledDateTimeLbl.text = self.scheduleDate
                        self.scheduledUsernameLbl.text = UserDefaults.standard[.loggedUserDetails]?.username ?? ""
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
    
    fileprivate func footerViewSetup() {
        let y = UIScreen.main.bounds.height - 119
        footerView.frame.size.width = UIScreen.main.bounds.width - 48
        footerView.frame.size.height = 52.0
        footerView.center.x = 24 + (UIScreen.main.bounds.width - 48) / 2
        footerView.center.y = y - 20
        footerView.shareBtn.addTarget(self, action: #selector(tappedShare(_:)), for: .touchUpInside)
        footerView.streamBtn.addTarget(self, action: #selector(tappedStream(_:)), for: .touchUpInside)
        footerView.vaultBtn.addTarget(self, action: #selector(tappedVault(_:)), for: .touchUpInside)
        self.view.addSubview(footerView)
    }
    
    @objc func tappedShare(_ button: UIButton) {
        LogHandler.debugLog("tappedShare")
    }
    
    @objc func tappedStream(_ button: UIButton) {
        LogHandler.debugLog("tappedStream")
    }
    
    @objc func tappedVault(_ button: UIButton) {
        LogHandler.debugLog("tappedVault")
    }
}

// MARK: Delegates and DataSources

extension StreamConfirmationVC: UICollectionViewDataSource,
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
