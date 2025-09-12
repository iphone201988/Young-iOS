import UIKit

class FeedSectionCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var viewMoreBtn: UIButton!
    @IBOutlet weak var feedMainView: UIView!
    @IBOutlet weak var feedsSpaciousEmptyView: UIView!
    @IBOutlet weak var adsSpaciousEmptyView: UIView!
    @IBOutlet weak var bottomEmptyView: UIView!
    @IBOutlet weak var topicCollectionView: UICollectionView! {
        didSet {
            topicCollectionView.registerCellFromNib(cellID: TopicCell.identifier)
        }
    }
    
    @IBOutlet weak var feedCollectionView: UICollectionView! {
        didSet {
            feedCollectionView.registerCellFromNib(cellID: HomeFeedCell.identifier)
        }
    }
    
    @IBOutlet weak var adsCollectionView: UICollectionView! {
        didSet {
            adsCollectionView.registerCellFromNib(cellID: AdsCell.identifier)
        }
    }
    
    // MARK: Variables
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    var trendingTopics: [Topic]? {
        didSet {
            topicCollectionView.delegate = self
            topicCollectionView.dataSource = self
            topicCollectionView.reloadData()
        }
    }
    
    var users: [UserDetails]? {
        didSet {
            let layout = PinterestLayout()
            layout.delegate = self
            feedCollectionView.collectionViewLayout = layout
            feedCollectionView.delegate = self
            feedCollectionView.dataSource = self
            feedCollectionView.reloadData()
        }
    }
    
    var news: [UserDetails]? {
        didSet {
            let layout = PinterestLayout()
            layout.delegate = self
            feedCollectionView.collectionViewLayout = layout
            feedCollectionView.delegate = self
            feedCollectionView.dataSource = self
            feedCollectionView.reloadData()
        }
    }
    
    var ads: [UserDetails]? {
        didSet {
            adsCollectionView.delegate = self
            adsCollectionView.dataSource = self
            adsCollectionView.reloadData()
        }
    }
    
    var onCollectionViewScroll: ((CGFloat, CGFloat, CGFloat) -> Void)?
    
    // MARK: Cell Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //        adsCollectionView.delegate = self
        //        adsCollectionView.dataSource = self
        //        adsCollectionView.reloadData()
        
        adsCollectionView.dataSource = self
        adsCollectionView.delegate = self
    }
    
    // MARK: Shared Methods

    // MARK: IB Actions
}

// MARK: Delegates and DataSources

extension FeedSectionCell: UICollectionViewDataSource,
                           UICollectionViewDelegate,
                           UICollectionViewDelegateFlowLayout, PinterestLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == topicCollectionView {
            return trendingTopics?.count ?? 0
        } else if collectionView == feedCollectionView {
            if feedCollectionView.tag == 1 {
                return news?.count ?? 0
            } else {
                return users?.count ?? 0
            }
        } else if collectionView == adsCollectionView {
            return ads?.count ?? 0
        } else {
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == topicCollectionView {
            let title = trendingTopics?[indexPath.item].topic ?? ""
            //let rank = "Trending no. \(indexPath.item + 1)"
            let rank = "#\(indexPath.item + 1)"
            let font = UIFont.systemFont(ofSize: 16, weight: .medium)
            
            let maxTextWidth = max(title.width(usingFont: font), rank.width(usingFont: font))
            let extraComponentsOccupiedSpace = 95.0
            let totalWidth = maxTextWidth + extraComponentsOccupiedSpace
            
            return CGSize(width: totalWidth, height: 80.0)
            
        } else if collectionView == adsCollectionView {
            return CGSize(width: 320, height: 203.0)
            
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: PinterestLayout?, heightForItemAt indexPath: IndexPath) -> CGFloat {
        if indexPath.item == 0 || indexPath.item == 3 {
            return 140  // tall cells
        }
        return 88  // short cells
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
        
        if collectionView == topicCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopicCell.identifier, for: indexPath) as! TopicCell
            cell.titleLbl.text = trendingTopics?[indexPath.item].topic ?? ""
            //let rank = "Trending no. \(indexPath.item + 1)"
            let rank = "#\(indexPath.item + 1)"
            cell.rankLbl.text = rank
            SharedMethods.shared.setImage(imageView: cell.topicImage, url: trendingTopics?[indexPath.item].image ?? "")
            return cell
            
        } else if collectionView == feedCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeFeedCell.identifier, for: indexPath) as! HomeFeedCell
            if feedCollectionView.tag == 1 {
                cell.newsDetails = news?[indexPath.item]
            } else {
                cell.userDetails = users?[indexPath.item]
            }
            return cell
            
        } else if collectionView == adsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdsCell.identifier, for: indexPath) as! AdsCell
            SharedMethods.shared.setImage(imageView: cell.adsImage, url: ads?[indexPath.item].file ?? "")
            return cell
            
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == feedCollectionView {
            if feedCollectionView.tag == 1 {
                let storyboard = AppStoryboards.menus.storyboardInstance
                guard let destVC = storyboard.instantiateViewController(withIdentifier: "NewsPreviewVC") as? NewsPreviewVC
                else { return }
                destVC.source = news?[indexPath.item].newsLink ?? ""
                SharedMethods.shared.pushTo(destVC: destVC)
            } else {
                let storyboard = AppStoryboards.menus.storyboardInstance
                guard let destVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC
                else { return }
                destVC.isAnotherUserID = users?[indexPath.item]._id
                SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let contentWidth = scrollView.contentSize.width
        let frameWidth = scrollView.frame.width
        onCollectionViewScroll?(offsetX, contentWidth, frameWidth)
    }
}
