//
//  RewardTagRow.swift
//  ILSANG
//
//  Created by Lee Jinhee on 12/1/24.
//

import SwiftUI

struct RewardTagRow: View {
    let rewards: [Reward]
    let isMyIllsangZone: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(PointType.sorted), id: \.rawValue) { type in
                if let reward = rewards.first(where: { $0.pointType == type }) {
                    if reward.pointType == .contribution && isMyIllsangZone {
                        TagView(
                            title: "\(reward.point)P",
                            image: type.image,
                            tagStyle: .pointWithIcon,
                            trailingView: {
                                DoublePointView(style: .text)
                            }
                        )
                    } else {
                        TagView(
                            title: "\(reward.point)P",
                            image: type.image,
                            tagStyle: .pointWithIcon
                        )
                    }
                }
            }
        }
    }
}


#Preview {
    RewardTagRow(rewards: [Reward(point: 10, pointType: .commercial), Reward(point: 10, pointType: .metro), Reward(point: 10, pointType: .contribution)], isMyIllsangZone: true)
    RewardTagRow(rewards: [Reward(point: 10, pointType: .commercial), Reward(point: 10, pointType: .metro), Reward(point: 10, pointType: .contribution)], isMyIllsangZone: false)
        .padding(.horizontal, 20)
}
