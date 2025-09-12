import UIKit
import SideMenu

class FamilyAndEducationVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var childrenTF: UITextField!
    @IBOutlet weak var educationLevelTF: UITextField!
    @IBOutlet weak var residenceStatusTF: UITextField!
    
    @IBOutlet weak var childrenBtn: UIButton!
    @IBOutlet weak var educationLevelBtn: UIButton!
    @IBOutlet weak var residenceStatusBtn: UIButton!
    
    // MARK: Variables
    fileprivate var viewModel = SharedVM()
    fileprivate var userDetails: UserDetails?
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        PickerManager.shared.configurePicker(for: childrenTF,
                                             with: Constants.children,
                                             iconButton: childrenBtn)
        
        PickerManager.shared.configurePicker(for: educationLevelTF,
                                             with: Constants.educationLevel,
                                             iconButton: educationLevelBtn)
        
        PickerManager.shared.configurePicker(for: residenceStatusTF,
                                             with: Constants.homeOwnershipStatus,
                                             iconButton: residenceStatusBtn)
        
        bindViewModel()
        viewModel.getUserProfile()
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
    
    @IBAction func saveChanges(_ sender: UIButton) {
        let params = [
            "children": childrenTF.text ?? "",
            "educationLevel": educationLevelTF.text ?? "",
            "residenceStatus": residenceStatusTF.text ?? ""
        ] as [String : Any]
        
        viewModel.updateUser(params: params)
    }
    
    // MARK: Shared Methods
    private func bindViewModel() {
        viewModel.$requestResponse.sink { resp in
            if resp.isSuccess == true {
                Toast.show(message: resp.message ?? "")
            }
            
            if let error = resp.error {
                Toast.show(message: error)
            }
        }.store(in: &viewModel.cancellables)
        
        viewModel.$particularUserDetails.sink { [weak self] resp in
            if let resp {
                self?.userDetails = resp
                self?.populateData()
            }
        }.store(in: &viewModel.cancellables)
    }
    
    fileprivate func populateData() {
        childrenTF.text = userDetails?.children ?? ""
        educationLevelTF.text = userDetails?.educationLevel ?? ""
        residenceStatusTF.text = userDetails?.residenceStatus ?? ""
    }
    
    // MARK: Delegates and DataSources
}
