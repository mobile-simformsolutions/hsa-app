//
//  DashboardSummaryMock.swift
//

import UIKit
import RealmSwift

extension DashboardSummary {
    static func decode<T: Decodable>(json: String, type: T.Type, wrappedInData: Bool) -> T? {
        guard let jsonData = json.data(using: .utf8) else {
            assertionFailure("failed to convert json to data")
            return nil
        }
        let decoder = JSONDecoder()
        if wrappedInData == true {
            do {
                let decoded = try decoder.decode([String: T].self, from: jsonData)
                if let data = decoded["data"] {
                    debugPrint(data)
                    return data
                }
                
            } catch {
                debugPrint(error)
                assertionFailure("failed to decode json to object \(error.localizedDescription)")
                return nil
            }
        }
        
        do {
            let decoded = try decoder.decode(T.self, from: jsonData)
            debugPrint(decoded)
            return decoded
        } catch {
            assertionFailure("failed to decode json to object \(error.localizedDescription)")
            return nil
        }
    }
    
    
    static func mockData() -> DashboardSummary {
        guard let decoded = decode(json: dashboardSummaryMockJson, type: DashboardSummary.self, wrappedInData: true) else {
            fatalError("Failed to decode data")
            
        }
        decoded.combinedBalance = Double.random(in: 1...100000)
        let trans = List<TransactionSummary>()
        trans.append(objectsIn: decoded.recentTransactions[0...Int.random(in: 1...decoded.recentTransactions.count-1)])
        decoded.recentTransactions = trans
        debugPrint(decoded)
        return decoded
    }
    
