import UIKit
import SideMenu

class InboxVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var inboxTableView: UITableView! {
        didSet{
            inboxTableView.registerCellFromNib(cellID: InboxCell.identifier)
        }
    }
    
    @IBOutlet weak var adsCollectionView: UICollectionView! {
        didSet {
            adsCollectionView.registerCellFromNib(cellID: AdsCell.identifier)
        }
    }
    
    // MARK: Variables
    private var viewModel = SharedVM()
    private var inboxChats = [Chat]()
    fileprivate var pageNo = 1
    fileprivate var limit = 4
    fileprivate var ads = [UserDetails]()
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bindViewModel()
        viewModel.getChats()
        getAds()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadContent(_ :)), name: .reloadContent, object: nil)
    }
    
    @objc fileprivate func reloadContent(_ notify: Notification) {
        viewModel.getChats()
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
    
    // MARK: Shared Methods
    private func bindViewModel() {
        viewModel.$inboxChats.sink { [weak self] resp in
            self?.inboxChats = resp
            self?.inboxTableView.reloadData()
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

extension InboxVC: UICollectionViewDataSource,
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

extension InboxVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inboxChats.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InboxCell.identifier, for: indexPath) as! InboxCell
        cell.userProfileBtn.tag = indexPath.row
        cell.viewMessageBtn.tag = indexPath.row
        cell.userProfileBtn.addTarget(self, action: #selector(tappedUserProfile(_ :)), for: .touchUpInside)
        cell.viewMessageBtn.addTarget(self, action: #selector(tappedViewMessage(_ :)), for: .touchUpInside)
        cell.chatDetails = inboxChats[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatUsers = inboxChats[indexPath.row].chatUsers ?? []
        if let loggedInUserId = UserDefaults.standard[.loggedUserDetails]?._id {
            let receiver = chatUsers.first(where: { $0._id != loggedInUserId })
            let storyboard = AppStoryboards.menus.storyboardInstance
            guard let destVC = storyboard.instantiateViewController(withIdentifier: "ViewMessageVC") as? ViewMessageVC
            else { return }
            destVC.receiverDetails = receiver
            destVC.dateTime = inboxChats[indexPath.row].createdAt
            destVC.threadID = inboxChats[indexPath.row]._id
            SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
        }
    }
    
    @objc fileprivate func tappedUserProfile(_ sender: UIButton) {
        let chatUsers = inboxChats[sender.tag].chatUsers ?? []
        if let loggedInUserId = UserDefaults.standard[.loggedUserDetails]?._id {
            let userID = chatUsers.first(where: { $0._id != loggedInUserId })?._id ?? ""
            let storyboard = AppStoryboards.menus.storyboardInstance
            guard let destVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC
            else { return }
            destVC.isAnotherUserID = userID
            SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
        }
    }
    
    @objc fileprivate func tappedViewMessage(_ sender: UIButton) {
        let chatUsers = inboxChats[sender.tag].chatUsers ?? []
        if let loggedInUserId = UserDefaults.standard[.loggedUserDetails]?._id {
            let receiver = chatUsers.first(where: { $0._id != loggedInUserId })
            let storyboard = AppStoryboards.menus.storyboardInstance
            guard let destVC = storyboard.instantiateViewController(withIdentifier: "ViewMessageVC") as? ViewMessageVC
            else { return }
            destVC.receiverDetails = receiver
            destVC.dateTime = inboxChats[sender.tag].createdAt
            destVC.threadID = inboxChats[sender.tag]._id
            SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
        }
    }
}
