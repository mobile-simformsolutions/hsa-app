//
//  RepositoryService.swift
//

import Foundation
import Combine
import Resolver

protocol StatusResponse: Codable {
    var message: String { get }
}

struct NullBody: Codable {
    
}

class RepositoryService {
    @Injected var networkStatus: NetworkStatusService
    let apiService = APIService()
    
    var subscribers: Set<AnyCancellable> = []
}

// MARK: Dashboard API Calls
extension RepositoryService {
    
    func fetchDashboard(completion: @escaping (Result<DashboardSummary, Error>) -> Void) {
        apiService.get(path: "dashboard-API-endpoint",
                       type: DashboardSummary.self,
                       extractionKey: nil,
                       completion: completion)
    }
    
    func fetchMoreTransactions(offset: Int, limit: Int, completion: @escaping (Result<[TransactionSummary], Error>) -> Void) {
        let params = ["offset": String(offset), "limit": String(limit)]
        apiService.get(path: "fetch-more-transactions-API-endpoint",
                       parameters: params,
                       type: [TransactionSummary].self,
                       extractionKey: "transactions",
                       completion: completion)
    }
    
    func transactions(for accountType: AccountType, offset: Int, limit: Int, completion: @escaping (Result<[TransactionSummary], Error>) -> Void) {
        let params = ["offset": String(offset), "limit": String(limit)]
        apiService.get(path: "transactions-API-endpoint",
                       parameters: params,
                       type: [TransactionSummary].self,
                       extractionKey: "transactions",
                       completion: completion)
    }
}

// MARK: Account API Calls
extension RepositoryService {
    
    func accountDetails(accountType: AccountType, completion: @escaping (Result<AccountDetails, Error>) -> Void) {
        apiService.get(
            path: "account-details-API-endpoint",
            type: AccountDetails.self,
            extractionKey: nil,
            completion: completion
        )
    }
}


// MARK: - Contact Us API Call
extension RepositoryService {
    func supportRequest(request: SupportRequest, completion: @escaping (Result<MessageOnlyResponse, Error>) -> Void) {
        apiService.post(
            path: "support-API-endpoint",
            body: request,
            type: MessageOnlyResponse.self,
            extractionKey: "status",
            completion: completion
        )
    }
}
