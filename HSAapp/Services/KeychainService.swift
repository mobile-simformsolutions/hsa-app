//
//  KeychainService.swift
//

import Foundation

enum KeychainService {
    enum KeychainError: Error {
        // Attempted read for an item that does not exist.
        case itemNotFound

        // Attempted save to override an existing item.
        // Use update instead of save to update existing items
        case duplicateItem

        // A read of an item in any format other than Data
        case invalidItemFormat

        // Any operation result status than errSecSuccess
        case unexpectedStatus(OSStatus)
    }
    
    static let tokenTag = "com.hsapp.tokenKey"
    static let serviceKey = "com.gethsa"
    
    static func save(_ password: String, for account: String) throws {
        guard let dataFromString: Data = password.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
            throw KeychainError.invalidItemFormat
        }
        let query: [String: AnyObject] = [
                // kSecAttrService,  kSecAttrAccount, and kSecClass
                // uniquely identify the item to save in Keychain
                kSecAttrService as String: serviceKey as AnyObject,
                kSecAttrAccount as String: account as AnyObject,
                kSecClass as String: kSecClassGenericPassword,
                
                // kSecValueData is the item value to save
                kSecValueData as String: dataFromString as AnyObject
            ]
            
            // SecItemAdd attempts to add the item identified by
            // the query to keychain
            let status = SecItemAdd(
                query as CFDictionary,
                nil
            )

            // errSecDuplicateItem is a special case where the
            // item identified by the query already exists. Throw
            // duplicateItem so the client can determine whether
            // or not to handle this as an error
            if status == errSecDuplicateItem {
                throw KeychainError.duplicateItem
            }

            // Any status other than errSecSuccess indicates the
            // save operation failed.
            guard status == errSecSuccess else {
                throw KeychainError.unexpectedStatus(status)
            }
        
    }
    
    static func update(password: Data, account: String) throws {
        let query: [String: AnyObject] = [
            // kSecAttrService,  kSecAttrAccount, and kSecClass
            // uniquely identify the item to update in Keychain
            kSecAttrService as String: serviceKey as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword
        ]
        
        // attributes is passed to SecItemUpdate with
        // kSecValueData as the updated item value
        let attributes: [String: AnyObject] = [
            kSecValueData as String: password as AnyObject
        ]
        
        // SecItemUpdate attempts to update the item identified
        // by query, overriding the previous value
        let status = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )

        // errSecItemNotFound is a special status indicating the
        // item to update does not exist. Throw itemNotFound so
        // the client can determine whether or not to handle
        // this as an error
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }

        // Any status other than errSecSuccess indicates the
        // update operation failed.
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    static func delete(forKey: String) throws {
        let query: [String: AnyObject] = [
            // kSecAttrService,  kSecAttrAccount, and kSecClass
            // uniquely identify the item to delete in Keychain
            kSecAttrService as String: serviceKey as AnyObject,
            kSecAttrAccount as String: forKey as AnyObject,
            kSecClass as String: kSecClassGenericPassword
        ]

        // SecItemDelete attempts to perform a delete operation
        // for the item identified by query. The status indicates
        // if the operation succeeded or failed.
        let status = SecItemDelete(query as CFDictionary)

        // Any status other than errSecSuccess indicates the
        // delete operation failed.
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
        
    static func read(forKey: String) throws -> String? {
        let query: [String: AnyObject] = [
            // kSecAttrService,  kSecAttrAccount, and kSecClass
            // uniquely identify the item to read in Keychain
            kSecAttrService as String: serviceKey as AnyObject,
            kSecAttrAccount as String: forKey as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            
            // kSecMatchLimitOne indicates keychain should read
            // only the most recent item matching this query
            kSecMatchLimit as String: kSecMatchLimitOne,

            // kSecReturnData is set to kCFBooleanTrue in order
            // to retrieve the data for the item
            kSecReturnData as String: kCFBooleanTrue
        ]

        // SecItemCopyMatching will attempt to copy the item
        // identified by query to the reference itemCopy
        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(
            query as CFDictionary,
            &itemCopy
        )

        // errSecItemNotFound is a special status indicating the
        // read item does not exist. Throw itemNotFound so the
        // client can determine whether or not to handle
        // this case
        guard status != errSecItemNotFound else {
            return nil
        }
        
        // Any status other than errSecSuccess indicates the
        // read operation failed.
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }

        // This implementation of KeychainInterface requires all
        // items to be saved and read as Data. Otherwise,
        // invalidItemFormat is thrown
        guard let password = itemCopy as? Data else {
            throw KeychainError.invalidItemFormat
        }

        return String(data: password, encoding: .utf8)
    }
}