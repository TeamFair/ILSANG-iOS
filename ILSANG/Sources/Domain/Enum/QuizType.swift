//
//  QuizType.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/21/25.
//


import UIKit

enum QuizType: Hashable {
    case text, ox
    
    init?(rawValue: String) {
        switch rawValue {
        case "WORDS": self = .text
        case "OX": self = .ox
        default: return nil
        }
    }
    
    var description: String {
        switch self {
        case .text:
            "서술형"
        case .ox:
            "OX"
        }
    }
}
