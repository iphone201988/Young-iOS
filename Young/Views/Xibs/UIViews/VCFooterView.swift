import UIKit

class VCFooterView: UICollectionViewCell {
    
    // MARK: Outlets
    @IBOutlet var baseView: UIView!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var streamBtn: UIButton!
    @IBOutlet weak var vaultBtn: UIButton!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var newAddOnView: UIView!
    @IBOutlet weak var newAddOnBtn: UIButton!
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var calendarBtn: UIButton!
    @IBOutlet weak var optionsView: UIStackView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var streamView: UIView!
    @IBOutlet weak var vaultView: UIView!
    
    // MARK: Variables
    
    // MARK: Xib Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    // MARK: IB Actions
    
    // MARK: Shared Methods
    private func nibSetup(){
        //Load nib for UIView
        Bundle.main.loadNibNamed("VCFooterView", owner: self, options: nil)
        addSubview(baseView)
        baseView.frame = self.bounds
    }
}
