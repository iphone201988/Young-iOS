import UIKit

class SelectedInterestCell: UICollectionViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var removeBtn: UIButton!
    
    // MARK: Variables
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    // MARK: Cell Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: Shared Methods
    
    // MARK: IB Actions
}
