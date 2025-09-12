import UIKit

class AccountCreatedVC: UIViewController {
    
    // MARK: Outlets
    
    // MARK: Variables
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: IB Actions
    @IBAction func done(_ sender: UIButton) {
        let storyboard = AppStoryboards.main.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "QRCodeVC") as? QRCodeVC
        else { return }
        let userAuthResp = UserDefaults.standard[.loggedUserDetails]
        destVC.userID = UserDefaults.standard[.loggedUserDetails]?._id ?? ""
        destVC.secretCode = UserDefaults.standard[.secret] ?? ""
        destVC.qrCodeString = UserDefaults.standard[.qrCodeUrl] ?? ""
        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
    }
    
    // MARK: Shared Methods
    
    // MARK: Delegates and DataSources
}
