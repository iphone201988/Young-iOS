import UIKit
import SideMenu

class FormUploadVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var photosCollectionView: UICollectionView! {
        didSet {
            photosCollectionView.registerCellFromNib(cellID: AddMoreCell.identifier)
        }
    }
    
    // MARK: Variables
    fileprivate var viewModel = SharedVM()
    fileprivate var uploadedForms = [String]()
    fileprivate var userDetails: UserDetails?
    fileprivate var formUploadToBeRemoved = [String]()
    
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
        let params = ["formUpload": uploadedForms, "formUploadToBeRemoved": formUploadToBeRemoved] as [String : Any]
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
                let forms = resp.formUpload ?? []
                self?.uploadedForms = [""] + forms
                self?.photosCollectionView.reloadData()
            }
        }.store(in: &viewModel.cancellables)
    }
}

// MARK: Delegates and DataSources

extension FormUploadVC: UICollectionViewDataSource,
                        UICollectionViewDelegate,
                        UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return uploadedForms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (photosCollectionView.frame.width)/2.5 - 20
        return CGSize(width: width, height: 142)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddMoreCell.identifier, for: indexPath) as! AddMoreCell
        if indexPath.item == 0 {
            cell.addImageIcon.isHidden = false
            cell.selectedImg.isHidden = true
            cell.deleteBtn.isHidden = true
        } else {
            cell.addImageIcon.isHidden = true
            cell.selectedImg.isHidden = false
            cell.deleteBtn.isHidden = false
            SharedMethods.shared.setImage(imageView: cell.selectedImg, url: uploadedForms[indexPath.item])
            cell.deleteBtn.tag = indexPath.item
            cell.deleteBtn.addTarget(self, action: #selector(deletePhoto(_ :)), for: .touchUpInside)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == photosCollectionView {
            if indexPath.item == 0 {
                MediaPicker.shared.browsedImage() { [weak self] image, imageURL in
                    if let imageURL {
                        let path = imageURL.path(percentEncoded: false)
                        self?.uploadedForms.append(path)
                        self?.photosCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    @objc func deletePhoto(_ sender: UIButton) {
        let path = uploadedForms[sender.tag]
        if path.contains("/uploads") {
            formUploadToBeRemoved.append(path)
        }
        uploadedForms.remove(at: sender.tag)
        photosCollectionView.reloadData()
    }
}
