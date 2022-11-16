//
//  AlertExtension.swift
//

import SwiftUI

struct AlertConfiguration: Identifiable {
    init(id: UUID = UUID(),
         title: String,
         message: String,
         buttons: [Alert.Button],
         error: Error? = nil,
         closeButtonAction: (() -> Void)? = nil,
         retryAction: (() -> Void)? = nil
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.buttons = buttons
        self.error = error
        self.closeButtonAction = closeButtonAction
        self.retryAction = retryAction
    }

    var id = UUID()
    
    var title: String
    var message: String
    var buttons: [Alert.Button]
    var error: Error?
    var closeButtonAction: (() -> Void)?
    var retryAction: (() -> Void)?
}

extension Alert {
    static func configure(_ configuration: AlertConfiguration) -> Alert {
        if
            configuration.buttons.count == 2,
            let firstButton = configuration.buttons.first,
            let secondButton = configuration.buttons.last
        {
            return Alert(
                title: Text(configuration.title),
                message: Text(configuration.message),
                primaryButton: firstButton,
                secondaryButton: secondButton
            )
        } else if configuration.buttons.count == 1, let firstButton = configuration.buttons.first {
            return Alert(
                title: Text(configuration.title),
                message: Text(configuration.message),
                dismissButton: firstButton
            )
        } else {
            return Alert(
                title: Text(configuration.title),
                message: Text(configuration.message),
                dismissButton: nil
            )
        }
    }
    
    static func fetchAlertConfiguration(_ retryBlock: @escaping () -> Void) -> AlertConfiguration {
        AlertConfiguration(
            title: "Issue loading data",
            message: "There was a problem loading your data",
            buttons: [
                .cancel(),
                .default(Text("Try Again"), action: {
                    onMain {
                        retryBlock()
                    }
                })
            ],
            error: nil,
            retryAction: retryBlock
        )
    }

    static func fetchAlertConfiguration(
        _ error: Error,
        closeButtonBlock: (() -> Void)? = nil,
        retryBlock: @escaping () -> Void
    ) -> AlertConfiguration {
        var errorMsg: String
        if let apiError = error as? APIError {
            errorMsg = apiError.alertDescription()
        } else {
            errorMsg = error.localizedDescription
        }

        return AlertConfiguration(
            title: "Issue loading data",
            message: "There was a problem loading your data\n\(errorMsg)",
            buttons: [
                .cancel(),
                .default(Text("Try Again"), action: {
                    onMain {
                        retryBlock()
                    }
                })
            ],
            error: error,
            closeButtonAction: closeButtonBlock,
            retryAction: retryBlock
        )
    }
}
