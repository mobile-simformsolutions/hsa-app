//
//  StatementSummary.swift
//  Zenda
//
//  Created by Chaitali Lad on 21/01/22.
//

import Foundation

struct StatementSummary: Decodable, Identifiable, Hashable {
    
    static func == (lhs: StatementSummary, rhs: StatementSummary) -> Bool {
        return lhs.id == rhs.id && lhs.date == rhs.date
    }
    
    var id: String  = "Unknown"
    var date: Date = Date()
    var presignedURLString: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case presignedURLString
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        let rawDate = try container.decode(Double.self, forKey: .date)
        self.date = Date(timeIntervalSince1970: rawDate)
        self.presignedURLString = try container.decode(String.self, forKey: .presignedURLString)
    }
}
