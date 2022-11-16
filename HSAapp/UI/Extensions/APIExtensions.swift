//
//  APIExtensions.swift
//

import Foundation

@propertyWrapper struct DecodableBool: Codable {
    var wrappedValue: Bool = false

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Int.self)
        wrappedValue = value == 1 ? true : false
    }
    
    init(wrappedValue: Bool) {
        self.wrappedValue = wrappedValue
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let value = wrappedValue == true ? 1 : 0
        try container.encode(value)
    }
}

@propertyWrapper struct EpochDate: Codable {
    var wrappedValue: Date

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value: Int = try container.decode(Int.self)
        let doubleValue: TimeInterval = Double(value) as TimeInterval
        wrappedValue = Date(timeIntervalSince1970: doubleValue)
    }
    
    init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let value = wrappedValue.timeIntervalSince1970
        try container.encode(value)
    }
}


class EnumMap<Key: Equatable, Value: Equatable> {
    typealias EnumMapping = (Key, Value)
    let keys: [Key]
    let values: [Value]
    
    init(_ mappings: EnumMapping...) {
        var initKeys = [Key]()
        var initValues = [Value]()
        mappings.forEach { mapping in
            initKeys.append(mapping.0)
            initValues.append(mapping.1)
        }
        self.keys = initKeys
        self.values = initValues
    }
    
    func keyFor(_ value: Value) -> Key? {
        if let index = values.firstIndex(where: { $0 == value }) {
            return keys[index]
        }
        return nil
    }
    
    func valueFor(_ key: Key) -> Value? {
        if let index = keys.firstIndex(where: { $0 == key }) {
            return values[index]
        }
        return nil
    }
}
