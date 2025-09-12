import UIKit

class HomeFeedCell: UICollectionViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    
    // MARK: Variables
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    var userDetails: UserDetails? {
        didSet {
            guard let userDetails else { return }
            SharedMethods.shared.setImage(imageView: profilePic, url: userDetails.profileImage ?? "")
            usernameLbl.text = userDetails.username ?? ""
        }
    }
    
    var newsDetails: UserDetails? {
        didSet {
            guard let newsDetails else { return }
            let imageURL = newsDetails.profileImage ?? ""
            let completeURL = "\(imageURL)"
            SharedMethods.shared.setImage(imageView: profilePic, url: completeURL)
            usernameLbl.text = newsDetails.username ?? ""
        }
    }
    
    // MARK: Cell Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: Shared Methods
    
    // MARK: IB Actions
}
