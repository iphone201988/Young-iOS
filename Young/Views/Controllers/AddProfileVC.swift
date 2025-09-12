import UIKit

class AddProfileVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var addAdditionalPhotosView: UIView!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.registerCellFromNib(cellID: AddMoreCell.identifier)
        }
    }
    
    // MARK: Variables
    var params: [String: Any] = [:]
    var additionalPhotos = [UIImage(), UIImage(), UIImage(), UIImage(), UIImage()]
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if Constants.accountRegistrationFor == .generalMemberAccountRegistration {
            addAdditionalPhotosView.isHidden = true
        } else {
            addAdditionalPhotosView.isHidden = false
        }
    }
    
    // MARK: IB Actions
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func mediaPickerView(_ sender: UIButton) {
        MediaPicker.shared.browsedImage() { [weak self] image, _ in
            self?.profilePic.image = image
        }
    }
    
    @IBAction func takePictureNow(_ sender: UIButton) {
        MediaPicker.shared.browsedImage() { [weak self] image, _ in
            self?.profilePic.image = image
        }
    }
    
    @IBAction func next(_ sender: UIButton) {
        switch Constants.accountRegistrationFor {
        case .generalMemberAccountRegistration,
                .smallBusinessAccountRegistration,
                .startupAccountRegistration,
                .investorVCAccountRegistration:
            let storyboard = AppStoryboards.main.storyboardInstance
            guard let destVC = storyboard.instantiateViewController(withIdentifier: "PersonalInfoVC") as? PersonalInfoVC
            else { return }
            if
                let pic = profilePic.image,
                let data = pic.jpegData(compressionQuality: 0.1) {
                destVC.params = ["profileImage": data, "additionalPhotos": additionalPhotos]
            }
            SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
            
        case .financialAdvisorAccountRegistration,
                .financialFirmAccountRegistration:
            let storyboard = AppStoryboards.main.storyboardInstance
            guard let destVC = storyboard.instantiateViewController(withIdentifier: "CRDVerificationVC") as? CRDVerificationVC
            else { return }
            if
                let pic = profilePic.image,
                let data = pic.jpegData(compressionQuality: 0.1) {
                destVC.params = ["profileImage": data, "additionalPhotos": additionalPhotos]
            }
            SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
            
        default: break
        }
    }
    
    // MARK: Shared Methods
}

// MARK: Delegates and DataSources

extension AddProfileVC: UICollectionViewDataSource,
                        UICollectionViewDelegate,
                        UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ((self.collectionView.frame.width)/2 - 15)
        return CGSize(width: width, height: 200)
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
        cell.selectedImg.image = additionalPhotos[indexPath.item]
        if additionalPhotos[indexPath.item] == UIImage() {
            cell.addImageIcon.isHidden = false
        } else {
            cell.addImageIcon.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        MediaPicker.shared.browsedImage() { [weak self] image, _ in
            self?.additionalPhotos[indexPath.item] = image
            self?.collectionView.reloadData()
        }
    }
}
