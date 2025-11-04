//
//  HonorGrade.swift
//  ILSANG
//
//  Created by Lee Jinhee on 11/4/25.
//

import UIKit

enum HonorGrade: String, CaseIterable, TabItemRepresentable, Equatable {
    case standard
    case rare
    case legend
    
    var honor: Honor {
        switch self {
        case .standard: Honor.standard
        case .rare: Honor.rare
        case .legend: Honor.legend
        }
    }
    var icon: String? { nil }
    var title: String { honor.title }
    var image: UIImage? { honor.image }
    var description: String { honor.description }
    
    init?(rawValue: String) {
        self = Self.allCases.first { $0.rawValue == rawValue.lowercased() } ?? .standard
    }
}
