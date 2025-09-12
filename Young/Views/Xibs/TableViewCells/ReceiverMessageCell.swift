import UIKit

class ReceiverMessageCell: UITableViewCell {
    
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
