import UIKit
import FSCalendar
import SideMenu
import Cosmos

class ProfileVC: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var profileMainView: UIView!
    @IBOutlet weak var editMainView: UIView!
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var bottomTabsView: UIView!
    @IBOutlet weak var ratingOverlayView: UIView!
    @IBOutlet weak var customFSCalendar: FSCalendar!
    @IBOutlet weak var currentYearLbl: UILabel!
    @IBOutlet weak var currentMonthLbl: UILabel!
    @IBOutlet weak var calendarOuterView: UIView!
    @IBOutlet weak var calendarBottomSpaciouEmptyView: UIView!
    @IBOutlet weak var reminderHeaderView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var topicView: UIView!
    @IBOutlet weak var descView: UIView!
    @IBOutlet weak var uploadFileView: UIView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var interfaceTitleLbl: UILabel!
    @IBOutlet weak var savedMainView: UIView!
    @IBOutlet weak var financialAdvisorView: UIStackView!
    @IBOutlet weak var memberUsernameView: UIStackView!
    @IBOutlet weak var servicesView: UIStackView!
    @IBOutlet weak var websiteView: UIStackView!
    @IBOutlet weak var goalsView: UIStackView!
    @IBOutlet weak var connectedProfileView: UIView!
    @IBOutlet weak var customersCountView: UIView!
    @IBOutlet weak var advisorIcon: UIImageView!
    @IBOutlet weak var companyNameTitleLbl: UILabel!
    @IBOutlet weak var launchDateView: UIStackView!
    @IBOutlet weak var financialExpView: UIStackView!
    @IBOutlet weak var launchDateTitleLbl: UILabel!
    @IBOutlet weak var customersOrInvestmentsCountTitleLbl: UILabel!
    @IBOutlet weak var servicesProductsTitleLbl: UILabel!
    @IBOutlet weak var followUnfollowStatusView: UIView!
    @IBOutlet weak var followUnfollowStatusBtn: UIButton!
    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak var optionsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var optionsViewBottom: NSLayoutConstraint!
    @IBOutlet weak var totalRatingLbl: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var totalShareLbl: UILabel!
    @IBOutlet weak var totalFollowingLbl: UILabel!
    @IBOutlet weak var totalFollowedByLbl: UILabel!
    @IBOutlet weak var totalCustomersLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var companyNameLbl: UILabel!
    @IBOutlet weak var memberUsernameLbl: UILabel!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var expLbl: UILabel!
    @IBOutlet weak var launchDateLbl: UILabel!
    @IBOutlet weak var memberSinceLbl: UILabel!
    @IBOutlet weak var aboutTV: UITextView!
    @IBOutlet weak var servicesProductsLbl: UILabel!
    @IBOutlet weak var websiteLbl: UILabel!
    @IBOutlet weak var goalLbl: UILabel!
    @IBOutlet weak var reportUserView: UIView!
    @IBOutlet weak var additionalPhotosView: UIView!
    @IBOutlet weak var sharePostsView: UIView!
    @IBOutlet weak var aboutDescView: UIView!
    @IBOutlet weak var roleLbl: UILabel!
    @IBOutlet weak var accountDetailsView: UIView!
    @IBOutlet weak var overallRatingView: CosmosView!
    @IBOutlet weak var totalRatingView: UIView!
    @IBOutlet weak var ratingValueLbl: UILabel!
    @IBOutlet weak var totalGivenRatingLbl: UILabel!
    @IBOutlet weak var fiveStarRatingCountLbl: UILabel!
    @IBOutlet weak var fourStarRatingCountLbl: UILabel!
    @IBOutlet weak var threeStarRatingCountLbl: UILabel!
    @IBOutlet weak var twoStarRatingCountLbl: UILabel!
    @IBOutlet weak var oneStarRatingCountLbl: UILabel!
    @IBOutlet weak var fiveStarRatingProgressBar: UIProgressView!
    @IBOutlet weak var fourStarRatingProgressBar: UIProgressView!
    @IBOutlet weak var threeStarRatingProgressBar: UIProgressView!
    @IBOutlet weak var twoStarRatingProgressBar: UIProgressView!
    @IBOutlet weak var oneStarRatingProgressBar: UIProgressView!
    @IBOutlet weak var totalRatingStars: CosmosView!
    @IBOutlet weak var reminderTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var topicTF: UITextField!
    @IBOutlet weak var descTF: UITextView!
    @IBOutlet weak var browsedFilename: UITextField!
    @IBOutlet weak var topicIcon: UIButton!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var connectedWithProfileIcon: UIImageView!
    @IBOutlet weak var connectWithProfileBtn: UIButton!
    @IBOutlet weak var shareTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var streamTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var vaultTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var ratingDetailsIcon: UIImageView!
    @IBOutlet weak var heartIcon: UIButton!
    @IBOutlet weak var customerWidth: NSLayoutConstraint!
    @IBOutlet weak var maritalStatusView: UIStackView!
    @IBOutlet weak var maritalStatusLbl: UILabel!
    @IBOutlet weak var publicSwitch: UISwitch!
    @IBOutlet weak var fairnessForwardView: UIStackView!
    @IBOutlet weak var fairnessForwardLbl: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.registerCellFromNib(cellID: OptionWithUnderlineCell.identifier)
        }
    }
    
    @IBOutlet weak var photosCollectionView: UICollectionView! {
        didSet {
            photosCollectionView.registerCellFromNib(cellID: AddMoreCell.identifier)
        }
    }
    
    @IBOutlet weak var shareCollectionView: UICollectionView! {
        didSet {
            shareCollectionView.registerCellFromNib(cellID: FeedCell.identifier)
        }
    }
    
    @IBOutlet weak var adsCollectionView: UICollectionView! {
        didSet {
            adsCollectionView.registerCellFromNib(cellID: AdsCell.identifier)
        }
    }
    
    @IBOutlet weak var editTableView: UITableView! {
        didSet{
            editTableView.registerCellFromNib(cellID: EditOptionCell.identifier)
            editTableView.registerCellFromNib(cellID: HeaderCell.identifier)
        }
    }
    
    @IBOutlet weak var remindersTableView: UITableView! {
        didSet{
            remindersTableView.registerCellFromNib(cellID: ReminderCell.identifier)
        }
    }
    
    @IBOutlet weak var savedOptionsCollectionView: UICollectionView! {
        didSet {
            savedOptionsCollectionView.registerCellFromNib(cellID: SavedOptionCell.identifier)
        }
    }
    
    @IBOutlet weak var categoriesCollectionView: UICollectionView! {
        didSet {
            categoriesCollectionView.registerCellFromNib(cellID: CategoryCell.identifier)
        }
    }
    
    @IBOutlet weak var savedShareTableView: UITableView! {
        didSet{
            savedShareTableView.registerCellFromNib(cellID: SavedFeedCell.identifier)
        }
    }
    
    @IBOutlet weak var savedStreamTableView: UITableView! {
        didSet{
            savedStreamTableView.registerCellFromNib(cellID: SavedFeedCell.identifier)
        }
    }
    
    @IBOutlet weak var savedVaultTableView: UITableView! {
        didSet{
            savedVaultTableView.registerCellFromNib(cellID: SavedFeedCell.identifier)
        }
    }
    
    // MARK: Variables
    fileprivate var selectedOption: ProfileSections = .profile
    fileprivate let footerView = VCFooterView()
    fileprivate let eventDates: [Date] = [Date()]
    fileprivate var selectedDate: Date?
    fileprivate var isAddNewEventViewActive: Bool = false
    fileprivate var selectedSavedOption: SavedOptions = .share
    fileprivate var selectedCategories: [Categories] = [.members]
    fileprivate var userDetails: UserDetails?
    private var viewModel = SharedVM()
    private var additionalPhotos = [String]()
    fileprivate var sharesPageNo = 1
    fileprivate var streamsPageNo = 1
    fileprivate var vaultsPageNo = 1
    private var eventPageNo = 1
    fileprivate var limit = 20
    fileprivate var eventsLimit = 100
    fileprivate var isConnectedWithAnotherUserProfile = false
    fileprivate var sharePosts = [PostDetails]()
    fileprivate var streamPosts = [PostDetails]()
    fileprivate var vaults = [PostDetails]()
    fileprivate var userID = ""
    private var calendarEvents = [Event]()
    private var browsedFileData: Data?
    var event: Events = .unspecified
    var isAnotherUserID: String? = nil
    let maxCharacters = 30
    
    fileprivate var pageNo = 1
    fileprivate var ads = [UserDetails]()
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        overallRatingView.settings.fillMode = .full
        totalRatingStars.settings.fillMode = .full
        
        remindersTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        savedShareTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        savedStreamTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        savedVaultTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        footerViewSetup()
        hideAllComponents()
        hideAllSavedOptionsTableView()
        profileMainView.isHidden = false
        footerView.isHidden = false
        interfaceTitleLbl.text = "Your Profile"
        
        // Register custom cell
        customFSCalendar.dataSource = self
        customFSCalendar.delegate = self
        customFSCalendar.register(CustomCalendarCell.self, forCellReuseIdentifier: "CustomCalendarCell")
        updateHeaderLabels()
        addNewCalendarEvent()
        initialViewSetup()
        bindViewModel()
        getAds()
        PickerManager.shared.configurePicker(for: topicTF,
                                             with: Constants.feedTopics,
                                             iconButton: topicIcon)
        
        mainScrollView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadContent(_ :)), name: .reloadContent, object: nil)
        
        counterLabel.text = "0/\(maxCharacters)"
        titleTF.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        counterLabel.text = "\(min(updatedText.count, maxCharacters))/\(maxCharacters)"
        return updatedText.count <= maxCharacters
    }
    
    @objc fileprivate func reloadContent(_ notify: Notification) {
        if let isAnotherUserID {
            viewModel.getUserProfile(anotherUserID: isAnotherUserID)
        } else {
            viewModel.getUserProfile()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ratingOverlayView.isHidden = true
        maritalStatusView.isHidden = true
        
        if let isAnotherUserID {
            followUnfollowStatusView.isHidden = false
            optionsView.isHidden = true
            optionsViewHeight.constant = 0
            optionsViewBottom.constant = 0
            reportUserView.isHidden = false
            connectedProfileView.isHidden = false
            accountDetailsView.isHidden = true
            viewModel.getUserProfile(anotherUserID: isAnotherUserID)
            userID = isAnotherUserID
        } else {
            reportUserView.isHidden = true
            connectedProfileView.isHidden = true
            accountDetailsView.isHidden = false
            viewModel.getUserProfile()
            if let id = UserDefaults.standard[.loggedUserDetails]?._id {
                userID = id
            }
        }
        
        viewModel.getRating(params: ["id": userID, "type": SavedOptions.user.type])
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize", object is UITableView {
            UIView.performWithoutAnimation {
                if selectedOption == .calendar {
                    reminderTableViewHeight.constant = remindersTableView.contentSize.height
                } else {
                    switch selectedSavedOption {
                    case .share: shareTableViewHeight.constant = savedShareTableView.contentSize.height
                    case .stream: streamTableViewHeight.constant = savedStreamTableView.contentSize.height
                    case .vault: vaultTableViewHeight.constant = savedVaultTableView.contentSize.height
                    default: break
                    }
                }
                view.layoutIfNeeded()
            }
        }
    }
    
    deinit {
        remindersTableView.removeObserver(self, forKeyPath: "contentSize")
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
    
    @IBAction func viewRating(_ sender: UIButton) {
        if let _ = userDetails?.isRated {
            footerView.isHidden = true
            ratingOverlayView.isHidden = false
        }
    }
    
    @IBAction func viewOverAllRating(_ sender: UIButton) {
        if let _ = userDetails?.isRated {
            footerView.isHidden = true
            ratingOverlayView.isHidden = false
        }
    }
    
    @IBAction func closeRatingOverlayView(_ sender: UIButton) {
        footerView.isHidden = false
        ratingOverlayView.isHidden = true
    }
    
    @IBAction func tappedPreviousYear(_ sender: UIButton) {
        moveCurrentPage(by: -1, unit: .year)
    }
    
    @IBAction func tappedNextYear(_ sender: UIButton) {
        moveCurrentPage(by: 1, unit: .year)
    }
    
    @IBAction func tappedPreviousMonth(_ sender: UIButton) {
        moveCurrentPage(by: -1, unit: .month)
    }
    
    @IBAction func tappedNextMonth(_ sender: UIButton) {
        moveCurrentPage(by: 1, unit: .month)
    }
    
    @IBAction func tappedAddNewEvent(_ sender: UIButton) {
        addNewCalendarEvent(isNew: true)
    }
    
    @IBAction func tappedSubmit(_ sender: UIButton) {
        let params = [
            "title": titleTF.text ?? "",
            "topic": topicTF.text ?? "",
            "description": descTF.text ?? "",
            "scheduledDate": "\(selectedDate ?? Date())",
            "type": CalendarEventTypes.own_events.rawValue
            //"public": publicSwitch.isOn
        ] as [String : Any]
        
        viewModel.addCalendarEvent(params: params, fileData: browsedFileData)
        
        addNewCalendarEvent()
    }
    
    @IBAction func tappedCancel(_ sender: UIButton) {
        addNewCalendarEvent()
    }
    
    @IBAction func viewAllReminders(_ sender: UIButton) { }
    
    @IBAction func viewAccountDetails(_ sender: UIButton) {
        let storyboard = AppStoryboards.menus.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "AccountDetailsVC") as? AccountDetailsVC
        else { return }
        destVC.event = event
        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
    }
    
    @IBAction func reportUser(_ sender: UIButton) {
        if let isAnotherUserID {
            let storyboard = AppStoryboards.menus.storyboardInstance
            guard let destVC = storyboard.instantiateViewController(withIdentifier: "ReportUserVC") as? ReportUserVC
            else { return }
            destVC.id = isAnotherUserID
            destVC.selectedSavedOption = .user
            SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
        }
    }
    
    @IBAction func followUnfollowStatus(_ sender: UIButton) {
        viewModel.followUnfollowUser(userID: isAnotherUserID ?? "")
    }
    
    @IBAction func newMessage(_ sender: UIButton) {
        let storyboard = AppStoryboards.menus.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "ViewMessageVC") as? ViewMessageVC
        else { return }
        destVC.receiverDetails = userDetails
        destVC.dateTime = ""
        destVC.threadID = userDetails?.chatId
        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
    }
    
    @IBAction func tapShares(_ sender: UIButton) {
        let storyboard = AppStoryboards.menus.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "MySharesVC") as? MySharesVC
        else { return }
        if let isAnotherUserID {
            destVC.isAnotherUserID = isAnotherUserID
        } else {
            if let id = UserDefaults.standard[.loggedUserDetails]?._id {
                destVC.isAnotherUserID = id
            }
        }
        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
    }
    
    @IBAction func tapFollowing(_ sender: UIButton) {
        navigateToUsersList("followedBy")
    }
    
    @IBAction func tapFollowedBy(_ sender: UIButton) {
        navigateToUsersList("followers")
    }
    
    @IBAction func tapCustomers(_ sender: UIButton) {
        navigateToUsersList("customers")
    }
    
    @IBAction func accountDetails(_ sender: UIButton) {
        let storyboard = AppStoryboards.menus.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "AccountDetailsVC") as? AccountDetailsVC
        else { return }
        destVC.event = event
        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
    }
    
    @IBAction func browseFile(_ sender: UIButton) {
        MediaPicker.shared.browsedImage() { [weak self] image, imageURL in
            let name = imageURL?.lastPathComponent ?? ""
            self?.browsedFilename.text = name
            self?.browsedFileData = image.jpegData(compressionQuality: 0.1)
        }
    }
    
    @IBAction func connectWithProfile(_ sender: UIButton) {
        isConnectedWithAnotherUserProfile.toggle()
        setConnectedWithProfileIcon()
        viewModel.updateCustomers(anotherUserID: isAnotherUserID ?? "")
    }
    
    @IBAction func exchange(_ sender: UIButton) {
        SharedMethods.shared.pushToWithoutData(destVC: ExchangeVC.self, storyboard: .menus, isAnimated: true)
    }
    
    @IBAction func ecosystem(_ sender: UIButton) {
        SharedMethods.shared.pushToWithoutData(destVC: EcosystemVC.self, storyboard: .menus, isAnimated: true)
    }
    
    // MARK: Shared Methods
    private func bindViewModel() {
        viewModel.$particularUserDetails.sink { [weak self] resp in
            if let resp {
                self?.userDetails = resp
                self?.populateData()
            }
        }.store(in: &viewModel.cancellables)
        
        viewModel.$updatedRating.sink { [weak self] rating in
            if let rating {
                self?.totalRatingLbl.text = "\(rating) rating"
                self?.overallRatingView.rating = rating
                self?.totalRatingView.isHidden = false
            }
        }.store(in: &viewModel.cancellables)
        
        viewModel.$requestResponse.sink { [weak self] resp in
            if let err = resp.error, !err.isEmpty {
                Toast.show(message: err)
            }
            
            if resp.isSuccess == true {
                switch resp.request {
                case .share, .getSavedPosts, .stream, .getSavedStreams, .vault, .getSavedVaults:
                    switch self?.selectedSavedOption {
                    case .share:
                        self?.sharePosts = self?.viewModel.sharePostsList ?? []
                        self?.savedShareTableView.reloadData()
                        
                    case .stream:
                        self?.streamPosts = self?.viewModel.streamPostsList ?? []
                        self?.savedStreamTableView.reloadData()
                        
                    case .vault:
                        self?.vaults = self?.viewModel.vaultsList ?? []
                        self?.savedVaultTableView.reloadData()
                        
                    default: break
                    }
                    
                case .logout, .deleteAccount:
                    if let vc = AppStoryboards.main.controller(LoginVC.self) {
                        SharedMethods.shared.navigateToRootVC(rootVC: vc)
                    }
                    
                case .event:
                    Toast.show(message: resp.message ?? "")
                    
                case .followUnfollowUser:
                    Toast.show(message: resp.message ?? "")
                    let msg = resp.message ?? ""
                    if msg.contains("Unfollowed") {
                        self?.followUnfollowStatusBtn.setTitle("Follow", for: .normal)
                        self?.heartIcon.isHidden = true
                    } else {
                        self?.followUnfollowStatusBtn.setTitle("Unfollow", for: .normal)
                        self?.heartIcon.isHidden = false
                    }
                    
                    //                    let previousStatus = self?.userDetails?.isFollowed ?? false
                    //                    let updatedStatus = !previousStatus
                    //                    if updatedStatus {
                    //                        self?.followUnfollowStatusBtn.setTitle("Unfollow", for: .normal)
                    //                        self?.heartIcon.isHidden = false
                    //                    } else {
                    //                        self?.followUnfollowStatusBtn.setTitle("Follow", for: .normal)
                    //                        self?.heartIcon.isHidden = true
                    //                    }
                    
                case .updateCustomers:
                    Toast.show(message: resp.message ?? "")
                    
                default: break
                }
            }
        }.store(in: &viewModel.cancellables)
        
        viewModel.$ratingData.sink { [weak self] resp in
            if let resp {
                let averageRating = resp.averageRating ?? 0.0
                self?.totalRatingStars.rating = averageRating
                self?.ratingValueLbl.text = "\(averageRating)"
                let totalCount = resp.totalCount ?? 0
                self?.totalGivenRatingLbl.text = "\(totalCount) ratings"
                if let ratingsCount = resp.ratingsCount {
                    
                    let fiveStar = ratingsCount["5"] ?? 0
                    let fiveStarAvg = totalCount > 0 ? Float(fiveStar) / Float(totalCount) : 0.0
                    self?.fiveStarRatingCountLbl.text = "\(fiveStar)"
                    self?.fiveStarRatingProgressBar.setProgress(fiveStarAvg, animated: true)
                    
                    let fourStar = ratingsCount["4"] ?? 0
                    let fourStarAvg = totalCount > 0 ? Float(fourStar) / Float(totalCount) : 0.0
                    self?.fourStarRatingCountLbl.text = "\(fourStar)"
                    self?.fourStarRatingProgressBar.setProgress(fourStarAvg, animated: true)
                    
                    let threeStar = ratingsCount["3"] ?? 0
                    let threeStarAvg = totalCount > 0 ? Float(threeStar) / Float(totalCount) : 0.0
                    self?.threeStarRatingCountLbl.text = "\(threeStar)"
                    self?.threeStarRatingProgressBar.setProgress(threeStarAvg, animated: true)
                    
                    let twoStar = ratingsCount["2"] ?? 0
                    let twoStarAvg = totalCount > 0 ? Float(twoStar) / Float(totalCount) : 0.0
                    self?.twoStarRatingCountLbl.text = "\(twoStar)"
                    self?.twoStarRatingProgressBar.setProgress(twoStarAvg, animated: true)
                    
                    let oneStar = ratingsCount["1"] ?? 0
                    let oneStarAvg = totalCount > 0 ? Float(oneStar) / Float(totalCount) : 0.0
                    self?.oneStarRatingCountLbl.text = "\(oneStar)"
                    self?.oneStarRatingProgressBar.setProgress(oneStarAvg, animated: true)
                }
            }
        }.store(in: &viewModel.cancellables)
        
        viewModel.$calendarEvents.sink { [weak self] resp in
            DispatchQueue.main.async {
                self?.calendarEvents = resp
                self?.remindersTableView.reloadData()
                self?.customFSCalendar.reloadData()
            }
        }.store(in: &viewModel.cancellables)
        
        viewModel.$updatedPostStatusIndex
            .receive(on: RunLoop.main)
            .sink { [weak self] info in
                if let info {
                    switch info.event {
                    case .share:
                        self?.sharePosts = self?.viewModel.sharePostsList ?? []
                        if info.key == .deletePost {
                            self?.savedShareTableView.reloadData()
                        } else {
                            self?.savedShareTableView.reloadRows(at: [IndexPath(row: info.index, section: 0)], with: .none)
                        }
                        
                    case .stream:
                        self?.streamPosts = self?.viewModel.streamPostsList ?? []
                        if info.key == .deletePost {
                            self?.savedStreamTableView.reloadData()
                        } else {
                            self?.savedStreamTableView.reloadRows(at: [IndexPath(row: info.index, section: 0)], with: .none)
                        }
                        
                    case .vault:
                        self?.vaults = self?.viewModel.vaultsList ?? []
                        if info.key == .deletePost {
                            self?.savedVaultTableView.reloadData()
                        } else {
                            self?.savedVaultTableView.reloadRows(at: [IndexPath(row: info.index, section: 0)], with: .none)
                        }
                        
                    default: break
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
    
    fileprivate func navigateToUsersList(_ type: String) {
        let storyboard = AppStoryboards.menus.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "UsersListVC") as? UsersListVC
        else { return }
        var params = [String: Any]()
        if let isAnotherUserID {
            params["id"] = isAnotherUserID
        } else {
            if let id = UserDefaults.standard[.loggedUserDetails]?._id {
                params["id"] = id
            }
        }
        params["type"] = type
        destVC.dict = params
        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
    }
    
    private func getAds() {
        viewModel.getAds(params: ["page": pageNo, "limit": limit], limit: limit)
    }
    
    fileprivate func populateData() {
        SharedMethods.shared.setImage(imageView: profilePic, url: userDetails?.profileImage ?? "")
        let firstName = userDetails?.firstName ?? ""
        let lastName = userDetails?.lastName ?? ""
        let completeName = "\(firstName) \(lastName)"
        usernameLbl.text = completeName
        totalShareLbl.text = "\(userDetails?.sharesCount ?? 0)"
        totalFollowingLbl.text = "\(userDetails?.following ?? 0)"
        totalFollowedByLbl.text = "\(userDetails?.followers ?? 0)"
        totalCustomersLbl.text = "\(userDetails?.customers ?? 0)"
        nameLbl.text = completeName
        companyNameLbl.text = userDetails?.company ?? ""
        memberUsernameLbl.text = userDetails?.username ?? ""
        cityLbl.text = userDetails?.city ?? ""
        stateLbl.text = userDetails?.state ?? ""
        expLbl.text = ""
        aboutTV.text = userDetails?.about ?? ""
        servicesProductsLbl.text = userDetails?.productsOffered ?? ""
        websiteLbl.text = userDetails?.website ?? ""
        goalLbl.text = ""
        if event == .unspecified {
            roleLbl.text = ""
        } else {
            roleLbl.text = event.rawValue
        }
        launchDateLbl.text = DateUtil.formatDateToLocal(from: userDetails?.createdAt ?? "", format: "d MMM yyyy")
        memberSinceLbl.text = DateUtil.formatDateToLocal(from: userDetails?.createdAt ?? "", format: "d MMM yyyy")
        additionalPhotos = userDetails?.additionalPhotos ?? []
        if additionalPhotos.isEmpty {
            additionalPhotosView.isHidden = true
        } else {
            additionalPhotosView.isHidden = false
            photosCollectionView.reloadData()
        }
        
        if let about = userDetails?.about, !about.isEmpty {
            aboutDescView.isHidden = false
            aboutTV.text = about
        } else {
            aboutDescView.isHidden = true
        }
        
        if isAnotherUserID == nil {
            editTableView.reloadData()
        }
        
        if let maritalStatus = userDetails?.maritalStatus,
           !maritalStatus.isEmpty {
            maritalStatusView.isHidden = false
            maritalStatusLbl.text = maritalStatus
        } else {
            maritalStatusView.isHidden = true
        }
        
        //        if let rating = userDetails?.isRated {
        //            totalRatingLbl.text = "\(rating) rating"
        //            overallRatingView.rating = rating
        //            totalRatingView.isHidden = false
        //            ratingDetailsIcon.isHidden = false
        //        } else {
        //            totalRatingLbl.text = ""
        //            overallRatingView.rating = 0.0
        //            totalRatingView.isHidden = true
        //            ratingDetailsIcon.isHidden = true
        //        }
        
        if let rating = userDetails?.averageRating {
            totalRatingLbl.text = "\(rating) rating"
            overallRatingView.rating = rating
            totalRatingView.isHidden = false
            ratingDetailsIcon.isHidden = false
        } else {
            totalRatingLbl.text = ""
            overallRatingView.rating = 0.0
            totalRatingView.isHidden = true
            ratingDetailsIcon.isHidden = true
        }
        
        if let isAnotherUserID {
            overallRatingView.isUserInteractionEnabled = true
            overallRatingView.didFinishTouchingCosmos = { [weak self] rating in
                self?.overallRatingView.isUserInteractionEnabled = false
                let params = ["ratings": rating, "type": SavedOptions.user.type, "id": isAnotherUserID]
                self?.viewModel.addRating(params: params) { [weak self] in
                    self?.overallRatingView.isUserInteractionEnabled = true
                    self?.viewModel.getRating(params: ["id": self?.userID ?? "", "type": SavedOptions.user.type])
                }
            }
            
            isConnectedWithAnotherUserProfile = userDetails?.isConnectedWithProfile ?? false
            setConnectedWithProfileIcon()
            
            if let isFollowed = userDetails?.isFollowed, isFollowed == true {
                followUnfollowStatusBtn.setTitle("Unfollow", for: .normal)
                heartIcon.isHidden = false
            } else {
                followUnfollowStatusBtn.setTitle("Follow", for: .normal)
                heartIcon.isHidden = true
            }
            
            interfaceTitleLbl.text = "Profile"
            
            if userDetails?.isReported == true {
                reportUserView.isHidden = true
            } else {
                reportUserView.isHidden = false
            }
        } else {
            overallRatingView.isUserInteractionEnabled = false
            heartIcon.isHidden = true
        }
        
        if userDetails?.fairnessForward == true {
            advisorIcon.isHidden = false
        } else {
            advisorIcon.isHidden = true
        }
        
        if let fairnessForward = userDetails?.fairnessForward {
            fairnessForwardView.isHidden = false
            fairnessForwardLbl.text = fairnessForward == true ? "Yes" : "No"
        } else {
            fairnessForwardView.isHidden = true
            fairnessForwardLbl.text = ""
        }
    }
    
    fileprivate func setConnectedWithProfileIcon() {
        if isConnectedWithAnotherUserProfile {
            connectedWithProfileIcon.image = UIImage(named: "selectedBox")
        } else {
            connectedWithProfileIcon.image = UIImage(named: "unselectedBox")
        }
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
    
    fileprivate func hideAllComponents() {
        profileMainView.isHidden = true
        editMainView.isHidden = true
        calendarView.isHidden = true
        savedMainView.isHidden = true
        bottomTabsView.isHidden = true
        footerView.isHidden = true
    }
    
    fileprivate func hideAllSavedOptionsTableView() {
        savedShareTableView.isHidden = true
        savedStreamTableView.isHidden = true
        savedVaultTableView.isHidden = true
    }
    
    fileprivate func addNewCalendarEvent(isNew: Bool = false) {
        calendarOuterView.isHidden = isNew
        calendarBottomSpaciouEmptyView.isHidden = isNew
        reminderHeaderView.isHidden = isNew
        remindersTableView.isHidden = isNew
        titleView.isHidden = !isNew
        topicView.isHidden = !isNew
        descView.isHidden = !isNew
        uploadFileView.isHidden = !isNew
        submitBtn.isHidden = !isNew
        cancelBtn.isHidden = !isNew
        isAddNewEventViewActive = isNew
        if selectedOption == .calendar {
            if isNew {
                interfaceTitleLbl.text = "Add Event"
            } else {
                interfaceTitleLbl.text = "Calendar"
            }
        }
    }
    
    fileprivate func initialViewSetup() {
        customerWidth.constant = 82.0
        switch event {
            
        case .generalMemberAccountRegistration:
            financialAdvisorView.isHidden = true
            memberUsernameView.isHidden = false
            servicesView.isHidden = false
            websiteView.isHidden = true
            goalsView.isHidden = false
            connectedProfileView.isHidden = true
            customersCountView.isHidden = false
            //advisorIcon.isHidden = true
            servicesProductsTitleLbl.text = "Interested"
            customersOrInvestmentsCountTitleLbl.text = "Services Patronized"
            customerWidth.constant = 132.0
            
        case .financialAdvisorAccountRegistration:
            financialAdvisorView.isHidden = false
            memberUsernameView.isHidden = true
            servicesView.isHidden = false
            websiteView.isHidden = false
            goalsView.isHidden = true
            connectedProfileView.isHidden = false
            customersCountView.isHidden = false
            //advisorIcon.isHidden = false
            servicesProductsTitleLbl.text = "Services/ Products"
            
        case .smallBusinessAccountRegistration:
            memberUsernameView.isHidden = true
            servicesView.isHidden = false
            websiteView.isHidden = false
            goalsView.isHidden = true
            connectedProfileView.isHidden = false
            customersCountView.isHidden = false
            //advisorIcon.isHidden = false
            companyNameTitleLbl.text = "Small Business"
            launchDateTitleLbl.text = "Founded"
            launchDateView.isHidden = false
            financialExpView.isHidden = true
            financialAdvisorView.isHidden = false
            servicesProductsTitleLbl.text = "Services/ Products"
            
        case .startupAccountRegistration:
            memberUsernameView.isHidden = true
            servicesView.isHidden = false
            websiteView.isHidden = false
            goalsView.isHidden = true
            connectedProfileView.isHidden = false
            customersCountView.isHidden = false
            //advisorIcon.isHidden = false
            companyNameTitleLbl.text = "Startup"
            launchDateView.isHidden = false
            financialExpView.isHidden = true
            financialAdvisorView.isHidden = false
            servicesProductsTitleLbl.text = "Services/ Products"
            
        case .investorVCAccountRegistration:
            customersOrInvestmentsCountTitleLbl.text = "Investments"
            memberUsernameView.isHidden = true
            servicesView.isHidden = false
            websiteView.isHidden = false
            goalsView.isHidden = true
            connectedProfileView.isHidden = false
            customersCountView.isHidden = false
            //advisorIcon.isHidden = false
            companyNameTitleLbl.text = "VC"
            launchDateTitleLbl.text = "Founded"
            launchDateView.isHidden = false
            financialExpView.isHidden = true
            financialAdvisorView.isHidden = false
            servicesProductsTitleLbl.text = "Interested"
            
        case .insurance, .financialFirmAccountRegistration:
            memberUsernameView.isHidden = true
            servicesView.isHidden = false
            websiteView.isHidden = false
            goalsView.isHidden = true
            connectedProfileView.isHidden = false
            customersCountView.isHidden = false
            //advisorIcon.isHidden = false
            companyNameTitleLbl.text = "Insurance"
            launchDateTitleLbl.text = "Founded"
            launchDateView.isHidden = false
            financialExpView.isHidden = true
            financialAdvisorView.isHidden = false
            servicesProductsTitleLbl.text = "Services/ Products"
            
        default: break
        }
        
        //        if let isAnotherUserID {
        //            followUnfollowStatusView.isHidden = false
        //            optionsView.isHidden = true
        //            optionsViewHeight.constant = 0
        //            optionsViewBottom.constant = 0
        //            reportUserView.isHidden = false
        //            connectedProfileView.isHidden = false
        //            accountDetailsView.isHidden = true
        //            viewModel.getUserProfile(anotherUserID: isAnotherUserID)
        //            userID = isAnotherUserID
        //        } else {
        //            reportUserView.isHidden = true
        //            connectedProfileView.isHidden = true
        //            accountDetailsView.isHidden = false
        //            viewModel.getUserProfile()
        //            if let id = UserDefaults.standard[.loggedUserDetails]?._id {
        //                userID = id
        //            }
        //        }
        //
        //        viewModel.getRating(params: ["id": userID, "type": SavedOptions.user.type])
    }
    
    private func getPosts(isResetPageNo: Bool = false) {
        let categories = selectedCategories.map({$0.type}).joined(separator: ",")
        var pageNo = 1
        
        if isResetPageNo {
            sharesPageNo = 1
            streamsPageNo = 1
            vaultsPageNo = 1
        }
        
        switch selectedSavedOption {
        case .share:
            pageNo = sharesPageNo
            
        case .stream:
            pageNo = streamsPageNo
            
        case .vault:
            pageNo = vaultsPageNo
            
        default: break
        }
        
        var params = ["userType": categories, "page": pageNo] as [String : Any]
        
        if selectedSavedOption != .vault {
            params["type"] = selectedSavedOption.type
        }
        
        viewModel.getPosts(params: params, limit: limit, event: selectedSavedOption, isfetchSavedData: true)
    }
    
    private func getEvents() {
        viewModel.getEvents(params: ["page": eventPageNo, "limit": eventsLimit], limit: eventsLimit)
    }
    
    @objc func tappedShare(_ button: UIButton) {
        createNewFeed(events: .share)
    }
    
    @objc func tappedStream(_ button: UIButton) {
        createNewFeed(events: .stream)
    }
    
    @objc func tappedVault(_ button: UIButton) {
        createNewFeed(events: .vault)
    }
    
    fileprivate func createNewFeed(events: SavedOptions) {
        let storyboard = AppStoryboards.menus.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "ShareVC") as? ShareVC
        else { return }
        destVC.events = events
        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
    }
}

// MARK: Delegates and DataSources

extension ProfileVC: UICollectionViewDataSource,
                     UICollectionViewDelegate,
                     UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == photosCollectionView {
            return additionalPhotos.count
            
        } else if collectionView == shareCollectionView {
            return 5
            
        } else if collectionView == adsCollectionView {
            return ads.count
            
        } else if collectionView == savedOptionsCollectionView {
            return SavedOptions.allCases.count
            
        } else if collectionView == categoriesCollectionView {
            return Categories.allCases.count
            
        } else {
            return ProfileSections.allCases.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == photosCollectionView {
            let width = (photosCollectionView.frame.width)/2.5 - 20
            return CGSize(width: width, height: 142)
            
        } else if collectionView == shareCollectionView {
            let width = (photosCollectionView.frame.width) - 50
            return CGSize(width: width, height: 299)
            
        } else if collectionView == adsCollectionView {
            return CGSize(width: 320, height: 204.0)
            
        } else if collectionView == savedOptionsCollectionView {
            let width = (savedOptionsCollectionView.frame.width)/3
            return CGSize(width: width, height: 52)
            
        } else if collectionView == categoriesCollectionView {
            let label = UILabel(frame: CGRect.zero)
            label.text = Categories.allCases[indexPath.item].rawValue
            label.sizeToFit()
            let extraComponentsOccupiedSpace = 65.0
            let width = label.frame.width + extraComponentsOccupiedSpace
            return CGSize(width: width, height: 25)
            
        } else {
            let width = self.collectionView.frame.width/4
            return CGSize(width: width, height: 52)
        }
    }
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    //        return UIEdgeInsets.zero
    //    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == photosCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddMoreCell.identifier, for: indexPath) as! AddMoreCell
            cell.addImageIcon.isHidden = true
            let url = additionalPhotos[indexPath.item]
            SharedMethods.shared.setImage(imageView: cell.selectedImg, url: url)
            return cell
            
        } else if collectionView == shareCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedCell.identifier, for: indexPath) as! FeedCell
            return cell
            
        }  else if collectionView == adsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdsCell.identifier, for: indexPath) as! AdsCell
            SharedMethods.shared.setImage(imageView: cell.adsImage, url: ads[indexPath.item].file ?? "")
            return cell
            
        } else if collectionView == savedOptionsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedOptionCell.identifier, for: indexPath) as! SavedOptionCell
            let option = SavedOptions.allCases[indexPath.item]
            cell.titleLbl.text = option.rawValue
            if selectedSavedOption == option {
                cell.optionView.backgroundColor = UIColor(named: "#7030A0")
                cell.titleLbl.textColor = .white
            } else {
                cell.optionView.backgroundColor = .clear
                cell.titleLbl.textColor = UIColor(named: "#7030A0")
            }
            
            return cell
            
        } else if collectionView == categoriesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell
            let category = Categories.allCases[indexPath.item]
            cell.titleLbl.text = category.rawValue
            if selectedCategories.contains(category) {
                cell.optionView.backgroundColor = UIColor(named: "#7030A0")
                cell.titleLbl.textColor = .white
            } else {
                cell.optionView.backgroundColor = .clear
                cell.titleLbl.textColor = UIColor(named: "#7030A0")
            }
            
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OptionWithUnderlineCell.identifier, for: indexPath) as! OptionWithUnderlineCell
            let option = ProfileSections.allCases[indexPath.item]
            cell.titleLbl.text = option.rawValue
            if selectedOption == option {
                cell.highlightView.isHidden = false
                cell.titleLbl.font = .systemFont(ofSize: 16, weight: .medium)
            } else {
                cell.highlightView.isHidden = true
                cell.titleLbl.font = .systemFont(ofSize: 16, weight: .light)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
            selectedOption = ProfileSections.allCases[indexPath.item]
            self.collectionView.reloadData()
            hideAllComponents()
            switch selectedOption {
            case .profile:
                profileMainView.isHidden = false
                footerView.isHidden = false
                let y = UIScreen.main.bounds.height - 44
                footerView.center.y = y
                interfaceTitleLbl.text = "Your Profile"
                
            case .edit:
                editMainView.isHidden = false
                bottomTabsView.isHidden = false
                interfaceTitleLbl.text = "Your Profile"
                
            case .calendar:
                calendarView.isHidden = false
                footerView.isHidden = false
                bottomTabsView.isHidden = false
                let y = UIScreen.main.bounds.height - 119
                footerView.center.y = y - 20
                if isAddNewEventViewActive {
                    interfaceTitleLbl.text = "Add Event"
                } else {
                    interfaceTitleLbl.text = "Calendar"
                    eventPageNo = 1
                    viewModel.isCalendarEventsListLastPage = false
                    getEvents()
                }
                
            case .saved:
                interfaceTitleLbl.text = selectedSavedOption.interfaceTitleValue
                savedMainView.isHidden = false
                let y = UIScreen.main.bounds.height - 119
                footerView.center.y = y - 20
                footerView.isHidden = false
                bottomTabsView.isHidden = false
                hideAllSavedOptionsTableView()
                switch selectedSavedOption {
                case .share: savedShareTableView.isHidden = false
                case .stream: savedStreamTableView.isHidden = false
                case .vault: savedVaultTableView.isHidden = false
                default: break
                }
                
                getPosts()
            }
        } else if collectionView == savedOptionsCollectionView {
            selectedSavedOption = SavedOptions.allCases[indexPath.item]
            interfaceTitleLbl.text = selectedSavedOption.interfaceTitleValue
            savedOptionsCollectionView.reloadData()
            hideAllSavedOptionsTableView()
            switch selectedSavedOption {
            case .share:
                savedShareTableView.isHidden = false
                
            case .stream:
                savedStreamTableView.isHidden = false
                
            case .vault:
                savedVaultTableView.isHidden = false
                
            default: break
            }
            
            getPosts()
            
        } else if collectionView == categoriesCollectionView {
            selectedCategories = [Categories.allCases[indexPath.item]]
            categoriesCollectionView.reloadData()
            getPosts(isResetPageNo: true)
            
        } else if collectionView == photosCollectionView {
            let storyboard = AppStoryboards.menus.storyboardInstance
            guard let destVC = storyboard.instantiateViewController(withIdentifier: "PreviewMediaVC") as? PreviewMediaVC
            else { return }
            destVC.mediaURL = additionalPhotos[indexPath.item]
            SharedMethods.shared.presentVC(destVC: destVC)
        }
    }
}

