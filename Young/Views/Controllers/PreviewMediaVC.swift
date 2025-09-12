import UIKit

class PreviewMediaVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var previewImageView: UIImageView!
    
    // MARK: Variables
    var mediaURL: String?
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let mediaURL, !mediaURL.isEmpty {
            SharedMethods.shared.setImage(imageView: previewImageView, url: mediaURL)
        }
    }
    
    // MARK: IB Actions
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: Shared Methods
    
    // MARK: Delegates and DataSources
}
