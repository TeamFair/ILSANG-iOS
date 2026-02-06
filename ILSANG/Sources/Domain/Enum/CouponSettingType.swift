//
//  CouponSettingType.swift
//  ILSANG
//
//  Created by Lee Jinhee on 1/3/26.
//


enum CouponSettingType: String {
    case week
    case realtime
    
    init?(type: String) {
        self.init(rawValue: type.lowercased())
    }
    
    var title: String {
        switch self {
        case .week: "이번 주 특별 보상"
        case .realtime: "특별 보상"
        }
    }
    
    var questDetailTitle: String {
        switch self {
        case .week:
            "일상존 퀘스트로\n쿠폰 확률을 높여보세요!"
        case .realtime:
            "일상존 퀘스트로\n쿠폰을 획득하세요!"
        }
    }
}
