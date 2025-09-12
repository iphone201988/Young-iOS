import Foundation

struct Validator {
    var firstName: String?
    var lastName: String?
    var username: String?
    var email: String?
    var phoneNumber: String?
    var password: String?
    var confirmPassword: String?
    
    init(
        firstName: String? = nil,
        lastName: String? = nil,
        username: String? = nil,
        email: String? = nil,
        phoneNumber: String? = nil,
        password: String? = nil,
        confirmPassword: String? = nil) throws {
            
            // validate firstName
            if let firstName = firstName?.trimmed() {
                guard !firstName.isEmpty else {
                    throw ValidationError.empty(.firstName)
                }
                self.firstName = firstName
            }
            
            // validate lastName
            if let lastName = lastName?.trimmed() {
                guard !lastName.isEmpty else {
                    throw ValidationError.empty(.lastName)
                }
                self.lastName = lastName
            }
            
            // validate username
            if let username = username?.trimmed() {
                guard !username.isEmpty else {
                    throw ValidationError.empty(.username)
                }
                self.username = username
            }
            
            // validate email
            if let email = email?.trimmed() {
                guard !EmailPropertyWrapper(email).wrappedValue.isEmpty else {
                    throw ValidationError.reason(reason: "email_err".localized(), .email)
                }
                
                guard !email.isEmpty else {
                    throw ValidationError.empty(.email)
                }
                self.email = email
            }
            
            // validate phoneNumber
            if let phone = phoneNumber?.trimmed() {
                guard !phone.isEmpty else {
                    throw ValidationError.empty(.phoneNumber)
                }
                
                // Allow optional leading '+' and then digits only
                let pattern = "^\\+?[0-9]{10,15}$"
                let regex = try NSRegularExpression(pattern: pattern)
                let range = NSRange(location: 0, length: phone.utf16.count)
                
                guard regex.firstMatch(in: phone, options: [], range: range) != nil else {
                    throw ValidationError.reason(reason: "Phone number must contain only digits and be 10 to 15 characters long. Optional '+' at the start is allowed.", .phoneNumber)
                }
                
                self.phoneNumber = phone
            }
            
            // Validate password
            if let pwd = password?.trimmed() {
                guard !pwd.isEmpty else {
                    throw ValidationError.empty(.password)
                }
                
                // Password requirements:
                let minLength = 12
                let uppercasePattern = ".*[A-Z]+.*"
                let lowercasePattern = ".*[a-z]+.*"
                let specialCharPattern = ".*[!@#$%^&*(),.?\":{}|<>]+.*"
                
                guard pwd.count >= minLength else {
                    throw ValidationError.reason(reason: "Password must be at least \(minLength) characters long.", .password)
                }
                
                guard pwd.range(of: uppercasePattern, options: .regularExpression) != nil else {
                    throw ValidationError.reason(reason: "Password must contain at least one uppercase letter.", .password)
                }
                
                guard pwd.range(of: lowercasePattern, options: .regularExpression) != nil else {
                    throw ValidationError.reason(reason: "Password must contain at least one lowercase letter.", .password)
                }
                
                guard pwd.range(of: specialCharPattern, options: .regularExpression) != nil else {
                    throw ValidationError.reason(reason: "Password must contain at least one special character.", .password)
                }
                
                self.password = pwd
            }
            
            // validate confirm password
            if let confirmPwd = confirmPassword?.trimmed() {
                guard !confirmPwd.isEmpty else {
                    throw ValidationError.empty(.confirmPassword)
                }
                
                if confirmPwd != password {
                    throw ValidationError.isNotMatch(.password, .confirmPassword)
                } else {
                    self.password = password
                }
            }
        }
}

@propertyWrapper
class EmailPropertyWrapper {
    private var emailValue: String
    var wrappedValue: String {
        get { return ValidatorRegex.isValidEmail(email: emailValue) ? emailValue : "" }
        set { emailValue = newValue }
    }
    init(_ email: String) { emailValue = email }
}

struct ValidationStatus {
    var isValid: Bool?
    var error: String?
    var type: ValidatorType?
}

extension ValidationStatus {
    static func valid(for type: ValidatorType? = nil) -> Self {
        .init(isValid: true, error: nil, type: type)
    }
    
    static func invalid(_ error: String, type: ValidatorType? = nil) -> Self {
        .init(isValid: false, error: error, type: type)
    }
}
