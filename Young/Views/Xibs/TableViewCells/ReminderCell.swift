import UIKit

class ReminderCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var topicLbl: UILabel!
    @IBOutlet weak var mediaWidth: NSLayoutConstraint!
    @IBOutlet weak var mediaBtn: UIButton!
    @IBOutlet weak var mediaImg: UIImageView!
    
    // MARK: Variables
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    var calendarEvent: Event? {
        didSet {
            guard let calendarEvent else { return }
            
            if let type = calendarEvent.type {
                let color = CalendarEventTypes(rawValue: type)?.typeColor
                indicatorView.backgroundColor = color
                titleLbl.textColor = color
            }
            
            titleLbl.text = calendarEvent.title ?? ""
            topicLbl.text = calendarEvent.topic ?? ""
            descLbl.text = calendarEvent.description ?? ""
            dateLbl.text =  DateUtil.formatDateToLocal(from: calendarEvent.scheduledDate ?? "", format: "d")
            dayLbl.text =  DateUtil.formatDateToLocal(from: calendarEvent.scheduledDate ?? "", format: "E")
            
            if let file = calendarEvent.file, !file.isEmpty {
                mediaWidth.constant = 30.0
                SharedMethods.shared.setImage(imageView: mediaImg, url: file)
            } else {
                mediaWidth.constant = 0.0
                mediaImg.image = nil
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
