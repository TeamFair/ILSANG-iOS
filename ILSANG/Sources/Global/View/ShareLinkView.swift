//
//  ShareLinkView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 12/17/25.
//


import UIKit
import SwiftUI

struct ShareLinkView: UIViewControllerRepresentable {
    let activityItems: [Any]
    var applicationActivities: [UIActivity]?
    let onComplete: (Bool) -> Void

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        controller.modalPresentationStyle = .popover
        controller.completionWithItemsHandler = { _, completed, _, _ in
            onComplete(completed)
        }

        return controller
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {}
}
