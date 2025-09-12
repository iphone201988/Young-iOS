import Foundation
import UIKit
import SideMenu
import Kingfisher

class SharedMethods {
    
    static var shared = SharedMethods()
    
    func navigateToRootVC(rootVC: UIViewController) {
        // Ensure the key window scene is used
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let navigationController = UINavigationController(rootViewController: rootVC)
            navigationController.navigationBar.isHidden = true
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }
    
    func pushToWithoutData(destVC: UIViewController.Type,
                           storyboard: AppStoryboards = .main,
                           isAnimated: Bool = false) {
        DispatchQueue.main.async {
            if let vc = storyboard.controller(destVC.self) {
                SharedMethods.shared.pushTo(destVC: vc, isAnimated: isAnimated)
            }
        }
    }
    
//    func pushTo(destVC: UIViewController, isAnimated: Bool = false) {
//        guard let rootViewController = getWindowRootViewController() else { return }
//        guard let topController = getTopViewController(from: rootViewController) else { return }
//
//        // Check if the destination view controller is already in the stack
//        if let existingVC = topController.navigationController?.viewControllers.first(where: { $0.isKind(of: destVC.classForCoder) }) {
//            // If it exists in the stack, pop to that view controller
//            DispatchQueue.main.async {
//                topController.navigationController?.popToViewController(existingVC, animated: isAnimated)
//            }
//        } else {
//            // Otherwise, push the new view controller
//            DispatchQueue.main.async {
//                topController.navigationController?.navigationBar.isHidden = true
//                topController.navigationController?.pushViewController(destVC, animated: isAnimated)
//            }
//        }
//    }
    
    func pushTo(destVC: UIViewController, isAnimated: Bool = false, selectedCategories: [Categories] = []) {
        guard let rootViewController = getWindowRootViewController(),
              let topController = getTopViewController(from: rootViewController),
              let navController = topController.navigationController
        else {
            return
        }

        // Prevent pushing if the top VC is already the same type
        if navController.topViewController?.isKind(of: destVC.classForCoder) == true {
            NotificationCenter.default.post(name: .changeCategoriesSelection, object: selectedCategories)
            return
        }

        // Avoid pushing the same VC instance multiple times
        if navController.viewControllers.contains(where: { $0 === destVC }) {
            return
        }

        // Check if a VC of the same type exists in the stack
        if let existingVC = navController.viewControllers.first(where: { $0.isKind(of: destVC.classForCoder) }) {
            DispatchQueue.main.async {
                navController.popToViewController(existingVC, animated: isAnimated)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                navController.navigationBar.isHidden = true
                navController.pushViewController(destVC, animated: isAnimated)
            }
        }
    }
    
    func presentVC(destVC: UIViewController, modalPresentationStyle: UIModalPresentationStyle = .popover) {
        guard let rootViewController = getWindowRootViewController() else { return }
        guard let topController = getTopViewController(from: rootViewController) else { return }
        DispatchQueue.main.async {
            destVC.modalPresentationStyle = modalPresentationStyle
            destVC.modalTransitionStyle = .coverVertical
            topController.present(destVC, animated: true)
        }
    }
    
    func navigateTo2FA() {
        let storyboard = AppStoryboards.main.storyboardInstance
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "QRCodeVC") as? QRCodeVC
        else { return }
        destVC.userID = UserDefaults.standard[.loggedUserDetails]?._id ?? ""
        destVC.secretCode = UserDefaults.standard[.secret] ?? ""
        destVC.qrCodeString = UserDefaults.standard[.qrCodeUrl] ?? ""
        SharedMethods.shared.pushTo(destVC: destVC, isAnimated: true)
    }
    
    func isNewAccountRegistration() -> Bool {
        switch Constants.accountRegistrationFor {
        case .newRegistration,
                .generalMemberAccountRegistration,
                .financialAdvisorAccountRegistration,
                .financialFirmAccountRegistration,
                .smallBusinessAccountRegistration,
                .startupAccountRegistration,
                .investorVCAccountRegistration,
                .insurance:
            return true
            
        default: return false
        }
    }
    
    func sideMenuSettings() -> SideMenuSettings {
        let presentationStyle = SideMenuPresentationStyle.menuSlideIn
        if #available(iOS 13.0, *) {
            presentationStyle.backgroundColor = UIColor.label.withAlphaComponent(0.3)
        } else {
            presentationStyle.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }
        presentationStyle.presentingEndAlpha = 0.75
        
        var settings = SideMenuSettings()
        settings.presentationStyle = presentationStyle
        settings.menuWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * CGFloat(0.7)
        settings.statusBarEndAlpha = 0
        return settings
    }
    
    @MainActor
    func setImage(imageView: UIImageView,
                  url: String,
                  loaderStyle: UIActivityIndicatorView.Style = .medium,
                  fallbackImage: UIImage = UIImage(named: "emptyUserPic") ?? UIImage()) {
        if url.isEmpty {
            imageView.image = fallbackImage
            return
        }

        if !url.contains("/uploads") && !url.contains("images.mktw.net") {
            imageView.image = UIImage(contentsOfFile: url)
            return
        }
        
//        if !url.contains("/uploads") {
//            imageView.image = UIImage(contentsOfFile: url)
//            return
//        }

        // Cancel previous image request if any
        imageView.kf.cancelDownloadTask()
        let baseURL = VaultInfo.shared.getKeyValue(by: "Media_Load_Base_URL").1 as? String ?? ""
        var completeURL = "\(baseURL)\(url)"
        
        if url.contains("images.mktw.net") {
            completeURL = url
        }

        guard let imageURL = URL(string: completeURL)
        else {
            imageView.image = fallbackImage
            return
        }
        
        let loaderTag = 9999
        
        // Remove any existing loader before adding new
        if let oldLoader = imageView.viewWithTag(loaderTag) as? UIActivityIndicatorView {
            oldLoader.removeFromSuperview()
        }
        
        let activityIndicator = UIActivityIndicatorView(style: loaderStyle)
        activityIndicator.tag = loaderTag
        activityIndicator.center = CGPoint(x: imageView.bounds.midX, y: imageView.bounds.midY)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        imageView.addSubview(activityIndicator)
        
        imageView.kf.setImage(
            with: imageURL,
            placeholder: nil,
            //options: [.transition(.fade(0.3)), .cacheOriginalImage]
            options: [
                .transition(.fade(0.3)),
                .cacheOriginalImage,
                .forceRefresh,
                .processor(DefaultImageProcessor.default)
            ]
        ) { result in
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                if case .failure(_) = result {
                    imageView.image = fallbackImage
                }
            }
        }
    }
    
    func shareMovie(movieTitle: String, description: String, posterImage: UIImage?, link: URL) {
        guard let rootViewController = getWindowRootViewController() else { return }
        guard let topController = getTopViewController(from: rootViewController) else { return }
        
        let customItemSource = CustomMovieActivityItemSource(
            title: movieTitle,
            description: description,
            url: link,
            image: posterImage
        )
        
        let activityVC = UIActivityViewController(activityItems: [customItemSource], applicationActivities: nil)
        
        activityVC.excludedActivityTypes = [
            .assignToContact,
            .saveToCameraRoll,
            .print,
            .addToReadingList
        ]
        
        // iPad compatibility
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topController.view
            popover.sourceRect = CGRect(x: topController.view.bounds.midX,
                                        y: topController.view.bounds.maxY - 40,
                                        width: 0,
                                        height: 0)
            popover.permittedArrowDirections = []
        }
        
        topController.present(activityVC, animated: true, completion: nil)
    }
}
