import UIKit
import SideMenu
import SwiftSoup

class HomeVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var bottomTabsView: UIView!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.registerCellFromNib(cellID: StockStatusCell.identifier)
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerCellFromNib(cellID: FeedSectionCell.identifier)
        }
    }
    
    // MARK: Variables
    var displayLink: CADisplayLink?
    let scrollSpeed: CGFloat = 0.5
    let footerView = VCFooterView()
    fileprivate var trendingTopics = [Topic]()
    fileprivate var users = [UserDetails]()
    fileprivate var ads = [UserDetails]()
    fileprivate var groupedUsers = [String : [UserDetails]]()
    fileprivate var viewModel = SharedVM()
    fileprivate var fiveNews = "https://feeds.content.dowjones.io/public/rss/mw_topstories"
    fileprivate var topFiveNews: [UserDetails] = []
    fileprivate var indexQuotes: [IndexQuote] = []
    
    //let symbols = ["AAPL"]
    let symbols = ["AAPL", "SPY", "QQQ", "DIA", "IWM"]
    //let symbols = ["^GSPC", "^DJI", "^NDX", "^RUT"]
    //let symbols = ["GSPC", "DJI", "NDX", "RUT"]
    
    var stocks = [StockInfo]()
    var loopedStocks: [StockInfo] = []
    fileprivate var pageNo = 1
    fileprivate var limit = 4
    var timer: Timer?
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        footerViewSetup()
        bindViewModel()
        viewModel.getTrendingTopics()
        //viewModel.getLatestUsers()
        fetchTopFiveNews()
        getAds()
    }
    
    fileprivate func fetchTopFiveNews() {
        
        if let feedURL = URL(string: fiveNews) {
            let parser = RSSParser()
            parser.parseFeed(url: feedURL) { [weak self] items in
                let firstFive = Array(items.prefix(5))
                let thumbnailFetcher = RSSThumbnailFetcher()
                thumbnailFetcher.fetchThumbnails(for: firstFive) { updatedItems in
                    DispatchQueue.main.async {
                        for item in updatedItems {
                            let details = UserDetails(username: item.title, profileImage: item.imageURL, newsLink: item.link)
                            self?.topFiveNews.append(details)
                        }
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let params = [
            "latitude": CurrentLocation.latitude,
            "longitude": CurrentLocation.longitude
        ]
        viewModel.updateUser(params: params)
        
      //  timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            StockQuoteService.shared.fetchQuotes(for: self.symbols) { [weak self] quotes in
                for (symbol, quote) in quotes {
                    LogHandler.debugLog("✅ \(symbol): Current = \(quote.c ?? 0), Change = \(quote.d ?? 0)")
                    var details: StockInfo?
                    let totalChange = quote.d ?? 0
                    if totalChange < 0 {
                        details = StockInfo(symbol: symbol, value: "\(quote.c ?? 0)", isdown: true)
                    } else {
                        details = StockInfo(symbol: symbol, value: "\(quote.c ?? 0)", isdown: false)
                    }
                    
                    if let details {
                        self?.stocks.append(details)
                    }
                }
                
                if let stocks = self?.stocks {
                    self?.loopedStocks = stocks + stocks + stocks
                }
                
                let middleIndex = self?.stocks.count ?? 0
                let indexPath = IndexPath(item: middleIndex, section: 0)
                self?.collectionView.delegate = self
                self?.collectionView.dataSource = self
                self?.collectionView.reloadData()
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2.0, execute: {
                    if self?.collectionView.numberOfSections ?? 0 > indexPath.section,
                       self?.collectionView.numberOfItems(inSection: indexPath.section) ?? 0 > indexPath.item {
                        self?.collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
                        self?.startAutoScroll()
                    } else {
                        LogHandler.debugLog("⚠️ scrollToItem: IndexPath \(indexPath) is out of bounds.")
                    }
                })
            }
       // }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Stop timer jab view disappear ho
        timer?.invalidate()
        timer = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        displayLink?.invalidate()
    }
    
    // MARK: IB Actions
    @IBAction func menu(_ sender: UIButton) {
        let storyboard = AppStoryboards.menus.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "SideMenuNavigationController") as? SideMenuNavigationController
        else { return }
        destVC.settings = SharedMethods.shared.sideMenuSettings()
        SharedMethods.shared.presentVC(destVC: destVC)
    }
    
    @IBAction func tapProfile(_ sender: UIButton) {
        guard let rootViewController = getWindowRootViewController() else { return }
        guard let topController = getTopViewController(from: rootViewController) else { return }
        if topController.isKind(of: ProfileVC.self) {
            return
        }
        let storyboard = AppStoryboards.menus.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC
        else { return }
        
        let userRole = Events.registrationFor(role: UserDefaults.standard[.loggedUserDetails]?.role ?? "") ?? .unspecified
        destVC.event = userRole
        topController.navigationController?.pushViewController(destVC, animated: true)
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
            if resp.isSuccess == true { }
            
            if let error = resp.error {
                Toast.show(message: error)
            }
        }.store(in: &viewModel.cancellables)
        
        viewModel.$trendingTopics.sink { [weak self] resp in
            self?.trendingTopics = resp
            self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }.store(in: &viewModel.cancellables)
        
        viewModel.$groupedUsers.sink { [weak self] resp in
            self?.groupedUsers = resp
            for (row, type) in HomeSections.allCases.enumerated() {
                if type != .trendingTopic && type != .ads {
                    self?.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
                }
            }
        }.store(in: &viewModel.cancellables)
        
        //        viewModel.$ads.sink { [weak self] resp in
        //            if !resp.isEmpty {
        //                let scrollTo = self?.ads.count ?? 0
        //                self?.ads = resp
        //                for (row, type) in HomeSections.allCases.enumerated() {
        //                    if type == .ads {
        //                        self?.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
        //                        if let cell = self?.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? FeedSectionCell {
        //                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        //                                cell.adsCollectionView.safeScrollToItem(at: scrollTo)
        //                            }
        //                        }
        //                    }
        //                }
        //            }
        //        }.store(in: &viewModel.cancellables)
        
        
        viewModel.$ads.sink { [weak self] resp in
            guard let self = self, !resp.isEmpty else { return }
            
            let oldCount = self.ads.count
            self.ads = resp
            
            for (row, type) in HomeSections.allCases.enumerated() {
                if type == .ads {
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? FeedSectionCell {
                        // Update collection view without animation
                        UIView.performWithoutAnimation {
                            cell.ads = self.ads
                            cell.adsCollectionView.reloadData()
                            cell.adsCollectionView.layoutIfNeeded()
                        }
                        
                        // Scroll to the position where new items were added (if any)
                        if resp.count > oldCount {
                            cell.adsCollectionView.safeScrollToItem(at: oldCount)
                        }
                    } else {
                        // If cell is not visible, just reload the row without animation
                        self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
                    }
                    break
                }
            }
        }.store(in: &viewModel.cancellables)
        
    }
    
    private func getAds() {
        viewModel.getAds(params: ["page": pageNo, "limit": limit], limit: limit)
    }
    
    fileprivate func startAutoScroll() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateScroll))
        displayLink?.add(to: .main, forMode: .default)
    }
    
    fileprivate func footerViewSetup() {
        //  if let position = bottomTabsView.superview?.convert(bottomTabsView.frame.origin, to: self.view) {
        let y = UIScreen.main.bounds.height - 119
        footerView.frame.size.width = UIScreen.main.bounds.width - 48
        footerView.frame.size.height = 52.0
        footerView.center.x = 24 + (UIScreen.main.bounds.width - 48) / 2
        footerView.center.y = y - 20
        footerView.shareBtn.addTarget(self, action: #selector(tappedShare(_:)), for: .touchUpInside)
        footerView.streamBtn.addTarget(self, action: #selector(tappedStream(_:)), for: .touchUpInside)
        footerView.vaultBtn.addTarget(self, action: #selector(tappedVault(_:)), for: .touchUpInside)
        self.view.addSubview(footerView)
        // }
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
    
    @objc func updateScroll() {
        let offsetX = collectionView.contentOffset.x + scrollSpeed
        collectionView.contentOffset.x = offsetX
        
        let totalContentWidth = collectionView.contentSize.width
        let visibleWidth = collectionView.frame.width
        
        // Reset when passed middle copy's end
        let maxOffset = totalContentWidth * 2 / 3
        if offsetX >= maxOffset {
            let resetOffset = totalContentWidth / 3 - visibleWidth / 2
            collectionView.setContentOffset(CGPoint(x: resetOffset, y: 0), animated: false)
        }
    }
}

// MARK: Delegates and DataSources

extension HomeVC: UICollectionViewDataSource,
                  UICollectionViewDelegate,
                  UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loopedStocks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(frame: CGRect.zero)
        let details = loopedStocks[indexPath.item]
        label.text = "\(details.symbol) \(details.value)"
        label.sizeToFit()
        let extraComponentsOccupiedSpace = 65.0
        let width = label.frame.width + extraComponentsOccupiedSpace
        return CGSize(width: width, height: 55)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StockStatusCell.identifier, for: indexPath) as! StockStatusCell
        let details = loopedStocks[indexPath.item]
        cell.stockValueLbl.text = "\(details.symbol) \(details.value)"
        if details.isdown {
            cell.upDownIcon.image = UIImage(named: "stockDown")
        } else {
            cell.upDownIcon.image = UIImage(named: "stockUp")
        }
        return cell
    }
}

