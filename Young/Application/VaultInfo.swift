import Foundation

final class VaultInfo {
    
    static var shared = VaultInfo()
    
    func getKeyValue(by key: String) -> (NSDictionary?, Any?) {
        guard let path = Bundle.main.path(forResource: "AppVault", ofType: "plist")
        else { return (nil, nil) }
        let dict = NSDictionary(contentsOfFile: path)
        let keyValue = dict?[key] as? Any
        return (dict, keyValue)
    }
}
