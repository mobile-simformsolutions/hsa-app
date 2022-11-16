//
//  EnumDecodable.swift
//

import Foundation

protocol EnumDecodable: RawRepresentable, Decodable {
    static var defaultDecoderValue: Self { get }
}

extension EnumDecodable where RawValue: Decodable {
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(RawValue.self)
        self = Self(rawValue: value) ?? Self.defaultDecoderValue
    }
}
