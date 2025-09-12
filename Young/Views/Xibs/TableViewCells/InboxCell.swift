import UIKit

class InboxCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var roleLbl: UILabel!
    @IBOutlet weak var dateTimeLbl: UILabel!
    @IBOutlet weak var userProfileBtn: UIButton!
    @IBOutlet weak var viewMessageBtn: UIButton!
    
    // MARK: Variables
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    var chatDetails: Chat? {
        didSet {
            let chatUsers = chatDetails?.chatUsers ?? []
            if let loggedInUserId = UserDefaults.standard[.loggedUserDetails]?._id {
                let user = chatUsers.first(where: { $0._id != loggedInUserId })
                SharedMethods.shared.setImage(imageView: profilePic, url: user?.profileImage ?? "")
                usernameLbl.text = user?.username ?? ""
                let userRole = Events.registrationFor(role: UserDefaults.standard[.loggedUserDetails]?.role ?? "") ?? .unspecified
                roleLbl.text = userRole.rawValue
            }
            
            let createdAt = chatDetails?.createdAt ?? ""
            dateTimeLbl.text = DateUtil.formatDateToLocal(from: createdAt, format: "h:mm a")
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
