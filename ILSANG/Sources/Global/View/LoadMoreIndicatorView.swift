//
//  LoadMoreIndicatorView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 11/9/25.
//

import SwiftUI

struct LoadMoreIndicatorView: View {
    let isVisible: Bool
    
    var body: some View {
        if isVisible {
            ProgressView()
                .padding(.top, 12)
        }
    }
}
