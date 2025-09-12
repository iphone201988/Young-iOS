import UIKit

class AddMoreCell: UICollectionViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var addMoreView: UIView!
    @IBOutlet weak var selectedImg: UIImageView!
    @IBOutlet weak var addImageIcon: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    
    // MARK: Variables
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    // MARK: Cell Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            self.setupDashedBorder()
        }
        
    }
    
    // MARK: Shared Methods
    private func setupDashedBorder() {
        let borderLayer = CAShapeLayer()
        borderLayer.strokeColor = UIColor(named: "#7D51F9")?.cgColor
        borderLayer.lineDashPattern = [6, 3] // Dash and gap length
        borderLayer.lineWidth = 1.5 // Increase thickness here
        borderLayer.frame = addMoreView.bounds
        borderLayer.fillColor = nil
        borderLayer.path = UIBezierPath(roundedRect: addMoreView.bounds, cornerRadius: 16).cgPath // Adjust corner radius as needed
        
        addMoreView.layer.addSublayer(borderLayer)
    }
    
    // MARK: IB Actions
}
