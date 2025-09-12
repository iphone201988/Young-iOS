import UIKit
import SideMenu
import PDFKit

class AccountDetailsVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var companyView: UIStackView!
    @IBOutlet weak var companyTitleLbl: UILabel!
    @IBOutlet weak var websiteView: UIStackView!
    @IBOutlet weak var titleView: UIStackView!
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var passwordLbl: UILabel!
    @IBOutlet weak var accountTypeLbl: UILabel!
    @IBOutlet weak var companyLbl: UILabel!
    @IBOutlet weak var websiteLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var planLbl: UILabel!
    @IBOutlet weak var nextBilingDateLbl: UILabel!
    @IBOutlet weak var renewLbl: UILabel!
    @IBOutlet weak var paymentAccountLbl: UILabel!
    @IBOutlet weak var upgradePlanBtn: UIButton!
    @IBOutlet weak var restorePlanBtn: UIButton!
    
    @IBOutlet weak var adsCollectionView: UICollectionView! {
        didSet {
            adsCollectionView.registerCellFromNib(cellID: AdsCell.identifier)
        }
    }
    
    // MARK: Variables
    fileprivate var userDetails: UserDetails?
    private var viewModel = SharedVM()
    fileprivate var pageNo = 1
    fileprivate var limit = 4
    fileprivate var ads = [UserDetails]()
    var event: Events = .unspecified
    fileprivate var selectedProduct = Products.standardPlan
    private var isRequestInProgress: Bool = false
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialViewSetup()
        bindViewModel()
        getAds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getUserProfile()
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
    
    @IBAction func upgradePlan(_ sender: UIButton) {
        //buyPlan(by: selectedProduct)
    }
    
    @IBAction func restorePlan(_ sender: UIButton) {
        //restorePlan()
    }
    
    @IBAction func changePassword(_ sender: UIButton) {
        let storyboard = AppStoryboards.menus.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "ChangePasswordVC") as? ChangePasswordVC
        else { return }
        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
    }
    
    @IBAction func accountDetails(_ sender: UIButton) {
        let storyboard = AppStoryboards.menus.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "ProfileDetailsVC") as? ProfileDetailsVC
        else { return }
        let userRole = Events.registrationFor(role: UserDefaults.standard[.loggedUserDetails]?.role ?? "") ?? .unspecified
        destVC.event = userRole
        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
    }
    
    @IBAction func paymentDetails(_ sender: UIButton) {
        let storyboard = AppStoryboards.menus.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "PaymentCardsListVC") as? PaymentCardsListVC
        else { return }
        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
    }
    
    @IBAction func closeAccount(_ sender: UIButton) {
        PopupUtil.popupAlert(title: "Young",
                             message: "delete_account_msg".localized(),
                             actionTitles: ["Delete", "No"],
                             actions: [ { [weak self] _, _ in
            self?.viewModel.deleteAccount()
        }])
    }
    
    @IBAction func deactivateAccount(_ sender: UIButton) {
        PopupUtil.popupAlert(title: "Young",
                             message: "deactivate_account_msg".localized(),
                             actionTitles: ["Delete", "No"],
                             actions: [ { [weak self] _, _ in
            self?.viewModel.updateUser(params: ["isDeactivatedByUser": true], isDeactivated: true)
        }])
    }
    
    @IBAction func downloadHistory(_ sender: UIButton) {
        viewModel.downloadHistory()
    }
    
    // MARK: Shared Methods
    fileprivate func initialViewSetup() {
        switch event {
            
        case .generalMemberAccountRegistration:
            companyView.isHidden = true
            websiteView.isHidden = true
            titleView.isHidden = true
            
        case .financialAdvisorAccountRegistration:
            companyView.isHidden = false
            websiteView.isHidden = false
            titleView.isHidden = false
            
        case .smallBusinessAccountRegistration:
            companyView.isHidden = false
            websiteView.isHidden = false
            titleView.isHidden = false
            companyTitleLbl.text = "Small Business"
            
        case .startupAccountRegistration:
            websiteView.isHidden = false
            titleView.isHidden = false
            companyView.isHidden = false
            companyTitleLbl.text = "Startup"
            
        case .investorVCAccountRegistration:
            websiteView.isHidden = false
            titleView.isHidden = false
            companyView.isHidden = false
            companyTitleLbl.text = "VC"
            
        case .insurance:
            websiteView.isHidden = false
            titleView.isHidden = false
            companyView.isHidden = false
            companyTitleLbl.text = "Insurance"
            
        default: break
        }
    }
    
    private func bindViewModel() {
        viewModel.$particularUserDetails.sink { [weak self] resp in
            if let resp {
                self?.userDetails = resp
                self?.populateData()
            }
        }.store(in: &viewModel.cancellables)
        
        viewModel.$requestResponse.sink { resp in
            if let err = resp.error, !err.isEmpty {
                Toast.show(message: err)
            }
        }.store(in: &viewModel.cancellables)
        
        viewModel.$downloadedHistory.sink { data in
            if !data.isEmpty {
                PDFExporter.exportJSONToMultiPagePDF(json: data, from: self)
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
    
    fileprivate func populateData() {
        let firstName = userDetails?.firstName ?? ""
        let lastName = userDetails?.lastName ?? ""
        let completeName = "\(firstName) \(lastName)"
        nameLbl.text = completeName
        emailLbl.text = userDetails?.email ?? ""
        usernameLbl.text = userDetails?.username ?? ""
        // passwordLbl.text = ""
        let userRole = Events.registrationFor(role: UserDefaults.standard[.loggedUserDetails]?.role ?? "") ?? .unspecified
        accountTypeLbl.text = userRole.rawValue
        companyLbl.text = userDetails?.company ?? ""
        websiteLbl.text = userDetails?.website ?? ""
        titleLbl.text = ""
        planLbl.text = ""
        nextBilingDateLbl.text = ""
        renewLbl.text = ""
        paymentAccountLbl.text = ""
    }
    
    @MainActor
    fileprivate func buyPlan(by productIdentifier: String) {
        // First set up the completion listener
        IAPHandler.shared.performActionOnPurchasedEvent() { [weak self] state in
            if state == .purchased {
                if self?.isRequestInProgress == false {
                    Task {
                        self?.isRequestInProgress = true
                        let params: [String: Any] = [
                            "original_transaction_id": IAPHandler.shared.originalTransactionID,
                            "transaction_id": IAPHandler.shared.transactionID,
                            "logged_user_id": UserDefaults.standard[.loggedUserDetails]?._id ?? "",
                            "subscription_expiry": IAPHandler.shared.subscriptionExpiry,
                            "product_id": IAPHandler.shared.purchasedProductID,
                            "subscription_purchase_date": IAPHandler.shared.subscriptionPurchaseDate
                        ]
                    }
                }
            } else if state == .purchasing || state == .failed {
                let msg = state.message()
                Toast.show(message: "Upgraded to Premium: \(msg)")
            }
        }
        
        // Trigger the purchase (must be async)
        Task {
            await IAPHandler.shared.purchase(productID: productIdentifier, presentingIn: self)
        }
    }
    
    @MainActor
    fileprivate func restorePlan() {
        IAPHandler.shared.performActionOnPurchasedEvent() { state in
            switch state {
            case .restored:
                Toast.show(message: "Restore successful ✅")
                // Do any post-restore navigation or logic here
            case .restoreFailed:
                Toast.show(message: "Restore failed ❌")
            default:
                break
            }
        }
        
        Task {
            await IAPHandler.shared.restorePurchases()
        }
    }
}

// MARK: Delegates and DataSources

extension AccountDetailsVC: UICollectionViewDataSource,
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
