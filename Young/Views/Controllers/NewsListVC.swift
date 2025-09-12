import UIKit
import SideMenu

class NewsListVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var newsTableView: UITableView! {
        didSet{
            newsTableView.registerCellFromNib(cellID: EditOptionCell.identifier)
        }
    }
    
    @IBOutlet weak var adsCollectionView: UICollectionView! {
        didSet {
            adsCollectionView.registerCellFromNib(cellID: AdsCell.identifier)
        }
    }
    
    // MARK: Variables
    let footerView = VCFooterView()
    fileprivate var pageNo = 1
    fileprivate var limit = 4
    fileprivate var ads = [UserDetails]()
    private var viewModel = SharedVM()
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        footerViewSetup()
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
        self.navigationController?.popViewController(animated: true)
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
    
    private func getAds() {
        viewModel.getAds(params: ["page": pageNo, "limit": limit], limit: limit)
    }
}

// MARK: Delegates and DataSources

extension NewsListVC: UICollectionViewDataSource,
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

extension NewsListVC: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return rssSections.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        54
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EditOptionCell.identifier) as? EditOptionCell
        else { return nil }
        // Configure cell UI
        cell.nextArrowIcon.isHidden = true
        cell.customIcon.isHidden = true
        cell.lastLoginView.isHidden = true
        cell.optionLbl.text = rssSections[section].title
        cell.mainViewLeading.constant = 24.0
        cell.mainViewTrailing.constant = 24.0
        cell.optionBtn.isHidden = false
        cell.optionBtn.tag = section
        cell.optionBtn.addTarget(self, action: #selector(tappedSection(_ :)), for: .touchUpInside)
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rssSections[section].feeds?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditOptionCell.identifier, for: indexPath) as! EditOptionCell
        let feed = rssSections[indexPath.section].feeds?[indexPath.row]
        cell.nextArrowIcon.isHidden = false
        cell.customIcon.isHidden = true
        cell.lastLoginView.isHidden = true
        cell.optionLbl.text = feed?.title
        cell.mainViewLeading.constant = 36.0
        cell.mainViewTrailing.constant = 24.0
        cell.optionBtn.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = AppStoryboards.menus.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "NewsVC") as? NewsVC
        else { return }
        destVC.section = rssSections[indexPath.section]
        destVC.newsXML = rssSections[indexPath.section].feeds?[indexPath.row]
        SharedMethods.shared.pushTo(destVC: destVC)
    }
    
    @objc func tappedSection(_ sender: UIButton) { }
}


struct RSSSection {
    let title: String?
    let url: String?
    let feeds: [RSSFeed]?
}

struct RSSFeed {
    let title: String?
    let url: String?
}

