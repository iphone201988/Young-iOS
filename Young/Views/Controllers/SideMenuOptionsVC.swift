import UIKit

struct SideMenuOptionDetails {
    var menu: SideMenuOptions
    var subMenus: [String]
}

class SideMenuOptionsVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.sectionFooterHeight = 0
            tableView.estimatedSectionFooterHeight = 0
            tableView.registerCellFromNib(cellID: EditOptionCell.identifier)
        }
    }
    
    // MARK: Variables
    private var viewModel = SharedVM()
    private var options = [SideMenuOptionDetails]()
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        for section in SideMenuOptions.allCases {
            if section == .name {
                let details = SideMenuOptionDetails(menu: section,
                                                    subMenus: NameSubMenus.allCases.map{ $0.rawValue })
                options.append(details)
                
            } else if section == .exchange || section == .ecosystem {
                let details = SideMenuOptionDetails(menu: section,
                                                    subMenus: OtherSubMenus.allCases.map{ $0.rawValue })
                options.append(details)
                
            } else {
                let details = SideMenuOptionDetails(menu: section, subMenus: [])
                options.append(details)
            }
        }
        
        tableView.reloadData()
        bindViewModel()
    }
    
    // MARK: IB Actions
    @IBAction func about(_ sender: UIButton) {
        dismiss(animated: true) {
            SharedMethods.shared.pushToWithoutData(destVC: AboutVC.self, storyboard: .menus, isAnimated: true)
        }
    }
    
    @IBAction func policiesAndAgreement(_ sender: UIButton) {
        dismiss(animated: true) {
            SharedMethods.shared.pushToWithoutData(destVC: PoliciesAndAgreementVC.self, storyboard: .menus, isAnimated: true)
        }
    }
    
    @IBAction func media(_ sender: UIButton) {
        dismiss(animated: true) {
            SharedMethods.shared.pushToWithoutData(destVC: MediaVC.self, storyboard: .menus, isAnimated: true)
        }
    }
    
    @IBAction func advertise(_ sender: UIButton) {
        dismiss(animated: true) {
            SharedMethods.shared.pushToWithoutData(destVC: AdvertiseVC.self, storyboard: .menus, isAnimated: true)
        }
    }
    
    @IBAction func contactUs(_ sender: UIButton) {
        dismiss(animated: true) {
            SharedMethods.shared.pushToWithoutData(destVC: ContactUsVC.self, storyboard: .menus, isAnimated: true)
        }
    }
    
    @IBAction func logout(_ sender: UIButton) {
        PopupUtil.popupAlert(title: "Young",
                             message: "logout_msg".localized(),
                             actionTitles: ["Logout", "No"],
                             actions: [ { [weak self] _, _ in
            self?.viewModel.logout()
        }])
    }
    
    // MARK: Shared Methods
    private func bindViewModel() {
        viewModel.$requestResponse.sink { resp in
            if resp.isSuccess == true {
                if let vc = AppStoryboards.main.controller(LoginVC.self) {
                    SharedMethods.shared.navigateToRootVC(rootVC: vc)
                }
            }
            
            if let error = resp.error {
                Toast.show(message: error)
            }
        }.store(in: &viewModel.cancellables)
    }
}

// MARK: Delegates and DataSources

