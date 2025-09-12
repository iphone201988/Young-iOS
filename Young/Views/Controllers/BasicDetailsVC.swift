import UIKit
import CountryPickerView

class BasicDetailsVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var firstnameTF: UITextField!
    @IBOutlet weak var lastnameTF: UITextField!
    @IBOutlet weak var companyView: UIView!
    @IBOutlet weak var companyTF: UITextField!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var countryCodeTF: UITextField!
    @IBOutlet weak var flagImg: UIImageView!
    @IBOutlet weak var countryPickerView: CountryPickerView!
    
    // MARK: Variables
    private var viewModel = AuthVM()
    fileprivate var selectedPhoneCode = ""
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if Constants.accountRegistrationFor == .generalMemberAccountRegistration {
            companyView.isHidden = true
        } else {
            companyView.isHidden = false
        }
        
        bindViewModel()
        
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        // Set current locale's country as default
        let currentCountry = countryPickerView.getCountryByCode(Locale.current.region?.identifier ?? "US")
        if let country = currentCountry {
            selectedPhoneCode = country.phoneCode
        }
    }
    
    // MARK: IB Actions
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func next(_ sender: UIButton) {
        viewModel.validateFieldsValue(firstName: firstnameTF.text,
                                      lastName: lastnameTF.text,
                                      username: usernameTF.text,
                                      email: emailTF.text,
                                      phoneNumber: phoneNumberTF.text)
    }
    
    @IBAction func phoneCode(_ sender: UIButton) {
        countryPickerView.showCountriesList(from: self)
    }
    
    // MARK: Shared Methods
    private func bindViewModel() {
        viewModel.$fieldsValidationStatus.sink { [weak self] status in
            if status.isValid == true {
                var params = [String: Any]()
                params = [
                    "firstName": self?.firstnameTF.text ?? "",
                    "lastName": self?.lastnameTF.text ?? "",
                    "role": Constants.accountRegistrationFor.type,
                    //"company": "",
                    "username": self?.usernameTF.text ?? "",
                    "email": self?.emailTF.text ?? "",
                    "countryCode": self?.selectedPhoneCode ?? "",
                    "phone": self?.phoneNumberTF.text ?? "",
                    "deviceToken": UserDefaults.standard[.deviceToken] ?? "",
                    "deviceType": Constants.deviceType
                ]

                let storyboard = AppStoryboards.main.storyboardInstance
                guard let destVC = storyboard.instantiateViewController(withIdentifier: "CreateNewPasswordVC") as? CreateNewPasswordVC
                else { return }
                destVC.params = params
                destVC.userID = ""
                destVC.passwordSetFor = .verification
                SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
            }
            
            if let error = status.error {
                Toast.show(message: error)
            }
        }.store(in: &viewModel.cancellables)
    }
}

// MARK: Delegates and DataSources
extension BasicDetailsVC: CountryPickerViewDelegate, CountryPickerViewDataSource {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        let phoneCode = country.phoneCode
        selectedPhoneCode = phoneCode
    }
}
