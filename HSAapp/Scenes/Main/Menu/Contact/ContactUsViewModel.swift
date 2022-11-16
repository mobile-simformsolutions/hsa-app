//
//  ContactUsViewModel.swift
//

import Foundation
import Resolver
import SwiftUI

class ContactUsViewModel: ObservableObject {
    
    // MARK: - Variables
    //
    let imageName = "ContactUsIcon"
    let title = "Contact us!"
    let subtitle = "We’re here to help make sure you have a great experience with HSA!"
    let buttonText = "Send Message"

    @Published var goToNextView = false
    @Published var goToDashboard = false
    @Published var formText: String = ""
    @Published var sendButtonState: ButtonState
    @Published var buttonValidationState: ValidationResult = .unknown
    @Published var showSpinner: Bool = false
    @Published var retryAlert: AlertConfiguration?
    
    @Injected private var repositoryService: RepositoryService
    private let supportRequestType: SupportRequestType
    private let sourceScreenName: SupportSourceScreenName

    init(supportRequestType: SupportRequestType, sourceScreenName: SupportSourceScreenName) {
        self.supportRequestType = supportRequestType
        self.sourceScreenName = sourceScreenName
        sendButtonState = .disabled(buttonText)
    }

    func validateForm(with text: String) {
        sendButtonState = TextValidation.validate(.notNull, input: text) == .valid ? .normal(buttonText) : .disabled(buttonText)
    }

    func sendSupportRequest(completion: @escaping (Result<(), Error>) -> Void) {
        showSpinner = true
        let suffixMessage = " [ Source screen: \(sourceScreenName.rawValue) ] "
        let newMessage = formText + suffixMessage
        let request = SupportRequest(message: newMessage, type: supportRequestType)

        repositoryService.supportRequest(request: request) { [weak self] result in
            onMain {
                defer {
                    self?.showSpinner = false
                }

                switch result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))

                    self?.retryAlert = Alert.fetchAlertConfiguration(error) { [weak self] in
                        self?.sendSupportRequest(completion: completion)
                    }
                }
            }
        }
    }

    func isTextInLimit(newText: String) -> Bool {
        let text = formText
        let isAtLimit = text.count + newText.count <= Constants.messageCharacterLimit
        return isAtLimit
    }
}

private extension ContactUsViewModel {
    enum Constants {
        static let messageCharacterLimit = 2000
    }
}
