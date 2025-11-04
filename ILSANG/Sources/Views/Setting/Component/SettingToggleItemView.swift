//
//  SettingToggleItemView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 4/15/25.
//

import SwiftUI

struct SettingToggleItemView<Content: View>: View {
    @Environment(\.layout) var layout
    let title: String
    var subtitle: String? = nil
    let isExpanded: Bool
    let toggleExpansion: () -> Void
    let expandedContent: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: toggleExpansion) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .styledFont(.medium, size: 16, lineHeight: 16)
                            .foregroundColor(.gray500)
                        if let subtitle {
                            Text(subtitle)
                                .styledFont(.subTitle1)
                                .foregroundColor(.gray300)
                        }
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                        .foregroundColor(.gray300)
                        .fontWeight(.medium)
                }
            }
            .frame(height: subtitle == nil ? 52 : 72)
            .padding(.horizontal, layout.horizontalPadding)
            .background(Color.white)
            
            if isExpanded {
                expandedContent()
            }
        }
    }
}
