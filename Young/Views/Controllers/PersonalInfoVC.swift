import UIKit

class PersonalInfoVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var ageView: UIView!
    @IBOutlet weak var genderView: UIView!
    @IBOutlet weak var martialStatusView: UIView!
    @IBOutlet weak var childrenView: UIView!
    @IBOutlet weak var homeOwnershipView: UIView!
    @IBOutlet weak var productsServicesOfferedView: UIView!
    @IBOutlet weak var industryInterestedInView: UIView!
    @IBOutlet weak var expertiseView: UIView!
    @IBOutlet weak var industryView: UIView!
    @IBOutlet weak var interestedView: UIView!
    
    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var genderTF: UITextField!
    @IBOutlet weak var martialStatusTF: UITextField!
    @IBOutlet weak var childernTF: UITextField!
    @IBOutlet weak var homeOwnershipTF: UITextField!
    @IBOutlet weak var productsServicesOfferedTF: UITextField!
    @IBOutlet weak var industryInterestedInTF: UITextField!
    @IBOutlet weak var expertiseTF: UITextField!
    @IBOutlet weak var industryTF: UITextField!
    @IBOutlet weak var interestedTF: UITextField!
    
    @IBOutlet weak var ageIcon: UIImageView!
    @IBOutlet weak var genderIcon: UIImageView!
    @IBOutlet weak var martialStatusIcon: UIImageView!
    @IBOutlet weak var childernIcon: UIImageView!
    @IBOutlet weak var homeOwnershipIcon: UIImageView!
    @IBOutlet weak var productsServicesOfferedIcon: UIImageView!
    
    @IBOutlet weak var expertiseIcon: UIImageView!
    @IBOutlet weak var industryIcon: UIImageView!
    @IBOutlet weak var interestedIcon: UIImageView!
    
    // MARK: Variables
    var params: [String: Any] = [:]
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        PickerManager.shared.configurePicker(for: ageTF,
                                             with: Constants.ageRanges,
                                             iconView: ageIcon)
        
        PickerManager.shared.configurePicker(for: genderTF,
                                             with: Constants.genders,
                                             iconView: genderIcon)
        
        PickerManager.shared.configurePicker(for: martialStatusTF,
                                             with: Constants.martialStatus,
                                             iconView: martialStatusIcon)
        
        PickerManager.shared.configurePicker(for: childernTF,
                                             with: Constants.children,
                                             iconView: childernIcon)
        
        PickerManager.shared.configurePicker(for: homeOwnershipTF,
                                             with: Constants.homeOwnershipStatus,
                                             iconView: homeOwnershipIcon)
        
        if Constants.accountRegistrationFor == .insurance {
            PickerManager.shared.configurePicker(for: productsServicesOfferedTF,
                                                 with: Constants.insuranceProductsServicesOffered,
                                                 iconView: productsServicesOfferedIcon)
        } else {
            PickerManager.shared.configurePicker(for: productsServicesOfferedTF,
                                                 with: Constants.financialAdvisorProductsServicesOffered,
                                                 iconView: productsServicesOfferedIcon)
        }
        
        if Constants.accountRegistrationFor == .investorVCAccountRegistration {
            PickerManager.shared.configurePicker(for: expertiseTF,
                                                 with: Constants.investorVCAreasOfExpertise,
                                                 iconView: expertiseIcon)
            
        } else if Constants.accountRegistrationFor == .insurance {
            PickerManager.shared.configurePicker(for: expertiseTF,
                                                 with: Constants.insuranceAreasOfExpertise,
                                                 iconView: expertiseIcon)
            
        } else {
            PickerManager.shared.configurePicker(for: expertiseTF,
                                                 with: Constants.financialAdvisorAreasOfExpertise,
                                                 iconView: expertiseIcon)
        }
        
        PickerManager.shared.configurePicker(for: industryTF,
                                             with: Constants.startupAndSmallBusinessIndustry,
                                             iconView: industryIcon)
        
        PickerManager.shared.configurePicker(for: interestedTF,
                                             with: Constants.startupAndSmallBusinessInterestedIn,
                                             iconView: interestedIcon)
        
        PickerManager.shared.configurePicker(for: industryInterestedInTF,
                                             with: Constants.investorVCIndustryInterestedIn,
                                             iconView: interestedIcon)
        
        if Constants.accountRegistrationFor == .generalMemberAccountRegistration {
            ageView.isHidden = false
            genderView.isHidden = false
            martialStatusView.isHidden = false
            childrenView.isHidden = false
            homeOwnershipView.isHidden = false
            productsServicesOfferedView.isHidden = true
            industryInterestedInView.isHidden = true
            expertiseView.isHidden = true
            industryView.isHidden = true
            interestedView.isHidden = true
        } else if Constants.accountRegistrationFor == .financialAdvisorAccountRegistration ||
                    Constants.accountRegistrationFor == .financialFirmAccountRegistration ||
                    Constants.accountRegistrationFor == .insurance {
            ageView.isHidden = true
            genderView.isHidden = true
            martialStatusView.isHidden = true
            childrenView.isHidden = true
            homeOwnershipView.isHidden = true
            productsServicesOfferedView.isHidden = false
            industryInterestedInView.isHidden = true
            expertiseView.isHidden = false
            industryView.isHidden = true
            interestedView.isHidden = true
        } else if Constants.accountRegistrationFor == .smallBusinessAccountRegistration ||
                    Constants.accountRegistrationFor == .startupAccountRegistration  {
            ageView.isHidden = true
            genderView.isHidden = true
            martialStatusView.isHidden = true
            childrenView.isHidden = true
            homeOwnershipView.isHidden = true
            productsServicesOfferedView.isHidden = true
            industryInterestedInView.isHidden = true
            expertiseView.isHidden = true
            industryView.isHidden = false
            interestedView.isHidden = false
        }  else if Constants.accountRegistrationFor == .investorVCAccountRegistration  {
            ageView.isHidden = true
            genderView.isHidden = true
            martialStatusView.isHidden = true
            childrenView.isHidden = true
            homeOwnershipView.isHidden = true
            productsServicesOfferedView.isHidden = true
            industryInterestedInView.isHidden = false
            expertiseView.isHidden = false
            industryView.isHidden = true
            interestedView.isHidden = true
        }
    }
    
    // MARK: IB Actions
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func next(_ sender: UIButton) {
        params["age"] = ageTF.text ?? ""
        params["gender"] = genderTF.text ?? ""
        params["maritalStatus"] = martialStatusTF.text ?? ""
        params["children"] = childernTF.text ?? ""
        params["homeOwnerShip"] = homeOwnershipTF.text ?? ""
        params["productsOffered"] = productsServicesOfferedTF.text ?? ""
        params["areaOfExpertise"] = expertiseTF.text ?? ""
        params["industry"] = industryTF.text ?? ""
        params["interestedIn"] = interestedTF.text ?? ""

        if Constants.accountRegistrationFor == .generalMemberAccountRegistration {
            let storyboard = AppStoryboards.main.storyboardInstance
            guard let destVC = storyboard.instantiateViewController(withIdentifier: "InterestsVC") as? InterestsVC
            else { return }
            destVC.params = params
            SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
        } else {
            let storyboard = AppStoryboards.main.storyboardInstance
            guard let destVC = storyboard.instantiateViewController(withIdentifier: "AccountPackageVC") as? AccountPackageVC
            else { return }
            destVC.params = params
            SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
        }
    }
    
    // MARK: Shared Methods
    
    // MARK: Delegates and DataSources
}