    static func mockTransactionsData() -> [TransactionSummary] {
        guard let jsonData = transactionsMockJson.data(using: .utf8) else {
            fatalError("Failed to create data")
        }
        
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode([TransactionSummary].self, from: jsonData)
            debugPrint(decoded)
            return decoded
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static func mockAccountSummaryData() -> AccountSummary {
        guard let jsonData = accountSummaryMockJson.data(using: .utf8) else {
            fatalError("Failed to create data")
        }
        
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(AccountSummary.self, from: jsonData)
            debugPrint(decoded)
            return decoded
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

let transactionSummaryMockData = """
                        [
                            {
                              "id": "2753495632634011",
                              "activity": "Dr. Linquist",
                              "description": "Purchase pending",
                              "mode": "debit",
                              "amount": 25.12,
                              "hsa_amount": 25.12,
                              "everyday_amount": 0,
                              "zguarantee": true,
                              "date": 1614004375,
                              "image": "medical",
                              "needs_attention": false,
            "show_details": true,
                            },
                            {
                              "id": "2753495632632312",
                              "activity": "Walgreens",
                              "description": "$10 from HSA",
                              "mode": "debit",
                              "amount": 19.95,
                              "hsa_amount": 10,
                              "everyday_amount": 9.95,
                              "zguarantee": true,
                              "date": 1613745175,
                              "image": "mixed",
                              "needs_attention": false,
            "show_details": true,
                            },
                            {
                              "id": "2753495632632233",
                              "activity": "Contribution/Interest Payment",
                              "description": "to HSA",
                              "mode": "credit",
                              "amount": 250,
                              "hsa_amount": 0,
                              "everyday_amount": 0,
                              "zguarantee": true,
                              "date": 1613226775,
                              "image": "deposit",
                              "needs_attention": false,
            "show_details": false,
                            },
                            {
                              "id": "2753495632632244",
                              "activity": "Reimbursement/Deposit/Interest Payment",
                              "description": "to Everyday",
                              "mode": "credit",
                              "amount": 295,
                              "hsa_amount": 0,
                              "everyday_amount": 0,
                              "zguarantee": true,
                              "date": 1612189975,
                              "image": "reimbursement/deposit",
                              "needs_attention": true,
            "show_details": true,
                            },
                            {
                              "id": "2753495632632615",
                              "activity": "Sharper Image",
                              "description": "$179.99 from HSA",
                              "mode": "debit",
                              "amount": 179.99,
                              "hsa_amount": 179.99,
                              "everyday_amount": 0,
                              "zguarantee": true,
                              "date": 1611757975,
                              "image": "non-medical",
                              "needs_attention": false,
            "show_details": false,
                            },
                            {
                              "id": "2753495632634596",
                              "activity": "Whole Foods",
                              "description": "from Everyday",
                              "mode": "debit",
                              "amount": 126.5,
                              "hsa_amount": 0,
                              "everyday_amount": 126.5,
                              "zguarantee": false,
                              "date": 1611412375,
                              "image": "non-medical",
                              "needs_attention": false,
            "show_details": false,
                            },
                                    {
                                      "id": "2753495632632237",
                                      "activity": "Contribution/Interest Payment",
                                      "description": "to HSA",
                                      "mode": "credit",
                                      "amount": 250,
                                      "hsa_amount": 0,
                                      "everyday_amount": 0,
                                      "zguarantee": true,
                                      "date": 1611153175,
                                      "image": "deposit",
                                      "needs_attention": true,
                    "show_details": false,
                                    },
                                    {
                                      "id": "2753495632632248",
                                      "activity": "Reimbursement/Deposit/Interest Payment",
                                      "description": "to Everyday",
                                      "mode": "credit",
                                      "amount": 295,
                                      "hsa_amount": 0,
                                      "everyday_amount": 0,
                                      "zguarantee": true,
                                      "date": 1610980375,
                                      "image": "reimbursement/deposit",
                                      "needs_attention": false,
                    "show_details": true,
                                    },
                                    {
                                      "id": "2753495632632619",
                                      "activity": "Sharper Image",
                                      "description": "$179.99 from HSA",
                                      "mode": "debit",
                                      "amount": 180.99,
                                      "hsa_amount": 179.99,
                                      "everyday_amount": 0,
                                      "zguarantee": false,
                                      "date": 1610548375,
                                      "image": "non-medical",
                                      "needs_attention": true,
                    "show_details": false,
                                    },
                                    {
                                      "id": "2753495632634510",
                                      "activity": "Whole Foods",
                                      "description": "from Everyday",
                                      "mode": "debit",
                                      "amount": 126.5,
                                      "hsa_amount": 0,
                                      "everyday_amount": 126.5,
                                      "zguarantee": true,
                                      "date": 1609511575,
                                      "image": "non-medical",
                                      "needs_attention": true,
                    "show_details": false,
                                    }
                          ]
    """

let accountSummaryMockJson: String = """
                              {
                                "type": "hsa",
                                "masked_bank_account_number": "XXXXXXXX4561",
                                "amount": 400,
                                "status": "active",
                                "action": "none"
                              }
    """
let dashboardSummaryMockJson: String = """
                    {
                        "data": {
                            "combined_balance": 20819.510000000002,
                            "summary": [
                                {
                                    "type": "hsa",
                                    "masked_bank_account_number": "********6388",
                                    "amount": 19940.22,
                                    "status": "active",
                                    "action": "none"
                                },
                                {
                                    "type": "everyday",
                                    "masked_bank_account_number": "********6396",
                                    "amount": 879.29,
                                    "status": "active",
                                    "action": "link"
                                },
                                {
                                    "type": "investment",
                                    "masked_bank_account_number": "",
                                    "amount": 0,
                                    "status": "inactive",
                                    "action": "none"
                                }
                            ],
                            "contributions": {
                                "amount": 0,
                                "max_amount": 3600,
                                "action": "none"
                            },
                            "transactions": [
                                {
                                    "id": "1ab596c8-737c-4a5f-8759-7bb60c70e4b0",
                                    "activity": "Pharmica Inc.",
                                    "description": "medical",
                                    "mode": "debit",
                                    "amount": 279.20000000000005,
                                    "zguarantee": true,
                                    "date": 1626273335,
                                    "needs_attention": false,
                                    "show_details": true,
                                    "image": "medical"
                                },
                                {
                                    "id": "1ab596c8-737c-4a5f-8759-7bb60c70e4b1",
                                    "activity": "Pharmica Inc.",
                                    "description": "deposit",
                                    "mode": "debit",
                                    "amount": 26.29,
                                    "zguarantee": true,
                                    "date": 1618487722,
                                    "needs_attention": false,
                                    "show_details": true,
                                    "image": "deposit"
                                },
                                {
                                    "id": "1ab596c8-737c-4a5f-8759-7bb60c70e4b2",
                                    "activity": "Stanford Health Care",
                                    "description": "contribution",
                                    "mode": "debit",
                                    "amount": 125,
                                    "zguarantee": true,
                                    "date": 1626273173,
                                    "needs_attention": false,
                                    "show_details": true,
                                    "image": "contribution"
                                },
                                {
                                    "id": "1ab596c8-737c-4a5f-8759-7bb60c70e4b3",
                                    "activity": "Stanford Health Care",
                                    "description": "reimbursement",
                                    "mode": "debit",
                                    "amount": 100,
                                    "zguarantee": true,
                                    "date": 1626273157,
                                    "needs_attention": false,
                                    "show_details": true,
                                    "image": "reimbursement"
                                },
                                {
                                    "id": "1ab596c8-737c-4a5f-8759-7bb60c70e4b4",
                                    "activity": "Stanford Health Care",
                                    "description": "interest-payment",
                                    "mode": "debit",
                                    "amount": 150,
                                    "zguarantee": true,
                                    "date": 1626273097,
                                    "needs_attention": false,
                                    "show_details": true,
                                    "image": "interest-payment"
                                },
                                {
                                    "id": "8d24f956-611a-4655-bb63-de9f16b9e8a2",
                                    "activity": "Deposit",
                                    "description": "mixedPurchase",
                                    "mode": "credit",
                                    "amount": 500,
                                    "zguarantee": false,
                                    "date": 1626273081,
                                    "needs_attention": false,
                                    "show_details": false,
                                    "image": "mixedPurchase"
                                },
                                        {
                                            "id": "8d24f956-611a-4655-bb63-de9f16b9e8a23",
                                            "activity": "Deposit",
                                            "description": "mixed",
                                            "mode": "credit",
                                            "amount": 500,
                                            "zguarantee": false,
                                            "date": 1626273081,
                                            "needs_attention": false,
                                            "show_details": false,
                                            "image": "mixed"
                                        },
                                {
                                    "id": "af96a3f3-abb1-497e-8db5-471515cd90a8",
                                    "activity": "Deposit",
                                    "description": "non-medical",
                                    "mode": "credit",
                                    "amount": 500,
                                    "zguarantee": false,
                                    "date": 1626272974,
                                    "needs_attention": false,
                                    "show_details": false,
                                    "image": "non-medical"
                                },
                                {
                                    "id": "71b4e454-3bc2-4762-af3f-7c3aa64a0624",
                                    "activity": "Deposit",
                                    "description": "reimbursement/deposit",
                                    "mode": "credit",
                                    "amount": 500,
                                    "zguarantee": false,
                                    "date": 1626272909,
                                    "needs_attention": false,
                                    "show_details": false,
                                    "image": "reimbursement/deposit"
                                },
                                {
                                    "id": "ca7f652f-3a79-40b1-b08d-c66769e6c490",
                                    "activity": "Deposit",
                                    "description": "To HSA",
                                    "mode": "credit",
                                    "amount": 500,
                                    "zguarantee": false,
                                    "date": 1626272885,
                                    "needs_attention": false,
                                    "show_details": false,
                                    "image": "deposit"
                                },
                                {
                                    "id": "c133b0d2-3453-48d9-b50b-5b60c15f497a",
                                    "activity": "Deposit",
                                    "description": "To HSA",
                                    "mode": "credit",
                                    "amount": 500,
                                    "zguarantee": false,
                                    "date": 1626272872,
                                    "needs_attention": false,
                                    "show_details": false,
                                    "image": "deposit"
                                }
                            ],
                            "ach_transactions": [
                                  {
                                    "txn_amount": 4000,
                                    "indicator": "D",
                                    "date": 1635500589,
                                    "status": "PENDING"
                                  },
                                  {
                                    "txn_amount": 4000,
                                    "indicator": "D",
                                    "date": 1635500589,
                                    "status": "PENDING"
                                  },
                                  {
                                    "txn_amount": 10,
                                    "indicator": "D",
                                    "date": 1635500589,
                                    "status": "PENDING"
                                  },
                                  {
                                    "txn_amount": 2,
                                    "indicator": "D",
                                    "date": 1635500589,
                                    "status": "PENDING"
                                  },
                                  {
                                    "txn_amount": 1.57,
                                    "indicator": "D",
                                    "date": 1635500589,
                                    "status": "PENDING"
                                  },
                                  {
                                    "txn_amount": 1.57,
                                    "indicator": "D",
                                    "date": 1635500589,
                                    "status": "PENDING"
                                  },
                                  {
                                    "txn_amount": 1.57,
                                    "indicator": "D",
                                    "date": 1635500589,
                                    "status": "PENDING"
                                  },
                                  {
                                    "txn_amount": 1.57,
                                    "indicator": "D",
                                    "date": 1635500589,
                                    "status": "PENDING"
                                  }
                                ]
                        }
                    }
        """


let transactionsMockJson =
"""
[
        {
        "id": "1ab596c8-737c-4a5f-8759-7bb60c70e4b0",
                                       "type": "none",
                                       "date": 1623110187,
                                       "merchant_details": {
                                         "merchant_category_code": "",
                                         "merchant_name": "Walgreens",
                                         "merchant_address": "Berkeley, CA",
                                         "merchant_id": ""
                                       },
                                       "zguarantee": true,
                                       "hsa_account_number_last4": "4561",
                                       "dda_account_number_last4": "4562",
                                       "amount": 19,
                                       "hsa_amount": 0,
                                       "dda_amount": 19,
                                       "view_expenses_statement": "If this is in fact a health related expense, you can create an expense and get it reimbursed.",
                                       "expense_action":"create",
                                       "expense_id": "123",
                                       "pro_tip": "Not sure what should be converted to an expense?"
        },
        {
        "id": "1ab596c8-737c-4a5f-8759-7bb60c70e4b1",
                                       "type": "refund",
                                       "date": 1623110187,
                                       "merchant_details": {
                                         "merchant_category_code": "",
                                         "merchant_name": "Walgreens",
                                         "merchant_address": "Berkeley, CA",
                                         "merchant_id": ""
                                       },
                                       "zguarantee": false,
                                       "hsa_account_number_last4": "4561",
                                       "dda_account_number_last4": "4562",
                                       "amount": 19,
                                       "hsa_amount": 0,
                                       "dda_amount": 19,
                                       "view_expenses_statement": "If this is in fact a health related expense, you can create an expense and get it reimbursed.",
                                       "expense_action":"create",
                                       "expense_id": "123",
                                       "pro_tip": "Not sure what should be converted to an expense?"
        },
        {
        "id": "1ab596c8-737c-4a5f-8759-7bb60c70e4b2",
                                       "type": "refunded",
                                       "date": 1623110187,
                                       "merchant_details": {
                                         "merchant_category_code": "",
                                         "merchant_name": "Walgreens",
                                         "merchant_address": "Berkeley, CA",
                                         "merchant_id": ""
                                       },
                                       "zguarantee": true,
                                       "hsa_account_number_last4": "4561",
                                       "dda_account_number_last4": "4562",
                                       "amount": 19,
                                       "hsa_amount": 122,
                                       "dda_amount": 0,
                                       "view_expenses_statement": "If this is in fact a health related expense, you can create an expense and get it reimbursed.",
                                       "expense_action":"create",
                                       "expense_id": "123",
                                       "pro_tip": "Not sure what should be converted to an expense?"
        },
        {
        "id": "1ab596c8-737c-4a5f-8759-7bb60c70e4b3",
                                       "type": "reimburse",
                                       "date": 1623110187,
                                       "merchant_details": {
                                         "merchant_category_code": "",
                                         "merchant_name": "Walgreens",
                                         "merchant_address": "Berkeley, CA",
                                         "merchant_id": ""
                                       },
                                       "zguarantee": true,
                                       "hsa_account_number_last4": "4561",
                                       "dda_account_number_last4": "4562",
                                       "amount": 19,
                                       "hsa_amount": 12,
                                       "dda_amount": 19,
                                       "view_expenses_statement": "If this is in fact a health related expense, you can create an expense and get it reimbursed.",
                                       "expense_action":"create",
                                       "expense_id": "123",
                                       "pro_tip": "Not sure what should be converted to an expense?"
        },
        {
        "id": "1ab596c8-737c-4a5f-8759-7bb60c70e4b4",
                                       "type": "reimbursed",
                                       "date": 1623110187,
                                       "merchant_details": {
                                         "merchant_category_code": "",
                                         "merchant_name": "Walgreens",
                                         "merchant_address": "Berkeley, CA",
                                         "merchant_id": ""
                                       },
                                       "zguarantee": true,
                                       "hsa_account_number_last4": "4561",
                                       "dda_account_number_last4": "4562",
                                       "amount": 19,
                                       "hsa_amount": 0,
                                       "dda_amount": 19,
                                       "view_expenses_statement": "If this is in fact a health related expense, you can create an expense and get it reimbursed.",
                                       "expense_action":"create",
                                       "expense_id": "123",
                                       "pro_tip": "Not sure what should be converted to an expense?"
        }
]
"""
