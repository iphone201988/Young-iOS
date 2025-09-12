import UIKit

class AccountPackageVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var standardPlanView: UIView!
    @IBOutlet weak var premiumPlanView: UIView!
    @IBOutlet weak var standardPlanLbl: UILabel!
    @IBOutlet weak var freePlanLbl: UILabel!
    @IBOutlet weak var freeMonthPlanLbl: UILabel!
    @IBOutlet weak var freePlanStatusIcon: UIImageView!
    @IBOutlet weak var premiumPlanLbl: UILabel!
    @IBOutlet weak var premium20PlanLbl: UILabel!
    @IBOutlet weak var premium20MonthPlanLbl: UILabel!
    @IBOutlet weak var premiumPlanStatusIcon: UIImageView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerCellFromNib(cellID: SubscriptionCell.identifier)
            tableView.registerCellFromNib(cellID: EditOptionCell.identifier)
        }
    }
    
    // MARK: Variables
    var params = [String: Any]()
    private var isRequestInProgress: Bool = false
    fileprivate var selectedProduct = Products.standardPlan
    fileprivate var selectedSection = 0
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        freePlan()
    }
    
    // MARK: IB Actions
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func next(_ sender: UIButton) {
        let storyboard = AppStoryboards.main.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "TermsConditionsVC") as? TermsConditionsVC
        else { return }
        destVC.params = params
        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
        
        //buyPlan(by: selectedProduct)
    }
    
    @IBAction func accountPackage(_ sender: UIButton) {
        if sender.tag == 100 {
            freePlan()
            params["packageName"] = "standard"
            selectedProduct = Products.standardPlan
        } else {
            premiumPlan()
            params["packageName"] = "premium"
            selectedProduct = Products.premiumPlan
        }
    }
    
    // MARK: Shared Methods
    fileprivate func freePlan() {
        standardPlanView.backgroundColor = UIColor(named: "#B897FD")
        standardPlanView.layer.borderWidth = 1
        standardPlanView.layer.borderColor = UIColor(named: "#7D51F9")?.cgColor
        freePlanStatusIcon.image = UIImage(named: "selectedCircle")
        standardPlanLbl.textColor = .white
        freePlanLbl.textColor = .white
        freeMonthPlanLbl.textColor = .white
        
        premiumPlanView.backgroundColor = UIColor(named: "#F1F0F0")
        premiumPlanView.layer.borderWidth = 0
        premiumPlanView.layer.borderColor = UIColor.clear.cgColor
        premiumPlanStatusIcon.image = UIImage(named: "unselectedCircle")
        premiumPlanLbl.textColor = .black
        premium20PlanLbl.textColor = .black
        premium20MonthPlanLbl.textColor = .black
    }
    
    fileprivate func premiumPlan() {
        premiumPlanView.backgroundColor = UIColor(named: "#B897FD")
        premiumPlanView.layer.borderWidth = 1
        premiumPlanView.layer.borderColor = UIColor(named: "#7D51F9")?.cgColor
        premiumPlanStatusIcon.image = UIImage(named: "selectedCircle")
        premiumPlanLbl.textColor = .white
        premium20PlanLbl.textColor = .white
        premium20MonthPlanLbl.textColor = .white
        
        standardPlanView.backgroundColor = UIColor(named: "#F1F0F0")
        standardPlanView.layer.borderWidth = 0
        standardPlanView.layer.borderColor = UIColor.clear.cgColor
        freePlanStatusIcon.image = UIImage(named: "unselectedCircle")
        standardPlanLbl.textColor = .black
        freePlanLbl.textColor = .black
        freeMonthPlanLbl.textColor = .black
    }
    
    //    fileprivate func buyPlan(by productIdentifier: String) {
    //        IAPHandler.shared.purchaseMyProduct(val: productIdentifier)
    //        IAPHandler.shared.performActionOnPurchasedEvent() { [weak self] state in
    //            if state == .purchased {
    //                if self?.isRequestInProgress == false {
    //                    Task {
    //                        self?.isRequestInProgress = true
    //                        let params = ["original_transaction_id": IAPHandler.shared.originalTransactionID,
    //                                      "transaction_id": IAPHandler.shared.transactionID,
    //                                      "logged_user_id": UserDefaults.standard[.loggedUserDetails]?._id ?? "",
    //                                      "subscription_expiry": IAPHandler.shared.subscriptionExpiry,
    //                                      "product_id": IAPHandler.shared.purchasedProductID,
    //                                      "subscription_purchase_date": IAPHandler.shared.subscriptionPurchaseDate]
    //
    //                        // TODO: - Logs module - Pending -
    //                        let storyboard = AppStoryboards.main.storyboardInstance
    //                        guard let destVC = storyboard.instantiateViewController(withIdentifier: "TermsConditionsVC") as? TermsConditionsVC
    //                        else { return }
    //                        destVC.params = params
    //                        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
    //                    }
    //                }
    //            } else if state == .purchasing || state == .failed {
    //                let msg = state.message()
    //                Toast.show(message: "Upgraded to Premium: \(msg)")
    //            }
    //        }
    //    }
    
    @MainActor
    fileprivate func buyPlan(by productIdentifier: String) {
        // First set up the completion listener
        IAPHandler.shared.performActionOnPurchasedEvent() { [weak self] state in
            if state == .purchased {
                if self?.isRequestInProgress == false {
                    Task {
                        self?.isRequestInProgress = true
                        //                        let params: [String: Any] = [
                        //                            "original_transaction_id": IAPHandler.shared.originalTransactionID,
                        //                            "transaction_id": IAPHandler.shared.transactionID,
                        //                            "logged_user_id": UserDefaults.standard[.loggedUserDetails]?._id ?? "",
                        //                            "subscription_expiry": IAPHandler.shared.subscriptionExpiry,
                        //                            "product_id": IAPHandler.shared.purchasedProductID,
                        //                            "subscription_purchase_date": IAPHandler.shared.subscriptionPurchaseDate
                        //                        ]
                        
                        let storyboard = AppStoryboards.main.storyboardInstance
                        guard let destVC = storyboard.instantiateViewController(withIdentifier: "TermsConditionsVC") as? TermsConditionsVC else { return }
                        destVC.params = self?.params ?? [:]
                        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
                    }
                }
            } else if state == .purchasing || state == .failed {
                let msg = state.message()
                Toast.show(message: "Upgraded to Premium: \(msg)")
            }
        }
        
        // Trigger the purchase (must be async)
        Task {
            await IAPHandler.shared.purchase(productID: productIdentifier, presentingIn: self)
        }
    }
}

