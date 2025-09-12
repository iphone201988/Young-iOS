import UIKit
import SideMenu

class UsersListVC: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var bottomTabsView: UIView!
    @IBOutlet weak var outerScrollView: UIScrollView!
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
    
    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.registerCellFromNib(cellID: UsernameCell.identifier)
            tableView.estimatedRowHeight = 44 // or a close estimate
        }
    }
    
    // MARK: Variables
    fileprivate let footerView = VCFooterView()
    fileprivate var selectedCategories = [Categories]()
    fileprivate var viewModel = SharedVM()
    fileprivate var users = [UserDetails]()
    fileprivate var pageNo = 1
    fileprivate var limit = 20
    var selectedUsers = [UserDetails]()
    fileprivate var ads = [UserDetails]()
    var categories: String = ""
    var delegateSelectedUsers: SelectedUsers?
    private var debounceTimer: Timer?
    
    var dict: [String: Any]?
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //footerViewSetup()
        getUsers()
        bindViewModel()
        getAds()
        searchTF.delegate = self
        searchTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadContent(_ :)), name: .reloadContent, object: nil)
    }
    
    @objc fileprivate func reloadContent(_ notify: Notification) {
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
        delegateSelectedUsers?.users(selectedUsers)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func exchange(_ sender: UIButton) {
        SharedMethods.shared.pushToWithoutData(destVC: ExchangeVC.self, storyboard: .menus, isAnimated: true)
    }
    
    @IBAction func ecosystem(_ sender: UIButton) {
        SharedMethods.shared.pushToWithoutData(destVC: EcosystemVC.self, storyboard: .menus, isAnimated: true)
    }
    
    // MARK: Shared Methods
    private func getUsers(search: String = "", isResetPageNo: Bool = false) {
        var params = [String: Any]()
        
        if !search.isEmpty {
            params["search"] = search
        }
        
        if isResetPageNo {
            pageNo = 1
        }
        
        params["page"] = pageNo
        params["limit"] = limit
        
        if let dict {
            params["id"] = dict["id"]
            params["type"] = dict["type"]
        } else {
            params["category"] = categories
        }
        
        viewModel.getUsers(params: params, limit: limit)
    }
    
    private func getAds() {
        viewModel.getAds(params: ["page": pageNo, "limit": limit], limit: limit)
    }
    
    private func bindViewModel() {
        viewModel.$requestResponse.sink { [weak self] resp in
            if resp.isSuccess == true {
                self?.users = self?.viewModel.usersList ?? []
                self?.tableView.reloadData()
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
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Invalidate previous timer
        debounceTimer?.invalidate()
        
        // Start new timer with 0.5s delay
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.getUsers(search: textField.text ?? "", isResetPageNo: true)
        }
    }
}

// MARK: Delegates and DataSources

extension UsersListVC: UICollectionViewDataSource,
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
        }
    }
}

extension UsersListVC: UITableViewDelegate,UITableViewDataSource {
    
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
        cell.tintColor = UIColor(named: "#00B050") // Set tint color for accessory (checkmark)
        if selectedUsers.contains(details) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = dict {
            guard let rootViewController = getWindowRootViewController() else { return }
            guard let topController = getTopViewController(from: rootViewController) else { return }
            if topController.isKind(of: ProfileVC.self) {
                return
            }
            let storyboard = AppStoryboards.menus.storyboardInstance
            guard let destVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC
            else { return }
            destVC.isAnotherUserID = users[indexPath.row]._id ?? ""
            topController.navigationController?.pushViewController(destVC, animated: true)
        } else {
            let details = users[indexPath.row]
            if selectedUsers.isEmpty {
                selectedUsers.append(details)
            } else {
                if let index = selectedUsers.firstIndex(of: details) {
                    selectedUsers.remove(at: index)
                } else {
                    selectedUsers.append(details)
                }
            }
            self.tableView.reloadRows(at: [indexPath], with: .none)
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
        } else {
            guard !viewModel.isUsersListLoading, !viewModel.isUsersListLastPage else { return }
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let frameHeight = scrollView.frame.size.height
            if offsetY > contentHeight - frameHeight - 100 { // 100 = buffer
                viewModel.isUsersListLoading = true
                pageNo += 1
                getUsers()
            }
        }
    }
}
