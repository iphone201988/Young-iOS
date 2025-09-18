import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        let accessToken = UserDefaults.standard[.accessToken] ?? ""
        // 🔹 Check if app launched via Universal Link
        if let userActivity = connectionOptions.userActivities.first,
           userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let incomingURL = userActivity.webpageURL {
            navigateToVaultsRoomVC(incomingURL.absoluteString)
        }
        
        if !accessToken.isEmpty {
            SharedMethods.shared.navigateTo2FA()
            if let vc = AppStoryboards.menus.controller(HomeVC.self) {
                SharedMethods.shared.navigateToRootVC(rootVC: vc)
            }
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let incomingURL = userActivity.webpageURL {
            // Handle navigation based on URL
            navigateToVaultsRoomVC(incomingURL.absoluteString)
        }
    }
    
    fileprivate func navigateToVaultsRoomVC(_ redirectURL: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard let rootViewController = getWindowRootViewController() else { return }
            guard let topController = getTopViewController(from: rootViewController) else { return }
            let storyboard = AppStoryboards.menus.storyboardInstance
            guard let destVC = storyboard.instantiateViewController(withIdentifier: "VaultsRoomVC") as? VaultsRoomVC
            else { return }
            if let lastComponent = redirectURL.split(separator: "_").last {
                let videoID = String(lastComponent)
                destVC.id = videoID
            }
            destVC.selectedSavedOption = .stream
            topController.navigationController?.pushViewController(destVC, animated: true)
        }
    }
}
