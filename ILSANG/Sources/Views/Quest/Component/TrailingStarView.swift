//
//  TrailingStarView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/22/25.
//


import SwiftUI

struct TrailingStarView: View {
    let favoriteYn: Bool
    
    var body: some View {
        VStack {
            Image(.star)
                .renderingMode(.template)
                .foregroundStyle(favoriteYn ? .primary300 : .gray100)
                .offset(y: -4)
            Spacer()
        }
    }
}