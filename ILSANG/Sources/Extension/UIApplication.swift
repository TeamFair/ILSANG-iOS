//
//  UIApplication.swift
//  ILSANG
//
//  Created by Lee Jinhee on 2/10/25.
//

import UIKit

extension UIApplication {
    var topController: UIViewController? {
        guard let windowScene = connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        var topVC = keyWindow.rootViewController
        while let presentedVC = topVC?.presentedViewController {
            topVC = presentedVC
        }
        return topVC
    }
}
