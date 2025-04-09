//
//  UISheetPresentationController.swift
//  ILSANG
//
//  Created by Lee Jinhee on 2/10/25.
//

import UIKit

extension UISheetPresentationController.Detent.Identifier {
    static let custom = UISheetPresentationController.Detent.Identifier("custom")
}

extension UISheetPresentationController.Detent {
    static let questDetailDetentHeightTall: CGFloat = 632.0
    static let questDetailDetentTall = UISheetPresentationController.Detent.custom { _ in questDetailDetentHeightTall }
    
    static let questDetailDetentHeightShort: CGFloat = 440.0
    static let questDetailDetentShort = UISheetPresentationController.Detent.custom { _ in questDetailDetentHeightShort }
}
