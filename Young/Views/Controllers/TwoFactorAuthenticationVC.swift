import UIKit

class TwoFactorAuthenticationVC: UIViewController {
    
    // MARK: Outlets
    
    // MARK: Variables
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: IB Actions
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func login(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    // MARK: Shared Methods
    
    // MARK: Delegates and DataSources
}
