import UIKit
import WebKit
import SideMenu

class NewsPreviewVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var webView: UIView!
    
    // MARK: Variables
    var source: String = ""
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        webViewSetup()
    }
    
    // MARK: IB Actions
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func menu(_ sender: UIButton) {
        let storyboard = AppStoryboards.menus.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "SideMenuNavigationController") as? SideMenuNavigationController
        else { return }
        destVC.settings = SharedMethods.shared.sideMenuSettings()
        SharedMethods.shared.presentVC(destVC: destVC)
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
        if let url = URL(string: source) {
            wkWebView.load(URLRequest(url: url))
        }
    }
}

// MARK: WKNavigationDelegate - Delegate and DataSources
extension NewsPreviewVC: WKNavigationDelegate {
    
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