extension ProfileVC: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == editTableView {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == editTableView {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: HeaderCell.identifier) as! HeaderCell
            if section == 0 {
                headerCell.headerLbl.text = "Account"
            } else {
                headerCell.headerLbl.text = "Account Management"
            }
            return headerCell
        } else {
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == editTableView {
            return 40
        } else {
            return .leastNonzeroMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == editTableView {
            if section == 0 {
                if event == .financialAdvisorAccountRegistration {
                    return AccountOptionsViaFinancialAdvisors.allCases.count
                } else if event == .startupAccountRegistration ||
                            event == .smallBusinessAccountRegistration ||
                            event == .investorVCAccountRegistration ||
                            event == .insurance ||
                            event == .financialFirmAccountRegistration {
                    return AccountOptionsViaStartUp.allCases.count
                } else {
                    return AccountOptions.allCases.count
                }
            } else {
                if event == .financialAdvisorAccountRegistration {
                    return AccountManagementOptionsViaFinancialAdvisors.allCases.count
                } else if event == .startupAccountRegistration ||
                            event == .smallBusinessAccountRegistration ||
                            event == .investorVCAccountRegistration ||
                            event == .insurance ||
                            event == .financialFirmAccountRegistration {
                    return AccountManagementOptionsViaStartUp.allCases.count
                } else {
                    return AccountManagementOptions.allCases.count
                }
            }
        } else if tableView == savedShareTableView {
            return sharePosts.count
        } else if tableView == savedStreamTableView {
            return streamPosts.count
        } else if tableView == savedVaultTableView {
            return vaults.count
        } else {
            return calendarEvents.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == remindersTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReminderCell.identifier, for: indexPath) as! ReminderCell
            cell.calendarEvent = calendarEvents[indexPath.row]
            cell.mediaBtn.tag = indexPath.row
            cell.mediaBtn.addTarget(self, action: #selector(tapMediaBtn(_ :)), for: .touchUpInside)
            return cell
            
        } else if tableView == savedShareTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: SavedFeedCell.identifier, for: indexPath) as! SavedFeedCell
            cell.savedOption = .share
            cell.postDetails = sharePosts[indexPath.row]
            
            cell.savesBtn.tag = indexPath.row
            cell.savesBtn.addTarget(self, action: #selector(saveUnsavePost(_ :)), for: .touchUpInside)
            
            cell.boomsBtn.tag = indexPath.row
            cell.boomsBtn.addTarget(self, action: #selector(likeDislikePost(_ :)), for: .touchUpInside)
            
            cell.reshareBtn.tag = indexPath.row
            cell.reshareBtn.addTarget(self, action: #selector(resharePost(_ :)), for: .touchUpInside)
            
            cell.tappedReport = { [weak self] action, postDetails in
                let storyboard = AppStoryboards.menus.storyboardInstance
                guard let destVC = storyboard.instantiateViewController(withIdentifier: "ReportUserVC") as? ReportUserVC
                else { return }
                destVC.selectedSavedOption = self?.selectedSavedOption
                destVC.id = postDetails._id ?? ""
                destVC.delegateExchange = self
                SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
            }
            
            cell.tappedDelete = { [weak self] action, postDetails in
                if let self = self {
                    self.viewModel.deletePost(id: postDetails._id ?? "", event: self.selectedSavedOption)
                }
            }
            
            return cell
            
        } else if tableView == savedStreamTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: SavedFeedCell.identifier, for: indexPath) as! SavedFeedCell
            cell.savedOption = .stream
            cell.postDetails = streamPosts[indexPath.row]
            
            cell.tappedShare = { action, postDetails in
                let movieTitle = postDetails.title ?? ""
                let description = postDetails.description ?? ""
                let poster = UIImage(named: "logo")
                let link = URL(string: "https://theboom.app/recored_stream_video_\(postDetails._id ?? "")")!
                SharedMethods.shared.shareMovie(movieTitle: movieTitle,
                                                description: description,
                                                posterImage: poster,
                                                link: link)
            }
            
            return cell
            
        } else if tableView == savedVaultTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: SavedFeedCell.identifier, for: indexPath) as! SavedFeedCell
            cell.savedOption = .vault
            cell.postDetails = vaults[indexPath.row]
            
            cell.savesBtn.tag = indexPath.row
            cell.savesBtn.addTarget(self, action: #selector(saveUnsavePost(_ :)), for: .touchUpInside)
            
            cell.tappedReport = { [weak self] action, postDetails in
                let storyboard = AppStoryboards.menus.storyboardInstance
                guard let destVC = storyboard.instantiateViewController(withIdentifier: "ReportUserVC") as? ReportUserVC
                else { return }
                destVC.selectedSavedOption = self?.selectedSavedOption
                destVC.id = postDetails._id ?? ""
                destVC.delegateExchange = self
                SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
            }
            
            cell.tappedDelete = { [weak self] action, postDetails in
                if let self = self {
                    self.viewModel.deletePost(id: postDetails._id ?? "", event: self.selectedSavedOption)
                }
            }
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: EditOptionCell.identifier, for: indexPath) as! EditOptionCell
            cell.nextArrowIcon.isHidden = false
            cell.customIcon.isHidden = true
            cell.lastLoginView.isHidden = true
            cell.lastLoginLbl.text = ""
            
            if indexPath.section == 0 {
                if event == .financialAdvisorAccountRegistration {
                    cell.optionLbl.text = AccountOptionsViaFinancialAdvisors.allCases[indexPath.row].rawValue
                } else if event == .startupAccountRegistration ||
                            event == .smallBusinessAccountRegistration ||
                            event == .investorVCAccountRegistration ||
                            event == .insurance ||
                            event == .financialFirmAccountRegistration {
                    cell.optionLbl.text = AccountOptionsViaStartUp.allCases[indexPath.row].rawValue
                } else {
                    cell.optionLbl.text = AccountOptions.allCases[indexPath.row].rawValue
                }
            } else {
                var option = ""
                if event == .financialAdvisorAccountRegistration {
                    option = AccountManagementOptionsViaFinancialAdvisors.allCases[indexPath.row].rawValue
                } else if event == .startupAccountRegistration ||
                            event == .smallBusinessAccountRegistration ||
                            event == .investorVCAccountRegistration ||
                            event == .insurance ||
                            event == .financialFirmAccountRegistration {
                    option = AccountManagementOptionsViaStartUp.allCases[indexPath.row].rawValue
                } else {
                    option = AccountManagementOptions.allCases[indexPath.row].rawValue
                }
                
                cell.optionLbl.text = option
                
                if option == SharedOptions.deleteAccount.rawValue ||
                    option == SharedOptions.logout.rawValue {
                    cell.nextArrowIcon.isHidden = true
                    cell.customIcon.isHidden = false
                }
                
                if option == SharedOptions.lastLogin.rawValue {
                    cell.lastLoginView.isHidden = false
                    let lastLogin = UserDefaults.standard[.loggedUserDetails]?.lastLogin ?? ""
                    cell.lastLoginLbl.text = DateUtil.formatDateToLocal(from: lastLogin, format: "d MMM yyyy")
                }
                
                if option == SharedOptions.deleteAccount.rawValue {
                    cell.customIcon.image = UIImage(named: "deleteAccount")
                }
                
                if option == SharedOptions.logout.rawValue {
                    cell.customIcon.image = UIImage(named: "logout")
                }
            }
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedOption == .edit {
            if indexPath.section == 0 {
                if event == .financialAdvisorAccountRegistration {
                    let option = AccountOptionsViaFinancialAdvisors.allCases[indexPath.row]
                    switch option {
                    case .profileDetails:
                        let storyboard = AppStoryboards.menus.storyboardInstance
                        guard let destVC = storyboard.instantiateViewController(withIdentifier: "ProfileDetailsVC") as? ProfileDetailsVC
                        else { return }
                        destVC.event = event
                        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
                        
                    case .professionalInformation:
                        let storyboard = AppStoryboards.menus.storyboardInstance
                        guard let destVC = storyboard.instantiateViewController(withIdentifier: "FinancialInformationVC") as? FinancialInformationVC
                        else { return }
                        destVC.event = event
                        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
                        
                    case .personalPreferences:
                        let storyboard = AppStoryboards.menus.storyboardInstance
                        guard let destVC = storyboard.instantiateViewController(withIdentifier: "AdditionalInformationVC") as? AdditionalInformationVC
                        else { return }
                        destVC.event = event
                        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
                        
                    case .formUpload:
                        SharedMethods.shared.pushToWithoutData(destVC: FormUploadVC.self,
                                                               storyboard: .menus,
                                                               isAnimated: true)
                    }
                } else if event == .startupAccountRegistration ||
                            event == .smallBusinessAccountRegistration ||
                            event == .investorVCAccountRegistration ||
                            event == .insurance ||
                            event == .financialFirmAccountRegistration {
                    let option = AccountOptionsViaStartUp.allCases[indexPath.row]
                    switch option {
                    case .profileDetails:
                        let storyboard = AppStoryboards.menus.storyboardInstance
                        guard let destVC = storyboard.instantiateViewController(withIdentifier: "ProfileDetailsVC") as? ProfileDetailsVC
                        else { return }
                        destVC.event = event
                        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
                        
                    case .businessFinancialInformation:
                        let storyboard = AppStoryboards.menus.storyboardInstance
                        guard let destVC = storyboard.instantiateViewController(withIdentifier: "FinancialInformationVC") as? FinancialInformationVC
                        else { return }
                        destVC.event = event
                        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
                        
                    case .additionalInformation:
                        let storyboard = AppStoryboards.menus.storyboardInstance
                        guard let destVC = storyboard.instantiateViewController(withIdentifier: "AdditionalInformationVC") as? AdditionalInformationVC
                        else { return }
                        destVC.event = event
                        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
                        
                    case .formUpload:
                        SharedMethods.shared.pushToWithoutData(destVC: FormUploadVC.self,
                                                               storyboard: .menus,
                                                               isAnimated: true)
                    }
                } else {
                    let option = AccountOptions.allCases[indexPath.row]
                    switch option {
                    case .profileDetails:
                        let storyboard = AppStoryboards.menus.storyboardInstance
                        guard let destVC = storyboard.instantiateViewController(withIdentifier: "ProfileDetailsVC") as? ProfileDetailsVC
                        else { return }
                        destVC.event = event
                        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
                        
                    case .familyAndEducation:
                        SharedMethods.shared.pushToWithoutData(destVC: FamilyAndEducationVC.self,
                                                               storyboard: .menus,
                                                               isAnimated: true)
                        
                    case .financialInformation:
                        let storyboard = AppStoryboards.menus.storyboardInstance
                        guard let destVC = storyboard.instantiateViewController(withIdentifier: "FinancialInformationVC") as? FinancialInformationVC
                        else { return }
                        destVC.event = event
                        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
                        
                    case .investmentSummary:
                        SharedMethods.shared.pushToWithoutData(destVC: InvestmentSummaryVC.self,
                                                               storyboard: .menus,
                                                               isAnimated: true)
                        
                    case .additionalInformation:
                        let storyboard = AppStoryboards.menus.storyboardInstance
                        guard let destVC = storyboard.instantiateViewController(withIdentifier: "AdditionalInformationVC") as? AdditionalInformationVC
                        else { return }
                        destVC.event = event
                        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
                    }
                }
                
            } else {
                if event == .financialAdvisorAccountRegistration {
                    let option = AccountManagementOptionsViaFinancialAdvisors.allCases[indexPath.row]
                    switch option {
                        //                    case .advisorAgreement:
                        //                        let storyboard = AppStoryboards.menus.storyboardInstance
                        //                        guard let destVC = storyboard.instantiateViewController(withIdentifier: "MemberAgreementVC") as? MemberAgreementVC
                        //                        else { return }
                        //                        destVC.event = event
                        //                        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
                        
                    case .accountVerification:
                        //                        let storyboard = AppStoryboards.menus.storyboardInstance
                        //                        guard let destVC = storyboard.instantiateViewController(withIdentifier: "AccountVerificationVC") as? AccountVerificationVC
                        //                        else { return }
                        //                        destVC.event = event
                        //                        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
                        
                        let storyboard = AppStoryboards.main.storyboardInstance
                        guard let destVC = storyboard.instantiateViewController(withIdentifier: "AddLicenseVC") as? AddLicenseVC
                        else { return }
                        destVC.event = event
                        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
                        
                    case .deleteAccount:
                        PopupUtil.popupAlert(title: "Young",
                                             message: "delete_account_msg".localized(),
                                             actionTitles: ["Delete", "No"],
                                             actions: [ { [weak self] _, _ in
                            self?.viewModel.deleteAccount()
                        }])
                        
                    case .logout:
                        PopupUtil.popupAlert(title: "Young",
                                             message: "logout_msg".localized(),
                                             actionTitles: ["Logout", "No"],
                                             actions: [ { [weak self] _, _ in
                            self?.viewModel.logout()
                        }])
                        
                    default: break
                    }
                    
                } else if event == .startupAccountRegistration ||
                            event == .smallBusinessAccountRegistration ||
                            event == .investorVCAccountRegistration ||
                            event == .insurance ||
                            event == .financialFirmAccountRegistration {
                    let option = AccountManagementOptionsViaFinancialAdvisors.allCases[indexPath.row]
                    switch option {
                        //                    case .advisorAgreement:
                        //                        let storyboard = AppStoryboards.menus.storyboardInstance
                        //                        guard let destVC = storyboard.instantiateViewController(withIdentifier: "MemberAgreementVC") as? MemberAgreementVC
                        //                        else { return }
                        //                        destVC.event = event
                        //                        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
                        
                    case .accountVerification:
                        //                        let storyboard = AppStoryboards.menus.storyboardInstance
                        //                        guard let destVC = storyboard.instantiateViewController(withIdentifier: "AccountVerificationVC") as? AccountVerificationVC
                        //                        else { return }
                        //                        destVC.event = event
                        //                        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
                        
                        let storyboard = AppStoryboards.main.storyboardInstance
                        guard let destVC = storyboard.instantiateViewController(withIdentifier: "AddLicenseVC") as? AddLicenseVC
                        else { return }
                        destVC.event = event
                        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
                        
                    case .deleteAccount:
                        PopupUtil.popupAlert(title: "Young",
                                             message: "delete_account_msg".localized(),
                                             actionTitles: ["Delete", "No"],
                                             actions: [ { [weak self] _, _ in
                            self?.viewModel.deleteAccount()
                        }])
                        
                    case .logout:
                        PopupUtil.popupAlert(title: "Young",
                                             message: "logout_msg".localized(),
                                             actionTitles: ["Logout", "No"],
                                             actions: [ { [weak self] _, _ in
                            self?.viewModel.logout()
                        }])
                        
                    default: break
                    }
                    
                } else {
                    let option = AccountManagementOptions.allCases[indexPath.row]
                    switch option {
                        //                    case .memberAgreement:
                        //                        SharedMethods.shared.pushToWithoutData(destVC: MemberAgreementVC.self,
                        //                                                               storyboard: .menus,
                        //                                                               isAnimated: true)
                        
                    case .accountVerification:
                        //                        SharedMethods.shared.pushToWithoutData(destVC: AccountVerificationVC.self,
                        //                                                               storyboard: .menus,
                        //                                                               isAnimated: true)
                        
                        let storyboard = AppStoryboards.main.storyboardInstance
                        guard let destVC = storyboard.instantiateViewController(withIdentifier: "AddLicenseVC") as? AddLicenseVC
                        else { return }
                        destVC.event = event
                        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
                        
                    case .deleteAccount:
                        PopupUtil.popupAlert(title: "Young",
                                             message: "delete_account_msg".localized(),
                                             actionTitles: ["Delete", "No"],
                                             actions: [ { [weak self] _, _ in
                            self?.viewModel.deleteAccount()
                        }])
                        
                    case .logout:
                        PopupUtil.popupAlert(title: "Young",
                                             message: "logout_msg".localized(),
                                             actionTitles: ["Logout", "No"],
                                             actions: [ { [weak self] _, _ in
                            self?.viewModel.logout()
                        }])
                        
                    default: break
                    }
                }
            }
        }
        
        if selectedOption == .saved {
            var id = ""
            switch selectedSavedOption {
            case .share:
                let postID = sharePosts[indexPath.row]._id ?? ""
                id = postID
                
            case .stream:
                let streamID = streamPosts[indexPath.row]._id ?? ""
                id = streamID
                
            case .vault:
                let vaultID = vaults[indexPath.row]._id ?? ""
                id = vaultID
                
            default: break
            }
            
            let storyboard = AppStoryboards.menus.storyboardInstance
            guard let destVC = storyboard.instantiateViewController(withIdentifier: "VaultsRoomVC") as? VaultsRoomVC
            else { return }
            destVC.id = id
            destVC.selectedSavedOption = selectedSavedOption
            destVC.delegateExchange = self
            SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
        }
    }
    
    @objc fileprivate func tapMediaBtn(_ sender: UIButton) {
        let details = calendarEvents[sender.tag]
        if let file = details.file {
            
        }
    }
    
    @objc func saveUnsavePost(_ sender: UIButton) {
        var id = ""
        switch selectedSavedOption {
        case .share:
            id = sharePosts[sender.tag]._id ?? ""
            
        case .stream:
            id = streamPosts[sender.tag]._id ?? ""
            
        case .vault:
            id = vaults[sender.tag]._id ?? ""
            
        default: break
        }
        
        viewModel.saveUnsaveVault(postID: id, event: selectedSavedOption)
    }
    
    @objc func likeDislikePost(_ sender: UIButton) {
        var id = ""
        switch selectedSavedOption {
        case .share:
            id = sharePosts[sender.tag]._id ?? ""
            
        case .stream:
            id = streamPosts[sender.tag]._id ?? ""
            
        case .vault:
            id = vaults[sender.tag]._id ?? ""
            
        default: break
        }
        
        viewModel.likeDislikePost(postID: id, event: selectedSavedOption)
    }
    
    @objc func resharePost(_ sender: UIButton) {
        viewModel.reshare(id: sharePosts[sender.tag]._id ?? "")
    }
}

