import UIKit

class PopupUtil {
    
    static func popupAlert(title: String?,
                           message: String?,
                           actionTitles: [String?],
                           actions: [((UIAlertAction, UITextField?) -> Void)?],
                           textFieldConfiguration: ((UITextField) -> Void)? = nil,
                           actionTitlesColor: [UIColor]? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            // Add the text field to the alert
            if let configureTextField = textFieldConfiguration {
                alert.addTextField { textField in
                    configureTextField(textField)
                }
            }
            
            for (index, title) in actionTitles.enumerated() {
                let action = UIAlertAction(title: title, style: .default) { action in
                    // Call the appropriate handler if available
                    if let handler = actions[safe: index]  {
                        let textField = alert.textFields?.first
                        handler?(action, textField)
                    }
                }
                if index == 0 {
                    if let firstTitleColor = actionTitlesColor?.first {
                        action.setValue(firstTitleColor, forKey: "titleTextColor")
                    } else {
                        action.setValue(UIColor.red, forKey: "titleTextColor")
                    }
                }
                alert.addAction(action)
            }
            
            guard let rootViewController = getWindowRootViewController() else { return }
            guard let topController = getTopViewController(from: rootViewController) else { return }
            topController.present(alert, animated: true, completion: nil)
        }
    }
    
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
