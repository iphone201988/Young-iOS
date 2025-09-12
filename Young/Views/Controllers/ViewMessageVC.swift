import UIKit
import SideMenu

class ViewMessageVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var roleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var messageTV: UITextView!
    @IBOutlet weak var viewMessageTableView: UITableView! {
        didSet{
            viewMessageTableView.registerCellFromNib(cellID: ViewMessageCell.identifier)
            viewMessageTableView.registerCellFromNib(cellID: ReceiverMessageCell.identifier)
        }
    }
    
    @IBOutlet weak var adsCollectionView: UICollectionView! {
        didSet {
            adsCollectionView.registerCellFromNib(cellID: AdsCell.identifier)
        }
    }
    
    // MARK: Variables
    private var viewModel = SharedVM()
    private var messages = [Chat]()
    private var socketIO = SocketIOUtil()
    let footerView = VCFooterView()
    var receiverDetails: UserDetails?
    var threadID: String?
    var dateTime: String?
    
    fileprivate var pageNo = 1
    fileprivate var limit = 4
    fileprivate var ads = [UserDetails]()
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        SharedMethods.shared.setImage(imageView: profilePic, url: receiverDetails?.profileImage ?? "")
        usernameLbl.text = receiverDetails?.username ?? ""
        let userRole = Events.registrationFor(role: receiverDetails?.role ?? "") ?? .unspecified
        roleLbl.text = userRole.rawValue
        dateLbl.text = DateUtil.formatDateToLocal(from: dateTime ?? "", format: "MMM d, yyyy")
        timeLbl.text = DateUtil.formatDateToLocal(from: dateTime ?? "", format: "h:mm a")
        //footerViewSetup()
        bindViewModel()
        viewModel.getChats(threadID: threadID)
        getAds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let params = ["": ""]
        socketIO.establishConnection(params: params) { [weak self] result in
            self?.socketIO.socketIOEvents = self
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        socketIO.disconnect()
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
    
    @IBAction func viewUserProfile(_ sender: UIButton) {
        //        let storyboard = AppStoryboards.menus.storyboardInstance
        //        guard let destVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC
        //        else { return }
        //        destVC.isAnotherUserID = receiverDetails?._id ?? ""
        //        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
        
        guard let rootViewController = getWindowRootViewController() else { return }
        guard let topController = getTopViewController(from: rootViewController) else { return }
        if topController.isKind(of: ProfileVC.self) {
            return
        }
        let storyboard = AppStoryboards.menus.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC
        else { return }
        
        destVC.isAnotherUserID = receiverDetails?._id ?? ""
        topController.navigationController?.pushViewController(destVC, animated: true)
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        let messageContent = messageTV.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if messageContent.isEmpty { return }
        var params = [String: String]()
        params["message"] = messageContent
        if let threadID {
            params["chatId"] = threadID
        } else {
            params["receiverId"] = receiverDetails?._id ?? ""
        }
        
        socketIO.sendMessage(params: params) { [weak self] success in
            self?.messageTV.text = ""
        }
    }
    
    // MARK: Shared Methods
    private func bindViewModel() {
        viewModel.$messages.sink { [weak self] resp in
            self?.messages = resp
            self?.viewMessageTableView.reloadData()
            //  DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let lastCount = resp.count - 1
            let totalRows = self?.viewMessageTableView.numberOfRows(inSection: 0) ?? 0
            
            // Ensure the table has at least one row, and that the index is valid
            if totalRows > 0 && lastCount >= 0 && lastCount < totalRows {
                let indexPath = IndexPath(row: totalRows - 1, section: 0)
                self?.viewMessageTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
            //  }
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
        let y = UIScreen.main.bounds.height - 44
        footerView.frame.size.width = UIScreen.main.bounds.width - 48
        footerView.frame.size.height = 52.0
        footerView.center.x = 24 + (UIScreen.main.bounds.width - 48) / 2
        footerView.center.y = y
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

extension ViewMessageVC: UICollectionViewDataSource,
                         UICollectionViewDelegate,
                         UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ads.count
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

extension ViewMessageVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let details = messages[indexPath.row]
        if let senderID = details.senderId?._id,
           let currentUserID = UserDefaults.standard[.loggedUserDetails]?._id {
            if senderID == currentUserID {
                let cell = tableView.dequeueReusableCell(withIdentifier: ViewMessageCell.identifier, for: indexPath) as! ViewMessageCell
                cell.editBtn.tag = indexPath.row
                cell.editBtn.addTarget(self, action: #selector(tappedEdit(_ :)), for: .touchUpInside)
                cell.messageDetails = messages[indexPath.row]
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: ReceiverMessageCell.identifier, for: indexPath) as! ReceiverMessageCell
                cell.messageDetails = messages[indexPath.row]
                return cell
            }
        } else {
            return UITableViewCell()
        }
    }
    
    @objc func tappedEdit(_ sender: UIButton) { }
}

extension ViewMessageVC: SocketIOEvents {
    
    func receivedNewMessage(message: Chat) {
        messages.append(message)
        viewMessageTableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let lastCount = self.messages.count - 1
            let totalRows = self.viewMessageTableView.numberOfRows(inSection: 0)
            // Ensure the table has at least one row, and that the index is valid
            if totalRows > 0 && lastCount >= 0 && lastCount < totalRows {
                let indexPath = IndexPath(row: totalRows - 1, section: 0)
                self.viewMessageTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
    
    func receivedNewVaultMessage(comment: Comment) { }
    
    func adminDisconnected() { }
}
