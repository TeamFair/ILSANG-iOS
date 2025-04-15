//
//  StandardScreenView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/26/25.
//

import SwiftUI

struct StandardScreenView<Content: View>: View {
    @Environment(\.dismiss) var dismiss
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationTitleView(title: title, isSeparatorHidden: true) {
                dismiss()
            }
            .padding(.bottom, 8)
            
            content
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .background(Color.background, ignoresSafeAreaEdges: .bottom)
        .navigationBarBackButtonHidden()
    }
}
