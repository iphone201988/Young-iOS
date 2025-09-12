import Foundation

final class DiditServices {
    static let shared = DiditServices()
    
    private let clientID = "QDPf650HjF-NyD4ARVlA4w"
    private let clientSecret = "oVFp1ZwgNE_uNsF9b0Rz3hhbGg05zS-gd3boekX2aks"
    private let authURL = URL(string: "https://apx.didit.me/auth/v2/token/")!
    private let sessionURL = URL(string: "https://verification.didit.me/v1/session")!
    private var accessToken: String?
    private var tokenExpiryDate: Date?
    
    private init() {}
    
    // MARK: - Authenticate and get access token
    func authenticate(completion: @escaping (Result<String, Error>) -> Void) {
        let credentials = "\(clientID):\(clientSecret)"
        guard let credentialData = credentials.data(using: .utf8) else {
            completion(.failure(NSError(domain: "EncodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to encode credentials"])))
            return
        }
        let base64Credentials = credentialData.base64EncodedString()
        
        var request = URLRequest(url: authURL)
        request.httpMethod = "POST"
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyString = "grant_type=client_credentials"
        request.httpBody = bodyString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let token = json["access_token"] as? String,
                   let expiresIn = json["expires_in"] as? Double {
                    self.accessToken = token
                    self.tokenExpiryDate = Date().addingTimeInterval(expiresIn)
                    completion(.success(token))
                } else if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let message = json["message"] as? String {
                    completion(.failure(NSError(domain: "DiditError", code: 0, userInfo: [NSLocalizedDescriptionKey: message])))
                } else {
                    completion(.failure(NSError(domain: "ParseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Create verification session
    func createVerificationSession(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        
        // Check token validity or re-authenticate
        func proceed(withToken token: String) {
            
            var request = URLRequest(url: sessionURL)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let firstName = UserDefaults.standard[.loggedUserDetails]?.firstName ?? ""
            let lastName = UserDefaults.standard[.loggedUserDetails]?.lastName ?? ""
            let completeName = firstName + " " + lastName
            
            let body: [String: Any] = [
                //"callback": "young://callback",
                "vendor_data": UserDefaults.standard[.loggedUserDetails]?._id ?? "123",
                "full_name": completeName
            ]

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                completion(.failure(error))
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "NoDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        completion(.success(json))
                    } else {
                        completion(.failure(NSError(domain: "ParseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
        
        // Check if token exists and valid
        if let token = accessToken,
           let expiry = tokenExpiryDate,
           expiry > Date() {
            proceed(withToken: token)
        } else {
            // Need to re-authenticate
            authenticate { result in
                switch result {
                case .success(let token):
                    proceed(withToken: token)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
