//
//  RewardResponse+Mapping.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/23/25.
//


extension RewardResponse {
    func toDomain() -> Reward? {
        guard let pointType = PointType(rawValue: pointType.lowercased()) else { return nil }
        return Reward(point: point, pointType: pointType)
    }
}
