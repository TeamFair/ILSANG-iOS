//
//  APIManager.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/16/24.
//

import Foundation

final class APIManager {
    static let baseURL = EnvironmentConfig.rootURL
    
    static func makeURL(_ target: APITarget) -> String {
        if let prefix = target.type {
            return "\(baseURL)/api/v\(target.version)/\(prefix)/\(target.path)"
        } else {
            return "\(baseURL)/api/v\(target.version)/\(target.path)"
        }
    }
}


enum EnvironmentConfig {
    // MARK: - Keys
    enum Keys {
        enum Plist {
            static let rootURL = "ROOT_URL"
        }
    }

    // MARK: - Plist
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()

    // MARK: - Plist values
    static let rootURL: String = {
        guard let rootURLstring = EnvironmentConfig.infoDictionary[Keys.Plist.rootURL] as? String else {
            fatalError("Root URL not set in plist for this environment")
        }
   
        return rootURLstring
    }()
}
