import UIKit
import SideMenu

class MediaVC: UIViewController {
    
    private enum Constants {
        static let mockLabels = [
            "This is a nice house, but it must be expensive. This is a nice house, but it must be expensive, This is a nice house, but it must be expensive. This is a nice house, but it must be expensive",
            "Wow, very nice design. It must have been hard to build this.",
            "I want to live in this, but I can't afford a flat.",
            "This looks stupid. This looks stupid. This looks stupid",
            "This one is also very modern looking.",
            "What a great design. This looks stupid. This looks stupid",
        ]
    }
    
    var numberOfCells = 2
    fileprivate let viewmodel = SharedVM()
    fileprivate var mediaData = [MediaData]()
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let layout = PinterestLayout()
            layout.layoutType = .withContent
            layout.delegate = self
            collectionView.collectionViewLayout = layout
            collectionView.registerCellFromNib(cellID: MediaCell.identifier)
        }
    }
    
    @IBOutlet weak var pinterestLayout: PinterestLayout!
    
    var houseImages: [UIImage?] = []
    var houseLabels: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // loadData()
        dataBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewmodel.getUploadedMedia()
    }
    
    fileprivate func dataBinding() {
        viewmodel.$mediaData
            .receive(on: DispatchQueue.main)
            .sink { resp in
                self.mediaData = resp
                self.collectionView.reloadData()
            }.store(in: &viewmodel.cancellables)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func menu(_ sender: UIButton) {
        let storyboard = AppStoryboards.menus.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "SideMenuNavigationController") as? SideMenuNavigationController
        else { return }
        destVC.settings = SharedMethods.shared.sideMenuSettings()
        SharedMethods.shared.presentVC(destVC: destVC)
    }
    
    private func loadData() {
        houseImages = (0..<numberOfCells).map { _ in return UIImage(named: "readyToLaunch") }
        houseLabels = (0..<numberOfCells).map {
            return Constants.mockLabels[$0 % Constants.mockLabels.count]
        }
    }
}

extension MediaVC: UICollectionViewDelegate, UICollectionViewDataSource, PinterestLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        mediaData.count
    }
    
//        func collectionView(_ collectionView: UICollectionView, layout: PinterestLayout?, heightForItemAt indexPath: IndexPath) -> CGFloat {
//    
//            let image = houseImages[indexPath.item]
//            let text = houseLabels[indexPath.item]
//    
//            let width = image?.size.width ?? 0
//            let height = image?.size.height ?? 0
//            let scaledImageHeight = (height * (layout?.cellWidth ?? 0.0)) / width
//    
//            let padding = 10.0
//    
//            let labelHeight = text.heightFitting(width: layout?.cellWidth ?? 0.0,
//                                                 font: UIFont.systemFont(ofSize: 12, weight: .semibold))
//            let cellHeight = scaledImageHeight + padding + labelHeight
//            return cellHeight
//        }
//    
//        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//            let dequeuedCell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaCell.identifier, for: indexPath)
//            let cell = dequeuedCell as? MediaCell ?? MediaCell()
//            cell.mediaImg.image = houseImages[indexPath.item]
//            cell.contentLbl.text = houseLabels[indexPath.item]
//            return cell
//        }

    func collectionView(_ collectionView: UICollectionView,
                        layout: PinterestLayout?,
                        heightForItemAt indexPath: IndexPath) -> CGFloat {
        
        let media = mediaData[indexPath.item]
        let cellWidth = layout?.cellWidth ?? 0.0
        
        // 🔹 Use cached height if available
        if let cachedHeight = media.calculatedHeight {
            let padding: CGFloat = 10.0
            let title = media.title ?? ""
            
//            var title = ""
//            if indexPath.row%2==0 {
//                title = media.title ?? ""
//            } else {
//                title = "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English."
//            }
            
            let labelHeight = title.heightFitting(
                width: cellWidth,
                font: UIFont.systemFont(ofSize: 12, weight: .semibold)
            )
            return cachedHeight + padding + labelHeight
        }
        
        // 🔹 Fallback default aspect ratio (e.g., 16:9)
        let defaultAspectRatio: CGFloat = 16.0 / 9.0
        let scaledImageHeight = cellWidth / defaultAspectRatio
        
        let padding: CGFloat = 10.0
        let title = media.title ?? ""
        let labelHeight = title.heightFitting(
            width: cellWidth,
            font: UIFont.systemFont(ofSize: 12, weight: .semibold)
        )
        
        return scaledImageHeight + padding + labelHeight
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MediaCell.identifier,
            for: indexPath
        ) as? MediaCell else { return UICollectionViewCell() }
        
        let media = mediaData[indexPath.item]
        cell.contentLbl.text = media.title ?? ""
        
//        if indexPath.row%2==0 {
//            cell.contentLbl.text = media.title
//        } else {
//            cell.contentLbl.text = "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English."
//        }
        
        let baseURL = VaultInfo.shared.getKeyValue(by: "Media_Load_Base_URL").1 as? String ?? ""
        let completeURL = "\(baseURL)\(media.imageUrl ?? "")"
        
        if let url = URL(string: completeURL) {
            cell.mediaImg.kf.setImage(with: url,
                                      placeholder: UIImage(named: "placeholder")) { [weak self] result in
                switch result {
                case .success(let value):
                    let image = value.image
                    let cellWidth = (collectionView.collectionViewLayout as? PinterestLayout)?.cellWidth ?? 0.0
                    
                    // calculate height
                    let aspectRatio = image.size.height / image.size.width
                    let newHeight = cellWidth * aspectRatio
                    
                    // cache height
                    self?.mediaData[indexPath.item].calculatedHeight = newHeight
                    
                    // refresh layout (smooth update)
                    collectionView.collectionViewLayout.invalidateLayout()
                    
                case .failure:
                    break
                }
            }
        }
        
        return cell
    }

}
