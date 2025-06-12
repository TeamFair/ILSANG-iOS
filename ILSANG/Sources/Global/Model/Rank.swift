//
//  Rank.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/16/25.
//


import SwiftUI

struct Rank {
    let idx: Int
    let nickname: String
    
    // 선택적 정보
    let xp: Int?
    var xpTotal: Int?
    var xpType: String?
    var title: String?
    var titleType: HonorGrade?
    var createdTitleAt: String?
    var profileImageId: String?
    var profileImage: UIImage?
    
    // 빌더
    struct Builder {
        private var idx: Int = 0
        private var nickname: String = ""
        
        private var xp: Int? = nil
        private var xpTotal: Int? = nil
        private var xpType: String? = nil
        private var title: String? = nil
        private var titleType: HonorGrade? = nil
        private var createdTitleAt: String? = nil
        private var profileImageId: String? = nil
        private var profileImage: UIImage? = nil
        
        init(idx: Int, nickname: String) {
            self.idx = idx
            self.nickname = nickname
        }
        
        func setXp(_ xp: Int?) -> Builder {
            var builder = self
            builder.xp = xp
            return builder
        }
        
        func setXpType(_ xpType: String?) -> Builder {
            var builder = self
            builder.xpType = xpType
            return builder
        }
        
        func setTitle(_ title: String?, type: HonorGrade?) -> Builder {
            var builder = self
            builder.title = title
            builder.titleType = type
            return builder
        }
        
        func setCreatedAt(_ date: String?) -> Builder {
            var builder = self
            builder.createdTitleAt = date
            return builder
        }
        
        func setXpTotal(_ xpTotal: Int?) -> Builder {
            var builder = self
            builder.xpTotal = xpTotal
            return builder
        }
        
        func setProfile(imageId: String?, image: UIImage?) -> Builder {
            var builder = self
            builder.profileImageId = imageId
            builder.profileImage = image
            return builder
        }
        
        func build() -> Rank {
            return Rank(
                idx: idx,
                nickname: nickname,
                xp: xp,
                xpTotal: xpTotal,
                xpType: xpType,
                title: title,
                titleType: titleType,
                createdTitleAt: createdTitleAt,
                profileImageId: profileImageId,
                profileImage: profileImage
            )
        }
    }
}

extension Rank.Builder {
    static func baseRankBuilder(idx: Int, nickname: String, profileImageId: String?, profileImage: UIImage?) -> Rank.Builder {
        return Rank.Builder(idx: idx, nickname: nickname)
            .setProfile(imageId: profileImageId, image: profileImage)
    }
}

extension TopRankViewModelItem {
    func toRank() -> Rank {
        return Rank.Builder
            .baseRankBuilder(
                idx: self.lank,
                nickname: nickname,
                profileImageId: profileImageId,
                profileImage: profileImage
            )
            .setXp(xpSum)
            .build()
    }
}

extension StatRankViewModelItem {
    func toRank(idx: Int) -> Rank {
        return Rank.Builder
            .baseRankBuilder(
                idx: idx,
                nickname: nickname,
                profileImageId: profileImageId,
                profileImage: profileImage
            )
            .setXp(xpPoint)
            .setXpTotal(xpTotalPoint)
            .setXpType(xpType)
            .setTitle(title?.name, type: HonorGrade(rawValue: title?.type ?? ""))
            .build()
    }
}

extension HistoryRankViewModelItem {
    func toRank(idx: Int) -> Rank {
        return Rank.Builder
            .baseRankBuilder(
                idx: idx,
                nickname: nickname,
                profileImageId: profileImageId,
                profileImage: profileImage
            )
            .setXp(xpPoint)
            .setXpTotal(xpPoint)
            .setTitle(title, type: titleType)
            .setCreatedAt(createdAt)
            .build()
    }
}
