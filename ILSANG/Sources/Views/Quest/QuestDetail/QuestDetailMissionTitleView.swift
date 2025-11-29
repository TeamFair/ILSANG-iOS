//
//  QuestDetailMissionTitleView.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 11/16/25.
//

import SwiftUI

struct QuestDetailMissionTitleView: View {
    let title: String
    var onHeightChange: (CGFloat) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("퀘스트 요약")
                .styledFont(.heading2)
                .foregroundStyle(.gray500)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(title.forceCharWrapping)
                .styledFont(.caption1)
                .foregroundStyle(.gray500)
        }
        .padding(16)
        .roundedBackground(cornerRadius: 12, bgColor: .background)
        .readHeight(onHeightChange)
    }
}

#Preview {
    QuestDetailMissionTitleView(title: "미션 타이틀", onHeightChange: { _ in })
}

struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    func readHeight(_ onChange: @escaping (CGFloat) -> Void) -> some View {
        background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: HeightPreferenceKey.self, value: geo.size.height)
            }
        )
        .onPreferenceChange(HeightPreferenceKey.self, perform: onChange)
    }
}
