import UIKit
import FSCalendar

class CustomCalendarCell: FSCalendarCell {

    let myView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "#F5F5F5")
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        return view
    }()

    let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue
        view.layer.cornerRadius = 1.5
        return view
    }()

    let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(named: "#71727A")
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium) // Customize font here
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(myView)
        contentView.addSubview(underlineView)
        contentView.addSubview(dateLabel)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        contentView.addSubview(myView)
        contentView.addSubview(underlineView)
        contentView.addSubview(dateLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Hide default titleLabel if it's visible
        titleLabel?.isHidden = true // Hide the default FSCalendar date label
        // Size & center myView (background bubble)
        let size: CGFloat = 30
        myView.frame = CGRect(
            x: (contentView.bounds.width - size) / 2,
            y: (contentView.bounds.height - size) / 2,
            width: size,
            height: size
        )

        // Bottom underline
        let underlineWidth: CGFloat = 20
        let underlineHeight: CGFloat = 3
        underlineView.frame = CGRect(
            x: (contentView.bounds.width - underlineWidth) / 2,
            y: contentView.bounds.height - underlineHeight - 6, //4
            width: underlineWidth,
            height: underlineHeight
        )

        // Date label centered in the cell
        dateLabel.frame = contentView.bounds
    }
}
