import Foundation

enum ValidatorType {
    case username
    case fullname
    case email
    case password
    case confirmPassword
    case oldPassword
    case firstName
    case lastName
    case phoneNumber
    
    var typeRawValue: String {
        switch self {
        case .username: return "Username"
        case .fullname: return "Fullname"
        case .email: return "Email"
        case .password: return "Password"
        case .confirmPassword: return "Confirm Password"
        case .oldPassword: return "Old Password"
        case .firstName: return "First Name"
        case .lastName: return "Last Name"
        case .phoneNumber: return "Phone Number"
        }
    }
}
