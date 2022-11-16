//
//  KeychainManager.swift
//

import Foundation
import KeychainAccess

protocol KeychainManaging: AnyObject {
    func set(value: String, atKey key: KeychainKey)
    func setObject<T: Codable>(object: T, atKey key: KeychainKey) throws

    func getValue(atKey key: KeychainKey) -> String?
    func getObject<T: Codable>(atKey key: KeychainKey) throws -> T?

    func removeValue(atKey key: KeychainKey) throws
}

enum KeychainKey: String {
    case userCredentials
}

class KeychainManager {
    private static let decoder = JSONDecoder()
    private static let encoder = JSONEncoder()

    private let keychain = Keychain(service: Constants.Keychain.serviceName)
}

extension KeychainManager: KeychainManaging {
    func set(value: String, atKey key: KeychainKey) {
        keychain[key.rawValue] = value
    }

    func setObject<T: Codable>(object: T, atKey key: KeychainKey) throws {
        let data = try Self.encoder.encode(object)
        try keychain.set(data, key: key.rawValue)
    }

    func getObject<T: Decodable>(atKey key: KeychainKey) throws -> T? {
        guard let data = try keychain.getData(key.rawValue) else {
            return nil
        }

        let object = try Self.decoder.decode(T.self, from: data)
        return object
    }

    func getValue(atKey key: KeychainKey) -> String? {
        keychain[key.rawValue]
    }

    func removeValue(atKey key: KeychainKey) throws {
        try keychain.remove(key.rawValue)
    }
}
