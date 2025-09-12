import UIKit

class ForgotPasswordVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var emailTF: UITextField!
    
    // MARK: Variables
    var userID: String = ""
    private var viewModel = AuthVM()
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bindViewModel()
    }
    
    // MARK: IB Actions
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func proceed(_ sender: UIButton) {
        viewModel.sendOtp(for: .forgot, email: emailTF.text ?? "")
    }
    
    // MARK: Shared Methods
    private func bindViewModel() {
        viewModel.$requestResponse.sink { [weak self] resp in
            if resp.isSuccess == true {
                let storyboard = AppStoryboards.main.storyboardInstance
                guard let destVC = storyboard.instantiateViewController(withIdentifier: "OtpVC") as? OtpVC
                else { return }
                destVC.email = self?.emailTF.text ?? ""
                destVC.userID = self?.viewModel.sendOTPResp?.data?._id ?? ""
                destVC.otpFor = .forgot
                SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
            }
            
            if let error = resp.error {
                Toast.show(message: error)
            }
        }.store(in: &viewModel.cancellables)
    }
    
    // MARK: Delegates and DataSources
}
