import UIKit
import SafariServices

class AddLicenseVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var uploadView: UIView!
    @IBOutlet weak var scanView: UIView!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var retakeBtn: UIButton!
    @IBOutlet weak var verifyBtn: UIButton!
    @IBOutlet weak var scanActionsView: UIStackView!
    @IBOutlet weak var licenseImg: UIImageView!
    
    // MARK: Variables
    var event: Events = .unspecified
    private var viewModel = SharedVM()
    
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
    
    @IBAction func continueToDidit(_ sender: UIButton) {
        userVerification()
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func upload(_ sender: UIButton) {
        uploadView.isHidden = true
        uploadBtn.isHidden = true
        scanActionsView.isHidden = false
        scanView.isHidden = false
    }
    
    @IBAction func retake(_ sender: UIButton) { }
    
    // MARK: Shared Methods
    fileprivate func userVerification() {
        
        DiditServices.shared.createVerificationSession() { result in
            switch result {
            case .success(let response):
                if let url = response["url"] as? String {
                    DispatchQueue.main.async {
                        if let verificationURL = URL(string: url) {
                            self.openVerificationPage(from: self, with: verificationURL)
                            //UIApplication.shared.open(verificationURL)
                        }
                    }
                } else {
                    LogHandler.debugLog("Verification URL missing!")
                }
                
            case .failure(let error):
                LogHandler.debugLog("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func openVerificationPage(from viewController: UIViewController, with verificationURL: URL) {
        let safariVC = SFSafariViewController(url: verificationURL)
        safariVC.modalPresentationStyle = .formSheet
        safariVC.delegate = self
        viewController.present(safariVC, animated: true)
    }
    
    private func bindViewModel() {
        viewModel.$documentVerifiedStatus.sink { status in
            if let status {
                switch status {
                case .verified, .inReview:
                    SharedMethods.shared.pushToWithoutData(destVC: AgreementVC.self)
                    
                default:
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }.store(in: &viewModel.cancellables)
    }
    
    // MARK: Delegates and DataSources
}

extension AddLicenseVC: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if event != .unspecified {
            self.navigationController?.popViewController(animated: true)
        } else {
            let userID = UserDefaults.standard[.loggedUserDetails]?._id ?? ""
            let accessToken = UserDefaults.standard[.accessToken] ?? ""
            if accessToken.isEmpty {
                viewModel.getUnauthUser(params: ["userId": userID])
            } else {
                viewModel.getUserProfile(anotherUserID: userID, forDocumentVerificationStatus: true)
            }
            
            //                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            //                            //            let storyboard = AppStoryboards.main.storyboardInstance
            //                            //            guard let destVC = storyboard.instantiateViewController(withIdentifier: "AddProfileVC") as? AddProfileVC
            //                            //            else { return }
            //                            //                    if
            //                            //                        let lic = licenseImg.image,
            //                            //                        let data = lic.jpegData(compressionQuality: 0.1) {
            //                            //                        destVC.params = ["licenseImage": data]
            //                            //                    }
            //                            //            SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
            //                            SharedMethods.shared.pushToWithoutData(destVC: AgreementVC.self)
            //                        }
        }
    }
}
