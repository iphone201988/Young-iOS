import Foundation

enum APIEndpoints: String, Codable, CaseIterable {
    case login
    case register
    case verifyOtp
    case sendOtp
    case logout
    case getUserProfile
    case followUnfollowUser
    case changePassword
    case completeRegistration
    case updateUser
    case verify2FA
    case share
    case stream
    case vault
    case getUsers
    case saveUnsaveVault
    case saveUnsavePost
    case likeDislikePost
    case comment
    case joinLeaveVault
    case getTrendingTopics
    case getLatestUsers
    case rating
    case chat
    case report
    case event
    case deleteAccount
    case updateCustomers
    case contactUs
    case reshare
    case getSavedPosts
    case getSavedStreams
    case getSavedVaults
    case getPaymentMethods
    case ads
    case getUnauthUser
    case downloadHistory
    case resetPassword
    case getUploadedMedia

    public func urlComponent() -> String {
        switch self {
        case .login: return "user/login"
        case .register: return "user/register"
        case .verifyOtp: return "user/verifyOtp"
        case .sendOtp: return "user/sendOtp"
        case .logout: return "user/logout"
        case .getUserProfile: return "user/getUserProfile"
        case .followUnfollowUser: return "user/followUnfollowUser"
        case .changePassword: return "user/changePassword"
        case .completeRegistration: return "user/completeRegistration"
        case .updateUser: return "user/updateUser"
        case .verify2FA: return "user/verify2FA"
        case .share: return "post"
        case .stream: return "user/stream"
        case .vault: return "vault"
        case .getUsers: return "user/getUsers"
        case .saveUnsaveVault: return "vault/saveUnsaveVault"
        case .saveUnsavePost: return "post/saveUnsavePost"
        case .likeDislikePost: return "post/likeDislikePost"
        case .comment: return "comment"
        case .joinLeaveVault: return "vault/joinLeaveVault"
        case .getTrendingTopics: return "post/getTrendingTopics"
        case .getLatestUsers: return "user/getLatestUsers"
        case .rating: return "rating"
        case .chat: return "chat"
        case .report: return "report"
        case .event: return "event"
        case .deleteAccount: return "user/deleteAccount"
        case .updateCustomers: return "user/updateCustomers"
        case .contactUs: return "user/contactUs"
        case .reshare: return "post/reshare"
        case .getSavedPosts: return "post/getSavedPosts"
        case .getSavedStreams: return "post/getSavedStreams"
        case .getSavedVaults: return "vault/getSavedVaults"
        case .getPaymentMethods: return "payment/getPaymentMethods"
        case .ads: return "ads"
        case .getUnauthUser: return "user/getUnauthUser"
        case .downloadHistory: return "post/downloadHistory"
        case .resetPassword: return "user/resetPassword"
        case .getUploadedMedia: return "user/getUploadedMedia"
        }
    }
}
