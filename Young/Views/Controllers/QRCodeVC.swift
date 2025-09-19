import UIKit

class QRCodeVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var secretCodeLbl: UILabel!
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var copySecretKey: UIButton!
    
    // MARK: Variables
    private var viewModel = AuthVM()
    var userID: String = ""
    var secretCode: String = ""
    var qrCodeString: String = ""
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Remove the prefix if present
        let base64String: String
        if qrCodeString.hasPrefix("data:image/png;base64,") {
            base64String = qrCodeString.replacingOccurrences(of: "data:image/png;base64,", with: "")
        } else {
            base64String = qrCodeString
        }
        
        if let dataDecoded = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) {
            let decodedimage = UIImage(data: dataDecoded)
            qrCodeImage.image = decodedimage
        }
        
        secretCodeLbl.text = secretCode
        bindViewModel()
    }
    
    // MARK: IB Actions
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedVerify(_ sender: UIButton) {
        let code = codeTF.text ?? ""
        if code.isEmpty {
            Toast.show(message: "Authenticator code can't be empty")
        } else {
            viewModel.verify2FA(userId: userID, otp: code)
        }
    }
    
    @IBAction func tappedCopySecretKey(_ sender: UIButton) {
        UIPasteboard.general.string = secretCodeLbl.text
        Toast.show(message: "Secret key copied to clipboard")
    }

    // MARK: Shared Methods
    private func bindViewModel() {
        viewModel.$requestResponse.sink { resp in
            if resp.isSuccess == true {
                if let vc = AppStoryboards.menus.controller(HomeVC.self) {
                    SharedMethods.shared.navigateToRootVC(rootVC: vc)
                }
            }
            
            if let error = resp.error {
                Toast.show(message: error)
            }
        }.store(in: &viewModel.cancellables)
    }
    
    // MARK: Delegates and DataSources
}
