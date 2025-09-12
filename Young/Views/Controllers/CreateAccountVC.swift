import UIKit

class CreateAccountVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var tblView: UITableView! {
        didSet {
            tblView.registerCellFromNib(cellID: OptionCell.identifier)
        }
    }
    
    // MARK: Variables
    fileprivate var accountType = ["General Member",
                                   "Financial Advisor",
                                   "Financial Firm",
                                   "Small Business",
                                   "Startup",
                                   "Investor/ VC"]
    
    fileprivate var selectedAccountType: Events = .generalMemberAccountRegistration
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Constants.accountRegistrationFor = .generalMemberAccountRegistration
    }
    
    // MARK: IB Actions
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func next(_ sender: UIButton) {
        SharedMethods.shared.pushToWithoutData(destVC: BasicDetailsVC.self)
    }
    
    @IBAction func login(_ sender: UIButton) {
        SharedMethods.shared.pushToWithoutData(destVC: LoginVC.self)
    }
    
    // MARK: Shared Methods
}

// MARK: Delegates and DataSources

extension CreateAccountVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        accountType.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OptionCell.identifier, for: indexPath) as! OptionCell
        let type = accountType[indexPath.row]
        cell.titleLbl.text = type
        let event = Events(rawValue: type) ?? .generalMemberAccountRegistration
        if selectedAccountType == event {
            cell.selectedOption()
        } else {
            cell.unselectedOption()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = accountType[indexPath.row]
        let event = Events(rawValue: type) ?? .generalMemberAccountRegistration
        Constants.accountRegistrationFor = event
        selectedAccountType = event
        tblView.reloadData()
    }
}
