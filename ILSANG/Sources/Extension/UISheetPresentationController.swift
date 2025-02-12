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
    static let questDetailDetentHeight: CGFloat = 464.0
    static let questDetailDetent = UISheetPresentationController.Detent.custom { _ in questDetailDetentHeight }
}
