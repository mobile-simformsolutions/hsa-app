//
//  Logging.swift
//

import Foundation
import Firebase
import FirebaseAnalytics
import CocoaLumberjack

enum LogLevel {
    case verbose, info, debug, error
}

// swiftlint:disable:next identifier_name
func Log(_ level: LogLevel, message: String) {
    Logging.shared.log(level, message: message)
}

// swiftlint:disable:next identifier_name
func Log(_ level: LogLevel, message: () -> String) {
    Log(level, message: message())
}

class Logging {
    static var shared = Logging()
    
    private init() {
        cocoaLoggerSetup()
    }
    
    private func cocoaLoggerSetup() {
        DDLog.add(DDOSLogger.sharedInstance)
        let fileLogger = DDFileLogger()
        fileLogger.rollingFrequency = 60 * 60 * 24
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
    }

    public func log(_ level: LogLevel, message: String) {
        switch level {
        case .verbose:
            DDLogVerbose(message)
        case .info:
            DDLogInfo(message)
        case .debug:
            DDLogDebug(message)
        case .error:
            DDLogError(message)
        }
    }
    
    public func logData() -> String {
        let logFilePaths = DDFileLogger().logFileManager.sortedLogFilePaths
        if let filePath = logFilePaths.first {
            let fileURL = URL(fileURLWithPath: filePath)
            do {
                let logContents = try String(contentsOf: fileURL, encoding: .utf8)
                return logContents
            } catch {
                return "No Log Data: Error reading logs"
            }
        } else {
            return "No Log Data"
        }
//        for logFilePath in logFilePaths {
//            let fileURL = NSURL(fileURLWithPath: logFilePath)
//            if let logFileData = try? NSData(contentsOfURL: fileURL, options: NSDataReadingOptions.DataReadingMappedIfSafe) {
//                // Insert at front to reverse the order, so that oldest logs appear first.
//                logFileDataArray.insert(logFileData, atIndex: 0)
//            }
//        }
//        return logFileDataArray
    }
}
