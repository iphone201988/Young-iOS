import UIKit
import SideMenu

class InvestmentSummaryVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var stockInvestmentsTF: UITextField!
    @IBOutlet weak var specifyStockSymbolsTF: UITextField!
    @IBOutlet weak var cryptoInvestmentsTF: UITextField!
    @IBOutlet weak var specifyCryptoSymbolsTF: UITextField!
    @IBOutlet weak var otherSecurityInvestmentsTF: UITextField!
    @IBOutlet weak var realEstateTF: UITextField!
    @IBOutlet weak var retirementAccountTF: UITextField!
    @IBOutlet weak var savingsTF: UITextField!
    @IBOutlet weak var startupsTF: UITextField!
    
    // MARK: Variables
    fileprivate var viewModel = SharedVM()
    fileprivate var userDetails: UserDetails?
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bindViewModel()
        viewModel.getUserProfile()
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
        let params = [
            "stockInvestments": stockInvestmentsTF.text ?? "",
            "specificStockSymbols": specifyStockSymbolsTF.text ?? "",
            "cryptoInvestments": cryptoInvestmentsTF.text ?? "",
            "specificCryptoSymbols": specifyCryptoSymbolsTF.text ?? "",
            "otherSecurityInvestments": otherSecurityInvestmentsTF.text ?? "",
            "realEstate": realEstateTF.text ?? "",
            "retirementAccount": retirementAccountTF.text ?? "",
            "savings": savingsTF.text ?? "",
            "startups": startupsTF.text ?? ""
        ] as [String : Any]
        
        viewModel.updateUser(params: params)
    }
    
    // MARK: Shared Methods
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
        stockInvestmentsTF.text = userDetails?.stockInvestments ?? ""
        specifyStockSymbolsTF.text = userDetails?.specificStockSymbols ?? ""
        cryptoInvestmentsTF.text = userDetails?.cryptoInvestments ?? ""
        specifyCryptoSymbolsTF.text = userDetails?.specificCryptoSymbols ?? ""
        otherSecurityInvestmentsTF.text = userDetails?.otherSecurityInvestments ?? ""
        realEstateTF.text = userDetails?.realEstate ?? ""
        retirementAccountTF.text = userDetails?.retirementAccount ?? ""
        savingsTF.text = userDetails?.savings ?? ""
        startupsTF.text = userDetails?.startups ?? ""
    }
    
    // MARK: Delegates and DataSources
}
