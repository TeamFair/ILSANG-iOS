//
//  UINavigationController.swift
//  ILSANG
//
//  Created by Lee Jinhee on 2/10/25.
//

import UIKit

extension UINavigationController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}
