//
//  RewardTagRow.swift
//  ILSANG
//
//  Created by Lee Jinhee on 12/1/24.
//

import SwiftUI

struct RewardTagRow: View {
    let rewards: [Reward]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(PointType.sorted), id: \.rawValue) { type in
                if let reward = rewards.first(where: { $0.pointType == type }) {
                    TagView(title: "\(reward.point)P", image: type.image, tagStyle: .pointWithIcon)
                }
            }
        }
    }
}


#Preview {
    RewardTagRow(rewards: [Reward(point: 10, pointType: .commercial), Reward(point: 10, pointType: .metro), Reward(point: 10, pointType: .contribution)])
        .padding(.horizontal, 20)
}
