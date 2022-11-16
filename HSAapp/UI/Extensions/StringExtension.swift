//
//  StringExtension.swift
//

import Foundation

extension String {
    
    func getURL() -> URL? {
        let detectorType: NSTextCheckingResult.CheckingType = [.link]
        do {
            let detector = try NSDataDetector(types: detectorType.rawValue)
            let results = detector.matches(in: self, options: [], range: NSRange(location: 0, length:
                                                                                        self.utf16.count))
            if let result = results.first, let range = Range(result.range, in: self) {
                let urlString = self[range]
                if let url = URL(string: String(urlString)) {
                    return url
                }
            }
        } catch {
            print("Error")
        }
        return nil
    }
}

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
