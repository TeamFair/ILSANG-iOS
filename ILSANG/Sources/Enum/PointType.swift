//
//  PointType.swift
//  ILSANG
//
//  Created by Lee Jinhee on 12/7/24.
//

import UIKit

enum PointType: String, CaseIterable, Identifiable, SelectableTabItem {
    var id: String { self.rawValue }
    case metro
    case commercial
    case contribution
    
    var headerText: String {
        switch self {
        case .metro:
            "일상지역"
        case .commercial:
            "일상존"
        case .contribution:
            "기여도"
        }
    }
    
    var parameterText: String {
        self.rawValue.uppercased()
    }
    
    var image: ImageResource {
        switch self {
        case .metro:
            return .rewardMetro
        case .commercial:
            return .rewardCommecial
        case .contribution:
            return .rewardContribution
        }
    }
    
    static var sorted: [PointType] {
         [.metro, .commercial, .contribution]
    }
}
