//
//  APITarget.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/16/24.
//

protocol APITarget {
    var type: String? { get }
    var path: String { get }
    var version: Int { get }
}

final class OpenTarget: APITarget {
    let type: String? = "open"
    let path: String
    let version: Int
    
    init(path: String, version: Int) {
        self.path = path
        self.version = version
    }
}

final class UserTarget: APITarget {
    let type: String? = "user"
    let path: String
    let version: Int
    
    init(path: String, version: Int) {
        self.path = path
        self.version = version
    }
}

final class NoTarget: APITarget {
    let type: String? = nil
    let path: String
    let version: Int
    
    init(path: String, version: Int) {
        self.path = path
        self.version = version
    }
}
