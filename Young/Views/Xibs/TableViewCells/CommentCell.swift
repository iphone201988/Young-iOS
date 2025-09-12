import UIKit

class CommentCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var userProfilePic: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postDateTimeLbl: UILabel!
    @IBOutlet weak var postContentLbl: UILabel!
    @IBOutlet weak var totalBoomsLbl: UILabel!
    @IBOutlet weak var roleLbl: UILabel!
    @IBOutlet weak var boomBtn: UIButton!
    @IBOutlet weak var boomIcon: UIImageView!
    
    // MARK: Variables
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    var commentDetails: Comment? {
        didSet {
            guard let commentDetails else { return }
            SharedMethods.shared.setImage(imageView: userProfilePic, url: commentDetails.userId?.profileImage ?? "")
            let firstname = commentDetails.userId?.firstName ?? ""
            let lastname = commentDetails.userId?.lastName ?? ""
            usernameLbl.text = "\(firstname) \(lastname)"
            postDateTimeLbl.text = DateUtil.formatDateToLocal(from: commentDetails.createdAt ?? "", format: "d MMM yyyy")
            postContentLbl.text = commentDetails.comment ?? ""
            totalBoomsLbl.text = "\(commentDetails.likesCount ?? 0) Booms"
            let userRole = Events.registrationFor(role: commentDetails.userId?.role ?? "") ?? .unspecified
            roleLbl.text = userRole.rawValue
            if commentDetails.isLiked == true {
                boomIcon.image = UIImage(named: "boom")
            } else {
                boomIcon.image = UIImage(named: "heart")
            }
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
