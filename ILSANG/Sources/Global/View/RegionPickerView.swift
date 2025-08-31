//
//  RegionPickerView.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/11/25.
//

import SwiftUI

struct RegionPickerView: View {
    let title: String
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 4) {
                Image(.illsangRegion)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16)
                    .frame(30)
                Text(title)
                    .styledFont(.tabBold)
                    .foregroundStyle(.gray500)
                Image(.arrowUnder)
                    .frame(18)
                    .foregroundStyle(.gray500)
            }
        }
    }
}

#Preview {
    RegionPickerView(title: "성남", onTap: {})
}
