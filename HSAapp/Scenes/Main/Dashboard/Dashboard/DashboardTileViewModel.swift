//
//  DashboardTileViewModel.swift
//

import SwiftUI

class DashboardTileViewModel: ObservableObject {
    
    // MARK: - Variables
    //
    private let currencyFormatter = NumberFormatter.defaultCurrencyFormatter()
    var accountSummary: AccountSummaryDataModel?
    var title: String = ""
    var subtitle: String = ""
    var displayAmount: String = ""
    var imageName: String = ""
    var imageBackgroundColor: Color = Color.white
    
    init(accountSummary: AccountSummaryDataModel) {
        self.accountSummary = accountSummary
        let amount = NSNumber(value: accountSummary.amount)
        self.displayAmount = currencyFormatter.string(from: amount) ?? ""
        self.title = titleFor(accountSummary)
        self.subtitle = subtitleFor(accountSummary)
        self.imageBackgroundColor = backgroundFor(accountSummary)
        self.imageName = iconFor(accountSummary)
    }
}

// MARK: Title
extension DashboardTileViewModel {
    func titleFor(_ accountSummary: AccountSummaryDataModel) -> String {
        switch accountSummary.type {
        case .everyday:
            return everydayTitle(accountSummary)
        case .hsa:
            return hsaTitle(accountSummary)
        }
    }
    
    private func hsaTitle(_ accountSummary: AccountSummaryDataModel) -> String {
        return accountSummary.amount > 0 ? appString.hsaSpending() : appString.fundYourHSA()
    }
    
    private func everydayTitle(_ accountSummary: AccountSummaryDataModel) -> String {
        return appString.everydaySpending()
    }
}


// MARK: subtitle
extension DashboardTileViewModel {
    func subtitleFor(_ accountSummary: AccountSummaryDataModel) -> String {
        switch accountSummary.type {
        case .everyday:
            return tileSubtitle(accountSummary)
        case .hsa:
            return tileSubtitle(accountSummary)
        }
    }
    
    private func tileSubtitle(_ accountSummary: AccountSummaryDataModel) -> String {
        switch accountSummary.type {
        case .hsa:
            return accountSummary.amount > 0 ? appString.currentBalance() : appString.setYourContrinution()
        case .everyday:
            return appString.currentBalance()
        }
    }
}

// MARK: image
extension DashboardTileViewModel {
    func iconFor(_ accountSummary: AccountSummaryDataModel) -> String {
        switch accountSummary.type {
        case .everyday:
            return "everydayAccount"
        case .hsa:
            return "healthSavingsAccount"
        }
    }
}

// MARK: background
extension DashboardTileViewModel {
    func backgroundFor(_ accountSummary: AccountSummaryDataModel) -> Color {
        switch accountSummary.type {
        case .hsa:
            if accountSummary.amount > 0 {
                return Color.activeState
            } else {
                return Color.actionNeededState
            }
        case .everyday:
            return Color.activeState
        }
    }
}
