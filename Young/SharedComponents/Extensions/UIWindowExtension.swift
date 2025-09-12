import UIKit

extension UIWindow {
    
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.keyWindow
        } else {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        }
    }
}

extension UINavigationController {
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let destVC = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
            popToViewController(destVC, animated: animated)
        }
    }
    
    func getCurrentVisibleViewControllerName() -> String? {
        if let topVC = self.topViewController {
            return String(describing: type(of: topVC))
        }
        return nil
    }
}

func getTopViewController(from rootViewController: UIViewController) -> UIViewController? {
    
    if let presentedViewController = rootViewController.presentedViewController {
        // If there's a presented view controller, it means we need to dig deeper
        return getTopViewController(from: presentedViewController)
    }
    
    if let navigationController = rootViewController as? UINavigationController {
        // If the root view controller is a navigation controller, get the visible view controller
        return navigationController.visibleViewController
    }
    
    if let tabBarController = rootViewController as? UITabBarController {
        // If the root view controller is a tab bar controller, get the selected view controller
        if let selectedViewController = tabBarController.selectedViewController {
            return getTopViewController(from: selectedViewController)
        }
    }
    
    // If the root view controller is none of the above, return it
    return rootViewController
}

func getWindowRootViewController() -> UIViewController? {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else { return nil }
    return window.rootViewController
}

func switchToTab(at index: Int) {
    guard let rootViewController = getWindowRootViewController() else {
        LogHandler.debugLog("Root view controller not found")
        return
    }
    
    guard let topController = getTopViewController(from: rootViewController) else {
        LogHandler.debugLog("Top view controller not found")
        return
    }
    
    DispatchQueue.main.async {
        if let tabBarController = topController.tabBarController {
            if index >= 0 && index < tabBarController.viewControllers?.count ?? 0 {
                tabBarController.selectedIndex = index
                LogHandler.debugLog("Switched to tab at index \(index)")
            } else {
                LogHandler.debugLog("Index \(index) is out of bounds for tab bar items")
            }
        } else {
            LogHandler.debugLog("Top view controller does not have a tab bar controller")
        }
    }
}

extension UITabBarController {
    func getCurrentVisibleViewControllerName() -> (String?, UIViewController?) {
        if let selectedVC = self.selectedViewController {
            return (String(describing: type(of: selectedVC)), selectedVC)
        }
        return (nil, nil)
    }
}