// MARK: - FSCalendar DataSource, Delegate & DelegateAppearance -
extension ProfileVC: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return monthPosition == .current
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "CustomCalendarCell", for: date, at: position) as! CustomCalendarCell
        let day = Calendar.current.component(.day, from: date)
        cell.dateLabel.text = "\(day)"
        
        // 🎨 Text color based on current month
        cell.dateLabel.textColor = (position == .current) ? UIColor(named: "#71727A") : .lightGray
        
        // 🎯 Reset to default hidden state
        cell.myView.isHidden = true
        cell.underlineView.isHidden = true
        cell.myView.backgroundColor = .clear
        
        var isEventDate = false
        var eventDetails: Event?
        
        if let event = calendarEvents.first(where: {
            Calendar.current.isDate($0.eventScheduledDate ?? Date(), inSameDayAs: date)}) {
            isEventDate = true
            eventDetails = event
        }
        
        var isSelected = false
        if let selectedDate {
            isSelected = Calendar.current.isDate(selectedDate, inSameDayAs: date)
        }
        
        // 📌 Show myView if event or selected
        if (isEventDate && position == .current) || isSelected {
            cell.myView.isHidden = false
        }
        
        // 📌 Show underline for event
        if isEventDate && position == .current {
            cell.underlineView.isHidden = false
            cell.myView.backgroundColor = UIColor(named: "#F5F5F5")
            
            if let eventDetails, let type = eventDetails.type {
                let color = CalendarEventTypes(rawValue: type)?.typeColor
                cell.underlineView.backgroundColor = color
            }
        }
        
        // 📌 Override background if selected
        if isSelected && position == .current {
            cell.myView.backgroundColor = UIColor(named: "#7030A0")
            cell.dateLabel.textColor = .white
        }
        
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        calendar.reloadData()
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        updateHeaderLabels()
    }
    
    private func moveCurrentPage(by value: Int, unit: Calendar.Component) {
        let current = customFSCalendar.currentPage
        guard
            let newPage = Calendar.current.date(byAdding: unit, value: value, to: current)
        else { return }
        customFSCalendar.setCurrentPage(newPage, animated: true)
        updateHeaderLabels() // 🎯 Update labels too
    }
    
    private func updateHeaderLabels() {
        let currentDate = customFSCalendar.currentPage
        let components = Calendar.current.dateComponents([.year, .month], from: currentDate)
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US") // or your preferred locale
        formatter.dateFormat = "MMMM" // Full month name
        
        if let year = components.year, let month = components.month {
            currentYearLbl.text = "\(year)"
            
            // Create a date to extract month name
            var monthDateComponents = DateComponents()
            monthDateComponents.year = year
            monthDateComponents.month = month
            if let monthDate = Calendar.current.date(from: monthDateComponents) {
                currentMonthLbl.text = formatter.string(from: monthDate)
            }
        }
    }
}

