//
//  CGFloat++.swift
//  ILSANG
//
//  Created by Lee Jinhee on 12/28/24.
//

import UIKit

extension CGFloat {
    static let screenWidth: CGFloat = UIScreen.main.bounds.width
    
    static var isSmallDevice: Bool {
        CGFloat.screenWidth < 380
    }
}
