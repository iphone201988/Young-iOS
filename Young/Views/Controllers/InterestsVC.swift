import UIKit

class InterestsVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var objTF: UITextField!
    @IBOutlet weak var expTF: UITextField!
    @IBOutlet weak var investmentsTF: UITextField!
    @IBOutlet weak var servicesTF: UITextField!
    
    @IBOutlet weak var objIcon: UIImageView!
    @IBOutlet weak var expIcon: UIImageView!
    @IBOutlet weak var investmentsIcon: UIImageView!
    @IBOutlet weak var servicesIcon: UIImageView!
    
    @IBOutlet weak var investmentCollectionView: UICollectionView! {
        didSet {
            investmentCollectionView.registerCellFromNib(cellID: SelectedInterestCell.identifier)
        }
    }
    
    @IBOutlet weak var servicesInterestedCollectionView: UICollectionView! {
        didSet {
            servicesInterestedCollectionView.registerCellFromNib(cellID: SelectedInterestCell.identifier)
        }
    }
    
    // MARK: Variables
    var params = [String: Any]()
    var selectedInvestments = [String]()
    var selectedServicesInteresteds = [String]()
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        PickerManager.shared.configurePicker(for: objTF,
                                             with: Constants.generalMemberObjective,
                                             iconView: objIcon)
        
        PickerManager.shared.configurePicker(for: expTF,
                                             with: Constants.generalMemberFinancialExperience,
                                             iconView: expIcon)
        
        PickerManager.shared.configurePicker(for: investmentsTF,
                                             with: Constants.generalMemberInvestments,
                                             iconView: investmentsIcon) { [weak self] selectedValue in
            if let options = self?.selectedInvestments, !options.contains(selectedValue) {
                self?.selectedInvestments.append(selectedValue)
                self?.investmentCollectionView.reloadData()
            }
        }
        
        PickerManager.shared.configurePicker(for: servicesTF,
                                             with: Constants.generalMemberServicesInterested,
                                             iconView: servicesIcon) { [weak self] selectedValue in
            if let options = self?.selectedServicesInteresteds, !options.contains(selectedValue) {
                self?.selectedServicesInteresteds.append(selectedValue)
                self?.servicesInterestedCollectionView.reloadData()
            }
        }
    }
    
    // MARK: IB Actions
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func next(_ sender: UIButton) {
        params["objective"] = objTF.text ?? ""
        params["financialExperience"] = expTF.text ?? ""
        params["investments"] = selectedInvestments.joined(separator: ",")
        params["servicesInterested"] = selectedServicesInteresteds.joined(separator: ",")
        let storyboard = AppStoryboards.main.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "AccountPackageVC") as? AccountPackageVC
        else { return }
        destVC.params = params
        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
    }
    
    // MARK: Shared Methods
}

extension InterestsVC: UICollectionViewDataSource,
                       UICollectionViewDelegate,
                       UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == investmentCollectionView {
            return selectedInvestments.count
        } else {
            return selectedServicesInteresteds.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(frame: CGRect.zero)
        var option = ""
        if collectionView == investmentCollectionView {
            option = selectedInvestments[indexPath.item]
        } else {
            option = selectedServicesInteresteds[indexPath.item]
        }
        label.text = option
        label.sizeToFit()
        let extraComponentsOccupiedSpace = 80.0
        let width = label.frame.width + extraComponentsOccupiedSpace
        return CGSize(width: width, height: 35)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedInterestCell.identifier, for: indexPath) as! SelectedInterestCell
        if collectionView == investmentCollectionView {
            cell.titleLbl.text = selectedInvestments[indexPath.item]
            cell.removeBtn.tag = indexPath.item
            cell.removeBtn.addTarget(self, action: #selector(removeInvestment(_ :)), for: .touchUpInside)
        } else {
            cell.titleLbl.text = selectedServicesInteresteds[indexPath.item]
            cell.removeBtn.tag = indexPath.item
            cell.removeBtn.addTarget(self, action: #selector(removeServicesInterested(_ :)), for: .touchUpInside)
        }
        return cell
    }
    
    @objc func removeInvestment(_ sender: UIButton) {
        selectedInvestments.remove(at: sender.tag)
        investmentCollectionView.reloadData()
    }
    
    @objc func removeServicesInterested(_ sender: UIButton) {
        selectedServicesInteresteds.remove(at: sender.tag)
        servicesInterestedCollectionView.reloadData()
    }
}
