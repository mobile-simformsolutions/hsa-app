//
//  ContributionSummaryDataModel.swift
//

import Foundation

struct ContributionSummaryDataModel {
    var amount: Double = 0
    var maxAmount: Double = 0
    var previousYearEligible: Bool = false
    let year: Int?
    var previousYearDetails: PreviousYearContributionSummaryDataModel?
    
    init(contributionSummary: ContributionSummary) {
        self.amount = contributionSummary.amount
        self.maxAmount = contributionSummary.maxAmount
        self.year = contributionSummary.year.value
        if let previousYearDetails = contributionSummary.previousYearDetails {
            self.previousYearDetails = PreviousYearContributionSummaryDataModel(data: previousYearDetails)
        } else {
            self.previousYearDetails = nil
        }
    }
}

struct PreviousYearContributionSummaryDataModel {
    var amount: Double = 0
    var maxAmount: Double = 0
    let year: Int?
    
    init(data: PreviousYearContributionSummary) {
        self.amount = data.amount
        self.maxAmount = data.maxAmount
        self.year = data.year.value
    }
}
