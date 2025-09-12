import Foundation
import UIKit

extension UIButton {
    func setBoldTitle(_ title: String, for state: UIControl.State) {
        let boldFont = UIFont.boldSystemFont(ofSize: self.titleLabel?.font.pointSize ?? UIFont.systemFontSize)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: boldFont
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        self.setAttributedTitle(attributedTitle, for: state)
    }
}
