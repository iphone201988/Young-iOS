import UIKit

class OtpVC: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var otpTF1: UITextField!
    @IBOutlet weak var otpTF2: UITextField!
    @IBOutlet weak var otpTF3: UITextField!
    @IBOutlet weak var otpTF4: UITextField!
    @IBOutlet weak var resendTimeLbl: UILabel!
    @IBOutlet weak var resendCodeBtn: UIButton!
    @IBOutlet weak var resendCodeBtnSpaciousView: UIView!
    @IBOutlet weak var countDownView: UIView!
    @IBOutlet weak var furtherProceedBtn: UIButton!
    
    // MARK: Variables
    var email: String = ""
    var userID: String = ""
    var otpFor: OTPFor = .verification
    private var countdownTimer: Timer?
    private var countdownSeconds = 60
    private var viewModel = AuthVM()
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        otpTF1.delegate = self
        otpTF2.delegate = self
        otpTF3.delegate = self
        otpTF4.delegate = self
        otpTF1.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        otpTF2.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        otpTF3.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        otpTF4.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        otpTF1.becomeFirstResponder()
        
        // Start the countdown
        startCountdown()
        
        if Constants.accountRegistrationFor != .unspecified {
            furtherProceedBtn.setTitle("Next", for: .normal)
        }
        
        bindViewModel()
    }
    
    // MARK: IB Actions
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func resendCode(_ sender: UIButton) {
        otpTF1.text = ""
        otpTF2.text = ""
        otpTF3.text = ""
        otpTF4.text = ""
        otpTF1.becomeFirstResponder()
        startCountdown()
    }
    
    @IBAction func verify(_ sender: UIButton) {
        let f1 = otpTF1.text ?? ""
        let f2 = otpTF2.text ?? ""
        let f3 = otpTF3.text ?? ""
        let f4 = otpTF4.text ?? ""
        
        if f1.isEmpty || f2.isEmpty || f3.isEmpty || f4.isEmpty {
            Toast.show(message: "Please enter valid OTP")
        } else {
            let otp = f1 + f2 + f3 + f4
            viewModel.verifyOtp(for: otpFor, otp: otp, userID: userID)
        }
    }
    
    // MARK: Shared Methods
    private func bindViewModel() {
        viewModel.$requestResponse.sink { [weak self] resp in
            if resp.isSuccess == true && resp.request == .verifyOtp {
                if SharedMethods.shared.isNewAccountRegistration() {
//                    switch Constants.accountRegistrationFor {
//                    case .generalMemberAccountRegistration,
//                            .smallBusinessAccountRegistration,
//                            .startupAccountRegistration,
//                            .investorVCAccountRegistration:
//                        SharedMethods.shared.pushToWithoutData(destVC: AddLicenseVC.self)
//                        
//                    case .financialAdvisorAccountRegistration,
//                            .financialFirmAccountRegistration:
//                        SharedMethods.shared.pushToWithoutData(destVC: CRDVerificationVC.self)
//                        
//                    default: break
//                    }
                    SharedMethods.shared.pushToWithoutData(destVC: AddLicenseVC.self)
                    //SharedMethods.shared.pushToWithoutData(destVC: AgreementVC.self)
                } else {
                    let storyboard = AppStoryboards.main.storyboardInstance
                    guard let destVC = storyboard.instantiateViewController(withIdentifier: "CreateNewPasswordVC") as? CreateNewPasswordVC
                    else { return }
                    destVC.userID = self?.userID ?? ""
                    destVC.passwordSetFor = self?.otpFor ?? .forgot
                    SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
                }
            }
            
            if let error = resp.error {
                Toast.show(message: error)
            }
        }.store(in: &viewModel.cancellables)
    }
    
    func startCountdown() {
        // Set the initial countdown value
        countdownSeconds = 60
        // Create and start the timer
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        // Update the label with the initial countdown value
        updateCountdownLabel()
        
        resendCodeBtn.isHidden = true
        resendCodeBtnSpaciousView.isHidden = true
        countDownView.isHidden = false
    }
    
    func updateCountdownLabel() {
        resendTimeLbl.text = String(format: "00:%02d", countdownSeconds)
    }
    
    @objc func updateCountdown() {
        if countdownSeconds > 0 {
            countdownSeconds -= 1
            updateCountdownLabel()
        } else {
            // Invalidate the timer and enable the button
            countdownTimer?.invalidate()
            countdownTimer = nil
            resendCodeBtn.isHidden = false
            resendCodeBtnSpaciousView.isHidden = false
            countDownView.isHidden = true
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        guard let text = textField.text else { return }
        if text.count >= 1 && text.count < 2 {
            switch textField {
            case otpTF1: otpTF2.becomeFirstResponder()
            case otpTF2: otpTF3.becomeFirstResponder()
            case otpTF3: otpTF4.becomeFirstResponder()
            case otpTF4: otpTF4.resignFirstResponder()
            default: break
            }
        } else if text.isEmpty {
            textField.text = " "
            switch textField {
            case otpTF1: otpTF1.becomeFirstResponder()
            case otpTF2: otpTF1.becomeFirstResponder()
            case otpTF3: otpTF2.becomeFirstResponder()
            case otpTF4: otpTF3.becomeFirstResponder()
            default: break
            }
        } else {
            if let lastCharacter = text.last {
                textField.text = String(lastCharacter)
                switch textField {
                case otpTF1: otpTF2.becomeFirstResponder()
                case otpTF2: otpTF2.becomeFirstResponder()
                case otpTF3: otpTF3.becomeFirstResponder()
                case otpTF4: otpTF4.resignFirstResponder()
                default: break
                }
            }
        }
    }
}
