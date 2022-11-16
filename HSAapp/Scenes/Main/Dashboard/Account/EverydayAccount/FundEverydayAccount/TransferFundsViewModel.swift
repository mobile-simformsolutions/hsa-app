//
//  TransferFundsViewModel.swift
//  Zenda
//
//  Created by Chaitali Lad on 15/02/22.
//

import Foundation
import SwiftUI
import Resolver
import Combine

enum EverydayTabs: String, CaseIterable {
    case transactions = "Transactions"
    case transferFunds = "Transfer Funds"
}

class TransferFundsViewModel: ObservableObject {
    
    @Injected private var repositoryService: RepositoryService
    private var subscribers: Set<AnyCancellable> = []

    @Published var initialLoad = true
    @Published var retryAlert: AlertConfiguration?
    @Published var transferFundButtonState: ButtonState
    @Published var account: Account?
    @Published var fromAccount: String = ""
    @Published var toAccount: String = ""
    @Published var amount: String = ""
    @Published var fromAccountValidationResult: ValidationResult = .unknown
    @Published var toAccountValidationResult: ValidationResult = .unknown
    @Published var amountValidationResult: ValidationResult = .unknown
    @Published var shouldDisplayValidationResult: Bool = false
    @Published var shouldTransferFromDDAToExternal: Bool = false
    @Published var showSuccessView: Bool = false
    @Published var goToSpecificView: Bool = false
    @Published var isBalanceEnough: Bool = false
    @Published var showSpinner: Bool = false
    
    var everydayAccountName = ""
    var externalAccountName = ""
    let transferFundButtonLabel = "Transfer Funds".uppercased()
    let fromLabel = "From: "
    let toLabel = "To: "
    var previouslyEnteredAmount: String = ""
    let minimumAmountLimit: Double = 10
    
    init(goToSpecificView: Bool) {
        self.goToSpecificView = goToSpecificView
        transferFundButtonState = .normal(transferFundButtonLabel)
    }
    
    init(goToSpecificView: Bool, _ accountDetails: Account) {
        self.goToSpecificView = goToSpecificView
        account = accountDetails
        transferFundButtonState = .normal(transferFundButtonLabel)
        setupUI()
    }
    
    func setupUI() {
        updateAccountLabels()
        $amount.sink { (amountText) in
            self.checkAmountValidation(amountText)
        }.store(in: &subscribers)
    }

    func updateAccountLabels() {
        guard let account = account else {
            return
        }
        everydayAccountName = "Zenda Everyday ……" + String(account.ddaAccountNumber.suffix(4))
        externalAccountName = account.bankName + " ……" + String(account.accountNumber.suffix(4))
        if shouldTransferFromDDAToExternal {
            fromAccount = fromLabel + everydayAccountName
            toAccount = toLabel + externalAccountName
        } else {
            fromAccount = fromLabel + externalAccountName
            toAccount = toLabel + everydayAccountName
        }
        checkAmountValidation(amount)
    }
    
    func checkAmountValidation(_ amountText: String) {
        if self.shouldTransferFromDDAToExternal && !self.isBalanceEnough {
            self.amountValidationResult = .unknown
            self.transferFundButtonState =  .disabled(self.transferFundButtonLabel)
        } else if amountText.isEmpty {
            self.amountValidationResult = .error
            self.transferFundButtonState =  .error("Enter amount")
        } else {
            if TextValidation.validateAmount(amountText) == .valid, let amountValue = Double(amountText) {
                self.previouslyEnteredAmount = amountText
                if amountValue < self.minimumAmountLimit {
                    self.amountValidationResult = ValidationResult.error
                    self.transferFundButtonState = .error("$\(self.minimumAmountLimit) Minimum")
                } else {
                    self.amountValidationResult = ValidationResult.valid
                    self.transferFundButtonState = .normal(self.transferFundButtonLabel)
                }
            } else {
                onMain {
                    self.amount = self.previouslyEnteredAmount
                }
            }
        }
    }
    
