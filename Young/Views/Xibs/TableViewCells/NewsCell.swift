import UIKit
import LinkPresentation

class NewsCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var linkRepView: UIView!
    @IBOutlet weak var publishDateLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var sourceLbl: UILabel!
    
    // MARK: Variables
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    // MARK: - Properties
    var onLinkTapped: ((String) -> Void)?
    private var currentLinkView: LPLinkView?
    
    var newsDetails: RSSItem? {
        didSet {
            guard let newsDetails else { return }
            //            if let localTime = DateUtil.convertUTCToLocal(newsDetails.pubDate ?? "") {
            //                publishDateLbl.text = localTime
            //            }
            
            //titleLbl.text = newsDetails.title ?? ""
            //sourceLbl.text = newsDetails.description ?? ""
            // Setup LPLinkView
            setupLinkPreview(for: newsDetails.link)
        }
    }
    
    // MARK: Cell Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        linkRepView.subviews.forEach { $0.removeFromSuperview() } // Cleanup for reuse
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentLinkView?.removeFromSuperview()
        currentLinkView = nil
    }
    
    // MARK: Shared Methods
    private func setupLinkPreview(for urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        
        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: url) { [weak self] metadata, error in
            guard let self = self, let metadata = metadata, error == nil else {
                LogHandler.debugLog("Link preview error: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                // Remove any existing preview
                self.currentLinkView?.removeFromSuperview()
                
                let linkView = LPLinkView(metadata: metadata)
                self.currentLinkView = linkView
                linkView.isUserInteractionEnabled = false // 🔒 Prevent default tap
                linkView.translatesAutoresizingMaskIntoConstraints = false
                self.linkRepView.addSubview(linkView)
                
                NSLayoutConstraint.activate([
                    linkView.leadingAnchor.constraint(equalTo: self.linkRepView.leadingAnchor),
                    linkView.trailingAnchor.constraint(equalTo: self.linkRepView.trailingAnchor),
                    linkView.topAnchor.constraint(equalTo: self.linkRepView.topAnchor),
                    linkView.bottomAnchor.constraint(equalTo: self.linkRepView.bottomAnchor)
                ])
                
                // Add custom tap gesture to container
                if self.linkRepView.gestureRecognizers?.isEmpty ?? true {
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.linkTapped))
                    self.linkRepView.addGestureRecognizer(tap)
                }
            }
        }
    }
    
    @objc private func linkTapped() {
        guard let link = newsDetails?.link else { return }
        onLinkTapped?(link)
    }
}
