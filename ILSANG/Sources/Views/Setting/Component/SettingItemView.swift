//
//  SettingListItemView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 4/15/25.
//

import SwiftUI

struct SettingItemView: View {
    @Environment(\.layout) var layout
    let item: Setting
    let action: (() -> ())?
    
    var body: some View {
        HStack {
            Text(item.title)
                .styledFont(.semibold, size: 16, lineHeight: 16)
                .foregroundColor(item.titleColor)
            Spacer()
            switch item.type {
            case .navigate:
                Image(systemName: "chevron.right")
                    .foregroundStyle(.gray300)
                    .fontWeight(.medium)
            case .alert:
                EmptyView()
            case .info(let string):
                Text(string)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.gray300)
                    .monospacedDigit()
            case .infoWithUnderLine(let string):
                Text(string)
                    .font(.system(size: 15, weight: .medium))
                    .underline()
                    .foregroundColor(.gray300)
                    .monospacedDigit()
            }
        }
        .padding(.horizontal, layout.horizontalPadding)
        .frame(height: 36) // 터치영역 좁혀주기 위함
        .frame(maxWidth: .infinity)
        .background()
        .onTapGesture {
            action?()
        }
        .frame(height: 52)
        .background()
    }
}
