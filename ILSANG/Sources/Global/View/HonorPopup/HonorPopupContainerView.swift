//
//  HonorPopupContainerView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/17/25.
//

import SwiftUI

struct HonorPopupContainerView: View {
    @EnvironmentObject private var manager: HonorAcquisitionManager
    @State private var isPresented = false
    
    var body: some View {
        ZStack {
            if let honor = manager.currentHonor,
               let grade = HonorGrade(rawValue: honor.title.type) {
                AnimatedPopup(isPresented: $isPresented) {
                    HonorAcquisitionPopup(
                        honorTitle: honor.title.name,
                        honorGrade: grade
                    ) {
                        withAnimation {
                            isPresented = false
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isPresented = manager.hasNextPopup
                            manager.dismissCurrentPopup()
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
    @Published private(set) var currentHonor: HonorHistory?
    private var queue: [HonorHistory] = []
    
    var hasNextPopup: Bool {
        !queue.isEmpty
    }
    
    private let honorNetwork: HonorNetworkProtocol
    
    init(honorNetwork: HonorNetworkProtocol) {
        self.honorNetwork = honorNetwork
    }
    
    func fetchUnreadHonorHistory() async {
        let result = await honorNetwork.getUnreadHonorHistory()
        switch result {
        case .success(let res):
            self.queue += res.data
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
        if let historyId = currentHonor?.titleHistory?.id {
            Task {
                await honorNetwork.readHonorHistory(historyId: historyId)
            }
        }
        currentHonor = nil
        showNextPopupIfNeeded()
    }
    
    func addMockHonors() {
        queue += HonorHistory.mockList
        showNextPopupIfNeeded()
    }
}

#Preview {
    HonorPopupContainerView()
}
