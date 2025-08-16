//
//  XpStat.swift
//  ILSANG
//
//  Created by Lee Jinhee on 12/7/24.
//

import UIKit

enum XpStat: String, CaseIterable, Identifiable, SelectableTabItem {
    var id: String {
        self.rawValue
    }
    
    case strength
    case intellect
    case fun
    case charm
    case sociability
    
    var headerText: String {
        switch self {
        case .strength:
            "체력"
        case .intellect:
            "지능"
        case .fun:
            "재미"
        case .charm:
            "매력"
        case .sociability:
            "사회성"
        }
    }
    
    var parameterText: String {
        switch self {
        case .strength:
            "STRENGTH"
        case .intellect:
            "INTELLECT"
        case .fun:
            "FUN"
        case .charm:
            "CHARM"
        case .sociability:
            "SOCIABILITY"
        }
    }
    
    var image: ImageResource {
        switch self {
        case .strength:
            return .strength
        case .intellect:
            return .intellect
        case .fun:
            return .fun
        case .charm:
            return .charm
        case .sociability:
            return .sociability
        }
    }
    
    static var sortedStat: [XpStat] {
        return [.strength, .intellect, .fun, .charm, .sociability]
    }
    
    static let mockDataDic: [XpStat: Int] = [
        .strength: 0,
        .intellect: 0,
        .fun: 40,
        .charm: 20,
        .sociability: 0
    ]
}
