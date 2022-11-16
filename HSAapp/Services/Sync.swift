//
//  Sync.swift
//

import Foundation
import RealmSwift
import Resolver

enum SyncStatus {
    case notRunning, running
}

class Sync {
    @Injected private var realmManager: RealmManager
    @Injected private var repositoryService: RepositoryService
    @Injected private var analytics: AnalyticsType
    @Injected private var userManager: UserManager

    static let shared = Sync()
    var currentStatus: SyncStatus = .notRunning

    func start(completion: @escaping (Result<Bool, Error>) -> Void) {
        if currentStatus != .running {
            repositoryService.fetchDashboard { [weak self] result in
                onMain {
                    guard let self = self else {
                        return
                    }
                    self.repositoryService.apiService.logTokens()
                    switch result {
                    case .failure(let error):
                        switch error as? APIError {
                        case .notFound:
                            completion(.success(true))
                        default:
                            completion(.failure(error))
                        }
                    case .success(let dashboard):
                        self.realmManager.writeToRealm(model: dashboard) { status in
                            completion(status)
                        }
                    }
                }
            }
        }
    }
}
