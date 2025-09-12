import UIKit

class CreateNewPasswordVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
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
        viewModel.validateFieldsValue(password: passwordTF.text, confirmPassword: confirmPasswordTF.text)
    }
    
    // MARK: Shared Methods
    private func bindViewModel() {
        viewModel.$requestResponse.sink { resp in
            if resp.isSuccess == true {
                if SharedMethods.shared.isNewAccountRegistration() {
                    let storyboard = AppStoryboards.main.storyboardInstance
                    guard let destVC = storyboard.instantiateViewController(withIdentifier: "OtpVC") as? OtpVC
                    else { return }
                    destVC.userID = UserDefaults.standard[.loggedUserDetails]?._id ?? ""
                    destVC.otpFor = .verification
                    SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
                } else {
                    SharedMethods.shared.pushToWithoutData(destVC: PasswordChangedVC.self)
                }
            }
            
            if let error = resp.error {
                Toast.show(message: error)
            }
        }.store(in: &viewModel.cancellables)
        
        viewModel.$fieldsValidationStatus.sink { [weak self] status in
            if status.isValid == true {
                self?.passwordErrorView.isHidden = true
                self?.errorLbl.text = ""
                let password = self?.passwordTF.text ?? ""
                if self?.passwordSetFor == .verification {
                    self?.params["password"] = password
                    self?.viewModel.register(params: self?.params ?? [:])
                } else if self?.passwordSetFor == .forgot {
                    self?.viewModel.changePassword(userID: self?.userID ?? "", password: password)
                }
            }
            
            if let error = status.error {
                if status.type == .password {
                    self?.passwordErrorView.isHidden = false
                    self?.errorLbl.text = "Password requirement should be a minimum of 12 characters, 1 uppercase, 1 lowercase and 1 special character."
                }
                
                if status.type == .confirmPassword {
                    self?.passwordErrorView.isHidden = true
                    self?.errorLbl.text = ""
                    Toast.show(message: error)
                }
            }
        }.store(in: &viewModel.cancellables)
    }
    
    // MARK: Delegates and DataSources
}
