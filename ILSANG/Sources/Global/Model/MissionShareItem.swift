//
//  MissionShareItem.swift
//  ILSANG
//
//  Created by Lee Jinhee on 12/17/25.
//


import LinkPresentation

final class MissionShareItem: NSObject, UIActivityItemSource {
    let title: String
    let image: UIImage

    init(title: String, image: UIImage) {
        self.title = title
        self.image = image
    }

    func activityViewControllerPlaceholderItem(
        _ activityViewController: UIActivityViewController
    ) -> Any {
        title
    }
    
    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        image
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
         let metadata = LPLinkMetadata()
         metadata.title = title
         metadata.imageProvider = NSItemProvider(object: image)
         return metadata
     }
}
