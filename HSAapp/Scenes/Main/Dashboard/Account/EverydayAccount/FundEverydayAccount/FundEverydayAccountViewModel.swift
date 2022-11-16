//
//  FundEverydayAccountViewModel.swift
//  Zenda
//
//  Created by Chaitali Lad on 09/09/21.
//

import Foundation
import SwiftUI
import RealmSwift
import Resolver

final class FundEverydayAccountViewModel: ObservableObject {
    @Injected private var repositoryService: RepositoryService
    
    let title = "Everyday account settings"
    let subtitle = "Automatically transfer money from your personal checking account into your Zenda Everyday account to use the card for non-medical expenses"
    let oneTimeDepositTitle = "Transfer Funds"
    let oneTimeDepositSubTitle = "Move money between your Everyday and your linked bank account"
    let autoTitle = "Enable auto-reload"
    let autoSubtitle = "Automatically pulls money from your account when balance dips below target"
    let bankInformationTitle = "Bank account information"
    var linkImageName: String = "link"
    var isInitialLoad = true

    @Published var account: Account?
    @Published var alertToShow: AlertConfiguration?
    @Published var recurringEnabled = false
    @Published var accountLinked = false
    @Published var showSpinner: Bool = false
    @Published var ddaRoutingNumber: String = ""
    @Published var ddaAccountNumber: String = ""
    @Published var bankInformation: String = ""
    @Published var linkStatus: String = "Status: "
    @Published var oneTimeDeposit = false
    @Published var openAccountLinkingView = false
    @Published var goToSpecificView = false

    init(goToSpecificView: Bool, accountType: AccountType) {
        self.goToSpecificView = goToSpecificView
        getExternalLinkedBankAccount()
    }
    
    func loadData() {
        if let account = account {
            ddaAccountNumber = account.ddaAccountNumber
            ddaRoutingNumber = account.ddaRoutingNumber
            bankInformation = "External Account......\(account.accountNumber.suffix(4))\n\(account.bankName)\nRouting #: \(account.routingNumber)"
            linkStatus = "Status: " + account.status.stringValue()
            accountLinked = true
        } else {
            accountLinked = false
        }
        openAccountLinkingView = !accountLinked
    }
    
    func getExternalLinkedBankAccount() {
        showSpinner = true

        repositoryService.getExternalBankAccount(accountType: .bankAccount, completion: { [weak self] result in
            onMain {
                guard let self = self else {
                    return
                }
                switch result {
                case .failure(let error):
                    Log(.error, message: "\(error.localizedDescription)")

                    if let error = error as? APIError {
                        switch error {
                        case .notFound:
                            self.account = nil
                            self.loadData()
                        case .noNetwork, .serverError:
                            self.alertToShow = Alert.fetchAlertConfiguration(error, retryBlock: { [weak self] in
                                self?.getExternalLinkedBankAccount()
                            })
                        default:
                            self.alertToShow = AlertConfiguration(
                                title: "Error",
                                message: error.localizedDescription,
                                buttons: [ .default(Text("Please try again"), action: {
                                    self.getExternalLinkedBankAccount()
                                })]
                            )
                        }
                    } else {
                        self.alertToShow = AlertConfiguration(title: "Error", message: error.localizedDescription, buttons: [ .default(Text("Please try again"), action: {
                            self.getExternalLinkedBankAccount()
                        })]
                        )
                    }

                case .success(let data):
                    self.account = data.first
                    self.loadData()
                }

                self.isInitialLoad = false
                self.showSpinner = false
            }
        })
    }
    
    func showUnlinkExternalAccountAlert() {
        self.alertToShow = AlertConfiguration(title: "Unlink your account?",
                                              message: "You will no longer be able to fund your spending account", buttons: [.cancel(), .default(Text("Unlink"), action: { [weak self] in
                                                self?.unlinkExternalLinkedBankAccount()
                                              })])
    }
    
    func oneTimeDepositPressed() {
        oneTimeDeposit = true
    }
    
    func unlinkExternalLinkedBankAccount() {
        showSpinner = true
        repositoryService.unlinkAccount(accountType: .bankAccount) { [weak self] result in
            onMain {
                guard let self = self else {
                    return
                }
                switch result {
                case .failure(let error):
                    Log(.error, message: "\(error.localizedDescription)")

                    if let error = error as? APIError {
                        switch error {
                        case .serverError, .noNetwork:
                            self.alertToShow = Alert.fetchAlertConfiguration(error) {
                                self.unlinkExternalLinkedBankAccount()
                            }
                        default:
                            if !error.errorDescription().isEmpty {
                                self.alertToShow = AlertConfiguration(title: "Error", message: error.errorDescription(), buttons: [.default(Text("OK"))])
                            } else {
                                self.alertToShow = AlertConfiguration(title: "Error", message: "Something went wrong. Please try again!", buttons: [.default(Text("OK"))])
                            }
                        }
                    } else {
                        self.alertToShow = AlertConfiguration(title: "Error", message: "Something went wrong. Please try again!", buttons: [.default(Text("OK"))])
                    }
                case .success(let data):
                    self.alertToShow = AlertConfiguration(title: data.message, message: "", buttons: [.default(Text("Ok"), action: { [weak self] in
                        self?.account = nil
                        self?.loadData()
                    })])
                }
                self.showSpinner = false
            }
        }
    }
}
