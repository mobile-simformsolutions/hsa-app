//
//  EverydayAccountViewModel.swift
//  Zenda
//
//  Created by Jan Kodeš on 18.08.2021.
//

import Foundation
import SwiftUI
import Resolver

final class EverydayAccountViewModel: ObservableObject {
    let balanceLabel = "Everyday Balance"
    @Published var displayBalance: String = ""
    @Published var balanceUpdateDate: String = ""
    @Published var routingNumber: String = ""
    @Published var accountNumber: String = ""

    @Published var transactionsSections: [TransactionSection] = []
    @Published var pendingTransactions: [TransactionSummaryViewModel] = []

    @Published var retryAlert: AlertConfiguration?

    @Published var listState: TransactionListState = .items(moreAvailable: false)
    @Published var isLoading = false
    @Published var openFundEverydayAccountView = false
    @Published var shouldDisplayLoading = true

    private let dateFormatter = DateFormatter()
    private let currencyFormatter = NumberFormatter.defaultCurrencyFormatter()

    @Injected private var repositoryService: RepositoryService

    init() {
        setup()
        loadData()
    }

    func setup() {
        displayBalance = currencyFormatter.string(from: NSNumber(value: 00))! // swiftlint:disable:this force_unwrapping

        dateFormatter.dateFormat = "EEEE, MMM d"
        balanceUpdateDate = dateFormatter.string(from: Date())
    }

    func loadData(completion: (() -> Void)? = nil) {
        guard listState != .loading else {
            RefreshScreen.shouldRefreshEveryDayAccountScreen = false
            completion?()
            return
        }

        // We only want to display placeholder + loading for the first time
        isLoading = shouldDisplayLoading
        listState = .loading

        repositoryService.accountDetails(accountType: .everyday) { [weak self] result in
            defer {
                self?.shouldDisplayLoading = false
            }

            switch result {
            case let .success(details):
                self?.updateBalance(from: details)
                self?.updateRoutingNumbers(from: details)
                self?.updateTransactions(from: details)

                self?.listState = .items(moreAvailable: details.transactions.count >= Constants.loadMoreLimit)
            case let .failure(error):
                Log(.error, message: error.localizedDescription)

                self?.retryAlert = Alert.fetchAlertConfiguration(
                    error,
                    retryBlock: { [weak self] in
                        self?.loadData(completion: completion)
                    }
                )
                self?.listState = .items(moreAvailable: false)
            }

            RefreshScreen.shouldRefreshEveryDayAccountScreen = false
            self?.isLoading = false
            completion?()
        }
    }

    func loadMore(completion: (() -> Void)? = nil) {
        guard listState != .loading else {
            completion?()
            return
        }

        listState = .loading

        repositoryService.transactions(for: .everyday, offset: transactionCount(), limit: Constants.loadMoreLimit) { [weak self] result in
            onMain {
                switch result {
                case .failure(let error):
                    Log(.error, message: "\(error.localizedDescription)")

                    self?.retryAlert = Alert.fetchAlertConfiguration(
                        error,
                        closeButtonBlock: { [weak self] in
                            self?.listState = .items(moreAvailable: true)

                        },
                        retryBlock: { [weak self] in
                        self?.loadMore(completion: completion)
                    })
                case .success(let transactions):
                    if transactions.isEmpty {
                        self?.listState = .items(moreAvailable: false)
                    } else {
                        self?.listState = .items(moreAvailable: transactions.count >= Constants.loadMoreLimit)
                        let transactionList = transactions.map { TransactionSummaryDataModel(transactionSummary: $0) }
                        self?.addTransactions(transactionList)
                    }

                    completion?()
                }
            }
        }
    }

    func refresh(completion: @escaping () -> Void) {
        loadData(completion: completion)
    }
}

// MARK: - UI Data

private extension EverydayAccountViewModel {
    func updateBalance(from accountDetails: AccountDetails) {
        displayBalance = currencyFormatter.string(from: NSNumber(value: accountDetails.balance)) ?? "-"
        balanceUpdateDate = dateFormatter.string(from: Date())
    }

    func updateRoutingNumbers(from accountDetails: AccountDetails) {
        accountNumber = accountDetails.accountNumber
        routingNumber = accountDetails.routingNumber
    }

    func updateTransactions(from accountDetails: AccountDetails) {
        let transactions = Array(accountDetails.transactions).map { TransactionSummaryDataModel(transactionSummary: $0) }
        addTransactions(transactions)

        pendingTransactions = Array(accountDetails.pendingTransactions)
            .sorted { $0.date > $1.date }
            .map {
                TransactionSummaryViewModel(
                    iconName: ($0.indicator == .withdrawal) ? "reimbursement":"deposit",
                    iconColor: .transactionDefault,
                    title: $0.indicator.displayText,
                    subtitle: ($0.indicator == .withdrawal) ? "From Everyday":"to Everyday",
                    displayAmount: ($0.indicator == .withdrawal ? "-" : "") + (NumberFormatter.defaultCurrencyFormatter().string(from: $0.amount) ?? ""),
                    amountColor: .transactionDefault,
                    needsAttention: false,
                    hasZGuarantee: false,
                    displayDate: TransactionSummaryViewModel.dateFormatter.string(from: $0.date),
                    allowNavigationToDetails: false
                )
            }
    }
}

// MARK: - TransactionsManaging

extension EverydayAccountViewModel: TransactionsManaging {}

// MARK: - Contants

extension EverydayAccountViewModel {
    enum Constants {
        static let loadMoreLimit = 10
    }
}

extension EverydayAccountViewModel {
    enum State: Equatable {
        case initial
        case success
        case failed(errorMessage: String)
    }
}
