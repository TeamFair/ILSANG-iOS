//
//  SelectableTabHeader.swift
//  ILSANG
//
//  Created by Lee Jinhee on 12/29/24.
//

import SwiftUI

protocol SelectableTabItem: Identifiable, Hashable, CaseIterable {
    var headerText: String { get }
}

struct SelectableTabHeader<Item: SelectableTabItem>: View {
    @Binding var selectedItem: Item
    let items: [Item]
    let horizontalPadding: CGFloat
    let height: CGFloat
    let hasBottomLine: Bool
    
    @Namespace private var namespace
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if hasBottomLine {
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.gray100)
            }
            HStack(spacing: 0) {
                ForEach(items) { item in
                    let isSelected = item == selectedItem
                    
                    Button {
                        selectedItem = item
                    } label: {
                        Text(item.headerText)
                            .foregroundColor(isSelected ? .gray500 : .gray300)
                            .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                            .frame(height: height)
                    }
                    .padding(.horizontal, 20)
                    .overlay(alignment: .bottom) {
                        if isSelected {
                            Rectangle()
                                .frame(height: 3)
                                .foregroundStyle(.primaryPurple)
                                .matchedGeometryEffect(id: "tabSelection", in: namespace)
                        }
                    }
                    .animation(.easeInOut, value: selectedItem)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
    }
}

#Preview {
    VStack {
        SelectableTabHeader(selectedItem: .constant(PointType.metro), items: PointType.allCases, horizontalPadding: 0, height: 44, hasBottomLine: true)
    }
}
