//
//  AnimatedPopup.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/18/25.
//

import SwiftUI

struct AnimatedPopup<Content: View>: View {
    @State private var showBackground = false
    @Binding var isPresented: Bool
    let content: () -> Content
    
    var body: some View {
        ZStack {
            Color.black.opacity(showBackground ? 0.5 : 0)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: showBackground)
            
            if isPresented {
                content()
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.9)
                                .animation(.bouncy),
                            removal: .scale(scale: 0.95)
                                .animation(.easeOut(duration: 0.2))
                        )
                    )
                    .zIndex(1)
            }
        }
        .onAppear {
            showBackground = true
        }
        .onChange(of: isPresented) { _, newValue in
            if newValue {
                showBackground = true
            } else {
                // 약간의 delay 후 배경 제거
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    if !isPresented {
                        showBackground = false
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isPresented)
    }
}
