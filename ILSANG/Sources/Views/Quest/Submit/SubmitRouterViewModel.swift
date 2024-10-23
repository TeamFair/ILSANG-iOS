//
//  SubmitViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/27/24.
//

import SwiftUI

@MainActor
class SubmitRouterViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var showSubmitAlertView: Bool = false
    
    let selectedQuest: QuestViewModelItem
    
    init(selectedImage: UIImage? = nil, selectedQuest: QuestViewModelItem) {
        self.selectedImage = selectedImage
        self.selectedQuest = selectedQuest
    }
    
    func clearSelectedImage() {
        self.showSubmitAlertView = false
        self.selectedImage = nil
    }
    
    func submit() {
        self.showSubmitAlertView = true
    }
}
