//
//  Font++.swift
//  ILSANG
//
//  Created by Lee Jinhee on 2/10/25.
//

import SwiftUI

extension Font {
    static func uiFont(_ weight: UIFont.Weight,_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
}
