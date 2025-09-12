import UIKit
import WebKit

class TermsConditionsVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var webView: UIView!
    @IBOutlet weak var acceptTermsConditionsStatusIcon: UIImageView!
    
    // MARK: Variables
    var params = [String: Any]()
    private var viewModel = AuthVM()
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        acceptTermsConditionsStatusIcon.image = UIImage(named: "unselectedCircle")
        webViewSetup()
        bindViewModel()
    }
    
    // MARK: IB Actions
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func acceptTermsConditions(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            acceptTermsConditionsStatusIcon.image = UIImage(named: "selectedCircle")
        } else {
            acceptTermsConditionsStatusIcon.image = UIImage(named: "unselectedCircle")
        }
    }
    
    @IBAction func next(_ sender: UIButton) {
        //        let storyboard = AppStoryboards.main.storyboardInstance
        //        guard let destVC = storyboard.instantiateViewController(withIdentifier: "AddPaymentVC") as? AddPaymentVC
        //        else { return }
        //        destVC.params = params
        //        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
        
       viewModel.completeRegistration(params: params)
    }
    
    // MARK: Shared Methods
    func webViewSetup() {
        //LoaderUtil.shared.showLoading()
        
        // 1. Initialize WKWebView
        // Do not set frame here. Constraints will handle the sizing.
        let wkWebView = WKWebView()
        
        // 2. Set navigation delegate
        wkWebView.navigationDelegate = self
        
        // 3. Set background color
        wkWebView.backgroundColor = .clear
        
        // 4. Important for Auto Layout: Disable translatesAutoresizingMaskIntoConstraints
        // This tells Auto Layout that you will provide constraints for this view,
        // rather than it trying to infer them from the frame.
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        
        // 5. Add as a subview to your container UIView
        self.webView.addSubview(wkWebView)
        
        // 6. Add Auto Layout Constraints to make it fill the superview
        NSLayoutConstraint.activate([
            wkWebView.topAnchor.constraint(equalTo: self.webView.topAnchor),
            wkWebView.leadingAnchor.constraint(equalTo: self.webView.leadingAnchor),
            wkWebView.trailingAnchor.constraint(equalTo: self.webView.trailingAnchor),
            wkWebView.bottomAnchor.constraint(equalTo: self.webView.bottomAnchor)
        ])
        
        // 7. Load the URL
        if let url = URL(string: "https://verticalresponse.com/blog/6-must-have-types-of-customer-help-content"){
            wkWebView.load(URLRequest(url: url))
        }
    }
    
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
}

// MARK: WKNavigationDelegate - Delegate and DataSources
extension TermsConditionsVC: WKNavigationDelegate {
    
    // Called when navigation starts
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // You can show a loading indicator here
    }
    
    // Called when content starts arriving for the main frame
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) { }
    
    // Called when the web view finishes loading a frame
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Hide your loading indicator here
        if let _ = webView.url?.absoluteString {
            LoaderUtil.shared.hideLoading()
        }
    }
    
    // Called if there is an error during navigation
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        LogHandler.debugLog("WebView didFailProvisionalNavigation with error: \(error.localizedDescription)")
        LoaderUtil.shared.hideLoading() // Hide loader on error too
    }
    
    // Called when the web view encounters an error after starting to load
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        LogHandler.debugLog("WebView didFail navigation with error: \(error.localizedDescription)")
        LoaderUtil.shared.hideLoading() // Hide loader on error too
    }
}
