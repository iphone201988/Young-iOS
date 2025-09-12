import UIKit
import SideMenu

class MemberAgreementVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var interfaceTitleLbl: UILabel!
    
    // MARK: Variables
    var event: Events = .unspecified
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialViewSetup()
    }
    
    // MARK: IB Actions
    @IBAction func menu(_ sender: UIButton) {
        let storyboard = AppStoryboards.menus.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "SideMenuNavigationController") as? SideMenuNavigationController
        else { return }
        destVC.settings = SharedMethods.shared.sideMenuSettings()
        SharedMethods.shared.presentVC(destVC: destVC)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Shared Methods
    fileprivate func initialViewSetup() {
        switch event {
            
        case .generalMemberAccountRegistration:
            interfaceTitleLbl.text = "Member Agreement"
            
        case .financialAdvisorAccountRegistration:
            interfaceTitleLbl.text = "Advisor Agreement"
            
        case .smallBusinessAccountRegistration:
            interfaceTitleLbl.text = "Advisor Agreement"
            
        case .startupAccountRegistration:
            interfaceTitleLbl.text = "Startup Agreements"
            
        default: break
        }
    }
    
    // MARK: Delegates and DataSources
}
