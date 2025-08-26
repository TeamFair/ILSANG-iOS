//
//  UserRankViewModelItem.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/25/25.
//

import UIKit

class UserRankViewModelItem: ObservableObject {
    let userId: String
    let profileImageId: String?
    @Published var profileImage: UIImage?
    let nickname: String
    let point: Int
    let rank: Int
    let title: TitleResponse?
    
    init(userId: String, profileImageId: String?, profileImage: UIImage?, nickname: String, point: Int, rank: Int, title: TitleResponse?) {
        self.userId = userId
        self.profileImageId = profileImageId
        self.profileImage = profileImage
        self.nickname = nickname
        self.point = point
        self.rank = rank
        self.title = title
    }
    
//    func loadImage() {
//        guard let profileImageId else { return }
//        
//        Task {
//            let profileImage = await ImageCacheService.shared.loadImageAsync(imageId: profileImageId)
//            await MainActor.run {
//                self.profileImage = profileImage
//            }
//        }
//    }
}

extension UserRankViewModelItem {
    static let mockData1 = UserRankViewModelItem(userId: "", profileImageId: "", profileImage: .img0, nickname: "김일상", point: 100000, rank: 1, title: .init(id: "", name: "칭호", grade: "LEGEND", type: "METRO"))
    static let mockData100 =  UserRankViewModelItem(userId: "", profileImageId: "", profileImage: nil, nickname: "김일상", point: 100, rank: 100, title: .init(id: "", name: "칭호", grade: "LEGEND", type: "METRO"))
    static let mockData1000 =  UserRankViewModelItem(userId: "", profileImageId: "", profileImage: .img0, nickname: "김일상", point: 1000, rank: 1000, title: .init(id: "", name: "칭호", grade: "STANDARD", type: "METRO"))
}
