//
//  App+Injection.swift
//

import Foundation
import Resolver

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        register { UserDefaultsManager(userDefaults: .standard) }
            .implements(UserDefaultsManaging.self)
            .scope(.cached)
        
        register { Analytics(userDefaultsManager: resolve()) }
            .implements(AnalyticsType.self)
            .scope(.cached)

        register { RepositoryService() }
            .scope(.cached)
        
        register { NetworkStatusService.shared }
            .scope(.cached)

        register { KeychainManager() }
            .implements(KeychainManaging.self)
            .scope(.cached)

        register { UserManager(
            repositoryService: resolve(),
            userDefaultsManager: resolve(),
            keychainManager: resolve())
        }
        .scope(.cached)

        register { RealmManager(userManager: resolve()) }
            .scope(.unique)
    }
}
