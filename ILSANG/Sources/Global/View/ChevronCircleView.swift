//
//  ChevronCircleView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/23/25.
//


import SwiftUI

struct ChevronCircleView: View {
    var body: some View {
        Image(.arrowRight)
            .resizable()
            .scaledToFit()
            .frame(9)
            .frame(26)
            .background(Color.gray92.opacity(0.1))
            .clipShape(.circle)
    }
}
