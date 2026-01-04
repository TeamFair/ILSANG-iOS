//
//  SubmitAlertView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/25/24.
//

import SwiftUI

struct SubmitAlertView: View {
    @ObservedObject var vm: SubmitRouterViewModel
    @EnvironmentObject var dependencies: AppDependencies
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            if vm.showSubmitAlertView {
                Color.black.opacity(0.3).ignoresSafeArea()
                submitAlertView
            }
            if let coupon = vm.selectedQuest.coupon, vm.showCouponRewardView {
                QuestCouponView(
                    coupon: coupon,
                    buttonTitle: "획득",
                    onDismiss: {
                        vm.showCouponRewardView = false
                        dependencies.questSubmissionNotifier.markQuestAsSubmitted()
                        dismiss()
                    }
                )
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .background(Color.black.opacity(0.3))
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

                if vm.selectedQuest.coupon?.type == .realtime {
                    vm.showCouponRewardView = true
                } else {
                    dependencies.questSubmissionNotifier.markQuestAsSubmitted()
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    let challengeNetwork = ChallengeNetwork()

    SubmitAlertView(vm: SubmitRouterViewModel(selectedImage: nil, selectedQuest: .mockData, submitService: ImageChallengeSubmitService(imageNetwork: ImageNetwork(), challengeNetwork: challengeNetwork), challengeNetwork: challengeNetwork))
}
