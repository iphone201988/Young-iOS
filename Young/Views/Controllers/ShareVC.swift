import UIKit
import SideMenu

class ShareVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var interfaceTitleLbl: UILabel!
    @IBOutlet weak var bottomTabsView: UIView!
    @IBOutlet weak var symbolView: UIView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var launchBtn: UIButton!
    @IBOutlet weak var scheduleBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var topicView: UIView!
    @IBOutlet weak var topicTF: UITextField!
    @IBOutlet weak var topicIcon: UIButton!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var descTV: UITextView!
    @IBOutlet weak var usersView: UIView!
    @IBOutlet weak var accessView: UIView!
    @IBOutlet weak var visibilityModeStatus: UISwitch!
    @IBOutlet weak var categoriesView: UIView!
    @IBOutlet weak var categoryIcon: UIButton!
    @IBOutlet weak var categoryTF: UITextField!
    @IBOutlet weak var stockSelectionIcon: UIImageView!
    @IBOutlet weak var cryptoSelectionIcon: UIImageView!
    @IBOutlet weak var scheduleDateTF: UITextField!
    @IBOutlet weak var symbolValueTF: UITextField!
    @IBOutlet weak var categoriesCollectionView: UICollectionView! {
        didSet {
            categoriesCollectionView.registerCellFromNib(cellID: SelectedInterestCell.identifier)
        }
    }
    
    @IBOutlet weak var adsCollectionView: UICollectionView! {
        didSet {
            adsCollectionView.registerCellFromNib(cellID: AdsCell.identifier)
        }
    }
    
    // MARK: Variables
    let footerView = VCFooterView()
    var events: SavedOptions = .share
    private var viewModel = SharedVM()
    private var selectedCategories = [Categories]()
    private var selectedUsersID = [String]()
    private var selectedSymbol = Symbols.stock
    private let datePicker = UIDatePicker()
    private var selectedScheduleData = Date()
    fileprivate var pageNo = 1
    fileprivate var limit = 4
    fileprivate var ads = [UserDetails]()
    fileprivate var scheduleDate = ""
    fileprivate var selectedUsers = [UserDetails]()
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //footerViewSetup()
        interfaceTitleLbl.text = events.rawValue
        switch events {
        case .share:
            symbolView.isHidden = false
            shareBtn.isHidden = false
            launchBtn.isHidden = true
            scheduleBtn.isHidden = true
            dateView.isHidden = true
            createBtn.isHidden = true
            usersView.isHidden = true
            accessView.isHidden = true
            categoriesView.isHidden = true
            stockSelectionIcon.image = UIImage(named: "selectedBox")
            cryptoSelectionIcon.image = UIImage(named: "unselectedBox")
            
        case .stream:
            symbolView.isHidden = true
            shareBtn.isHidden = true
            launchBtn.isHidden = false
            scheduleBtn.isHidden = false
            dateView.isHidden = false
            createBtn.isHidden = true
            usersView.isHidden = true
            accessView.isHidden = true
            categoriesView.isHidden = true
            // Configure hidden text field
            scheduleDateTF.inputView = datePicker
            datePicker.datePickerMode = .dateAndTime
            datePicker.preferredDatePickerStyle = .wheels // or .inline
            // Optional: Add toolbar with "Done"
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
            toolbar.setItems([done], animated: false)
            scheduleDateTF.inputAccessoryView = toolbar
            
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            let selectedDate = formatter.string(from: selectedScheduleData)
            scheduleDateTF.text = selectedDate
            
        case .vault:
            symbolView.isHidden = true
            shareBtn.isHidden = true
            launchBtn.isHidden = true
            scheduleBtn.isHidden = true
            dateView.isHidden = true
            createBtn.isHidden = false
            usersView.isHidden = false
            accessView.isHidden = false
            categoriesView.isHidden = false
            
        default: break
        }
        
        PickerManager.shared.configurePicker(for: topicTF,
                                             with: Constants.feedTopics,
                                             iconButton: topicIcon)
        
        PickerManager.shared.configurePicker(for: categoryTF,
                                             with: Categories.allCases.map(\.rawValue),
                                             iconButton: categoryIcon) { [weak self] selectedCategory in
            if let category = Categories(rawValue: selectedCategory) {
                let selectedCat = self?.selectedCategories ?? []
                if !selectedCat.contains(category) {
                    self?.selectedCategories.append(category)
                    self?.categoriesCollectionView.reloadData()
                }
            }
        }
        
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
    
    @IBAction func share(_ sender: UIButton) {
        switch viewModel.validateFields(
            title: titleTF.text,
            topic: topicTF.text,
            description: descTV.text,
            symbolValue: symbolValueTF.text,
            image: postImageView.image,
            isShare: true
        ) {
        case .success:
            let storyboard = AppStoryboards.menus.storyboardInstance
            guard let destVC = storyboard.instantiateViewController(withIdentifier: "StreamConfirmationVC") as? StreamConfirmationVC else { return }
            destVC.events = events
            destVC.params = [
                "title": titleTF.text ?? "",
                "topic": topicTF.text ?? "",
                "description": descTV.text ?? "",
                "symbol": selectedSymbol.rawValue,
                "symbolValue": symbolValueTF.text ?? ""
            ]
            destVC.shareImage = postImageView.image
            SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
            
        case .failure(let message):
            Toast.show(message: message)
        }
    }
    
    @IBAction func launch(_ sender: UIButton) {
        switch viewModel.validateFields(
            title: titleTF.text,
            topic: topicTF.text,
            description: descTV.text,
            symbolValue: nil,
            image: postImageView.image
        ) {
        case .success:
            let storyboard = AppStoryboards.menus.storyboardInstance
            guard let destVC = storyboard.instantiateViewController(withIdentifier: "StreamConfirmationVC") as? StreamConfirmationVC else { return }
            destVC.events = events
            destVC.shareImage = postImageView.image
            destVC.isLaunch = true
            destVC.params = [
                "title": titleTF.text ?? "",
                "topic": topicTF.text ?? "",
                "description": descTV.text ?? "",
                "symbol": selectedSymbol.rawValue
            ]
            SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
            
        case .failure(let message):
            Toast.show(message: message)
        }
    }
    
    @IBAction func schedule(_ sender: UIButton) {
        switch viewModel.validateFields(
            title: titleTF.text,
            topic: topicTF.text,
            description: descTV.text,
            symbolValue: nil,
            image: postImageView.image,
            isSchedule: true,
            scheduleDate: scheduleDate
        ) {
        case .success:
            let storyboard = AppStoryboards.menus.storyboardInstance
            guard let destVC = storyboard.instantiateViewController(withIdentifier: "StreamConfirmationVC") as? StreamConfirmationVC else { return }
            destVC.events = events
            destVC.shareImage = postImageView.image
            destVC.isLaunch = false
            destVC.params = [
                "title": titleTF.text ?? "",
                "topic": topicTF.text ?? "",
                "description": descTV.text ?? "",
                "symbol": selectedSymbol.rawValue,
                "scheduleDate": formattedScheduleDate()
            ]
            destVC.scheduleDate = scheduleDate
            SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
            
        case .failure(let message):
            Toast.show(message: message)
        }
    }
    
    @IBAction func browseMedia(_ sender: UIButton) {
        MediaPicker.shared.browsedImage() { [weak self] image, _ in
            self?.postImageView.image = image
        }
    }
    
    @IBAction func chooseUsers(_ sender: UIButton) {
        let storyboard = AppStoryboards.menus.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "UsersListVC") as? UsersListVC
        else { return }
        destVC.categories = selectedCategories.map({$0.type}).joined(separator: ",")
        destVC.selectedUsers = selectedUsers
        destVC.delegateSelectedUsers = self
        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
    }
    
    @IBAction func visibilityModeToggle(_ sender: UISwitch) {
        visibilityModeStatus.setOn(sender.isOn, animated: true)
    }
    
    @IBAction func create(_ sender: UIButton) {
        if events == .vault {
            if selectedCategories.count == 0  {
                Toast.show(message: "Please choose atleast one category")
            } else {
                if selectedUsersID.count == 0 {
                    Toast.show(message: "Please choose atleast one category type member")
                } else {
                    let params = [
                        "title": titleTF.text ?? "",
                        "topic": topicTF.text ?? "",
                        "description": descTV.text ?? "",
                        "access": VisibilityMode.isPublic(status: visibilityModeStatus.isOn),
                        "members": selectedUsersID.joined(separator: ","),
                        "category": selectedCategories.map{$0.type}.joined(separator: ",")]
                    as [String : Any]
                    
                    let mediaData = postImageView.image?.jpegData(compressionQuality: 0.1)
                    
                    viewModel.createPost(params: params,
                                         mediaData: mediaData,
                                         event: events)
                }
            }
            
        } else {
            let storyboard = AppStoryboards.menus.storyboardInstance
            guard let destVC = storyboard.instantiateViewController(withIdentifier: "StreamConfirmationVC") as? StreamConfirmationVC
            else { return }
            destVC.events = events
            SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
        }
    }
    
    @IBAction func tappedStock(_ sender: UIButton) {
        selectedSymbol = .stock
        stockSelectionIcon.image = UIImage(named: "selectedBox")
        cryptoSelectionIcon.image = UIImage(named: "unselectedBox")
    }
    
    @IBAction func tappedCrypto(_ sender: UIButton) {
        selectedSymbol = .crypto
        stockSelectionIcon.image = UIImage(named: "unselectedBox")
        cryptoSelectionIcon.image = UIImage(named: "selectedBox")
    }
    
    @IBAction func exchange(_ sender: UIButton) {
        SharedMethods.shared.pushToWithoutData(destVC: ExchangeVC.self, storyboard: .menus, isAnimated: true)
    }
    
    @IBAction func ecosystem(_ sender: UIButton) {
        SharedMethods.shared.pushToWithoutData(destVC: EcosystemVC.self, storyboard: .menus, isAnimated: true)
    }
    
    // MARK: Shared Methods
    private func bindViewModel() {
        viewModel.$requestResponse.sink { resp in
            
            //self.resetCreateButtonState()
            if resp.isSuccess == true {
                NotificationCenter.default.post(name: .reloadContent, object: nil)
                Toast.show(message: resp.message ?? "") {
                    self.navigationController?.popViewController(animated: true)
                }
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
    
    fileprivate func formattedScheduleDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // +00:00
        return formatter.string(from: selectedScheduleData)
    }
    
    @objc func showDatePicker() {
        scheduleDateTF.becomeFirstResponder() // shows the date picker as keyboard
    }
    
    @objc func doneTapped() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        let selectedDate = formatter.string(from: datePicker.date)
        selectedScheduleData = datePicker.date
        scheduleDateTF.text = selectedDate
        scheduleDate = selectedDate
        scheduleDateTF.resignFirstResponder()
        if datePicker.date > Date() {
            launchBtn.isHidden = true
        } else {
            launchBtn.isHidden = false
        }
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

extension ShareVC: UICollectionViewDataSource,
                   UICollectionViewDelegate,
                   UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoriesCollectionView {
            return selectedCategories.count
        } else {
            return ads.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == categoriesCollectionView {
            let label = UILabel(frame: CGRect.zero)
            label.text = Categories.allCases[indexPath.item].rawValue
            label.sizeToFit()
            let extraComponentsOccupiedSpace = 80.0
            let width = label.frame.width + extraComponentsOccupiedSpace
            return CGSize(width: width, height: 35)
        } else {
            return CGSize(width: 320, height: 204.0)
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
        if collectionView == categoriesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedInterestCell.identifier, for: indexPath) as! SelectedInterestCell
            cell.titleLbl.text = selectedCategories[indexPath.item].rawValue
            cell.removeBtn.tag = indexPath.item
            cell.removeBtn.addTarget(self, action: #selector(removeSelectedCategory( _:)), for: .touchUpInside)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdsCell.identifier, for: indexPath) as! AdsCell
            SharedMethods.shared.setImage(imageView: cell.adsImage, url: ads[indexPath.item].file ?? "")
            return cell
        }
    }
    
    @objc func removeSelectedCategory(_ sender: UIButton) {
        selectedCategories.remove(at: sender.tag)
        categoriesCollectionView.reloadData()
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

extension ShareVC: SelectedUsers {
    func users(_ users: [UserDetails]) {
        selectedUsers = users
        selectedUsersID = users.map { $0._id ?? "" }
    }
}
