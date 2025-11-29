//
//  MyPageSegment.swift
//  ILSANG
//
//  Created by Kim Andrew on 5/22/24.
//

import SwiftUI

protocol TabItemRepresentable {
    var title: String { get }
    var icon: String? { get }
    var image: UIImage? { get }
}

struct MyPageTabView<Tab: TabItemRepresentable & CaseIterable & Equatable>: View {
    @Binding var selectedTab: Tab
    private let tabs = Tab.allCases
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(Array(tabs), id: \.title) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    MyPageTabItemView(tab: tab, isSelected: selectedTab == tab)
                }
            }
        }
    }
}

struct MyPageTabItemView<Tab: TabItemRepresentable>: View {
    let tab: Tab
    let isSelected: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            if let image = tab.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(18)
            }
            if let icon = tab.icon {
                Text(icon)
                    .styledFont(.tabBold)
            }
            Text(tab.title)
                .styledFont(.tabBold)
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
