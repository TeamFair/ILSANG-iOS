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
        HStack(spacing: 4) {
            Image(.illsangRegion)
                .resizable()
                .scaledToFit()
                .frame(width: 16)
                .frame(30)
            Button {
                onTap()
            } label: {
                Text(title)
                    .styledFont(.tabBold)                
                Image(.arrowUnder)
                    .frame(18)
            }
            .foregroundStyle(.gray500)
        }
    }
}

#Preview {
    RegionPickerView(title: "성남", onTap: {})
}
