import UIKit

class UsernameCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var totalRatingLbl: UILabel!
    @IBOutlet weak var roleLbl: UILabel!
    @IBOutlet weak var interestServiceLbl: UILabel!
    
    // MARK: Variables
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    var userDetails: UserDetails? {
        didSet {
            guard let userDetails else { return }
            usernameLbl.text = userDetails.username ?? ""
            SharedMethods.shared.setImage(imageView: profilePic, url: userDetails.profileImage ?? "")
            totalRatingLbl.text = "\(userDetails.isRated ?? 0.0)"
            let userRole = Events.registrationFor(role: userDetails.role ?? "") ?? .unspecified
            roleLbl.text = userRole.rawValue
            // Interests (for Gen members)/ Services (for all others)
            if userRole == .generalMemberAccountRegistration {
                let interests = userDetails.topicsOfInterest ?? []
                let formatted = interests.joined(separator: ", ")
                interestServiceLbl.text = formatted
            } else {
                interestServiceLbl.text = userDetails.servicesInterested ?? ""
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
