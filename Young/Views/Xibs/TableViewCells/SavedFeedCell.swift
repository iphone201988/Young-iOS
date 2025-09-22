import UIKit
import Cosmos

class SavedFeedCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var moreOptionBtn: UIButton!
    @IBOutlet weak var streamTimeLbl: UILabel!
    @IBOutlet weak var shareImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var likesCommentsCountView: UIView!
    @IBOutlet weak var newCommentView: UIView!
    @IBOutlet weak var ratingStarsView: UIView!
    @IBOutlet weak var totalRatingView: UIView!
    @IBOutlet weak var totalRatingViewHeight: NSLayoutConstraint!
    @IBOutlet weak var usersView: UIView!
    @IBOutlet weak var likesCommentsCountBottomSpaciousView: UIView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var videoTimeLbl: UILabel!
    @IBOutlet weak var userProfilePic: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postDateTimeLbl: UILabel!
    @IBOutlet weak var usernameViewTotalRatingLbl: UILabel!
    @IBOutlet weak var saveCommentViewTotalRatingLbl: UILabel!
    @IBOutlet weak var ratingStarsViewTotalRatingLbl: UILabel!
    @IBOutlet weak var postContentLbl: UILabel!
    @IBOutlet weak var totalCommentLbl: UILabel!
    @IBOutlet weak var commentTV: UITextView!
    @IBOutlet weak var postCommentBtn: UIButton!
    @IBOutlet weak var totalBoomsLbl: UILabel!
    @IBOutlet weak var totalSavesLbl: UILabel!
    @IBOutlet weak var boomsBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var savesBtn: UIButton!
    @IBOutlet weak var saveIcon: UIImageView!
    @IBOutlet weak var boomIcon: UIImageView!
    @IBOutlet weak var member1ProfilePic: UIImageView!
    @IBOutlet weak var member2ProfilePic: UIImageView!
    @IBOutlet weak var member3ProfilePic: UIImageView!
    @IBOutlet weak var moreMembersIcon: UIImageView!
    @IBOutlet weak var boomView: UIView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var reshareView: UIView!
    @IBOutlet weak var reshareBtn: UIButton!
    @IBOutlet weak var overallRatingView: CosmosView!
    @IBOutlet weak var roleLbl: UILabel!
    @IBOutlet weak var streamStatusIcon: UIImageView!
    @IBOutlet weak var symbolLbl: UILabel!
    @IBOutlet weak var feedTitleLbl: UILabel!
    @IBOutlet weak var mediaViewHeight: NSLayoutConstraint!
    
    // MARK: Variables
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    var tappedReport: ((UIAction, PostDetails) -> Void)?
    var tappedDelete: ((UIAction, PostDetails) -> Void)?
    var tappedFeature: ((UIAction, PostDetails) -> Void)?
    var tappedShare: ((UIAction, PostDetails) -> Void)?
    var tappedAddToCalendar: ((UIAction, PostDetails) -> Void)?
    
    var savedOption: SavedOptions? {
        didSet {
            guard let savedOption else { return }
            moreOptionBtn.isHidden = true
            streamTimeLbl.isHidden = true
            shareImageViewHeight.constant = 0.0
            usernameView.isHidden = false
            contentLbl.isHidden = false
            likesCommentsCountView.isHidden = false
            newCommentView.isHidden = true
            ratingStarsView.isHidden = false
            totalRatingView.isHidden = true
            totalRatingViewHeight.constant = 0.0
            usersView.isHidden = true
            likesCommentsCountBottomSpaciousView.isHidden = true
            saveView.isHidden = true
            reshareView.isHidden = true
            streamStatusIcon.isHidden = true
            
            switch savedOption {
            case .share:
                //totalRatingView.isHidden = false
                //likesCommentsCountBottomSpaciousView.isHidden = false
            
                moreOptionBtn.isHidden = false
                shareImageViewHeight.constant = 216 // 231
                usernameView.isHidden = false
                //ratingStarsView.isHidden = false
                
            case .stream:
                //totalRatingView.isHidden = false
                //likesCommentsCountBottomSpaciousView.isHidden = false
                
                moreOptionBtn.isHidden = false
                shareImageViewHeight.constant = 216 // 347
                usernameView.isHidden = false
                //ratingStarsView.isHidden = false
                streamStatusIcon.isHidden = false
                
            case .vault:
                moreOptionBtn.isHidden = false
                shareImageViewHeight.constant = 216
                usernameView.isHidden = false
                //newCommentView.isHidden = false
                //ratingStarsView.isHidden = false
                usersView.isHidden = false
                boomView.isHidden = true
                totalRatingViewHeight.constant = 28.0
                
            default: break
            }
        }
    }
    
    var exchangeOption: SavedOptions? {
        didSet {
            guard let exchangeOption else { return }
            moreOptionBtn.isHidden = true
            streamTimeLbl.isHidden = true
            shareImageViewHeight.constant = 0.0
            usernameView.isHidden = true
            contentLbl.isHidden = false
            likesCommentsCountView.isHidden = false
            newCommentView.isHidden = true
            ratingStarsView.isHidden = false
            totalRatingView.isHidden = true
            totalRatingViewHeight.constant = 0.0
            usersView.isHidden = true
            likesCommentsCountBottomSpaciousView.isHidden = true
            boomView.isHidden = false
            reshareView.isHidden = true
            streamStatusIcon.isHidden = true
            
            switch exchangeOption {
            case .share:
                moreOptionBtn.isHidden = false
                shareImageViewHeight.constant = 216
                usernameView.isHidden = false
                //ratingStarsView.isHidden = false
                reshareView.isHidden = false
                
            case .stream:
                moreOptionBtn.isHidden = false
                shareImageViewHeight.constant = 216
                usernameView.isHidden = false
                //ratingStarsView.isHidden = false
                streamStatusIcon.isHidden = false
                
            case .vault:
                moreOptionBtn.isHidden = false
                shareImageViewHeight.constant = 216
                usernameView.isHidden = false
                //newCommentView.isHidden = false
                //ratingStarsView.isHidden = false
                usersView.isHidden = false
                totalRatingViewHeight.constant = 28.0
                boomView.isHidden = true
                
            default: break
            }
        }
    }
    
    var isMyShares: Bool = false
    
    var postDetails: PostDetails? {
        didSet {
            overallRatingView.settings.fillMode = .full
            guard let postDetails else { return }
            
            if let feedImage = postDetails.image {
                mediaViewHeight.constant = 331.0
                postImage.isHidden = false
                SharedMethods.shared.setImage(imageView: postImage, url: feedImage)
            } else {
                if isMyShares {
                    mediaViewHeight.constant = 0.0
                } else {
                    mediaViewHeight.constant = 30.0
                }
                postImage.isHidden = true
                postImage.image = nil
            }
            
            if let userId = postDetails.userId {
                SharedMethods.shared.setImage(imageView: userProfilePic, url: userId.profileImage ?? "")
                let firstName = userId.firstName ?? ""
                let lastName = userId.lastName ?? ""
                usernameLbl.text = "\(firstName) \(lastName)"
                if let role = userId.role, !role.isEmpty {
                    let userRole = Events.registrationFor(role: role) ?? .unspecified
                    roleLbl.text = userRole.rawValue
                } else {
                    roleLbl.text = ""
                }
            }
            
            if let admin = postDetails.admin {
                SharedMethods.shared.setImage(imageView: userProfilePic, url: admin.profileImage ?? "")
                usernameLbl.text = admin.username ?? ""
                if let role = admin.role, !role.isEmpty {
                    let userRole = Events.registrationFor(role: role) ?? .unspecified
                    roleLbl.text = userRole.rawValue
                } else {
                    roleLbl.text = ""
                }
            }
            
            feedTitleLbl.text = postDetails.title ?? ""
            postContentLbl.text = postDetails.description ?? ""
            totalBoomsLbl.text = "\(postDetails.likesCount ?? 0) Booms"
            totalCommentLbl.text = "\(postDetails.commentsCount ?? 0) Comments"
            //totalSavesLbl.text = "\(vaultDetails.savesCount ?? 0) saves"
            postDateTimeLbl.text = DateUtil.formatDateToLocal(from: postDetails.createdAt ?? "")
            if postDetails.isSaved == true {
                saveIcon.image = UIImage(named: "save")
            } else {
                saveIcon.image = UIImage(named: "unsave")
            }
            
            if postDetails.isLiked == true {
                boomIcon.image = UIImage(named: "boom")
            } else {
                boomIcon.image = UIImage(named: "heart")
            }
            
            if postDetails.members?.count ?? 0 > 3 {
                moreMembersIcon.isHidden = false
            } else {
                moreMembersIcon.isHidden = true
            }
            
            if let members = postDetails.members {
                for (index, member) in members.enumerated() {
                    if index == 0 {
                        SharedMethods.shared.setImage(imageView: member1ProfilePic, url: member.profileImage ?? "")
                    } else if index == 1 {
                        SharedMethods.shared.setImage(imageView: member2ProfilePic, url: member.profileImage ?? "")
                    } else if index == 2 {
                        SharedMethods.shared.setImage(imageView: member3ProfilePic, url: member.profileImage ?? "")
                    }
                }
            }
            
            usernameViewTotalRatingLbl.text = "\(postDetails.ratings ?? 0.0)"
            saveCommentViewTotalRatingLbl.text = "\(postDetails.ratings ?? 0.0)"
            ratingStarsViewTotalRatingLbl.text = "\(postDetails.ratings ?? 0.0)"
            overallRatingView.rating = postDetails.ratings ?? 0.0
            let symbol = postDetails.symbol ?? ""
            let symbolValue = postDetails.symbolValue ?? ""
            let symbolTitle = Symbols(rawValue: symbol)?.title ?? Symbols.stock.title
            symbolLbl.text = "\(symbolTitle): \(symbolValue)"
            if symbolValue.isEmpty {
                symbolLbl.isHidden = true
            } else {
                symbolLbl.isHidden = false
            }
            
            var isLoggedUserCreator: Bool = false
            
            if let user = postDetails.userId {
                if user._id == UserDefaults.standard[.loggedUserDetails]?._id {
                    isLoggedUserCreator = true
                }
            }
            
            if let admin = postDetails.admin {
                if admin._id == UserDefaults.standard[.loggedUserDetails]?._id {
                    isLoggedUserCreator = true
                }
            }
            
            if isLoggedUserCreator {
                
                var actions: [UIAction] = [
                    UIAction(title: "Delete") { [weak self] action in
                        self?.tappedDelete?(action, postDetails)
                    }
                ]
                
                if savedOption == .share || exchangeOption == .share {
                    actions.append(
                        UIAction(title: "Feature") { [weak self] action in
                            self?.tappedFeature?(action, postDetails)
                        }
                    )
                } 
                
                if let _ = postDetails.scheduleDate {
                    
                    if postDetails.isAlreadyAddedToCalendar == true {
                        
                    } else {
                        actions.append(
                            UIAction(title: "Add to Calendar") { [weak self] action in
                                self?.tappedAddToCalendar?(action, postDetails)
                            }
                        )
                    }
                } else {
                    if let _ = postDetails.streamUrl {
                        actions.append(
                            UIAction(title: "Share Video Link") { [weak self] action in
                                self?.tappedShare?(action, postDetails)
                            }
                        )
                    }
                }
                
                let menu = UIMenu(title: "", children: actions)
                moreOptionBtn.menu = menu
                moreOptionBtn.showsMenuAsPrimaryAction = true
                reshareView.isHidden = true
            } else {
                if postDetails.isReported == true {
                    moreOptionBtn.isHidden = true
                } else {
                    moreOptionBtn.isHidden = false
                    //                    let menu = UIMenu(title: "", children: [
                    //                        UIAction(title: "Report") { [weak self] action in
                    //                            self?.tappedReport?(action, postDetails)
                    //                        }
                    //                    ])
                    
                    var actions: [UIAction] = [
                        UIAction(title: "Report") { [weak self] action in
                            self?.tappedReport?(action, postDetails)
                        }
                    ]
                    
                    if let _ = postDetails.scheduleDate {
                        
                        if postDetails.isAlreadyAddedToCalendar == true {
                            
                        } else {
                            actions.append(
                                UIAction(title: "Add to Calendar") { [weak self] action in
                                    self?.tappedAddToCalendar?(action, postDetails)
                                }
                            )
                        }
                        
                    } else {
                        if let _ = postDetails.streamUrl {
                            actions.append(
                                UIAction(title: "Share Video Link") { [weak self] action in
                                    self?.tappedShare?(action, postDetails)
                                }
                            )
                        }
                    }
                    
                    let menu = UIMenu(title: "", children: actions)
                    moreOptionBtn.menu = menu
                    moreOptionBtn.showsMenuAsPrimaryAction = true
                }
            }
            
            if let _ = postDetails.scheduleDate {
                streamStatusIcon.image = UIImage(named: "schedule")
            } else {
                if let _ = postDetails.streamUrl {
                    streamStatusIcon.image = UIImage(named: "play-button")
                } else {
                    streamStatusIcon.image = UIImage(named: "live-stream")
                }
            }
        }
    }
    
    // MARK: Cell Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: Shared Methods
    
    // MARK: IB Actions
}