    func transferFunds() {
        shouldDisplayValidationResult = true
        guard let account = account, amountValidationResult == .valid, let amount = Decimal(string: amount) else {
            return
        }
        let transferType: FundTransactionType = shouldTransferFromDDAToExternal ? .credit : .debit
        let fundAccountInfo = FundAccount(externalBankAccountID: account.accountID, transactionType: transferType, reloadType: .oneTime, amount: amount)

        transferFundButtonState = .processing("Processing")
        showSpinner = true
        repositoryService.loadMoney(fundAccountRequest: fundAccountInfo) { [weak self] result in
            onMain {
                guard let self = self else {
                    return
                }
                defer {
                    self.showSpinner = false
                }
                switch result {
                case .failure(let error):
                    Log(.error, message: "\(error.localizedDescription)")

                    if let error = error as? APIError {
                        switch error {
                        case .noNetwork, .requestTimeout, .serverError:
                            self.transferFundButtonState = .normal(self.transferFundButtonLabel)
                            self.retryAlert = Alert.fetchAlertConfiguration(error, retryBlock: { [weak self] in
                                self?.transferFunds()
                            })
                        default:
                            if !error.errorDescription().isEmpty {
                                self.transferFundButtonState = .error(error.errorDescription())
                            } else {
                                self.transferFundButtonState = .errorFrom("Amount")
                            }
                        }
                    } else {
                        self.transferFundButtonState = .errorFrom("Amount")
                    }
                case .success:
                    self.transferFundButtonState = .normal(self.transferFundButtonLabel)
                    self.showSuccessView = true
                    RefreshScreen.shouldRefreshEveryDayAccountScreen = true
                }
            }
        }
    }
    
    func getExternalLinkedBankAccount() {
        showSpinner = initialLoad
        repositoryService.getExternalBankAccount(accountType: .bankAccount, completion: { [weak self] result in
            onMain {
                guard let self = self else {
                    return
                }
                switch result {
                case .failure(let error):
                    self.showSpinner = false
                    if let error = error as? APIError {
                        switch error {
                        case .notFound:
                            self.retryAlert = AlertConfiguration(title: "Error", message: "No linked account found", buttons: [ .default(Text("Ok"), action: {
                                NavigationUtil().popToRootView()
                            })])
                        case .noNetwork, .requestTimeout, .serverError:
                            self.retryAlert = Alert.fetchAlertConfiguration(error, retryBlock: { [weak self] in
                                self?.getExternalLinkedBankAccount()
                            })
                        default:
                            self.retryAlert = AlertConfiguration(title: "Error", message: error.errorDescription(), buttons: [ .default(Text("Please try again"), action: {
                                self.getExternalLinkedBankAccount()
                            }), .cancel()])}
                    } else {
                        self.retryAlert = AlertConfiguration(title: "Error", message: error.localizedDescription, buttons: [ .default(Text("Please try again"), action: {
                            self.getExternalLinkedBankAccount()
                        }), .cancel()])
                    }
                    Log(.error, message: "\(error.localizedDescription)")
                case .success(let data):
                    if let accountDetails = data.first {
                        self.account = accountDetails
                        self.loadEverydayAccountData()
                    }
                }
            }
        })
    }
    
    func loadEverydayAccountData() {
        showSpinner = initialLoad
        repositoryService.accountBalance(accountType: .everyday, completion: { [weak self] result in
            onMain {
                defer {
                    self?.showSpinner = false
                }
                switch result {
                case let .success(details):
                    self?.isBalanceEnough = details.balance > 0
                    self?.setupUI()
                    self?.initialLoad = false
                case let .failure(error):
                    if let error = error as? APIError {
                        switch error {
                        case .noNetwork, .requestTimeout, .serverError:
                            self?.retryAlert = Alert.fetchAlertConfiguration(error, retryBlock: { [weak self] in
                                self?.loadEverydayAccountData()
                            })
                        default:
                            self?.retryAlert = AlertConfiguration(title: "Error", message: error.errorDescription(), buttons: [ .default(Text("Please try again"), action: {
                                self?.loadEverydayAccountData()
                            }), .cancel()])}
                    } else {
                        self?.retryAlert = AlertConfiguration(title: "Error", message: error.localizedDescription, buttons: [ .default(Text("Please try again"), action: {
                            self?.loadEverydayAccountData()
                        }), .cancel()])
                    }
                    Log(.error, message: error.localizedDescription)
                }
            }
        })
    }
    
    func formattedTransferedAmount() -> String {
        let value = Double(amount) ?? 0
        return String(format: "%.2f", value)
    }
}
