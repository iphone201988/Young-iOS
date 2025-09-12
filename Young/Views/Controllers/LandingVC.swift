import UIKit

class LandingVC: UIViewController {
    
    // MARK: Outlets
    
    // MARK: Variables
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: IB Actions
    @IBAction func registerNow(_ sender: UIButton) {
        SharedMethods.shared.pushToWithoutData(destVC: CreateAccountVC.self)
    }
    
    @IBAction func getStarted(_ sender: UIButton) {
        SharedMethods.shared.pushToWithoutData(destVC: LoginVC.self)
    }
    
    // MARK: Shared Methods
    
    // MARK: Delegates and DataSources
}
