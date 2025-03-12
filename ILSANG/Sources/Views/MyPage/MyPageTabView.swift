//
//  MyPageSegment.swift
//  ILSANG
//
//  Created by Kim Andrew on 5/22/24.
//

import SwiftUI

struct MyPageTabView: View {
    @Binding var selectedTab: MyPageTab
    private let tabs = MyPageTab.allCases
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(tabs, id: \.title) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    MyPageTabItemView(tab: tab, isSelected: selectedTab == tab)
                }
            }
        }
        .padding(.vertical, 20)
    }
}

struct MyPageTabItemView: View {
    let tab: MyPageTab
    let isSelected: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            Text(tab.icon)
                .font(.system(size: 11))
            Text(tab.title)
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? Color.white : Color.gray500)
        }
        .frame(height: 38)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(isSelected ? Color.accentColor : Color.white)
        )
    }
}

enum MyPageTab: CaseIterable {
    case quest
    // case activity
    case info
    
    var title: String {
        switch self {
        case .quest: return "챌린지"
            // case .activity: return "활동"
        case .info: return "내 정보"
        }
    }
    
    var icon: String {
        switch self {
        case .quest: return "📜"
            // case .activity: return "⛳️"
        case .info: return "🎖️"
        }
    }
}
