import UIKit
import SideMenu

class AdditionalInformationVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var interfaceTitleLbl: UILabel!
    @IBOutlet weak var fairnessForwardView: UIView!
    @IBOutlet weak var fairForwardView: UIView!
    @IBOutlet weak var seekingView: UIView!
    @IBOutlet weak var seekingTitleLbl: UILabel!
    @IBOutlet weak var areaOfExpertiseView: UIView!
    @IBOutlet weak var seekingTF: UITextField!
    @IBOutlet weak var seekingBtn: UIButton!
    @IBOutlet weak var areaOfExpertiseTF: UITextField!
    @IBOutlet weak var areaOfExpertiseBtn: UIButton!
    @IBOutlet weak var aboutTV: UITextView!
    @IBOutlet weak var fairnessForwardYesIcon: UIImageView!
    @IBOutlet weak var fairnessForwardNoIcon: UIImageView!
    @IBOutlet weak var fairnessForwardYesBtn: UIButton!
    @IBOutlet weak var fairnessForwardNoBtn: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.registerCellFromNib(cellID: SelectedInterestCell.identifier)
        }
    }
    
    @IBOutlet weak var photosCollectionView: UICollectionView! {
        didSet {
            photosCollectionView.registerCellFromNib(cellID: AddMoreCell.identifier)
        }
    }
    
    @IBOutlet weak var areaOfExpertiseCollectionView: UICollectionView! {
        didSet {
            areaOfExpertiseCollectionView.registerCellFromNib(cellID: SelectedInterestCell.identifier)
        }
    }
    
    // MARK: Variables
    var event: Events = .unspecified
    fileprivate var selectedAreaOfExpertiseOptions = [String]()
    fileprivate var selectedSeekingOptions = [String]()
    fileprivate var isFairnessForward: Bool = false
    fileprivate var viewModel = SharedVM()
    fileprivate var additionalPhotos = [String]()
    fileprivate var userDetails: UserDetails?
    fileprivate var additionalPhotosToBeRemoved = [String]()
    fileprivate var isViaPopulateData: Bool = true
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fairForwardView.isHidden = true
        initialViewSetup()
        bindViewModel()
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
    
    @IBAction func accept(_ sender: UIButton) {
        fairForwardView.isHidden = true
    }
    
    @IBAction func fairnessForwardYes(_ sender: UIButton) {
        fairnessForwardYesIcon.image = UIImage(named: "selectedBox")
        fairnessForwardNoIcon.image = UIImage(named: "unselectedBox")
        isFairnessForward = true
        if isViaPopulateData {
            isViaPopulateData = false
        } else {
            fairForwardView.isHidden = false
        }
    }
    
    @IBAction func fairnessForwardNo(_ sender: UIButton) {
        fairnessForwardYesIcon.image = UIImage(named: "unselectedBox")
        fairnessForwardNoIcon.image = UIImage(named: "selectedBox")
        isFairnessForward = false
    }
    
    @IBAction func saveChanges(_ sender: UIButton) {
        var params = [
            "about": aboutTV.text ?? "",
            "fairnessForward": isFairnessForward,
            "areaOfExpertise": selectedAreaOfExpertiseOptions.joined(separator: ","),
            "productsOffered": selectedSeekingOptions.joined(separator: ","),
            "seeking": selectedSeekingOptions.joined(separator: ","),
            "industriesSeeking": selectedSeekingOptions.joined(separator: ",")
        ] as [String : Any]
        
        params["additionalPhotosToBeRemoved"] = additionalPhotosToBeRemoved
        params["additionalPhotos"] = additionalPhotos
        
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
    
    fileprivate func initialViewSetup() {
        switch event {
            
        case .generalMemberAccountRegistration://
            interfaceTitleLbl.text = "Additional Information"
            fairnessForwardView.isHidden = true
            
        case .financialAdvisorAccountRegistration://
            interfaceTitleLbl.text = "Personal Preferences"
            fairnessForwardView.isHidden = false
            
        case .smallBusinessAccountRegistration:
            interfaceTitleLbl.text = "Personal Preferences"
            fairnessForwardView.isHidden = false
            seekingView.isHidden = false
            PickerManager.shared.configurePicker(for: seekingTF,
                                                 with: Constants.startUpSeeking,
                                                 iconButton: seekingBtn,
                                                 noNeedToSetDefaultSelection: true) { [weak self] selectedOption in
                if let options = self?.selectedSeekingOptions, !options.contains(selectedOption) {
                    self?.selectedSeekingOptions.append(selectedOption)
                    self?.collectionView.reloadData()
                }
            }
            
        case .startupAccountRegistration:
            interfaceTitleLbl.text = "Additional Information"
            fairnessForwardView.isHidden = true
            seekingView.isHidden = false
            PickerManager.shared.configurePicker(for: seekingTF,
                                                 with: Constants.startUpSeeking,
                                                 iconButton: seekingBtn,
                                                 noNeedToSetDefaultSelection: true) { [weak self] selectedOption in
                if let options = self?.selectedSeekingOptions, !options.contains(selectedOption) {
                    self?.selectedSeekingOptions.append(selectedOption)
                    self?.collectionView.reloadData()
                }
            }
            
        case .investorVCAccountRegistration:
            interfaceTitleLbl.text = "Personal Preferences"
            fairnessForwardView.isHidden = false
            seekingView.isHidden = false
            seekingTitleLbl.text = "Industries Seeking*"
            PickerManager.shared.configurePicker(for: seekingTF,
                                                 with: Constants.startupAndSmallBusinessIndustry,
                                                 iconButton: seekingBtn,
                                                 noNeedToSetDefaultSelection: true) { [weak self] selectedOption in
                if let options = self?.selectedSeekingOptions, !options.contains(selectedOption) {
                    self?.selectedSeekingOptions.append(selectedOption)
                    self?.collectionView.reloadData()
                }
            }
            
        case .insurance, .financialFirmAccountRegistration:
            interfaceTitleLbl.text = "Personal Preferences"
            fairnessForwardView.isHidden = false
            seekingView.isHidden = false
            seekingTitleLbl.text = "Products/ Services Offered*"
            areaOfExpertiseView.isHidden = false
            
            PickerManager.shared.configurePicker(for: seekingTF,
                                                 with: Constants.productsOrServicesOffered,
                                                 iconButton: seekingBtn,
                                                 noNeedToSetDefaultSelection: true) { [weak self] selectedOption in
                if let options = self?.selectedSeekingOptions, !options.contains(selectedOption) {
                    self?.selectedSeekingOptions.append(selectedOption)
                    self?.collectionView.reloadData()
                }
            }
            
            PickerManager.shared.configurePicker(for: areaOfExpertiseTF,
                                                 with: Constants.productsOrServicesOffered,
                                                 iconButton: areaOfExpertiseBtn,
                                                 noNeedToSetDefaultSelection: true) { [weak self] selectedOption in
                if let options = self?.selectedAreaOfExpertiseOptions, !options.contains(selectedOption) {
                    self?.selectedAreaOfExpertiseOptions.append(selectedOption)
                    self?.areaOfExpertiseCollectionView.reloadData()
                }
            }
            
        default: break
        }
        
        viewModel.getUserProfile()
    }
    
    fileprivate func populateData() {
        aboutTV.text = userDetails?.about ?? ""
        let fairnessForwardStatus = userDetails?.fairnessForward ?? false
        isFairnessForward = fairnessForwardStatus
        if fairnessForwardStatus {
            fairnessForwardYesBtn.sendActions(for: .touchUpInside)
        } else {
            fairnessForwardNoBtn.sendActions(for: .touchUpInside)
        }
        
        let photos = userDetails?.additionalPhotos ?? []
        additionalPhotos = [""] + photos
        photosCollectionView.reloadData()

        switch event {
            
        case .startupAccountRegistration, .smallBusinessAccountRegistration:
            let seeking = userDetails?.seeking ?? ""
            selectedSeekingOptions = seeking.isEmpty ? [] : seeking.components(separatedBy: ",")
            collectionView.reloadData()
            
        case .investorVCAccountRegistration:
            let industriesSeeking = userDetails?.industriesSeeking ?? ""
            selectedSeekingOptions = industriesSeeking.isEmpty ? [] : industriesSeeking.components(separatedBy: ",")
            collectionView.reloadData()
            
        case .insurance, .financialFirmAccountRegistration:
            let productsOffered = userDetails?.productsOffered ?? ""
            selectedSeekingOptions = productsOffered.isEmpty ? [] : productsOffered.components(separatedBy: ",")
            collectionView.reloadData()
            
            let areaOfExpertise = userDetails?.areaOfExpertise ?? ""
            selectedAreaOfExpertiseOptions = areaOfExpertise.isEmpty ? [] : areaOfExpertise.components(separatedBy: ",")
            areaOfExpertiseCollectionView.reloadData()
            
        default: break
        }
    }
}