// MARK: Delegates and DataSources
extension AccountPackageVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        subscriptionPlans.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: SubscriptionCell.identifier) as! SubscriptionCell
        
        // Configure cell UI based on selection
        if selectedSection == section {
            cell.planView.backgroundColor = UIColor(named: "#B897FD")
            cell.planView.layer.borderWidth = 1
            cell.planView.layer.borderColor = UIColor(named: "#7D51F9")?.cgColor
            cell.selectedIcon.image = UIImage(named: "selectedCircle")
            cell.planNameLbl.textColor = .white
            cell.planPriceLbl.textColor = .white
            cell.planDurationLbl.textColor = .white
        } else {
            cell.planView.backgroundColor = UIColor(named: "#F1F0F0")
            cell.planView.layer.borderWidth = 0
            cell.planView.layer.borderColor = UIColor.clear.cgColor
            cell.selectedIcon.image = UIImage(named: "unselectedCircle")
            cell.planNameLbl.textColor = .black
            cell.planPriceLbl.textColor = .black
            cell.planDurationLbl.textColor = .black
        }
        
        // Set plan info
        let plan = subscriptionPlans[section]
        cell.planNameLbl.text = plan["name"] as? String
        cell.planPriceLbl.text = plan["price"] as? String
        cell.planDurationLbl.text = plan["duration"] as? String
        
        // Add tap gesture to header cell
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped(_:)))
        cell.contentView.tag = section
        cell.contentView.addGestureRecognizer(tapGesture)
        
        return cell.contentView
    }
    
    @objc func headerTapped(_ sender: UITapGestureRecognizer) {
        guard let section = sender.view?.tag else { return }
        selectedSection = section
        
        // Update params and selectedProduct based on the selected section
        if section == 0 {
            params["packageName"] = "standard"
            selectedProduct = Products.standardPlan
        } else if section == 1 {
            params["packageName"] = "premium"
            selectedProduct = Products.premiumPlan
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        85
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let plan = subscriptionPlans[section]
        let features = plan["features"] as? [String]
        return features?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditOptionCell.identifier, for: indexPath) as! EditOptionCell
        let plan = subscriptionPlans[indexPath.section]
        let features = plan["features"] as? [String]
        cell.nextArrowIcon.isHidden = true
        cell.customIcon.isHidden = true
        cell.lastLoginView.isHidden = true
        cell.lastLoginLbl.text = ""
        cell.optionLbl.text = features?[indexPath.row] ?? ""
        return cell
    }
}

var subscriptionPlans = [
    //    ["name": "Standard Plan",
    //     "price": "Free",
    //     "duration": "/month",
    //     "features": ["Create Shares", "Join Other Vaults"]],
    
    ["name": "Premium Plan",
     "price": "$20",
     "duration": "/month",
     "features": ["Create Own Vault", "Create and Join Live Streams"]]
]
