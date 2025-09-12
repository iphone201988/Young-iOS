import UIKit
import SideMenu

class ChangePasswordVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var oldPasswordTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var oldPasswordHideShowBtn: UIButton!
    @IBOutlet weak var passwordHideShowBtn: UIButton!
    @IBOutlet weak var confirmPasswordHideShowBtn: UIButton!
    @IBOutlet weak var furtherProceedBtn: UIButton!
    @IBOutlet weak var passwordErrorView: UIView!
    @IBOutlet weak var errorLbl: UILabel!
    
    // MARK: Variables
    private var viewModel = AuthVM()
    var params = [String: Any]()
    var userID: String = ""
    var passwordSetFor: OTPFor = .verification
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if SharedMethods.shared.isNewAccountRegistration() {
            furtherProceedBtn.setTitle("Next", for: .normal)
        }
        passwordErrorView.isHidden = true
        bindViewModel()
    }
    
    // MARK: IB Actions
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func menu(_ sender: UIButton) {
        let storyboard = AppStoryboards.menus.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "SideMenuNavigationController") as? SideMenuNavigationController
        else { return }
        destVC.settings = SharedMethods.shared.sideMenuSettings()
        SharedMethods.shared.presentVC(destVC: destVC)
    }
    
    @IBAction func oldPasswordEyeHideShow(_ sender: UIButton) {
        oldPasswordHideShowBtn.isSelected = !sender.isSelected
        if oldPasswordHideShowBtn.isSelected {
            oldPasswordTF.isSecureTextEntry = false
        } else {
            oldPasswordTF.isSecureTextEntry = true
        }
    }
    
    @IBAction func passwordEyeHideShow(_ sender: UIButton) {
        passwordHideShowBtn.isSelected = !sender.isSelected
        if passwordHideShowBtn.isSelected {
            passwordTF.isSecureTextEntry = false
        } else {
            passwordTF.isSecureTextEntry = true
        }
    }
    
    @IBAction func confrimPasswordEyeHideShow(_ sender: UIButton) {
        confirmPasswordHideShowBtn.isSelected = !sender.isSelected
        if confirmPasswordHideShowBtn.isSelected {
            confirmPasswordTF.isSecureTextEntry = false
        } else {
            confirmPasswordTF.isSecureTextEntry = true
        }
    }
    
    @IBAction func confirm(_ sender: UIButton) {
        let oldPwd = oldPasswordTF.text ?? ""
        let newPwd = passwordTF.text ?? ""
        let confirmPwd = confirmPasswordTF.text ?? ""
        if oldPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty {
            Toast.show(message: "All fields are required")
        } else {
            if newPwd != confirmPwd {
                Toast.show(message: "Password and Confirm Password does not match")
            } else {
                let params = ["currentPassword": oldPwd, "newPassword": newPwd]
                viewModel.updatePassword(params: params)
            }
        }
    }
    
    // MARK: Shared Methods
    private func bindViewModel() {
        viewModel.$requestResponse.sink { resp in
            if resp.isSuccess == true {
                Toast.show(message: resp.message ?? "") {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
            if let error = resp.error {
                Toast.show(message: error)
            }
        }.store(in: &viewModel.cancellables)
    }
    
    // MARK: Delegates and DataSources
}
