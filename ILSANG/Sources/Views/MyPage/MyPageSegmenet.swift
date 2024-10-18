//
//  MyPageSegment.swift
//  ILSANG
//
//  Created by Kim Andrew on 5/22/24.
//

import SwiftUI

struct MyPageSegment: View {
    @Binding var selectedIndex: Int
    
    private let items = ["퀘스트", "활동", "뱃지"]
    private let icons = ["📜", "⛳️", "🎖️"]
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<items.count, id: \.self) { index in
                Button {
                    selectedIndex = index
                }  label: {
                    SegmentStruct(sgmIcon: icons[index], sgmTitle: items[index], index: index, selectedIndex: selectedIndex)
                }
            }
        }
        .padding(.vertical, 16)
    }
}

struct SegmentStruct: View {
    let sgmIcon: String
    let sgmTitle: String
    let index: Int
    let selectedIndex: Int
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            Text(sgmIcon)
                .font(.system(size: 11))
            Text(sgmTitle)
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(selectedIndex == index ? Color.white : Color.gray500)
        }
        .frame(height: 38)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(selectedIndex == index ? Color.accentColor : Color.white)
        )
    }
}
