import UIKit

class SubscriptionCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var planView: UIView!
    @IBOutlet weak var planNameLbl: UILabel!
    @IBOutlet weak var planPriceLbl: UILabel!
    @IBOutlet weak var planDurationLbl: UILabel!
    @IBOutlet weak var selectedIcon: UIImageView!

    // MARK: Variables
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    // MARK: Cell Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: Shared Methods
    
    // MARK: IB Actions
}
