//
//  RankingDetailViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/24/25.
//


import UIKit

class RankingDetailViewModel: ObservableObject {
    enum ViewStatus {
        case error
        case loading
        case loaded
    }
    
    @Published var viewStatus: ViewStatus = .loaded // 변경
    @Published var userRank: [StatRankViewModelItem] = []
    @Published var imageList: [UIImage] = []
    @Published var imageIdx = 0
    let regionTitle = "야탑"
    let regionRank: Int = 1
    let regionPoint: Int = 100
    
    func getRankDetail() async {
        // try await rankNetwork.getRankDetail
       
        self.userRank.append(
            .init(
                xpPoint: 10,
                xpTotalPoint: 100,
                title: .mockLegend,
                customerId: "133",
                nickname: "유저124",
                profileImageId: "",
                profileImage: nil
            )
        )
    }
    
    func getImages() async {
        // try await rankNetwork.getImages()
       
        self.imageList = [.img0, .img1, .img2, .img0]
    }
}
