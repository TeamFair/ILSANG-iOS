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
    static let customDetent = UISheetPresentationController.Detent.custom(identifier: .custom) { _ in
        return 464.0
    }
}
