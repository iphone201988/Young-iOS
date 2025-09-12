import UIKit

class LoginVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var emailUsernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var passwordHideShowBtn: UIButton!
    
    // MARK: Variables
    private var viewModel = AuthVM()
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Constants.accountRegistrationFor = .unspecified
        bindViewModel()
        
        //        let storyboard = AppStoryboards.main.storyboardInstance
        //        guard let destVC = storyboard.instantiateViewController(withIdentifier: "AccountPackageVC") as? AccountPackageVC
        //        else { return }
        //        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
        
    }
    
    // MARK: IB Actions
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func passwordEyeHideShow(_ sender: UIButton) {
        passwordHideShowBtn.isSelected = !sender.isSelected
        if passwordHideShowBtn.isSelected {
            passwordTF.isSecureTextEntry = false
        } else {
            passwordTF.isSecureTextEntry = true
        }
    }
    
    @IBAction func forgotPassword(_ sender: UIButton) {
        SharedMethods.shared.pushToWithoutData(destVC: ForgotPasswordVC.self)
    }
    
    @IBAction func login(_ sender: UIButton) {
        let emailOrUsername = emailUsernameTF.text ?? ""
        if emailOrUsername.isEmail {
            viewModel.validateFieldsValue(email: emailOrUsername, password: passwordTF.text ?? "")
        } else {
            viewModel.validateFieldsValue(username: emailOrUsername, password: passwordTF.text ?? "")
        }
    }
    
    @IBAction func registerNow(_ sender: UIButton) {
        SharedMethods.shared.pushToWithoutData(destVC: CreateAccountVC.self)
    }
    
    // MARK: Shared Methods
    private func bindViewModel() {
        viewModel.$requestResponse.sink { resp in
            if resp.isSuccess == true {
                let userAuthResp = UserDefaults.standard[.loggedUserDetails]
                if userAuthResp?.is2FAEnabled == true {
                    SharedMethods.shared.navigateTo2FA()
                } else {
                    if userAuthResp?.isRegistrationCompleted == false {
                        let role = UserDefaults.standard[.loggedUserDetails]?.role ?? ""
                        let accountRegistrationFor = Events.registrationFor(role: role)
                        Constants.accountRegistrationFor = accountRegistrationFor ?? .generalMemberAccountRegistration
                        SharedMethods.shared.pushToWithoutData(destVC: AddLicenseVC.self)
                        //SharedMethods.shared.pushToWithoutData(destVC: AgreementVC.self)
                    } else {
                        SharedMethods.shared.navigateTo2FA()
                    }
                }
            }
            
            if let error = resp.error {
                Toast.show(message: error)
            }
        }.store(in: &viewModel.cancellables)
        
        viewModel.$fieldsValidationStatus.sink { [weak self] status in
            if status.isValid == true {
                self?.viewModel.login()
            }
            
            if let error = status.error {
                Toast.show(message: error)
            }
        }.store(in: &viewModel.cancellables)
    }
    
    // MARK: Delegates and DataSources
}
