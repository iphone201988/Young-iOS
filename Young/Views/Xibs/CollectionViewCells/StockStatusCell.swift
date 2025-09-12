import UIKit

class StockStatusCell: UICollectionViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var stockValueLbl: UILabel!
    @IBOutlet weak var upDownIcon: UIImageView!
    
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
