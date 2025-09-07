//
//  HonorPopupContainerView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/17/25.
//

import SwiftUI

struct HonorPopupContainerView: View {
    @EnvironmentObject private var dependencies: AppDependencies
    @State private var isPresented = false
    
    var body: some View {
        ZStack {
            if let honor = dependencies.honorAcquisitionManager.currentHonor {
                AnimatedPopup(isPresented: $isPresented) {
                    HonorAcquisitionPopup(
                        honorTitle: honor.name,
                        honorGrade: honor.grade
                    ) {
                        withAnimation {
                            isPresented = false
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isPresented = dependencies.honorAcquisitionManager.hasNextPopup
                            dependencies.honorAcquisitionManager.dismissCurrentPopup()
                        }
                    }
                }
                .onAppear {
                    isPresented = true
                }
            }
        }
    }
}


@MainActor
final class HonorAcquisitionManager: ObservableObject {
    @Published private(set) var currentHonor: UserTitle?
    private var queue: [UserTitle] = []
    
    var hasNextPopup: Bool {
        !queue.isEmpty
    }
    
    private let titleRepository: TitleRepositoryInterface
    
    init(titleRepository: TitleRepositoryInterface) {
        self.titleRepository = titleRepository
    }
    
    func fetchUnreadHonorHistory() async {
        let result = await titleRepository.getUnreadTitleHistories()
        switch result {
        case .success(let res):
            self.queue += res
            self.showNextPopupIfNeeded()
        case .failure(let err):
            Log(err)
            return
        }
    }
    
    private func showNextPopupIfNeeded() {
        guard currentHonor == nil, !queue.isEmpty else { return }
        currentHonor = queue.removeFirst()
    }
    
    func dismissCurrentPopup() {
        if let historyId = currentHonor?.titleHistoryId {
            Task {
                await titleRepository.readTitleHistory(historyId: historyId)
            }
        }
        currentHonor = nil
        showNextPopupIfNeeded()
    }
    
//    func addMockHonors() {
//        queue += HonorHistory.mockList
//        showNextPopupIfNeeded()
//    }
}

#Preview {
    HonorPopupContainerView()
}