extension SideMenuOptionsVC: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        options.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options[section].subMenus.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        54
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EditOptionCell.identifier) as? EditOptionCell
        else { return nil }
        
        let menu = options[section].menu
        
        // Configure cell UI
        cell.nextArrowIcon.isHidden = (menu == .name || menu == .exchange || menu == .ecosystem)
        cell.customIcon.isHidden = true
        cell.lastLoginView.isHidden = true
        cell.optionLbl.text = (menu == .name) ? (UserDefaults.standard[.loggedUserDetails]?.name ?? "N/A") : menu.rawValue
        
        if cell.optionLbl.text == "Exchange" || cell.optionLbl.text == "Ecosystem" {
            cell.optionLbl.textColor = UIColor(named: "#00B050")
        } else {
            cell.optionLbl.textColor = .black
        }
        
        cell.mainViewLeading.constant = 0.0
        cell.optionBtn.isHidden = false
        cell.optionBtn.tag = section
        cell.optionBtn.addTarget(self, action: #selector(tappedSection(_ :)), for: .touchUpInside)
        //cell.mainOptionView.backgroundColor = UIColor(named: "#7030A0")
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditOptionCell.identifier, for: indexPath) as! EditOptionCell
        let subMenu = options[indexPath.section].subMenus[indexPath.row]
        cell.nextArrowIcon.isHidden = false
        cell.customIcon.isHidden = true
        cell.lastLoginView.isHidden = true
        cell.optionLbl.text = subMenu
        cell.mainViewLeading.constant = 12.0
        cell.optionBtn.isHidden = true
        //cell.mainOptionView.backgroundColor = UIColor(named: "#F8F8F8")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menu = options[indexPath.section].menu
        let subMenu = options[indexPath.section].subMenus[indexPath.row]
        switch menu {
        case .name :
            switch subMenu {
                
            case NameSubMenus.profile.rawValue:
                dismiss(animated: false) {
                    guard let rootViewController = getWindowRootViewController() else { return }
                    guard let topController = getTopViewController(from: rootViewController) else { return }
                    if topController.isKind(of: ProfileVC.self) {
                        return
                    }
                        let storyboard = AppStoryboards.menus.storyboardInstance
                        guard let destVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC
                        else { return }
                   
                        let userRole = Events.registrationFor(role: UserDefaults.standard[.loggedUserDetails]?.role ?? "") ?? .unspecified
                        destVC.event = userRole
                    topController.navigationController?.pushViewController(destVC, animated: true)
//                        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
                }
                
            case NameSubMenus.inbox.rawValue:
                dismiss(animated: false) {
                    SharedMethods.shared.pushToWithoutData(destVC: InboxVC.self, storyboard: .menus, isAnimated: true)
                }
                
            default: break
            }
            
        case .exchange:
            switch subMenu {
            case OtherSubMenus.member.rawValue:
                dismiss(animated: true) {
                    let storyboard = AppStoryboards.menus.storyboardInstance
                    guard let destVC = storyboard.instantiateViewController(withIdentifier: "ExchangeVC") as? ExchangeVC
                    else { return }
                    destVC.selectedCategories = [Categories.members]
                    SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true, selectedCategories: [Categories.members])
                }
                
            case OtherSubMenus.financialAdvisors.rawValue:
                dismiss(animated: true) {
                    let storyboard = AppStoryboards.menus.storyboardInstance
                    guard let destVC = storyboard.instantiateViewController(withIdentifier: "ExchangeVC") as? ExchangeVC
                    else { return }
                    destVC.selectedCategories = [Categories.advisors]
                    SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true, selectedCategories: [Categories.advisors])
                }
                
            case OtherSubMenus.startups.rawValue:
                dismiss(animated: true) {
                    let storyboard = AppStoryboards.menus.storyboardInstance
                    guard let destVC = storyboard.instantiateViewController(withIdentifier: "ExchangeVC") as? ExchangeVC
                    else { return }
                    destVC.selectedCategories = [Categories.startups]
                    SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true, selectedCategories: [Categories.startups])
                }
                
            case OtherSubMenus.smallBusiness.rawValue:
                dismiss(animated: true) {
                    let storyboard = AppStoryboards.menus.storyboardInstance
                    guard let destVC = storyboard.instantiateViewController(withIdentifier: "ExchangeVC") as? ExchangeVC
                    else { return }
                    destVC.selectedCategories = [Categories.smallBusinesses]
                    SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true, selectedCategories: [Categories.smallBusinesses])
                }
                
            case OtherSubMenus.investorVC.rawValue:
                dismiss(animated: true) {
                    let storyboard = AppStoryboards.menus.storyboardInstance
                    guard let destVC = storyboard.instantiateViewController(withIdentifier: "ExchangeVC") as? ExchangeVC
                    else { return }
                    destVC.selectedCategories = [Categories.investor]
                    SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true, selectedCategories: [Categories.investor])
                }
                
            default: break
            }
            
        case .ecosystem:
            switch subMenu {
            case OtherSubMenus.member.rawValue:
                dismiss(animated: true) {
                    let storyboard = AppStoryboards.menus.storyboardInstance
                    guard let destVC = storyboard.instantiateViewController(withIdentifier: "EcosystemVC") as? EcosystemVC
                    else { return }
                    destVC.selectedCategories = [Categories.members]
                    SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true, selectedCategories: [Categories.members])
                }
                
            case OtherSubMenus.financialAdvisors.rawValue:
                dismiss(animated: true) {
                    let storyboard = AppStoryboards.menus.storyboardInstance
                    guard let destVC = storyboard.instantiateViewController(withIdentifier: "EcosystemVC") as? EcosystemVC
                    else { return }
                    destVC.selectedCategories = [Categories.advisors]
                    SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true, selectedCategories: [Categories.advisors])
                }
                
            case OtherSubMenus.startups.rawValue:
                dismiss(animated: true) {
                    let storyboard = AppStoryboards.menus.storyboardInstance
                    guard let destVC = storyboard.instantiateViewController(withIdentifier: "EcosystemVC") as? EcosystemVC
                    else { return }
                    destVC.selectedCategories = [Categories.startups]
                    SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true, selectedCategories: [Categories.startups])
                }
                
            case OtherSubMenus.smallBusiness.rawValue:
                dismiss(animated: true) {
                    let storyboard = AppStoryboards.menus.storyboardInstance
                    guard let destVC = storyboard.instantiateViewController(withIdentifier: "EcosystemVC") as? EcosystemVC
                    else { return }
                    destVC.selectedCategories = [Categories.smallBusinesses]
                    SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true, selectedCategories: [Categories.smallBusinesses])
                }
                
            case OtherSubMenus.investorVC.rawValue:
                dismiss(animated: true) {
                    let storyboard = AppStoryboards.menus.storyboardInstance
                    guard let destVC = storyboard.instantiateViewController(withIdentifier: "EcosystemVC") as? EcosystemVC
                    else { return }
                    destVC.selectedCategories = [Categories.investor]
                    SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true, selectedCategories: [Categories.investor])
                }
                
            default: break
            }
            
        default: break
        }
    }
    
    @objc func tappedSection(_ sender: UIButton) {
        let menu = options[sender.tag].menu
        switch menu {
        case .home:
            dismiss(animated: false) {
                guard let rootViewController = getWindowRootViewController() else { return }
                guard let topController = getTopViewController(from: rootViewController) else { return }
                topController.navigationController?.popToRootViewController(animated: true)
            }
            
        default: break
        }
    }
}
