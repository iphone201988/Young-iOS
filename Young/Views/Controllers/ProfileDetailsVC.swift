import UIKit
import SideMenu

class ProfileDetailsVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var raceDropdownBtn: UIButton!
    @IBOutlet weak var memberUsernameView: UIView!
    @IBOutlet weak var companyView: UIView!
    @IBOutlet weak var phoneNumberView: UIView!
    @IBOutlet weak var websiteView: UIView!
    @IBOutlet weak var educationLevelView: UIView!
    @IBOutlet weak var maritalStatusView: UIView!
    @IBOutlet weak var addPicBtn: UIButton!
    @IBOutlet weak var industryView: UIView!
    @IBOutlet weak var launchDateView: UIView!
    @IBOutlet weak var launchDateTitleLbl: UILabel!
    
    @IBOutlet weak var raceTF: UITextField!
    @IBOutlet weak var genderTF: UITextField!
    @IBOutlet weak var ageRangeTF: UITextField!
    @IBOutlet weak var maritalStatusTF: UITextField!
    @IBOutlet weak var educationLevelTF: UITextField!
    @IBOutlet weak var industryTF: UITextField!
    
    @IBOutlet weak var raceBtn: UIButton!
    @IBOutlet weak var genderBtn: UIButton!
    @IBOutlet weak var ageRangeBtn: UIButton!
    @IBOutlet weak var maritalStatusBtn: UIButton!
    @IBOutlet weak var educationLevelBtn: UIButton!
    @IBOutlet weak var industryBtn: UIButton!
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var firstnameTF: UITextField!
    @IBOutlet weak var lastnameTF: UITextField!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var companyTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var websiteTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var stateTF: UITextField!
    @IBOutlet weak var launchDateLbl: UITextField!
    
    // MARK: Variables
    private var viewModel = SharedVM()
    var event: Events = .unspecified
    fileprivate var userDetails: UserDetails?
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialViewSetup()
        
        PickerManager.shared.configurePicker(for: raceTF,
                                             with: Constants.race,
                                             iconButton: raceBtn)
        
        PickerManager.shared.configurePicker(for: genderTF,
                                             with: Constants.genders,
                                             iconButton: genderBtn)
        
        PickerManager.shared.configurePicker(for: ageRangeTF,
                                             with: Constants.ageRanges,
                                             iconButton: ageRangeBtn)
        
        PickerManager.shared.configurePicker(for: maritalStatusTF,
                                             with: Constants.martialStatus,
                                             iconButton: maritalStatusBtn)
        
        PickerManager.shared.configurePicker(for: educationLevelTF,
                                             with: Constants.educationLevel,
                                             iconButton: educationLevelBtn)
        
        PickerManager.shared.configurePicker(for: industryTF,
                                             with: Constants.startupAndSmallBusinessIndustry,
                                             iconButton: industryBtn)
        
        bindViewModel()
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
    
    @IBAction func browseProfilePic(_ sender: UIButton) {
        MediaPicker.shared.browsedImage() { [weak self] image, _ in
            self?.profilePic.image = image
        }
    }
    
    @IBAction func updateProfile(_ sender: UIButton) {
        var params = [
            "firstName": firstnameTF.text ?? "",
            "lastName": lastnameTF.text ?? "",
            "company": companyTF.text ?? "",
            "website": websiteTF.text ?? "",
            "city": cityTF.text ?? "",
            "state": stateTF.text ?? "",
            "race": raceTF.text ?? "",
            "gender": genderTF.text ?? "",
            "ageRange": ageRangeTF.text ?? "",
            "maritalStatus": maritalStatusTF.text ?? "",
        ]
        
        params["yearFounded"] = launchDateLbl.text ?? ""
        params["educationLevel"] = educationLevelTF.text ?? ""
        
        let data = profilePic.image?.jpegData(compressionQuality: 0.1)
        viewModel.updateUser(params: params, profileImageData: data)
    }
    
    @IBAction func raceDropdown(_ sender: UIButton) { }
    
    // MARK: Shared Methods
    fileprivate func initialViewSetup() {
        switch event {
            
        case .generalMemberAccountRegistration:
            companyView.isHidden = true
            phoneNumberView.isHidden = true
            websiteView.isHidden = true
            educationLevelView.isHidden = true
            memberUsernameView.isHidden = false
            maritalStatusView.isHidden = false
            
        case .financialAdvisorAccountRegistration:
            companyView.isHidden = false
            phoneNumberView.isHidden = false
            websiteView.isHidden = false
            educationLevelView.isHidden = false
            memberUsernameView.isHidden = true
            maritalStatusView.isHidden = true
            
        case .smallBusinessAccountRegistration:
            companyView.isHidden = false
            phoneNumberView.isHidden = false
            websiteView.isHidden = false
            memberUsernameView.isHidden = true
            maritalStatusView.isHidden = true
            industryView.isHidden = false
            launchDateView.isHidden = false
            educationLevelView.isHidden = true
            
        case .startupAccountRegistration:
            companyView.isHidden = false
            phoneNumberView.isHidden = false
            websiteView.isHidden = false
            memberUsernameView.isHidden = true
            maritalStatusView.isHidden = true
            industryView.isHidden = false
            launchDateView.isHidden = false
            educationLevelView.isHidden = true
            
        case .investorVCAccountRegistration, .insurance, .financialFirmAccountRegistration:
            companyView.isHidden = false
            phoneNumberView.isHidden = false
            websiteView.isHidden = false
            memberUsernameView.isHidden = true
            maritalStatusView.isHidden = true
            industryView.isHidden = true
            launchDateView.isHidden = false
            educationLevelView.isHidden = true
            launchDateTitleLbl.text = "Year Founded*"
            
        default: break
        }
        
        viewModel.getUserProfile()
    }
    
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
        SharedMethods.shared.setImage(imageView: profilePic, url: userDetails?.profileImage ?? "")
        firstnameTF.text = userDetails?.firstName ?? ""
        lastnameTF.text = userDetails?.lastName ?? ""
        usernameTF.text = userDetails?.username ?? ""
        companyTF.text = userDetails?.company ?? ""
        emailTF.text = userDetails?.email ?? ""
        websiteTF.text = userDetails?.website ?? ""
        phoneNumberTF.text = userDetails?.phone ?? ""
        cityTF.text = userDetails?.city ?? ""
        stateTF.text = userDetails?.state ?? ""
        raceTF.text = userDetails?.race ?? ""
        genderTF.text = userDetails?.gender ?? ""
        ageRangeTF.text = userDetails?.age ?? ""
        maritalStatusTF.text = userDetails?.maritalStatus ?? ""
        launchDateLbl.text = userDetails?.yearFounded ?? ""
        educationLevelTF.text = userDetails?.educationLevel ?? ""
    }
    
    // MARK: Delegates and DataSources
}
