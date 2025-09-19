import UIKit
import SideMenu
import Cosmos
import AVKit
import AVFoundation

class VaultsRoomVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var vaultMoreBtn: UIButton!
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var newCommentView: UIView!
    @IBOutlet weak var ratingStarsView: UIView!
    @IBOutlet weak var totalRatingView: UIView!
    @IBOutlet weak var userProfilePic: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var ratingStarsViewTotalRatingLbl: UILabel!
    @IBOutlet weak var commentTV: UITextView!
    @IBOutlet weak var postCommentBtn: UIButton!
    @IBOutlet weak var bottomTabsView: UIView!
    @IBOutlet weak var dateTimeLbl: UILabel!
    @IBOutlet weak var roleLbl: UILabel!
    @IBOutlet weak var commentsTblHeight: NSLayoutConstraint!
    @IBOutlet weak var newCommentTopView: UIView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var previousPageBtn: UIButton!
    @IBOutlet weak var nextPageBtn: UIButton!
    @IBOutlet weak var pageNoLbl: UILabel!
    @IBOutlet weak var interfaceTitle: UILabel!
    @IBOutlet weak var memberView: UIView!
    @IBOutlet weak var memberBottomView: UIView!
    @IBOutlet weak var overallRatingView: CosmosView!
    @IBOutlet weak var ratingValueLbl: UILabel!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var leaveBtn: UIButton!
    @IBOutlet weak var streamingBtn: UIButton!
    @IBOutlet weak var pageNoView: UIView!
    @IBOutlet weak var postImageHeight: NSLayoutConstraint!
    @IBOutlet weak var adsCollectionView: UICollectionView! {
        didSet {
            adsCollectionView.registerCellFromNib(cellID: AdsCell.identifier)
        }
    }
    
    @IBOutlet weak var membersCollectionView: UICollectionView! {
        didSet {
            membersCollectionView.registerCellFromNib(cellID: MemberCell.identifier)
        }
    }
    
    @IBOutlet weak var commentsTableView: UITableView! {
        didSet{
            commentsTableView.registerCellFromNib(cellID: CommentCell.identifier)
            commentsTableView.estimatedRowHeight = 44
        }
    }
    
    // MARK: Variables
    fileprivate let footerView = VCFooterView()
    fileprivate var viewModel = SharedVM()
    fileprivate var postDetails: PostDetails?
    fileprivate var members = [UserDetails]()
    fileprivate var comments = [Comment]()
    fileprivate var pageNo = 1
    fileprivate var pageNo2 = 1
    fileprivate var limit = 4
    fileprivate var ads = [UserDetails]()
    
    var id: String = ""
    var selectedSavedOption: SavedOptions = .share
    var delegateExchange: Exchange?
    private var socketIO = SocketIOUtil()
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        overallRatingView.settings.fillMode = .full
        commentsTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        //footerViewSetup()
        viewModel.getPost(by: id, event: selectedSavedOption)
        getComments()
        bindViewModel()
        
        vaultMoreBtn.isHidden = true
        memberView.isHidden = true
        memberBottomView.isHidden = true
        streamingBtn.isHidden = true
        
        switch selectedSavedOption {
        case .share:
            interfaceTitle.text = "Share"
            
        case .stream:
            interfaceTitle.text = "Stream"
            
        case .vault:
            interfaceTitle.text = "Vault Room"
            memberBottomView.isHidden = false
            memberView.isHidden = false
            memberBottomView.isHidden = false
            
        default: break
        }
        
        overallRatingView.didFinishTouchingCosmos = { [weak self] rating in
            self?.overallRatingView.isUserInteractionEnabled = false
            let params = ["ratings": rating,
                          "type": self?.selectedSavedOption.type ?? SavedOptions.share.type,
                          "id": self?.id ?? ""]
            self?.viewModel.addRating(params: params) { [weak self] in
                self?.overallRatingView.isUserInteractionEnabled = true
                self?.ratingValueLbl.text = "\(rating)"
                if let option = self?.selectedSavedOption {
                    self?.delegateExchange?.updateRating(for: option, id: self?.id ?? "", rating: rating)
                }
            }
        }
        
        getAds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if selectedSavedOption == .vault, !id.isEmpty {
            self.socketIO.establishConnection(params: [:]) { [weak self] result in
                self?.socketIO.joinVault(params: ["vaultId": self?.id ?? ""]) { success in
                    self?.socketIO.socketIOEvents = self
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        socketIO.disconnect()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize", object is UITableView {
            UIView.performWithoutAnimation {
                commentsTblHeight.constant = commentsTableView.contentSize.height
                view.layoutIfNeeded()
            }
        }
    }
    
    deinit {
        commentsTableView.removeObserver(self, forKeyPath: "contentSize")
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
    
    @IBAction func moveToPreviousPage(_ sender: UIButton) {
        pageNo -= 1
        getComments()
    }
    
    @IBAction func moveToNextPage(_ sender: UIButton) {
        pageNo += 1
        getComments()
    }
    
    @IBAction func vaultMore(_ sender: UIButton) {
        
        var menuActions: [UIMenuElement] = []
        
        if postDetails?.isMember == true {
            menuActions.append(
                UIAction(title: "Leave") { [weak self] _ in
                    guard let self = self else { return }
                    viewModel.joinLeaveVault(vaultID: id, event: selectedSavedOption)
                }
            )
        } else {
            menuActions.append(
                UIAction(title: "Join") { [weak self] _ in
                    guard let self = self else { return }
                    viewModel.joinLeaveVault(vaultID: id, event: selectedSavedOption)
                }
            )
        }
        
        let menu = UIMenu(title: "", children: menuActions)
        vaultMoreBtn.menu = menu
        vaultMoreBtn.showsMenuAsPrimaryAction = true // Shows menu on tap
    }
    
    @IBAction func postComment(_ sender: UIButton) {
        let commentTV = commentTV.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !commentTV.isEmpty {
            var params = ["id": id, "comment": commentTV, "type": selectedSavedOption.type]
            
            if let chatId = postDetails?.chatId, !chatId.isEmpty {
                params["chatId"] = chatId
            }
            
            if selectedSavedOption == .vault {
                socketIO.sendMessageInVault(params: params) { [weak self] success in
                    self?.commentTV.text = ""
                }
            } else {
                viewModel.addComment(params: params, event: selectedSavedOption)
            }
        }
    }
    
    @IBAction func joinVault(_ sender: UIButton) {
        viewModel.joinLeaveVault(vaultID: id, event: selectedSavedOption)
    }
    
    @IBAction func leaveVault(_ sender: UIButton) {
        viewModel.joinLeaveVault(vaultID: id, event: selectedSavedOption)
    }
    
    @IBAction func streaming(_ sender: UIButton) {
        if let _ = postDetails?.scheduleDate {
            
        } else {
            let storyboard = AppStoryboards.menus.storyboardInstance
            guard let destVC = storyboard.instantiateViewController(withIdentifier: "LiveStreamingVC") as? LiveStreamingVC
            else { return }
            if let streamUrl = postDetails?.streamUrl {
                let videoURL = "https://youngappbucket.s3.us-east-2.amazonaws.com\(streamUrl)"
                destVC.recordedStreamURL = videoURL
            } else {
                destVC.isProducer = false
                destVC.roomName = id
            }
            SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
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
                switch self?.selectedSavedOption {
                case .share:
                    self?.postDetails = self?.viewModel.particularShareDetails
                    
                case .stream:
                    self?.postDetails = self?.viewModel.particularStreamDetails
                    
                case .vault:
                    self?.postDetails = self?.viewModel.particularVaultDetails
                    
                default: break
                }
                
                if resp.request == .joinLeaveVault {
                    //self?.vaultMoreBtn.sendActions(for: .touchUpInside)
                    if self?.postDetails?.isMember == true {
                        self?.newCommentTopView.isHidden = false
                        self?.newCommentView.isHidden = false
                        
                        self?.joinBtn.isHidden = true
                        self?.leaveBtn.isHidden = false
                        
                        //self?.getComments()
                        
                    } else {
                        self?.newCommentTopView.isHidden = true
                        self?.newCommentView.isHidden = true
                        
                        self?.joinBtn.isHidden = false
                        self?.leaveBtn.isHidden = true
                        
                        //self?.viewModel.comments.removeAll()
                        //self?.pageNoView.isHidden = true
//                        UIView.performWithoutAnimation {
//                            self?.commentsTableView.reloadData()
//                        }
                    }
                } else {
                    self?.populateData()
                }
            }
            
            if let error = resp.error {
                Toast.show(message: error)
            }
        }.store(in: &viewModel.cancellables)
        
        viewModel.$comments.sink { [weak self] resp in
            self?.commentTV.text = ""
            self?.comments = resp
            if resp.count > 0 {
                self?.pageNoView.isHidden = false
            } else {
                self?.pageNoView.isHidden = true
            }
            switch self?.viewModel.triggeredEvent {
            case .addComment:
                if let option = self?.selectedSavedOption {
                    self?.delegateExchange?.updateCommentCount(for: option, id: self?.id ?? "")
                }
                
                UIView.performWithoutAnimation {
                    self?.commentsTableView.reloadData()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    guard let self = self else { return }
                    let bottomOffset = CGPoint(
                        x: 0,
                        y: max(0, (self.mainScrollView.contentSize.height - self.mainScrollView.bounds.height))
                    )
                    self.mainScrollView.setContentOffset(bottomOffset, animated: false)
                }
                
            case .getComments:
                self?.commentsTableView.reloadData()
                
            default: break
            }
            self?.viewModel.triggeredEvent = nil
        }.store(in: &viewModel.cancellables)
        
        viewModel.$commentPagination.sink { [weak self] resp in
            if let resp, let totalPages = resp.total, totalPages > 1 {
                if self?.pageNo == totalPages {
                    self?.nextPageBtn.isEnabled = false
                } else {
                    self?.nextPageBtn.isEnabled = true
                }
                
                if self?.pageNo ?? 1 > 1 {
                    self?.previousPageBtn.isEnabled = true
                } else {
                    self?.previousPageBtn.isEnabled = false
                }
                
            } else {
                self?.nextPageBtn.isEnabled = false
                self?.previousPageBtn.isEnabled = false
            }
        }.store(in: &viewModel.cancellables)
        
        ///Due to complications in reload particular row that's why update cell i.e. func likeDislikeComment(id: String, event: SavedOptions)
        //        viewModel.$updatedCommentStatusIndex.sink { [weak self] info in
        //            if let info {
        //                let index = info.index
        //                let indexPath = IndexPath(row: index, section: 0)
        //                DispatchQueue.main.async {
        //                    self?.commentsTableView.reloadRows(at: [indexPath], with: .bottom)
        //                }
        //            }
        //        }.store(in: &viewModel.cancellables)
        
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
        viewModel.getAds(params: ["page": pageNo2, "limit": limit], limit: limit)
    }
    
    fileprivate func footerViewSetup() {
        let y = UIScreen.main.bounds.height - 119
        footerView.frame.size.width = UIScreen.main.bounds.width - 48
        footerView.frame.size.height = 52.0
        footerView.center.x = 24 + (UIScreen.main.bounds.width - 48) / 2
        footerView.center.y = y - 20
        footerView.emptyView.isHidden = false
        footerView.newAddOnView.isHidden = false
        footerView.shareBtn.addTarget(self, action: #selector(tappedShare(_:)), for: .touchUpInside)
        footerView.streamBtn.addTarget(self, action: #selector(tappedStream(_:)), for: .touchUpInside)
        footerView.vaultBtn.addTarget(self, action: #selector(tappedVault(_:)), for: .touchUpInside)
        self.view.addSubview(footerView)
    }
    
    fileprivate func populateData() {
        titleLbl.text = postDetails?.title ?? ""
        contentLbl.text = postDetails?.description ?? ""
        dateTimeLbl.text = DateUtil.formatDateToLocal(from: postDetails?.createdAt ?? "", format: "d MMM yyyy")
        
        if let image = postDetails?.image, !image.isEmpty {
            postImageHeight.constant = 200
            SharedMethods.shared.setImage(imageView: postImage, url: postDetails?.image ?? "")
        } else {
            postImageHeight.constant = 0
            postImage.image = nil
        }
        
        joinBtn.isHidden = true
        leaveBtn.isHidden = true
        var profilePicURL = ""
        var username = ""
        switch selectedSavedOption {
        case .share:
            profilePicURL = postDetails?.userId?.profileImage ?? ""
            let firstName = postDetails?.userId?.firstName ?? ""
            let lastName = postDetails?.userId?.lastName ?? ""
            username = "\(firstName) \(lastName)"
            
        case .stream:
            profilePicURL = postDetails?.userId?.profileImage ?? ""
            let firstName = postDetails?.userId?.firstName ?? ""
            let lastName = postDetails?.userId?.lastName ?? ""
            username = "\(firstName) \(lastName)"
            streamingBtn.isHidden = false
            streamingBtn.isUserInteractionEnabled = false
            if let scheduleDate = postDetails?.scheduleDate {
                let dateTime = DateUtil.convertUTCToLocalAt(scheduleDate) ?? ""
                let loggedUserID = UserDefaults.standard[.loggedUserDetails]?._id ?? ""
                if postDetails?.userId?._id == loggedUserID {
                    let utcDate = DateUtil.utcStringToDate(utcString: scheduleDate)
                    if utcDate <= Date() {
                        streamingBtn.setTitle("Start Live Streaming", for: .normal)
                    } else {
                        streamingBtn.setTitle("Schedule: \(dateTime)", for: .normal)
                    }
                } else {
                    streamingBtn.setTitle("Schedule: \(dateTime)", for: .normal)
                }
            } else {
                if let _ = postDetails?.streamUrl {
                    streamingBtn.setTitle("Play Recorded Stream", for: .normal)
                    streamingBtn.isUserInteractionEnabled = true
                } else {
                    streamingBtn.setTitle("Join Live Streaming", for: .normal)
                    streamingBtn.isUserInteractionEnabled = true
                }
            }
            
        case .vault:
            profilePicURL = postDetails?.admin?.profileImage ?? ""
            //username = postDetails?.admin?.username ?? ""
            let firstName = postDetails?.admin?.firstName ?? ""
            let lastName = postDetails?.admin?.lastName ?? ""
            username = "\(firstName) \(lastName)"
            
        default: break
        }
        
        SharedMethods.shared.setImage(imageView: userProfilePic, url: profilePicURL)
        usernameLbl.text = username
        
        if let adminID = postDetails?.admin?._id {
            let loggedUserID = UserDefaults.standard[.loggedUserDetails]?._id
            if adminID == loggedUserID {
                //vaultMoreBtn.isHidden = true
               // getComments()
            } else {
                //vaultMoreBtn.isHidden = false
                if postDetails?.isMember == true {
                    joinBtn.isHidden = true
                    leaveBtn.isHidden = false
                   // getComments()
                } else {
                    joinBtn.isHidden = false
                    leaveBtn.isHidden = true
                }
            }
            getComments()
        }
        
        if selectedSavedOption == .vault {
            if postDetails?.isMember == true ||
                postDetails?.admin?._id == UserDefaults.standard[.loggedUserDetails]?._id {
                newCommentTopView.isHidden = false
                newCommentView.isHidden = false
            } else {
                newCommentTopView.isHidden = true
                newCommentView.isHidden = true
            }
        } else {
            newCommentTopView.isHidden = false
            newCommentView.isHidden = false
        }
        
        if selectedSavedOption == .stream {
            getComments()
        }
        
        previousPageBtn.isEnabled = false
        
        members = postDetails?.members ?? []
        membersCollectionView.reloadData()
        
        ratingValueLbl.text = "(\(postDetails?.ratings ?? 0.0))"
        overallRatingView.rating = postDetails?.ratings ?? 0.0
    }
    
    fileprivate func getComments() {
        pageNoLbl.text = "\(pageNo)"
        viewModel.getComments(params: ["id": id, "type": selectedSavedOption.type, "page": pageNo],
                              event: selectedSavedOption)
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

extension VaultsRoomVC: UICollectionViewDataSource,
                        UICollectionViewDelegate,
                        UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == adsCollectionView {
            return ads.count
            
        } else if collectionView == membersCollectionView {
            return members.count
            
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == adsCollectionView {
            return CGSize(width: 320, height: 204.0)
            
        } else if collectionView == membersCollectionView {
            return CGSize(width: 55, height: 55)
            
        } else {
            return CGSize(width: 0.0, height: 0.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == adsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdsCell.identifier, for: indexPath) as! AdsCell
            SharedMethods.shared.setImage(imageView: cell.adsImage, url: ads[indexPath.item].file ?? "")
            return cell
            
        } else if collectionView == membersCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemberCell.identifier, for: indexPath) as! MemberCell
            cell.memberDetails = members[indexPath.item]
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == adsCollectionView {
            let offsetX = scrollView.contentOffset.x
            let contentWidth = scrollView.contentSize.width
            let frameWidth = scrollView.frame.width
            guard !self.viewModel.isAdsListLoading, !self.viewModel.isAdsListLastPage else { return }
            if offsetX > contentWidth - frameWidth - 100 { // For horizontal scroll
                self.viewModel.isAdsListLoading = true
                self.pageNo2 += 1
                self.getAds()
            }
        }
    }
}

extension VaultsRoomVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as! CommentCell
        cell.commentDetails = comments[indexPath.item]
        cell.boomBtn.tag = indexPath.row
        cell.boomBtn.addTarget(self, action: #selector(likeDislikeComment(_ :)), for: .touchUpInside)
        return cell
    }
    
    @objc func likeDislikeComment(_ sender: UIButton) {
        if let id = comments[sender.tag]._id {
            let previousStatus = comments[sender.tag].isLiked ?? false
            comments[sender.tag].isLiked = !previousStatus
            var likesCount = comments[sender.tag].likesCount ?? 0
            if comments[sender.tag].isLiked == true {
                likesCount += 1
            } else {
                likesCount -= 1
            }
            comments[sender.tag].likesCount = likesCount
            if let cell = commentsTableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? CommentCell {
                cell.commentDetails = comments[sender.tag]
            }
            viewModel.likeDislikeComment(id: id, event: selectedSavedOption)
        }
    }
}

extension VaultsRoomVC: SocketIOEvents {
    
    func receivedNewMessage(message: Chat) { }
    
    func receivedNewVaultMessage(comment: Comment) {
        var loadedComments = viewModel.comments
        loadedComments.append(comment)
        viewModel.triggeredEvent = .addComment
        viewModel.comments = loadedComments
        //        comments.append(comment)
        //        commentsTableView.reloadData()
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        //            let lastCount = self.comments.count - 1
        //            let totalRows = self.commentsTableView.numberOfRows(inSection: 0)
        //            // Ensure the table has at least one row, and that the index is valid
        //            if totalRows > 0 && lastCount >= 0 && lastCount < totalRows {
        //                let indexPath = IndexPath(row: totalRows - 1, section: 0)
        //                self.commentsTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        //            }
        //        }
    }
    
    func adminDisconnected() { }
}
