import UIKit

class OptionCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var optionView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var selectedStatusIcon: UIImageView!
    
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
    func selectedOption() {
        optionView.backgroundColor = UIColor(named: "#B897FD")
        optionView.layer.borderWidth = 1
        optionView.layer.borderColor = UIColor(named: "#7D51F9")?.cgColor
        titleLbl.textColor = .white
        selectedStatusIcon.image = UIImage(named: "selectedTick")
    }
    
    func unselectedOption() {
        optionView.backgroundColor = .clear
        optionView.layer.borderWidth = 1
        optionView.layer.borderColor = UIColor(named: "#C5C6CC")?.cgColor
        titleLbl.textColor = UIColor(named: "#71727A")
        selectedStatusIcon.image = nil
    }
    
    // MARK: IB Actions
}