let rssSections: [RSSSection] = [
    
    RSSSection(title: "Nasdaq",
               url: "https://www.nasdaq.com/nasdaq-RSS-Feeds",
               feeds: [
                RSSFeed(title: "Cryptocurrencies",
                        url: "https://www.nasdaq.com/feed/rssoutbound?category=Cryptocurrencies"),
                RSSFeed(title: "Markets",
                        url: "https://www.nasdaq.com/feed/rssoutbound?category=Markets"),
                RSSFeed(title: "Nasdaq Inc News",
                        url: "https://www.nasdaq.com/feed/rssoutbound?category=Nasdaq"),
                RSSFeed(title: "IPO",
                        url: "https://www.nasdaq.com/feed/rssoutbound?category=IPOs"),
                RSSFeed(title: "Investing",
                        url: "https://www.nasdaq.com/feed/rssoutbound?category=Investing"),
                RSSFeed(title: "Retirement",
                        url: "https://www.nasdaq.com/feed/rssoutbound?category=Retirement"),
                RSSFeed(title: "Saving Money",
                        url: "https://www.nasdaq.com/feed/rssoutbound?category=Saving%20Money")
               ]),
    
    RSSSection(title: "Investing.com",
               url: "https://www.investing.com/",
               feeds: [
                RSSFeed(title: "All News",
                        url: "https://www.investing.com/rss/investing_news.rss"),
                RSSFeed(title: "Stock Market News",
                        url: "https://www.investing.com/rss/news_25.rss"),
                RSSFeed(title: "Cryptocurrency News",
                        url: "https://www.investing.com/rss/news_301.rss"),
                RSSFeed(title: "SEC Filings",
                        url: "https://www.investing.com/rss/news_1064.rss")
               ]),
    
    RSSSection(title: "MarketWatch",
               url: "https://www.marketwatch.com/site/rss",
               feeds: [
                RSSFeed(title: "Top Stories",
                        url: "https://feeds.content.dowjones.io/public/rss/mw_topstories"),
                RSSFeed(title: "Real-time Headlines",
                        url: "https://feeds.content.dowjones.io/public/rss/mw_realtimeheadlines"),
                RSSFeed(title: "Breaking News",
                        url: "https://feeds.content.dowjones.io/public/rss/mw_bulletins"),
                RSSFeed(title: "Market Pulse",
                        url: "https://feeds.content.dowjones.io/public/rss/mw_marketpulse")
               ]),
    
    RSSSection(title: "CNBC",
               url: "https://www.cnbc.com/rss-feeds/",
               feeds: [
                RSSFeed(title: "Business",
                        url: "https://search.cnbc.com/rs/search/combinedcms/view.xml?partnerId=wrss01&id=10001147"),
                RSSFeed(title: "Earnings",
                        url: "https://search.cnbc.com/rs/search/combinedcms/view.xml?partnerId=wrss01&id=15839135"),
                RSSFeed(title: "Economy",
                        url: "https://search.cnbc.com/rs/search/combinedcms/view.xml?partnerId=wrss01&id=20910258"),
                RSSFeed(title: "Finance",
                        url: "https://search.cnbc.com/rs/search/combinedcms/view.xml?partnerId=wrss01&id=10000664"),
                RSSFeed(title: "Wealth",
                        url: "https://search.cnbc.com/rs/search/combinedcms/view.xml?partnerId=wrss01&id=10001054"),
                RSSFeed(title: "Small Business",
                        url: "https://search.cnbc.com/rs/search/combinedcms/view.xml?partnerId=wrss01&id=44877279"),
                RSSFeed(title: "Investing",
                        url: "https://search.cnbc.com/rs/search/combinedcms/view.xml?partnerId=wrss01&id=15839069"),
                RSSFeed(title: "Financial Advisors",
                        url: "https://search.cnbc.com/rs/search/combinedcms/view.xml?partnerId=wrss01&id=100646281"),
                RSSFeed(title: "Personal Finance",
                        url: "https://search.cnbc.com/rs/search/combinedcms/view.xml?partnerId=wrss01&id=21324812")
               ]),
    
    RSSSection(title: "WSJ",
               url: "https://www.wsj.com/",
               feeds: [
                RSSFeed(title: "U.S. Business",
                        url: "https://feeds.content.dowjones.io/public/rss/WSJcomUSBusiness"),
                RSSFeed(title: "Market News",
                        url: "https://feeds.content.dowjones.io/public/rss/RSSMarketsMain"),
                RSSFeed(title: "Economy",
                        url: "https://feeds.content.dowjones.io/public/rss/socialeconomyfeed"),
                RSSFeed(title: "Personal Finance",
                        url: "https://feeds.content.dowjones.io/public/rss/RSSPersonalFinance")
               ]),
    
    RSSSection(title: "CNN",
               url: "https://edition.cnn.com/",
               feeds: [
                RSSFeed(title: "Business News",
                        url: "http://rss.cnn.com/rss/money_latest.rss"),
                RSSFeed(title: "Top Stories",
                        url: "http://rss.cnn.com/rss/money_topstories.rss"),
                RSSFeed(title: "Economy",
                        url: "http://rss.cnn.com/rss/money_news_economy.rss")
               ])
]

struct RSSItem {
    let title: String?
    let link: String?
    let pubDate: String?
    let description: String?
    var imageURL: String?
}

import Foundation

class RSSParser: NSObject, XMLParserDelegate {
    private var items: [RSSItem] = []
    private var currentElement = ""
    
    private var currentTitle = ""
    private var currentLink = ""
    private var currentPubDate = ""
    private var currentDescription = ""
    
    private var parsingItem = false
    private var completion: (([RSSItem]) -> Void)?
    
    func parseFeed(url: URL, completion: @escaping ([RSSItem]) -> Void) {
        self.completion = completion
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                LogHandler.debugLog("Failed to fetch feed: \(error)")
                completion([])
                return
            }
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
        task.resume()
    }
    
    // MARK: - XMLParserDelegate Methods
    
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "item" {
            parsingItem = true
            currentTitle = ""
            currentLink = ""
            currentPubDate = ""
            currentDescription = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard parsingItem else { return }
        
        switch currentElement {
        case "title":
            currentTitle += string
        case "link":
            currentLink += string
        case "pubDate":
            currentPubDate += string
        case "description":
            currentDescription += string
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let item = RSSItem(
                title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                link: currentLink.trimmingCharacters(in: .whitespacesAndNewlines),
                pubDate: currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines),
                description: currentDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            items.append(item)
            parsingItem = false
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        completion?(items)
    }
}