// MARK: Delegates and DataSources

extension AdditionalInformationVC: UICollectionViewDataSource,
                                   UICollectionViewDelegate,
                                   UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == photosCollectionView {
            return additionalPhotos.count
        } else if collectionView == areaOfExpertiseCollectionView {
            return selectedAreaOfExpertiseOptions.count
        } else {
            return selectedSeekingOptions.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == photosCollectionView {
            let width = (photosCollectionView.frame.width)/2.5 - 20
            return CGSize(width: width, height: 142)
        } else if collectionView == areaOfExpertiseCollectionView {
            let label = UILabel(frame: CGRect.zero)
            label.text = selectedAreaOfExpertiseOptions[indexPath.item]
            label.sizeToFit()
            let extraComponentsOccupiedSpace = 80.0
            let width = label.frame.width + extraComponentsOccupiedSpace
            return CGSize(width: width, height: 35)
        } else {
            let label = UILabel(frame: CGRect.zero)
            label.text = selectedSeekingOptions[indexPath.item]
            label.sizeToFit()
            let extraComponentsOccupiedSpace = 80.0
            let width = label.frame.width + extraComponentsOccupiedSpace
            return CGSize(width: width, height: 35)
        }
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
        if collectionView == photosCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddMoreCell.identifier, for: indexPath) as! AddMoreCell
            if indexPath.item == 0 {
                cell.addImageIcon.isHidden = false
                cell.selectedImg.isHidden = true
                cell.deleteBtn.isHidden = true
            } else {
                cell.addImageIcon.isHidden = true
                cell.selectedImg.isHidden = false
                cell.deleteBtn.isHidden = false
                SharedMethods.shared.setImage(imageView: cell.selectedImg, url: additionalPhotos[indexPath.item])
                cell.deleteBtn.tag = indexPath.item
                cell.deleteBtn.addTarget(self, action: #selector(deletePhoto(_ :)), for: .touchUpInside)
            }
            return cell
        } else if collectionView == areaOfExpertiseCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedInterestCell.identifier, for: indexPath) as! SelectedInterestCell
            cell.titleLbl.text = selectedAreaOfExpertiseOptions[indexPath.item]
            cell.removeBtn.tag = indexPath.item
            cell.removeBtn.addTarget(self, action: #selector(removeAreaOfExpertiseOptions(_ :)), for: .touchUpInside)
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedInterestCell.identifier, for: indexPath) as! SelectedInterestCell
            cell.titleLbl.text = selectedSeekingOptions[indexPath.item]
            cell.removeBtn.tag = indexPath.item
            cell.removeBtn.addTarget(self, action: #selector(removeSeekingOptions(_ :)), for: .touchUpInside)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == photosCollectionView {
            if indexPath.item == 0 {
                if additionalPhotos.count < 6 {
                    MediaPicker.shared.browsedImage() { [weak self] image, imageURL in
                        if let imageURL {
                            let path = imageURL.path(percentEncoded: false)
                            self?.additionalPhotos.append(path)
                            self?.photosCollectionView.reloadData()
                        }
                    }
                } else {
                    Toast.show(message: "You can add max of 5 photos")
                }
            }
        }
    }
    
    @objc func deletePhoto(_ sender: UIButton) {
        let path = additionalPhotos[sender.tag]
        if path.contains("/uploads") {
            additionalPhotosToBeRemoved.append(path)
        }
        additionalPhotos.remove(at: sender.tag)
        photosCollectionView.reloadData()
    }
    
    @objc func removeSeekingOptions(_ sender: UIButton) {
        selectedSeekingOptions.remove(at: sender.tag)
        collectionView.reloadData()
    }
    
    @objc func removeAreaOfExpertiseOptions(_ sender: UIButton) {
        selectedAreaOfExpertiseOptions.remove(at: sender.tag)
        areaOfExpertiseCollectionView.reloadData()
    }
}
