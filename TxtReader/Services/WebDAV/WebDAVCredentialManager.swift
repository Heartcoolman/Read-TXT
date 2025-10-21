import Foundation
import Security

class WebDAVCredentialManager {
    static let shared = WebDAVCredentialManager()
    
    private init() {}
    
    // MARK: - Save Credentials
    func saveCredentials(accountID: UUID, username: String, password: String) throws {
        let passwordData = password.data(using: .utf8)!
        let account = accountID.uuidString
        
        // Delete existing item if any
        try? deleteCredentials(accountID: accountID)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: "TxtReader.WebDAV",
            kSecValueData as String: passwordData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unableToSave(status: status)
        }
    }
    
    // MARK: - Retrieve Credentials
    func getPassword(accountID: UUID) throws -> String {
        let account = accountID.uuidString
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: "TxtReader.WebDAV",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let password = String(data: data, encoding: .utf8) else {
            throw KeychainError.unableToRetrieve(status: status)
        }
        
        return password
    }
    
    // MARK: - Delete Credentials
    func deleteCredentials(accountID: UUID) throws {
        let account = accountID.uuidString
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: "TxtReader.WebDAV"
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unableToDelete(status: status)
        }
    }
}

enum KeychainError: Error {
    case unableToSave(status: OSStatus)
    case unableToRetrieve(status: OSStatus)
    case unableToDelete(status: OSStatus)
    
    var localizedDescription: String {
        switch self {
        case .unableToSave(let status):
            return "无法保存到钥匙串 (状态: \(status))"
        case .unableToRetrieve(let status):
            return "无法从钥匙串检索 (状态: \(status))"
        case .unableToDelete(let status):
            return "无法从钥匙串删除 (状态: \(status))"
        }
    }
}

