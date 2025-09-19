import UIKit
import SideMenu

class FinancialInformationVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var interfaceTitleLbl: UILabel!
    @IBOutlet weak var crdNumberView: UIView!
    @IBOutlet weak var certificationsView: UIView!
    @IBOutlet weak var yearsInIndustryView: UIView!
    @IBOutlet weak var yearsEmployedView: UIView!
    @IBOutlet weak var salaryRangeView: UIView!
    @IBOutlet weak var financialExpView: UIView!
    @IBOutlet weak var riskToleranceView: UIView!
    @IBOutlet weak var investmentAccountsView: UIView!
    @IBOutlet weak var retirementView: UIView!
    @IBOutlet weak var investmentRealEstateView: UIView!
    @IBOutlet weak var goalsView: UIView!
    @IBOutlet weak var servicesProvidedOrTopicsTitleLbl: UILabel!
    @IBOutlet weak var stageBusinessView: UIView!
    @IBOutlet weak var fundsRaisedView: UIView!
    @IBOutlet weak var fundsRaisingView: UIView!
    @IBOutlet weak var businessRevenueView: UIView!
    @IBOutlet weak var providedOrTopicsCollectionView: UIView!
    @IBOutlet weak var occupationView: UIView!
    @IBOutlet weak var investorsView: UIView!
    
    @IBOutlet weak var licensesOrCertificationTF: UITextField!
    @IBOutlet weak var yearsInFinancialIndustryTF: UITextField!
    @IBOutlet weak var yearsEmloyedTF: UITextField!
    @IBOutlet weak var salaryRangeTF: UITextField!
    @IBOutlet weak var financialExpTF: UITextField!
    @IBOutlet weak var riskToleranceTF: UITextField!
    @IBOutlet weak var topicsOfInterestTF: UITextField!
    
    @IBOutlet weak var stageOfBusinessTF: UITextField!
    @IBOutlet weak var fundsRaisedTF: UITextField!
    @IBOutlet weak var fundsRaisingTF: UITextField!
    @IBOutlet weak var businessRevenueTF: UITextField!
    
    @IBOutlet weak var licensesOrCertificationBtn: UIButton!
    @IBOutlet weak var yearsInFinancialIndustryBtn: UIButton!
    @IBOutlet weak var yearsEmloyedBtn: UIButton!
    @IBOutlet weak var salaryRangeBtn: UIButton!
    @IBOutlet weak var financialExpBtn: UIButton!
    @IBOutlet weak var riskToleranceBtn: UIButton!
    @IBOutlet weak var topicsOfInterestBtn: UIButton!
    
    @IBOutlet weak var stageOfBusinessBtn: UIButton!
    @IBOutlet weak var fundsRaisedBtn: UIButton!
    @IBOutlet weak var fundsRaisingBtn: UIButton!
    @IBOutlet weak var businessRevenueBtn: UIButton!
    
    @IBOutlet weak var crdNumberTF: UITextField!
    @IBOutlet weak var occupationTF: UITextField!
    @IBOutlet weak var goalTF: UITextField!
    
    @IBOutlet weak var investmentAccountsYesIcon: UIImageView!
    @IBOutlet weak var investmentAccountsNoIcon: UIImageView!
    @IBOutlet weak var investmentAccountsYesBtn: UIButton!
    @IBOutlet weak var investmentAccountsNoBtn: UIButton!
    
    @IBOutlet weak var retirementYesIcon: UIImageView!
    @IBOutlet weak var retirementNoIcon: UIImageView!
    @IBOutlet weak var retirementYesBtn: UIButton!
    @IBOutlet weak var retirementNoBtn: UIButton!
    
    @IBOutlet weak var investmentRealEstateYesIcon: UIImageView!
    @IBOutlet weak var investmentRealEstateNoIcon: UIImageView!
    @IBOutlet weak var investmentRealEstateYesBtn: UIButton!
    @IBOutlet weak var investmentRealEstateNoBtn: UIButton!
    
    @IBOutlet weak var investorsYesIcon: UIImageView!
    @IBOutlet weak var investorsNoIcon: UIImageView!
    @IBOutlet weak var investorsYesBtn: UIButton!
    @IBOutlet weak var investorsNoBtn: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.registerCellFromNib(cellID: SelectedInterestCell.identifier)
        }
    }
    
    // MARK: Variables
    var selectedInterests = [String]()
    var servicesProvided = [String]()
    var event: Events = .unspecified
    fileprivate var options = [String]()
    fileprivate var viewModel = SharedVM()
    fileprivate var userDetails: UserDetails?
    fileprivate var isInvestmentAccounts: Bool = false
    fileprivate var isRetirement: Bool = false
    fileprivate var isInvestmentRealEstate: Bool = false
    fileprivate var isInvestors: Bool = false
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialViewSetup()
        
        PickerManager.shared.configurePicker(for: licensesOrCertificationTF,
                                             with: Constants.licensesOrCertification,
                                             iconButton: licensesOrCertificationBtn)
        
        PickerManager.shared.configurePicker(for: yearsInFinancialIndustryTF,
                                             with: Constants.yearsInFinancialIndustry,
                                             iconButton: yearsInFinancialIndustryBtn)
        
        PickerManager.shared.configurePicker(for: yearsEmloyedTF,
                                             with: Constants.yearsEmployed,
                                             iconButton: yearsEmloyedBtn)
        
        PickerManager.shared.configurePicker(for: salaryRangeTF,
                                             with: Constants.salaryRange,
                                             iconButton: salaryRangeBtn)
        
        PickerManager.shared.configurePicker(for: financialExpTF,
                                             with: Constants.financialExperience,
                                             iconButton: financialExpBtn)
        
        PickerManager.shared.configurePicker(for: riskToleranceTF,
                                             with: Constants.riskTolerance,
                                             iconButton: riskToleranceBtn)
        
        PickerManager.shared.configurePicker(for: stageOfBusinessTF,
                                             with: Constants.stageOfBusiness,
                                             iconButton: stageOfBusinessBtn)
        
        PickerManager.shared.configurePicker(for: fundsRaisedTF,
                                             with: Constants.fundsRaised,
                                             iconButton: fundsRaisedBtn)
        
        PickerManager.shared.configurePicker(for: fundsRaisingTF,
                                             with: Constants.fundsRaising,
                                             iconButton: fundsRaisingBtn)
        
        PickerManager.shared.configurePicker(for: businessRevenueTF,
                                             with: Constants.businessRevenue,
                                             iconButton: businessRevenueBtn)
        
        bindViewModel()
        
        occupationTF.autocapitalizationType = .words
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
    
    @IBAction func saveChanges(_ sender: UIButton) {
        var params = [
            "crdNumber": crdNumberTF.text ?? "",
            "certificates": licensesOrCertificationTF.text ?? "",
            "occupation": occupationTF.text ?? "",
            "yearsInFinancialIndustry": yearsInFinancialIndustryTF.text ?? "",
            "yearsEmployed": yearsEmloyedTF.text ?? "",
            "salaryRange": salaryRangeTF.text ?? "",
            "riskTolerance": riskToleranceTF.text ?? "",
            "topicsOfInterest": selectedInterests.joined(separator: ","),
            "goals": goalTF.text ?? "",
            "investors": isInvestors,
            "investmentAccounts": isInvestmentAccounts,
            "retirement": isRetirement,
            "investmentRealEstate": isInvestmentRealEstate,
            "financialExperience": financialExpTF.text ?? ""
        ] as [String : Any]
        
        params["stageOfBusiness"] = stageOfBusinessTF.text ?? ""
        params["fundsRaised"] = fundsRaisedTF.text ?? ""
        params["fundsRaising"] = fundsRaisingTF.text ?? ""
        params["businessRevenue"] = businessRevenueTF.text ?? ""
        params["servicesProvided"] = servicesProvided.joined(separator: ",")
        
        viewModel.updateUser(params: params)
    }
    
    @IBAction func investmentAccountsYes(_ sender: UIButton) {
        investmentAccountsYesIcon.image = UIImage(named: "selectedBox")
        investmentAccountsNoIcon.image = UIImage(named: "unselectedBox")
        isInvestmentAccounts = true
    }
    
    @IBAction func investmentAccountsNo(_ sender: UIButton) {
        investmentAccountsYesIcon.image = UIImage(named: "unselectedBox")
        investmentAccountsNoIcon.image = UIImage(named: "selectedBox")
        isInvestmentAccounts = false
    }
    
    @IBAction func retirementYes(_ sender: UIButton) {
        retirementYesIcon.image = UIImage(named: "selectedBox")
        retirementNoIcon.image = UIImage(named: "unselectedBox")
        isRetirement = true
    }
    
    @IBAction func retirementNo(_ sender: UIButton) {
        retirementYesIcon.image = UIImage(named: "unselectedBox")
        retirementNoIcon.image = UIImage(named: "selectedBox")
        isRetirement = false
    }
    
    @IBAction func investmentRealEstateYes(_ sender: UIButton) {
        investmentRealEstateYesIcon.image = UIImage(named: "selectedBox")
        investmentRealEstateNoIcon.image = UIImage(named: "unselectedBox")
        isInvestmentRealEstate = true
    }
    
    @IBAction func investmentRealEstateNo(_ sender: UIButton) {
        investmentRealEstateYesIcon.image = UIImage(named: "unselectedBox")
        investmentRealEstateNoIcon.image = UIImage(named: "selectedBox")
        isInvestmentRealEstate = false
    }
    
    @IBAction func investorsYes(_ sender: UIButton) {
        investorsYesIcon.image = UIImage(named: "selectedBox")
        investorsNoIcon.image = UIImage(named: "unselectedBox")
        isInvestors = true
    }
    
    @IBAction func investorsNo(_ sender: UIButton) {
        investorsYesIcon.image = UIImage(named: "unselectedBox")
        investorsNoIcon.image = UIImage(named: "selectedBox")
        isInvestors = false
    }
    
    // MARK: Shared Methods
    fileprivate func initialViewSetup() {
        switch event {
            
        case .generalMemberAccountRegistration:
            interfaceTitleLbl.text = "Financial Information"
            crdNumberView.isHidden = true
            certificationsView.isHidden = true
            yearsInIndustryView.isHidden = true
            yearsEmployedView.isHidden = false
            salaryRangeView.isHidden = false
            financialExpView.isHidden = false
            riskToleranceView.isHidden = false
            investmentAccountsView.isHidden = false
            retirementView.isHidden = false
            investmentRealEstateView.isHidden = false
            goalsView.isHidden = false
            servicesProvidedOrTopicsTitleLbl.text = "Topics of Interest*"
            
            PickerManager.shared.configurePicker(for: topicsOfInterestTF,
                                                 with: Constants.topicsOfInterest,
                                                 iconButton: topicsOfInterestBtn) { [weak self] selectedValue in
                if let options = self?.selectedInterests, !options.contains(selectedValue) {
                    self?.selectedInterests.append(selectedValue)
                    self?.options = self?.selectedInterests ?? []
                    self?.collectionView.reloadData()
                }
            }
            
        case .financialAdvisorAccountRegistration:
            interfaceTitleLbl.text = "Professional Information"
            crdNumberView.isHidden = false
            certificationsView.isHidden = false
            yearsInIndustryView.isHidden = false
            yearsEmployedView.isHidden = true
            salaryRangeView.isHidden = true
            financialExpView.isHidden = true
            riskToleranceView.isHidden = true
            investmentAccountsView.isHidden = true
            retirementView.isHidden = true
            investmentRealEstateView.isHidden = true
            goalsView.isHidden = true
            investorsView.isHidden = true
            servicesProvidedOrTopicsTitleLbl.text = "Services Provided*"
            options = servicesProvided
            
            PickerManager.shared.configurePicker(for: topicsOfInterestTF,
                                                 with: Constants.servicesOffered,
                                                 iconButton: topicsOfInterestBtn) { [weak self] selectedValue in
                if let options = self?.servicesProvided, !options.contains(selectedValue) {
                    self?.servicesProvided.append(selectedValue)
                    self?.options = self?.servicesProvided ?? []
                    self?.collectionView.reloadData()
                }
            }
            
        case .smallBusinessAccountRegistration, .investorVCAccountRegistration, .insurance, .financialFirmAccountRegistration:
            interfaceTitleLbl.text = "Business & Financial Information"
            crdNumberView.isHidden = true
            certificationsView.isHidden = true
            yearsInIndustryView.isHidden = true
            yearsEmployedView.isHidden = true
            salaryRangeView.isHidden = true
            financialExpView.isHidden = true
            riskToleranceView.isHidden = true
            investmentAccountsView.isHidden = true
            retirementView.isHidden = true
            investmentRealEstateView.isHidden = true
            goalsView.isHidden = true
            servicesProvidedOrTopicsTitleLbl.text = ""
            options = servicesProvided
            investorsView.isHidden = false
            businessRevenueView.isHidden = false
            providedOrTopicsCollectionView.isHidden = true
            occupationView.isHidden = true
            
        case .startupAccountRegistration:
            yearsEmployedView.isHidden = true
            salaryRangeView.isHidden = true
            financialExpView.isHidden = true
            riskToleranceView.isHidden = true
            investmentAccountsView.isHidden = true
            retirementView.isHidden = true
            investmentRealEstateView.isHidden = true
            goalsView.isHidden = true
            servicesProvidedOrTopicsTitleLbl.text = "Services Provided*"
            options = servicesProvided
            interfaceTitleLbl.text = "Business & Financial Information"
            stageBusinessView.isHidden = false
            fundsRaisedView.isHidden = false
            fundsRaisingView.isHidden = false
            businessRevenueView.isHidden = false
            crdNumberView.isHidden = true
            certificationsView.isHidden = true
            yearsInIndustryView.isHidden = true
            providedOrTopicsCollectionView.isHidden = true
            occupationView.isHidden = true
            investorsView.isHidden = true
            
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
        crdNumberTF.text = userDetails?.crdNumber ?? ""
        occupationTF.text = userDetails?.occupation ?? ""
        licensesOrCertificationTF.text = userDetails?.certificates ?? ""
        yearsInFinancialIndustryTF.text = userDetails?.yearsInFinancialIndustry ?? ""
        yearsEmloyedTF.text = userDetails?.yearsEmployed ?? ""
        salaryRangeTF.text = userDetails?.salaryRange ?? ""
        financialExpTF.text = userDetails?.financialExperience ?? ""
        riskToleranceTF.text = userDetails?.riskTolerance ?? ""
        goalTF.text = userDetails?.goals ?? ""
        financialExpTF.text = userDetails?.financialExperience ?? ""
        stageOfBusinessTF.text = userDetails?.stageOfBusiness ?? ""
        fundsRaisedTF.text = userDetails?.fundsRaised ?? ""
        fundsRaisingTF.text = userDetails?.fundsRaising ?? ""
        businessRevenueTF.text = userDetails?.businessRevenue ?? ""
        
        if event == .generalMemberAccountRegistration {
            selectedInterests = userDetails?.topicsOfInterest ?? []
            options = selectedInterests
            collectionView.reloadData()
        }
        
        if event == .financialAdvisorAccountRegistration {
            let selectedServicesProvided = userDetails?.servicesProvided ?? ""
            servicesProvided = selectedServicesProvided.isEmpty ? [] : selectedServicesProvided.components(separatedBy: ",")
            options = servicesProvided
            collectionView.reloadData()
        }
        
        let investmentAccounts = userDetails?.investmentAccounts ?? false
        isInvestmentAccounts = investmentAccounts
        if investmentAccounts {
            investmentAccountsYesBtn.sendActions(for: .touchUpInside)
        } else {
            investmentAccountsNoBtn.sendActions(for: .touchUpInside)
        }
        
        let investorsStatus = userDetails?.investors ?? false
        isInvestors = investorsStatus
        if investorsStatus {
            investorsYesBtn.sendActions(for: .touchUpInside)
        } else {
            investorsNoBtn.sendActions(for: .touchUpInside)
        }
        
        let retirementStatus = userDetails?.retirement ?? false
        isRetirement = retirementStatus
        if retirementStatus {
            retirementYesBtn.sendActions(for: .touchUpInside)
        } else {
            retirementNoBtn.sendActions(for: .touchUpInside)
        }
        
        let investmentRealEstateStatus = userDetails?.investmentRealEstate ?? false
        isInvestmentRealEstate = investmentRealEstateStatus
        if investmentRealEstateStatus {
            investmentRealEstateYesBtn.sendActions(for: .touchUpInside)
        } else {
            investmentRealEstateNoBtn.sendActions(for: .touchUpInside)
        }
    }
}

