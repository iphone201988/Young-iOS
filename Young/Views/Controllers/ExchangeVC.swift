import UIKit
import FSCalendar
import SideMenu

class ExchangeVC: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var interfaceTitleLbl: UILabel!
    @IBOutlet weak var bottomTabsView: UIView!
    @IBOutlet weak var filterOptionsBtn: UIButton!
    @IBOutlet weak var sortBtn: UIButton!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var adsCollectionView: UICollectionView! {
        didSet {
            adsCollectionView.registerCellFromNib(cellID: AdsCell.identifier)
        }
    }
    
    @IBOutlet weak var adsCollectionView2: UICollectionView! {
        didSet {
            adsCollectionView2.registerCellFromNib(cellID: AdsCell.identifier)
        }
    }
    
    @IBOutlet weak var adsCollectionView3: UICollectionView! {
        didSet {
            adsCollectionView3.registerCellFromNib(cellID: AdsCell.identifier)
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
    fileprivate let footerView = VCFooterView()
    fileprivate var selectedSavedOption: SavedOptions = .share
    var selectedCategories: [Categories] = [.members]
    fileprivate var viewModel = SharedVM()
    fileprivate var sharesPageNo = 1
    fileprivate var streamsPageNo = 1
    fileprivate var vaultsPageNo = 1
    fileprivate var limit = 20
    fileprivate var users = [UserDetails]()
    fileprivate var pageNo = 1
    fileprivate var sharePosts = [PostDetails]()
    fileprivate var streamPosts = [PostDetails]()
    fileprivate var vaults = [PostDetails]()
    
    fileprivate var selectedFilterOption: String = "Date Posted"
    fileprivate var selectedSortOption: String = ""
    
    fileprivate var distance = false
    fileprivate var rating = 0
    fileprivate var byFollowers = false
    fileprivate var bySave = false
    fileprivate var byBoom = false
    
    private var debounceTimer: Timer?
    fileprivate var ads = [UserDetails]()
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadContent(_ :)),
                                               name: .reloadContent,
                                               object: nil)
        footerViewSetup()
        hideAllSavedOptionsTableView()
        savedShareTableView.isHidden = false
        interfaceTitleLbl.text = selectedSavedOption.rawValue
        getPosts()
        bindViewModel()
        updateFilterMenu()
        updateSortMenu()
        
        searchTF.delegate = self
        searchTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        getAds()
        
        scrollToSelectedCategory()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changeCategoriesSelection(_ :)),
                                               name: .changeCategoriesSelection,
                                               object: nil)
    }
    
    @objc fileprivate func changeCategoriesSelection(_ notify: Notification) {
        if let categories = notify.object as? [Categories] {
            selectedCategories = categories
            getPosts(isResetPageNo: true, search: searchTF.text ?? "")
            scrollToSelectedCategory()
        }
    }
    
    fileprivate func scrollToSelectedCategory() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for (index, category) in Categories.allCases.enumerated() {
                if category == self.selectedCategories.first {
                    self.categoriesCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
                }
            }
        }
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
    
    @IBAction func sort(_ sender: UIButton) { }
    
    @IBAction func filterOptions(_ sender: UIButton) { }
    
    @IBAction func exchange(_ sender: UIButton) {
        SharedMethods.shared.pushToWithoutData(destVC: ExchangeVC.self, storyboard: .menus, isAnimated: true)
    }
    
    @IBAction func ecosystem(_ sender: UIButton) {
        SharedMethods.shared.pushToWithoutData(destVC: EcosystemVC.self, storyboard: .menus, isAnimated: true)
    }
    
    // MARK: Shared Methods
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Invalidate previous timer
        debounceTimer?.invalidate()
        
        // Start new timer with 0.5s delay
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            guard let query = textField.text, !query.isEmpty
            else {
                self?.getPosts(isResetPageNo: true)
                return
            }
            self?.triggerSearchAPI(query: query)
        }
    }
    
    func triggerSearchAPI(query: String) {
        LogHandler.debugLog("🚀 Triggering API for query: \(query)")
        // Your API logic here
        getPosts(isResetPageNo: true, search: query)
    }
    
    private func bindViewModel() {
        viewModel.$requestResponse.sink { [weak self] resp in
            if resp.isSuccess == true {
                
                if resp.request == .saveUnsaveVault || resp.request == .likeDislikePost { return }
                
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
            }
            
            if let error = resp.error {
                Toast.show(message: error)
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
                
                self.adsCollectionView2.reloadData()
                self.adsCollectionView2.layoutIfNeeded()
                
                self.adsCollectionView3.reloadData()
                self.adsCollectionView3.layoutIfNeeded()
            }
            
            // Scroll to the position where new items were added (if any)
            if resp.count > oldCount {
                self.adsCollectionView.safeScrollToItem(at: oldCount)
                self.adsCollectionView2.safeScrollToItem(at: oldCount)
                self.adsCollectionView3.safeScrollToItem(at: oldCount)
            }
        }.store(in: &viewModel.cancellables)
    }
    
    private func getAds() {
        viewModel.getAds(params: ["page": pageNo, "limit": limit], limit: limit)
    }
    
    private func getPosts(isResetPageNo: Bool = false, search: String = "") {
        let categories = selectedCategories.map({$0.type}).joined(separator: ",")
        var pageNo = 1
        
        if isResetPageNo {
            sharesPageNo = 1
            streamsPageNo = 1
            vaultsPageNo = 1
            
            viewModel.isSharePostsListLastPage = false
            viewModel.isStreamPostsListLastPage = false
            viewModel.isVaultsListLastPage = false
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
        
        //var params = ["userType": categories, "page": pageNo, "limit": limit] as [String : Any]
        var params = ["userType": categories, "page": pageNo] as [String : Any]
        
        if selectedSavedOption != .vault {
            params["type"] = selectedSavedOption.type
            if byBoom {
                params["byBoom"] = byBoom
            }
        }
        
        if distance {
            params["distance"] = distance
        }
        
        if rating > 0 { params["rating"] = rating }
        
        if byFollowers {
            params["byFollowers"] = byFollowers
        }
        
        if bySave {
            params["bySave"] = bySave
        }
        
        if !search.isEmpty {
            params["search"] = search
        }
        
        viewModel.getPosts(params: params, limit: limit, event: selectedSavedOption)
    }
    
    fileprivate func footerViewSetup() {
        let y = UIScreen.main.bounds.height - 119
        footerView.frame.size.width = UIScreen.main.bounds.width - 48
        footerView.frame.size.height = 52.0
        footerView.center.x = 24 + (UIScreen.main.bounds.width - 48) / 2
        footerView.center.y = y - 20
        footerView.emptyView.isHidden = false
        
        footerView.optionsView.alpha = 0.0
        footerView.optionsView.isUserInteractionEnabled = false
        
        //        footerView.shareView.isHidden = true
        //        footerView.streamView.isHidden = true
        //        footerView.vaultView.isHidden = true
        
        footerView.newAddOnView.isHidden = false
        footerView.calendarView.isHidden = true
        footerView.shareBtn.addTarget(self, action: #selector(tappedShare(_:)), for: .touchUpInside)
        footerView.streamBtn.addTarget(self, action: #selector(tappedStream(_:)), for: .touchUpInside)
        footerView.vaultBtn.addTarget(self, action: #selector(tappedVault(_:)), for: .touchUpInside)
        footerView.newAddOnBtn.addTarget(self, action: #selector(tappedNewAddOn(_:)), for: .touchUpInside)
        self.view.addSubview(footerView)
    }
    
    fileprivate func hideAllSavedOptionsTableView() {
        savedShareTableView.isHidden = true
        savedStreamTableView.isHidden = true
        savedVaultTableView.isHidden = true
    }
    
    fileprivate func updateFilterMenu() {
        
        // Date Posted action
        let datePostedAction = UIAction(
            title: "Date Posted",
            state: (selectedFilterOption == "Date Posted") ? .on : .off
        ) { [weak self] _ in
            if self?.selectedFilterOption == "Date Posted" {
                self?.selectedFilterOption = ""
            } else {
                self?.selectedFilterOption = "Date Posted"
            }
            
            self?.distance = false
            self?.rating = 0
            self?.updateFilterMenu()
            self?.getPosts(isResetPageNo: true)
        }
        
        // Distance action
        let distanceAction = UIAction(
            title: "Distance",
            state: (selectedFilterOption == "Distance") ? .on : .off
        ) { [weak self] _ in
            if self?.selectedFilterOption == "Distance" {
                self?.selectedFilterOption = ""
            } else {
                self?.selectedFilterOption = "Distance"
            }
            
            self?.distance = true
            self?.rating = 0
            self?.updateFilterMenu()
            self?.getPosts(isResetPageNo: true)
        }
        
        // Rating sub-options (1 to 5 Stars)
        let ratingOptions = (1...5).map { star in
            let title = "\(star) Star\(star > 1 ? "s" : "")"
            return UIAction(
                title: title,
                state: (selectedFilterOption == title) ? .on : .off
            ) { [weak self] _ in
                if self?.selectedFilterOption == title {
                    self?.selectedFilterOption = ""
                    self?.rating = 0
                } else {
                    self?.selectedFilterOption = title
                    self?.rating = star
                }
                
                //self?.rating = star
                self?.updateFilterMenu()
                self?.getPosts(isResetPageNo: true)
            }
        }
        
        // Rating submenu
        let ratingMenu = UIMenu(title: "Rating", options: .displayInline, children: ratingOptions)
        
        // Build the final menu
        let menu = UIMenu(title: "", children: [
            datePostedAction,
            distanceAction,
            ratingMenu
        ])
        
        filterOptionsBtn.menu = menu
        filterOptionsBtn.showsMenuAsPrimaryAction = true
    }
    
    fileprivate func updateSortMenu() {
        var options = [String]()
        if selectedSavedOption == .vault {
            options = ["Followed", "Saved"]
        } else {
            options = ["Followed", "Saved", "Booms"]
        }
        
        let actions = options.map { option in
            UIAction(
                title: option,
                state: (option == selectedSortOption) ? .on : .off
            ) { [weak self] _ in
                
                self?.byFollowers = false
                self?.bySave = false
                self?.byBoom = false
                
                self?.selectedSortOption = option
                if option == "Followed" {
                    self?.byFollowers = true
                } else if option == "Saved" {
                    self?.bySave = true
                } else if option == "Booms" {
                    self?.byBoom = true
                }
                self?.updateSortMenu() // Refresh menu with new selection
                self?.getPosts(isResetPageNo: true)
                // Do something with the selection here if needed
            }
        }
        
        let menu = UIMenu(title: "", children: actions)
        sortBtn.menu = menu
        sortBtn.showsMenuAsPrimaryAction = true
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
    
    @objc func tappedNewAddOn(_ button: UIButton) {
        let storyboard = AppStoryboards.menus.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "ShareVC") as? ShareVC
        else { return }
        destVC.events = selectedSavedOption
        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
    }
    
    @objc func reloadContent(_ notify: Notification) {
        getPosts(isResetPageNo: true)
    }
}

// MARK: Delegates and DataSources

extension ExchangeVC: UICollectionViewDataSource,
                      UICollectionViewDelegate,
                      UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == savedOptionsCollectionView {
            return SavedOptions.allCases.count
        } else {
            if collectionView == adsCollectionView || collectionView == adsCollectionView2 || collectionView == adsCollectionView3 {
                return ads.count
            } else {
                return Categories.allCases.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == adsCollectionView ||
            collectionView == adsCollectionView2 ||
            collectionView == adsCollectionView3 {
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
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == adsCollectionView ||
            collectionView == adsCollectionView2 ||
            collectionView == adsCollectionView3 {
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
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == savedOptionsCollectionView {
            selectedSavedOption = SavedOptions.allCases[indexPath.item]
            interfaceTitleLbl.text = selectedSavedOption.rawValue
            savedOptionsCollectionView.reloadData()
            hideAllSavedOptionsTableView()
            switch selectedSavedOption {
            case .share:
                savedShareTableView.isHidden = false
                updateSortMenu()
                
            case .stream:
                savedStreamTableView.isHidden = false
                updateSortMenu()
                
            case .vault:
                savedVaultTableView.isHidden = false
                updateSortMenu()
                
            default: break
            }
            
            getPosts(isResetPageNo: true)
            
        } else if collectionView == categoriesCollectionView {
            selectedCategories = [Categories.allCases[indexPath.item]]
            categoriesCollectionView.reloadData()
            getPosts(isResetPageNo: true)
        }
    }
}

extension ExchangeVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == savedShareTableView {
            return sharePosts.count
        } else if tableView == savedStreamTableView {
            return streamPosts.count
        } else if tableView == savedVaultTableView {
            return vaults.count
        } else {
            return 9
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == savedShareTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: SavedFeedCell.identifier, for: indexPath) as! SavedFeedCell
            cell.exchangeOption = .share
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
            
            cell.tappedFeature = { [weak self] action, postDetails in
                if let self = self {
                    showFeaturePostAlert(amount: 9.99) {
                        // Handle confirmed payment logic here
                        
                    }
                }
            }
            
            return cell
            
        } else if tableView == savedStreamTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: SavedFeedCell.identifier, for: indexPath) as! SavedFeedCell
            cell.exchangeOption = .stream
            cell.postDetails = streamPosts[indexPath.row]
            
            cell.boomsBtn.tag = indexPath.row
            cell.boomsBtn.addTarget(self, action: #selector(likeDislikePost(_ :)), for: .touchUpInside)
            
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
            cell.exchangeOption = .vault
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
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        
        /*
         if selectedSavedOption == .stream {
         let storyboard = AppStoryboards.menus.storyboardInstance
         guard let destVC = storyboard.instantiateViewController(withIdentifier: "LiveStreamingVC") as? LiveStreamingVC
         else { return }
         destVC.isProducer = false
         destVC.roomName = id
         SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
         } else {
         let storyboard = AppStoryboards.menus.storyboardInstance
         guard let destVC = storyboard.instantiateViewController(withIdentifier: "VaultsRoomVC") as? VaultsRoomVC
         else { return }
         destVC.id = id
         destVC.selectedSavedOption = selectedSavedOption
         destVC.delegateExchange = self
         SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
         }
         */
        
        let storyboard = AppStoryboards.menus.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "VaultsRoomVC") as? VaultsRoomVC
        else { return }
        destVC.id = id
        destVC.selectedSavedOption = selectedSavedOption
        destVC.delegateExchange = self
        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
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
        } else {
            
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
    
    func showFeaturePostAlert(amount: Double,
                              onConfirm: @escaping () -> Void) {
        let message = """
        Your post will be featured on the Home page for 24 hours based on an algorithm.
        
        The payment amount is $\(String(format: "%.2f", amount)). Your saved payment method will be charged automatically.
        
        Do you want to proceed?
        """
        
        let alert = UIAlertController(title: "Feature Your Post", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Confirm & Pay", style: .default, handler: { _ in
            onConfirm()
        }))
        
        self.present(alert, animated: true, completion: nil)
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

extension ExchangeVC: Exchange {
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
