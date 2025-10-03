//
//  PresentationDetent++.swift
//  ILSANG
//
//  Created by Lee Jinhee on 2/10/25.
//

import SwiftUI

extension PresentationDetent {
    static let questDetailTall = PresentationDetent.height(632)
    static let questDetailShort = PresentationDetent.height(440)
    static let questDetailTallWithCoupon = PresentationDetent.height(736)
    static let questDetailShortWithCoupon = PresentationDetent.height(544)

    static func heightForQuest(quest: QuestViewModelItem) -> PresentationDetent {
        let isTall = quest.questType == .repeat || quest.missionType == .photo
        let hasCoupon = quest.hasCouponReward

        switch (isTall, hasCoupon) {
        case (true, true): return .questDetailTallWithCoupon
        case (true, false): return .questDetailTall
        case (false, true): return .questDetailShortWithCoupon
        case (false, false): return .questDetailShort
        }
    }
}
