//
//  PersistenceService.swift
//

import Foundation
import RealmSwift


struct PersistenceService {
    func reset() {
        do {
            let localRealm = try Realm()

            try localRealm.write {
                localRealm.deleteAll()
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
