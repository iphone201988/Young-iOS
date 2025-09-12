import UIKit
import SideMenu

class NewsVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var sourceLbl: UILabel!
    @IBOutlet weak var sourceLinkLbl: UILabel!
    @IBOutlet weak var newsTableView: UITableView! {
        didSet{
            newsTableView.registerCellFromNib(cellID: NewsCell.identifier)
        }
    }
    
    @IBOutlet weak var adsCollectionView: UICollectionView! {
        didSet {
            adsCollectionView.registerCellFromNib(cellID: AdsCell.identifier)
        }
    }
    
    // MARK: Variables
    let footerView = VCFooterView()
    var section: RSSSection?
    var newsXML: RSSFeed?
    fileprivate var items: [RSSItem] = []
    
    fileprivate var pageNo = 1
    fileprivate var limit = 4
    fileprivate var ads = [UserDetails]()
    private var viewModel = SharedVM()
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        footerViewSetup()
        sourceLbl.text = "Source: \(section?.title ?? "")"
        //sourceLinkLbl.text = section?.url ?? ""
        
        if
            let newsXML,
            let feedURL = URL(string: newsXML.url ?? "") {
            let parser = RSSParser()
            parser.parseFeed(url: feedURL) { [weak self] items in
                DispatchQueue.main.async {
                    self?.items = items
                    self?.newsTableView.reloadData()
                }
            }
        }
        
        getAds()
        bindViewModel()
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
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func sourcePreview(_ sender: UIButton) {
        let storyboard = AppStoryboards.menus.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "NewsPreviewVC") as? NewsPreviewVC
        else { return }
        destVC.source = section?.url ?? ""
        SharedMethods.shared.pushTo(destVC: destVC)
    }
    
    // MARK: Shared Methods
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
    
    private func getAds() {
        viewModel.getAds(params: ["page": pageNo, "limit": limit], limit: limit)
    }
    
    private func bindViewModel() {
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
}

// MARK: Delegates and DataSources

extension NewsVC: UICollectionViewDataSource,
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

extension NewsVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.identifier, for: indexPath) as! NewsCell
        cell.newsDetails = items[indexPath.row]
        cell.onLinkTapped = { link in
            let storyboard = AppStoryboards.menus.storyboardInstance
            guard let destVC = storyboard.instantiateViewController(withIdentifier: "NewsPreviewVC") as? NewsPreviewVC
            else { return }
            destVC.source = link
            SharedMethods.shared.pushTo(destVC: destVC)
        }
        return cell
    }
}
