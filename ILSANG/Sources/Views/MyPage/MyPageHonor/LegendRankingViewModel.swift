////
////  LegendRankingViewModel.swift
////  ILSANG
////
////  Created by Lee Jinhee on 5/17/25.
////
//
//import Foundation
//
//final class LegendRankingViewModel: ObservableObject {
//    @Published var historyRanks: [HistoryRankViewModelItem] = []
//    private let honorId: String
//    let honorName: String
//    private let honorNetwork: HonorNetwork
//
//    init(honorId: String, honorName: String, honorNetwork: HonorNetwork) {
//        self.honorId = honorId
//        self.honorName = honorName
//        self.honorNetwork = honorNetwork
//    }
//    
//    @MainActor
//    func fetchLegendRanks() async {
//        let result = await honorNetwork.getLegendRank(honorId: honorId)
//        switch result {
//        case .success(let res):
//            let items = await withTaskGroup(of: (Int, HistoryRankViewModelItem).self) { group in
//                for (index, rank) in res.data.enumerated() {
//                    group.addTask {
//                        let item = await HistoryRankViewModelItem.make(from: rank)
//                        return (index, item)
//                    }
//                }
//                
//                var results = Array<HistoryRankViewModelItem?>(repeating: nil, count: res.data.count)
//                for await (index, item) in group {
//                    results[index] = item
//                }
//                
//                return results.compactMap { $0 } // nil 제거
//            }
//            
//            self.historyRanks = items
//        case .failure(let error):
//            Log("전설 칭호 조회 실패: \(error)")
//        }
//    }
//}
