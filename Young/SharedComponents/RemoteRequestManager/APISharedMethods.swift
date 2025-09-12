import UIKit
import Foundation

class APISharedMethods {
    
    static var shared = APISharedMethods()
    
    func appleDeviceId() -> String {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "NO_APPLE_DEVICE_IDENTIFIER"
        return deviceId
    }
    
    func basicAuth(_ userName: String, _ password: String) -> String {
        let credentialString = "\(userName):\(password)"
        guard let credentialData = credentialString.data(using: String.Encoding.utf8) else { return "" }
        let base64Credentials = credentialData.base64EncodedString(options: [])
        return base64Credentials
    }
    
    func requestURL(request: URLRequest) -> String {
        return request.url?.absoluteString ?? "null_url".localized()
    }
    
    func parseError(_ error: Error) -> String {
        guard let decodingError = error as? DecodingError else { return "data_not_parseable_to_string".localized() }
        let err = "\(decodingError)"
        let errDesc = String(format: "parse_error_message".localized(), arguments: [err])
        return errDesc
    }
    
    func jsonDataToString(_ jsonData: Data?) {
        guard let jsonData = jsonData else { return }
        let _ = String(data: jsonData, encoding: .utf8)
    }
    
    func arrStringDictToString(_ dict: [[String: String]]) -> String? {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(dict) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        }
        return nil
    }
    
    func stringAnyDictToStringDict(_ dict: [String: Any]) -> [String: String] {
        var newDict = [String: String]()
        for (key, value) in dict { newDict[key] = "\(value)" }
        return newDict
    }
    
    func generateModelData<T: Codable>(_ value: T) -> Data? {
        do {
            let jsonData = try JSONEncoder().encode(value)
            return jsonData
        } catch {
            LogHandler.reportLogOnConsole(
                nil,
                "unable_to_generate_data_from_model".localized()
            )
        }
        return nil
    }
    
    func generateModelRawJson<T: Codable>(_ value: T) -> [String: Any]? {
        guard let data = generateModelData(value) else { return nil }
        if let rawJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] { return rawJson }
        return nil
    }
    
    func remoteRequestBaseURL(for socket: Bool = false) -> String? {
        let info = VaultInfo.shared.getKeyValue(by: "App_Environment")
        guard
            let dict = info.0,
            let keyValue = info.1 as? [String: Bool],
            let env = keyValue.first(where: { $0.value })?.key
        else {
            LogHandler.reportLogOnConsole(nil, "empty_app_environment_err_msg".localized())
            return nil
        }
        
        let key = "\(env)_Base_URL"
        var baseURL = ""
        
        guard let url = dict[key] as? String, !url.isEmpty
        else {
            LogHandler.reportLogOnConsole(nil, String(format: "empty_base_url_err_msg".localized(), [key]))
            return nil
        }
        
        baseURL = url
        
        let tail = dict["Base_URL_Tail"] as? String ?? ""
        if !tail.isEmpty && socket == false {
            baseURL = "\(baseURL)\(tail)"
        }
        
        return baseURL
    }
    
    func socketHostURL() -> String {
        return remoteRequestBaseURL(for: true) ?? ""
    }
    
    func remoteRequestXApiKey() -> String? {
        let info = VaultInfo.shared.getKeyValue(by: "App_Environment")
        guard
            let dict = info.0,
            let keyValue = info.1 as? [String: Bool],
            let env = keyValue.first(where: { $0.value })?.key
        else {
            LogHandler.reportLogOnConsole(nil, "empty_app_environment_err_msg".localized())
            return nil
        }
        
        let key = "\(env)_X_API_Key"
        guard let url = dict[key] as? String, !url.isEmpty
        else {
            LogHandler.reportLogOnConsole(nil, String(format: "empty_base_url_err_msg".localized(), [key]))
            return nil
        }
        
        return url
    }
}