extension HomeVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        HomeSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedSectionCell.identifier, for: indexPath) as! FeedSectionCell
        let section = HomeSections.allCases[indexPath.row]
        cell.titleLbl.text = section.rawValue
        cell.viewMoreBtn.isHidden = false
        cell.topicCollectionView.isHidden = true
        cell.feedMainView.isHidden = true
        cell.adsCollectionView.isHidden = true
        cell.adsSpaciousEmptyView.isHidden = true
        cell.feedsSpaciousEmptyView.isHidden = true
        cell.bottomEmptyView.isHidden = true
        cell.viewMoreBtn.isHidden = false
        cell.viewMoreBtn.tag = indexPath.row
        cell.viewMoreBtn.addTarget(self, action: #selector(viewMore(_ :)), for: .touchUpInside)
        cell.feedCollectionView.tag = indexPath.row
        
        switch section {
        case .trendingTopic:
            cell.topicCollectionView.isHidden = false
            cell.viewMoreBtn.isHidden = true
            cell.feedsSpaciousEmptyView.isHidden = false
            cell.trendingTopics = trendingTopics
            
        case .ads:
            cell.viewMoreBtn.isHidden = true
            cell.adsCollectionView.isHidden = false
            cell.adsSpaciousEmptyView.isHidden = false
            cell.bottomEmptyView.isHidden = false
            cell.ads = ads
            cell.onCollectionViewScroll = { offsetX, contentWidth, frameWidth in
                guard !self.viewModel.isAdsListLoading, !self.viewModel.isAdsListLastPage else { return }
                if offsetX > contentWidth - frameWidth - 100 { // For horizontal scroll
                    self.viewModel.isAdsListLoading = true
                    self.pageNo += 1
                    LogHandler.debugLog("Scrolled to page: \(self.pageNo), offsetX: \(offsetX), contentWidth: \(contentWidth), frameWidth: \(frameWidth)")
                    self.getAds()
                }
            }
            
        default:
            cell.feedMainView.isHidden = false
            if section == .news {
                cell.news = topFiveNews
            } else {
                cell.users = groupedUsers[section.type] ?? []
            }
        }
        
        return cell
    }
    
    @objc func viewMore(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            SharedMethods.shared.pushToWithoutData(destVC: NewsListVC.self,storyboard: .menus, isAnimated: true)
            
        default:
            if let category = HomeSections.getSeletedCategory(by: sender.tag) {
                let storyboard = AppStoryboards.menus.storyboardInstance
                guard let destVC = storyboard.instantiateViewController(withIdentifier: "ExchangeVC") as? ExchangeVC
                else { return }
                destVC.selectedCategories = [category]
                SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
            }
        }
    }
}

class RSSThumbnailFetcher {
    func fetchThumbnail(for item: RSSItem, completion: @escaping (String?) -> Void) {
        guard let urlString = item.link, let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data,
                  let html = String(data: data, encoding: .utf8),
                  error == nil else {
                completion(nil)
                return
            }
            
            do {
                let doc = try SwiftSoup.parse(html)
                if let meta = try doc.select("meta[property=og:image]").first() {
                    let imageURL = try meta.attr("content")
                    completion(imageURL)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func fetchThumbnails(for items: [RSSItem], completion: @escaping ([RSSItem]) -> Void) {
        var updatedItems = items
        let group = DispatchGroup()
        
        for (index, item) in items.enumerated() {
            group.enter()
            fetchThumbnail(for: item) { imageURL in
                updatedItems[index].imageURL = imageURL
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(updatedItems)
        }
    }
}
