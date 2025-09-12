import UIKit
import UserNotifications
import UserNotificationsUI
import AVFoundation
import CoreLocation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        KeyboardStateListener.shared.start()
        initializeLocation()
        requestMicrophonePermission { _ in }
        
        Task {
            await IAPHandler.shared.fetchAvailableProducts()
        }

        UNUserNotificationCenter.current().delegate = self
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.alert, .sound]) { (granted, error) in
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
        let notification = launchOptions?[.remoteNotification]
        
        if let data = notification, let notificationData = data as? [AnyHashable : Any] {
            self.application(application, didReceiveRemoteNotification: notificationData)
        }
        
        if let launchOpts = launchOptions as [UIApplication.LaunchOptionsKey: Any]? {
            if let _ = launchOpts[UIApplication.LaunchOptionsKey.remoteNotification] as? NSDictionary { }
        } else {
            //go with the regular flow
        }
        return true
    }
    
    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            // Permission already granted
            completion(true)
            
        case .denied:
            // Permission denied
            completion(false)
            
        case .undetermined:
            // Request permission
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
            
        @unknown default:
            completion(false)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenID = deviceToken.map { data in String(format: "%02.2hhx", data) }
        UserDefaults.standard[.deviceToken] = deviceTokenID.joined()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if let uuidString = UIDevice.current.identifierForVendor?.uuidString {
            let data = Data(uuidString.utf8)
            let deviceTokenID = data.map { data in String(format: "%02.2hhx", data) }
            UserDefaults.standard[.deviceToken] = deviceTokenID.joined()
        } else {
            UserDefaults.standard[.deviceToken] = "please check device token"
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        let type = userInfo["type"] as? String ?? ""
        let pushType = PushNotificationTypes(rawValue: type)
        guard let rootViewController = getWindowRootViewController() else { return }
        guard let topController = getTopViewController(from: rootViewController) else { return }
        
        if topController is InboxVC && pushType == .message {
            NotificationCenter.default.post(name: .reloadContent, object: nil)
        }
        
        if topController is UsersListVC && pushType == .follower ||
            topController is UsersListVC && pushType == .customer {
            NotificationCenter.default.post(name: .reloadContent, object: nil)
        }
        
        if topController is ProfileVC && pushType == .customer {
            NotificationCenter.default.post(name: .reloadContent, object: nil)
        }
        
        //        if topController is ExchangeVC && pushType == .live_stream {
        //            NotificationCenter.default.post(name: .reloadContent, object: nil)
        //        }
        
        if topController is ViewMessageVC && pushType == .message {
            completionHandler([.sound])
        } else {
            completionHandler([.alert, .sound, .banner])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        handlePush(userInfo: userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        // Kill case fall in this method
        handlePush(userInfo: userInfo)
    }
    
    func handlePush(userInfo: [AnyHashable : Any]) {
        
        let type = userInfo["type"] as? String ?? ""
        let pushType = PushNotificationTypes(rawValue: type)

        guard let rootViewController = getWindowRootViewController() else { return }
        guard let topController = getTopViewController(from: rootViewController) else { return }
        
        switch pushType {
        case .message:
            let storyboard = AppStoryboards.menus.storyboardInstance
            guard let destVC = storyboard.instantiateViewController(withIdentifier: "ViewMessageVC") as? ViewMessageVC
            else { return }
            let chatId = userInfo["chatId"] as? String ?? ""
            let receiverDetails = UserDetails(_id: userInfo["userId"] as? String ?? "",
                                              role: userInfo["role"] as? String ?? "",
                                              username: userInfo["username"] as? String ?? "",
                                              profileImage: userInfo["profileImage"] as? String ?? "",
                                              chatId: "")
            destVC.receiverDetails = receiverDetails
            destVC.threadID = chatId
            topController.navigationController?.pushViewController(destVC, animated: true)
            
        case .customer, .follower:
            let storyboard = AppStoryboards.menus.storyboardInstance
            guard let destVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC
            else { return }
            if let userID = userInfo["userId"] as? String, !userID.isEmpty {
                destVC.isAnotherUserID = userID
            }
            topController.navigationController?.pushViewController(destVC, animated: true)
            
        case .live_stream, .share:
            let storyboard = AppStoryboards.menus.storyboardInstance
            guard let destVC = storyboard.instantiateViewController(withIdentifier: "VaultsRoomVC") as? VaultsRoomVC
            else { return }
            if let postID = userInfo["postId"] as? String, !postID.isEmpty {
                destVC.id = postID
            }
           
            if pushType == .live_stream {
                destVC.selectedSavedOption = .stream
            }
            
            if pushType == .share {
                destVC.selectedSavedOption = .share
            }
            
            topController.navigationController?.pushViewController(destVC, animated: true)

        default: break
        }
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    func initializeLocation() {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinates = manager.location?.coordinate else { return }
        CurrentLocation.latitude = coordinates.latitude.roundToPlace(7)
        CurrentLocation.longitude = coordinates.longitude.roundToPlace(7)
    }
}
