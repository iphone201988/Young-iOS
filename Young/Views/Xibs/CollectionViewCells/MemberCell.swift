import UIKit

class MemberCell: UICollectionViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var memberImg: UIImageView!
    
    // MARK: Variables
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    var memberDetails: UserDetails? {
        didSet {
            guard let memberDetails else { return }
            SharedMethods.shared.setImage(imageView: memberImg, url: memberDetails.profileImage ?? "")
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
