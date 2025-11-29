//
//  RenderDebugContainer.swift
//  ILSANG
//
//  Created by Lee Jinhee on 10/3/25.
//

import SwiftUI

struct RenderDebugContainer<Content: View>: View {
    let content: () -> Content
    
    var body: some View {
        let backgroundColor = Color(
            red: .random(in: 0.3...1),
            green: .random(in: 0.3...1),
            blue: .random(in: 0.3...1)
        )
        
        ZStack {
            backgroundColor.ignoresSafeArea()
            content()
                .padding(4)
        }
    }
}
