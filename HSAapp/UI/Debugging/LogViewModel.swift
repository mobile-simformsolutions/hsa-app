//
//  LogViewModel.swift
//

import SwiftUI
import MessageUI

class LogViewModel: ObservableObject {
    
    @Published var canSendEmail = MFMailComposeViewController.canSendMail()
    @Published var sendEmailLabel = MFMailComposeViewController.canSendMail() ? appString.sendText() : appString.configureEmail()
    
    var logData: String {
        let logs = Logging.shared.logData()
        return logs
    }
    
    func logs() -> Data? {
        return logData.data(using: .utf8)
    }
    
    func sendPressed() {
        
    }
}
