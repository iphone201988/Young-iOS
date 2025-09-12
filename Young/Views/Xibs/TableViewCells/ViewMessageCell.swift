import UIKit

class ViewMessageCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var messageContentView: UIView!
    @IBOutlet weak var messageContentLbl: UILabel!
    @IBOutlet weak var dateTimeLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    
    // MARK: Variables
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    var messageDetails: Chat? {
        didSet {
            messageContentLbl.text = messageDetails?.message ?? ""
            dateTimeLbl.text = DateUtil.formatDateToLocal(from: messageDetails?.createdAt ?? "",
                                                          format: "MMM d, yyyy h:mm a")
            
//            if let senderID = messageDetails?.senderId?._id,
//               let currentUserID = UserDefaults.standard[.loggedUserDetails]?._id {
//                if senderID == currentUserID {
//                    messageContentView.backgroundColor = UIColor(named: "#7030A0")
//                } else {
//                    messageContentView.backgroundColor = UIColor(named: "#F8F8F8")
//                }
//            }
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
