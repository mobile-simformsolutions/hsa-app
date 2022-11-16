//
//  Bundle+Version.swift
//

import Foundation

extension Bundle {
    
    var shortVersion: String {
        if let result = infoDictionary?["CFBundleShortVersionString"] as? String {
            return result
        } else {
            assert(false)
            return ""
        }
    }
    
    var buildVersion: String {
        if let result = infoDictionary?["CFBundleVersion"] as? String {
            return result
        } else {
            assert(false)
            return ""
        }
    }
    
    var fullVersion: String {
        return "\(shortVersion) (\(buildVersion))"
    }
    
    func checkForForceUpgrade(minVersion: String) -> Bool {
        var valueToReturn  = false
        let current = self.shortVersion
        let versionCompare = current.compare(minVersion, options: .numeric)
        if versionCompare == .orderedAscending {
            // ask user to update
            valueToReturn = true
        }
        return valueToReturn
    }
}
