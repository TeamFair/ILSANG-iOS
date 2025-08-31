//
//  SubmitAlertView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/25/24.
//

import SwiftUI

struct SubmitAlertView: View {
    @ObservedObject var vm: SubmitRouterViewModel
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            if vm.showSubmitAlertView {
                Color.black.opacity(0.7).ignoresSafeArea()
                submitAlertView
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if vm.showSubmitAlertView && vm.submitStatus != .complete {
                vm.handleScenePhaseChange(to: newPhase)
            }
        }
        .onDisappear {
            vm.cancelSubmitTask() // 뷰 사라지면 작업 취소
            vm.showSubmitAlertView = false
        }
    }
    
    @ViewBuilder
    private var submitAlertView: some View {
        switch vm.submitStatus {
        case .inProgress, .fail, .retry:
            SubmitStatusView(status: vm.submitStatus) {
                vm.showSubmitAlertView = false
            }
        case .complete:
            SubmitCompleteView(quest: vm.selectedQuest) {
                vm.showSubmitAlertView = false
                dismiss()
            }
        }
    }
}

#Preview {
    let challengeNetwork = ChallengeNetwork()

    SubmitAlertView(vm: SubmitRouterViewModel(selectedImage: nil, selectedQuest: .mockData, submitService: ImageChallengeSubmitService(imageNetwork: ImageNetwork(), challengeNetwork: challengeNetwork), challengeNetwork: challengeNetwork))
}
