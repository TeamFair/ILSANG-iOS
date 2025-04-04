//
//  QuestDetailTitleView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 4/4/25.
//

import SwiftUI

struct QuestDetailTitleView: View {
    let title: String

    var body: some View {
        Text(title)
            .styledFont(.badge1)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .foregroundStyle(.white)
            .background(Color.primaryPurple)
            .clipShape(.capsule)
    }
}