extension ProfileVC: UIScrollViewDelegate {
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
        } else {
            
            if selectedOption == .calendar &&  interfaceTitleLbl.text == "Calendar" {
                guard !viewModel.isCalendarEventsListLoading, !viewModel.isCalendarEventsListLastPage else { return }
                let offsetY = scrollView.contentOffset.y
                let contentHeight = scrollView.contentSize.height
                let frameHeight = scrollView.frame.size.height
                if offsetY > contentHeight - frameHeight - 100 { // 100 = buffer
                    viewModel.isCalendarEventsListLoading = true
                    eventPageNo += 1
                    getEvents()
                }
            }
            
            if selectedOption == .saved {
                
                switch selectedSavedOption {
                case .share:
                    guard !viewModel.isSharePostsListLoading, !viewModel.isSharePostsListLastPage else { return }
                    
                case .stream:
                    guard !viewModel.isStreamPostsListLoading, !viewModel.isStreamPostsListLastPage else { return }
                    
                case .vault:
                    guard !viewModel.isVaultsListLoading, !viewModel.isVaultsListLastPage else { return }
                    
                default: break
                }
                
                let offsetY = scrollView.contentOffset.y
                let contentHeight = scrollView.contentSize.height
                let frameHeight = scrollView.frame.size.height
                if offsetY > contentHeight - frameHeight - 100 { // 100 = buffer
                    switch selectedSavedOption {
                    case .share:
                        sharesPageNo += 1
                        viewModel.isSharePostsListLoading = true
                        
                    case .stream:
                        streamsPageNo += 1
                        viewModel.isStreamPostsListLoading = true
                        
                    case .vault:
                        vaultsPageNo += 1
                        viewModel.isVaultsListLoading = true
                        
                    default: break
                    }
                    
                    getPosts()
                }
            }
        }
    }
}

extension ProfileVC: Exchange {
    func reloadContent(for event: SavedOptions) {
        getPosts()
    }
    
    func updateRating(for event: SavedOptions, id: String, rating: Double) {
        viewModel.updatePostKeyStatus(key: .rating, event: event, postID: id, rating: rating)
    }
    
    func updateCommentCount(for event: SavedOptions, id: String) {
        viewModel.updatePostKeyStatus(key: .commentCount, event: event, postID: id)
    }
    
    func updateReportStatus(for event: SavedOptions, id: String) {
        viewModel.updatePostKeyStatus(key: .reportedPost, event: event, postID: id)
    }
}
