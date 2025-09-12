import UIKit

class PasswordChangedVC: UIViewController {
    
    // MARK: Outlets
    
    // MARK: Variables
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // MARK: IB Actions
    @IBAction func done(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    // MARK: Shared Methods

    // MARK: Delegates and DataSources
}
