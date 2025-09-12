import UIKit
import FSCalendar
import SideMenu

class EcosystemVC: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var bottomTabsView: UIView!
    @IBOutlet weak var filterOptionsBtn: UIButton!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var adsCollectionView: UICollectionView! {
        didSet {
            adsCollectionView.registerCellFromNib(cellID: AdsCell.identifier)
        }
    }
    
    @IBOutlet weak var categoriesCollectionView: UICollectionView! {
        didSet {
            categoriesCollectionView.registerCellFromNib(cellID: CategoryCell.identifier)
        }
    }
    
    @IBOutlet weak var savedShareTableView: UITableView! {
        didSet{
            savedShareTableView.registerCellFromNib(cellID: UsernameCell.identifier)
        }
    }
    
    // MARK: Variables
    fileprivate let footerView = VCFooterView()
    fileprivate var viewModel = SharedVM()
    fileprivate var users = [UserDetails]()
    fileprivate var pageNo = 1
    fileprivate var limit = 20
    var selectedCategories = [Categories.members]
    
    fileprivate var selectedFilterOption: String = ""
    
    fileprivate var distance = false
    fileprivate var byCustomers = false
    fileprivate var byFollowers = false
    fileprivate var rating = 0
    
    private var debounceTimer: Timer?
    
    fileprivate var ads = [UserDetails]()
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        footerViewSetup()
        
        bindViewModel()
        updateFilterMenu()
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
            getUsers(search: searchTF.text ?? "", isResetPageNo: true)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUsers()
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
    
    @IBAction func exchange(_ sender: UIButton) {
        SharedMethods.shared.pushToWithoutData(destVC: ExchangeVC.self, storyboard: .menus, isAnimated: true)
    }
    
    @IBAction func ecosystem(_ sender: UIButton) {
        SharedMethods.shared.pushToWithoutData(destVC: EcosystemVC.self, storyboard: .menus, isAnimated: true)
    }
    
    // MARK: Shared Methods
    fileprivate func updateFilterMenu() {
        
        // Distance action
        let distanceAction = UIAction(
            title: "Distance",
            state: (selectedFilterOption == "Distance") ? .on : .off
        ) { [weak self] _ in
            self?.selectedFilterOption = "Distance"
            self?.distance = true
            self?.byCustomers = false
            self?.byFollowers = false
            self?.rating = 0
            self?.updateFilterMenu()
            self?.getUsers(isResetPageNo: true)
        }
        
        let customersAction = UIAction(
            title: "Number of Customers",
            state: (selectedFilterOption == "Number of Customers") ? .on : .off
        ) { [weak self] _ in
            self?.selectedFilterOption = "Number of Customers"
            self?.distance = false
            self?.byCustomers = true
            self?.byFollowers = false
            self?.rating = 0
            self?.updateFilterMenu()
            self?.getUsers(isResetPageNo: true)
        }
        
        let followersAction = UIAction(
            title: "Number of Followers",
            state: (selectedFilterOption == "Number of Followers") ? .on : .off
        ) { [weak self] _ in
            self?.selectedFilterOption = "Number of Followers"
            self?.distance = false
            self?.byCustomers = false
            self?.byFollowers = true
            self?.rating = 0
            self?.updateFilterMenu()
            self?.getUsers(isResetPageNo: true)
        }
        
        // Rating sub-options (1 to 5 Stars)
        let ratingOptions = (1...5).map { star in
            let title = "\(star) Star\(star > 1 ? "s" : "")"
            return UIAction(
                title: title,
                state: (selectedFilterOption == title) ? .on : .off
            ) { [weak self] _ in
                self?.selectedFilterOption = title
                self?.distance = false
                self?.byCustomers = false
                self?.byFollowers = true
                self?.rating = star
                self?.updateFilterMenu()
                self?.getUsers(isResetPageNo: true)
            }
        }
        
        // Rating submenu
        let ratingMenu = UIMenu(title: "Rating", options: .displayInline, children: ratingOptions)
        
        // Build the final menu
        let menu = UIMenu(title: "", children: [
            distanceAction,
            customersAction,
            followersAction,
            ratingMenu
        ])
        
        filterOptionsBtn.menu = menu
        filterOptionsBtn.showsMenuAsPrimaryAction = true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Invalidate previous timer
        debounceTimer?.invalidate()
        
        // Start new timer with 0.5s delay
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            guard let query = textField.text, !query.isEmpty
            else {
                self?.getUsers(isResetPageNo: true)
                return
            }
            self?.triggerSearchAPI(query: query)
        }
    }
    
    func triggerSearchAPI(query: String) {
        LogHandler.debugLog("🚀 Triggering API for query: \(query)")
        // Your API logic here
        getUsers(search: query, isResetPageNo: true)
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
    
    private func getUsers(search: String = "", isResetPageNo: Bool = false) {
        let categories = selectedCategories.map({$0.type}).joined(separator: ",")
        var params = [String: Any]()
        params["category"] = categories
        
        if !search.isEmpty {
            params["search"] = search
        }
        
        if distance {
            params["distance"] = distance
        }
        
        if byCustomers {
            params["byCustomers"] = byCustomers
        }
        
        if byFollowers {
            params["byFollowers"] = byFollowers
        }
        
        if rating > 0 {
            params["rating"] = rating
        }
        
        if isResetPageNo {
            pageNo = 1
        }
        
        params["page"] = pageNo
        params["limit"] = limit
        
        viewModel.getUsers(params: params, limit: limit)
    }
    
    private func bindViewModel() {
        viewModel.$requestResponse.sink { [weak self] resp in
            if resp.isSuccess == true {
                self?.users = self?.viewModel.usersList ?? []
                self?.savedShareTableView.reloadData()
            }
            
            if let error = resp.error {
                Toast.show(message: error)
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

extension EcosystemVC: UICollectionViewDataSource,
                       UICollectionViewDelegate,
                       UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == adsCollectionView {
            return ads.count
        } else {
            return Categories.allCases.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == adsCollectionView {
            return CGSize(width: 320, height: 204.0)
            
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
        if collectionView == adsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdsCell.identifier, for: indexPath) as! AdsCell
            SharedMethods.shared.setImage(imageView: cell.adsImage, url: ads[indexPath.item].file ?? "")
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
        if collectionView == categoriesCollectionView {
            selectedCategories = [Categories.allCases[indexPath.item]]
            categoriesCollectionView.reloadData()
            getUsers(search: searchTF.text ?? "", isResetPageNo: true)
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
                self.pageNo += 1
                self.getAds()
            }
        }
    }
}

extension EcosystemVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UsernameCell.identifier, for: indexPath) as! UsernameCell
        let details = users[indexPath.row]
        cell.roleLbl.isHidden = false
        cell.interestServiceLbl.isHidden = false
        cell.userDetails = details
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let storyboard = AppStoryboards.menus.storyboardInstance
        //        guard let destVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC
        //        else { return }
        //       destVC.isAnotherUserID = users[indexPath.item]._id
        //        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
        
        guard let rootViewController = getWindowRootViewController() else { return }
        guard let topController = getTopViewController(from: rootViewController) else { return }
        if topController.isKind(of: ProfileVC.self) { return }
        let storyboard = AppStoryboards.menus.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC
        else { return }
        destVC.isAnotherUserID = users[indexPath.item]._id
        topController.navigationController?.pushViewController(destVC, animated: true)
    }
}
