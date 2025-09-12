import UIKit

extension UICollectionView {
    
    func registerCellFromNib(cellID: String) {
        self.register(UINib(nibName: cellID, bundle: nil), forCellWithReuseIdentifier: cellID)
    }
    
    func setEmptyMessage(_ message: String, animationName: String) {
        // Remove any existing background view
        self.backgroundView?.removeFromSuperview()
        
        // Create a container view for the message and animation
        let containerView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: self.bounds.size.width,
                height: self.bounds.size.height
            )
        )
        containerView.backgroundColor = .clear // Optional: Change to fit your design

        // Create and configure the message label
        let messageLabel = UILabel(
            frame: CGRect(
                x: 0,
                y: 0,
                width: containerView.bounds.size.width,
                height: 60
            )
        ) // Adjust height as needed
        
        messageLabel.text = message
        messageLabel.textColor = UIColor(named: "F1E4FF") ?? .white
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "CircularStd-Book", size: 16)
        messageLabel.sizeToFit()
        messageLabel.center.x = containerView.center.x
        
        // Add animation view and message label to the container view
        containerView.addSubview(messageLabel)
        
        // Set the container view as the background view
        self.backgroundView = containerView
    }
    
    func restore() {
        self.backgroundView = nil
    }
    
    func hide_show_no_data_message(count: Int,
                                   msg: String = "It appears that your request yielded no results, or data.",
                                   animationName: String = "noDataFound") {
        if count > 0 {
            restore()
        } else {
            setEmptyMessage(msg, animationName: animationName)
        }
    }
}

extension UICollectionView {
    func safeScrollToItem(at index: Int, section: Int = 0, position: UICollectionView.ScrollPosition = .right, animated: Bool = false) {
        let total = self.numberOfItems(inSection: section)
        guard index < total else {
            LogHandler.debugLog("⚠️ Cannot scroll. Index \(index) out of bounds (total items: \(total)).")
            return
        }

        self.scrollToItem(at: IndexPath(item: index, section: section), at: position, animated: animated)
    }
}
