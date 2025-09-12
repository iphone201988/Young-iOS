import UIKit

class EditOptionCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var optionLbl: UILabel!
    @IBOutlet weak var nextArrowIcon: UIImageView!
    @IBOutlet weak var customIcon: UIImageView!
    @IBOutlet weak var lastLoginView: UIView!
    @IBOutlet weak var lastLoginLbl: UILabel!
    @IBOutlet weak var mainViewLeading: NSLayoutConstraint!
    @IBOutlet weak var optionBtn: UIButton!
    @IBOutlet weak var mainOptionView: UIView!
    @IBOutlet weak var mainViewTrailing: NSLayoutConstraint!
    
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