// MARK: Delegates and DataSources

extension FinancialInformationVC: UICollectionViewDataSource,
                                  UICollectionViewDelegate,
                                  UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(frame: CGRect.zero)
        label.text = options[indexPath.item]
        label.sizeToFit()
        let extraComponentsOccupiedSpace = 80.0
        let width = label.frame.width + extraComponentsOccupiedSpace
        return CGSize(width: width, height: 35)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedInterestCell.identifier, for: indexPath) as! SelectedInterestCell
        cell.titleLbl.text = options[indexPath.item]
        
        if event == .generalMemberAccountRegistration {
            cell.removeBtn.tag = indexPath.item
            cell.removeBtn.addTarget(self, action: #selector(removeTopicOfInterest(_ :)), for: .touchUpInside)
        }
        
        if event == .financialAdvisorAccountRegistration {
            cell.removeBtn.tag = indexPath.item
            cell.removeBtn.addTarget(self, action: #selector(removeServicesProvided(_ :)), for: .touchUpInside)
        }
        
        return cell
    }
    
    @objc func removeServicesProvided(_ sender: UIButton) {
        servicesProvided.remove(at: sender.tag)
        options = servicesProvided
        collectionView.reloadData()
    }
    
    @objc func removeTopicOfInterest(_ sender: UIButton) {
        selectedInterests.remove(at: sender.tag)
        options = selectedInterests
        collectionView.reloadData()
    }
}
