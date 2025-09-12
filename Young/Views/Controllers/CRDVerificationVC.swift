import UIKit

class CRDVerificationVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var crdTF: UITextField!
    
    // MARK: Variables
    var params: [String: Any] = [:]
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: IB Actions
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func next(_ sender: UIButton) {
        let storyboard = AppStoryboards.main.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "PersonalInfoVC") as? PersonalInfoVC
        else { return }
        params["crdNumber"] = crdTF.text ?? ""
        destVC.params = params
        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
    }
    
    // MARK: Shared Methods
    
    // MARK: Delegates and DataSources
}
