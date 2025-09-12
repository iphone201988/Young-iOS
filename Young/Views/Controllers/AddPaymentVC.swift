import UIKit

class AddPaymentVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var firstnameTF: UITextField!
    @IBOutlet weak var lastnameTF: UITextField!
    @IBOutlet weak var bilingAddressTF: UITextField!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var stateTF: UITextField!
    @IBOutlet weak var zipcodeTF: UITextField!
    @IBOutlet weak var cardNumberTF: UITextField!
    @IBOutlet weak var cardExpTF: UITextField!
    @IBOutlet weak var cardCVVTF: UITextField!
    
    // MARK: Variables
    var params = [String: Any]()
    private var viewModel = AuthVM()
    
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
    
    @IBAction func add(_ sender: UIButton) {
        params["stripeCustomerId"] = ""
        viewModel.completeRegistration(params: params)
    }
    
    @IBAction func skip(_ sender: UIButton) {
        params["stripeCustomerId"] = ""
        viewModel.completeRegistration(params: params)
    }
    
    // MARK: Shared Methods
    private func bindViewModel() {
        viewModel.$requestResponse.sink { resp in
            if resp.isSuccess == true {
                SharedMethods.shared.pushToWithoutData(destVC: AccountCreatedVC.self)
            }
            
            if let error = resp.error {
                Toast.show(message: error)
            }
        }.store(in: &viewModel.cancellables)
        
        viewModel.$fieldsValidationStatus.sink { status in
            if let error = status.error {
                Toast.show(message: error)
            }
        }.store(in: &viewModel.cancellables)
    }
    
    // MARK: Delegates and DataSources
}
