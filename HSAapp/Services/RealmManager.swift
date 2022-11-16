//
//  RealmManager.swift
//

import Foundation
import Realm
import RealmSwift
import Resolver

class RealmManager {
    private let userManager: UserManager

    init(userManager: UserManager) {
        self.userManager = userManager
    }

    static func initRealm() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 0,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { _, oldSchemaVersion in
                // We haven't migrated anything yet, so oldSchemaVersion == 0
                if oldSchemaVersion < 1 {
                    // Nothing to do!
                    // Realm will automatically detect new properties and deleted properties
                    // And will update the schema on disk automatically
                }
            }
        )

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config

        // swiftlint:disable:next force_unwrapping
        Log(.debug, message: "Realm: \(Realm.Configuration.defaultConfiguration.fileURL!)")
    }
    
    /// write to realm
    /// - Parameters:
    ///   - model: object to write
    ///   - completion: completion handler
    func writeToRealm<T: Object>(model: T, completion: @escaping (Result<Bool, Error>) -> Void) {
        do {
            let localRealm = try Realm()
            // remove old accounts
            let oldModel = localRealm.objects(T.self)
            if userManager.isLoggedIn {
                try localRealm.write {
                    localRealm.delete(oldModel, cascading: true)
                    localRealm.add(model)
                    completion(.success(true))
                }
            } else {
                userManager.logout(clearData: false)
            }
        } catch {
            completion(.failure(error))
        }
    }

    func fetchObjects<T: Object>(with type: T.Type) throws -> Results<T> {
        let realm = try Realm()
        return realm.objects(T.self)
    }
}

// MARK: Realm extension for cascading delete
extension Realm {
    func delete<S: Sequence>(_ objects: S, cascading: Bool) where S.Iterator.Element: Object {
        for obj in objects {
            delete(obj, cascading: cascading)
        }
    }
    
    func delete<Entity: Object>(_ entity: Entity, cascading: Bool) {
        if cascading {
            cascadeDelete(entity)
        } else {
            delete(entity)
        }
    }
}

private extension Realm {
    private func cascadeDelete(_ entity: RLMObjectBase) {
        guard let entity = entity as? Object else { return }
        
        var toBeDeleted = Set<RLMObjectBase>()
        
        toBeDeleted.insert(entity)
        
        while !toBeDeleted.isEmpty {
            guard let element = toBeDeleted.removeFirst() as? Object, !element.isInvalidated else { continue }
            
            resolve(element: element, toBeDeleted: &toBeDeleted)
        }
    }
    
    private func resolve(element: Object, toBeDeleted: inout Set<RLMObjectBase>) {
        element.objectSchema.properties.forEach {
            guard let value = element.value(forKey: $0.name) else { return }
            
            if let entity = value as? RLMObjectBase {
                toBeDeleted.insert(entity)
            } else if let list = value as? RLMSwiftCollectionBase {
                for index in 0..<list._rlmCollection.count {
                    if let object = list._rlmCollection.object(at: index) as? RLMObjectBase {
                        toBeDeleted.insert(object)
                    }
                }
            }
        }
        
        delete(element)
    }
}
