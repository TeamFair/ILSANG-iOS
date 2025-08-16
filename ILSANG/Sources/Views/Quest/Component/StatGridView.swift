//
//  StatGridView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 12/1/24.
//

import SwiftUI

struct StatGridView: View {
    let rewardDic: [PointType: Int]
    let expireDate: String?
    let showEventTagView: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            tagView
            eventTagView
        }
    }
    
    private var tagView: some View {
        HStack(spacing: 4) {
            ForEach(Array(PointType.sorted), id: \.rawValue) { type in
                let point = rewardDic[type, default: 0]
                if point > 0 {
                    TagView(title: "\(point)P", image: type.image, tagStyle: .pointWithIcon)
                }
            }
        }
    }
    
    @ViewBuilder
    private var eventTagView: some View {
        if let tagTitle = expireDate?.timeAgoSinceDate(withYear: false), showEventTagView {
            TagView(title: "~"+tagTitle, tagStyle: .eventDate)
        }
    }
}


#Preview {
    StatGridView(rewardDic: [.commercial: 100, .metro: 10, .contribution: 10], expireDate: nil, showEventTagView: false)
        .padding(.horizontal, 20)
}
