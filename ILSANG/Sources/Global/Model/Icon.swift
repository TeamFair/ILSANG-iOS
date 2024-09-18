//
//  Icon.swift
//  ILSANG
//
//  Created by Kim Andrew on 9/11/24.
//

import Foundation
import SwiftUI

enum IconSize {
    case small
    case medium
    
    var value: CGFloat {
        switch self {
        case .small:
            26
        case .medium:
            60
        }
    }
}

enum IconColor {
    case red
    case green
    case blue
    case gray
    
    var fgColor: Color {
        switch self {
        case .red:
            return .subRed
        case .green:
            return .subGreen
        case .blue:
            return .subBlue
        case .gray:
            return .gray400
        }
    }
    
    var bgColor: Color {
        switch self {
        case .red:
            return .badgeRed
        case .green:
            return .badgeGreen
        case .blue:
            return .badgeBlue
        case .gray:
            return .gray400.opacity(0.1)
        }
    }
}
