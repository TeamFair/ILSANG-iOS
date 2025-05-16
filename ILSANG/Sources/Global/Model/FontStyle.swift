//
//  FontStyle.swift
//  ILSANG
//
//  Created by Lee Jinhee on 2/10/25.
//

import UIKit

struct FontStyle {
    let size: CGFloat
    let weight: UIFont.Weight
    let lineHeight: CGFloat
    let tracking: CGFloat
    
    static let title1 = FontStyle(size: 23, weight: .bold, lineHeight: 24, tracking: 0)
    static let title2 = FontStyle(size: 17, weight: .bold, lineHeight: 22, tracking: 0)
    
    static let heading1 = FontStyle(size: 17, weight: .bold, lineHeight: 20, tracking: -0.4)
    static let heading2 = FontStyle(size: 15, weight: .bold, lineHeight: 18, tracking: -0.4)
    static let heading3 = FontStyle(size: 19, weight: .bold, lineHeight: 23, tracking: -0.4)
    
    static let subTitle1 = FontStyle(size: 16, weight: .semibold, lineHeight: 24, tracking: -0.4)
    static let subTitle2 = FontStyle(size: 16, weight: .regular, lineHeight: 24, tracking: -0.4)
    
    static let caption1 = FontStyle(size: 13, weight: .regular, lineHeight: 20, tracking: -0.3)
    static let caption2 = FontStyle(size: 12, weight: .regular, lineHeight: 16, tracking: -0.3)
    
    static let body = FontStyle(size: 15, weight: .regular, lineHeight: 22, tracking: -0.3)
    
    static let button = FontStyle(size: 16, weight: .semibold, lineHeight: 18, tracking: 0)
    
    static let tabBold = FontStyle(size: 14, weight: .semibold, lineHeight: 24, tracking: 0)
    static let tabRegular = FontStyle(size: 14, weight: .regular, lineHeight: 24, tracking: 0)
    
    static let badge1 = FontStyle(size: 11, weight: .semibold, lineHeight: 12, tracking: 0)
    static let badge2 = FontStyle(size: 10, weight: .semibold, lineHeight: 12, tracking: -0.3)
    
    func uiFont() -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
}
