//
//  IllsangZoneSelectionView.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/11/25.
//

import SwiftUI

struct IllsangZoneSelectionView: View {
    @StateObject private var viewModel: IllsangZoneSelectionViewModel
    @Environment(\.dismiss) var dismiss
    
    var onSuccess: ((CommercialArea) -> Void)?
    
    init(userRepository: UserRepositoryInterface, areaRepository: AreaRepositoryInterface, onSuccess: ((CommercialArea) -> Void)? = nil) {
        self._viewModel = StateObject(wrappedValue: IllsangZoneSelectionViewModel(userRepository: userRepository, areaRepository: areaRepository))
        self.onSuccess = onSuccess
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationTitleView(title: "일상존 선택") {
                    dismiss()
                }
                .padding(.bottom, 8)
                .padding(.horizontal, -20)
                
                AreaSelectionView(
                    areas: $viewModel.areas,
                    selectedMetroIdx: $viewModel.selectedMetroIdx,
                    selectedCommercialArea: $viewModel.selectedArea,
                    onChangeSelectedCommercial: { area in
                        viewModel.selectedArea = area
                    }
                )
            }
            .task {
                await viewModel.loadAreas()
            }
            .navigationBarBackButtonHidden()
            .padding(.horizontal, 20)
            .safeAreaInset(edge: .bottom, alignment: .center) {
                if viewModel.selectedArea != nil {
                    PrimaryButton(title: "내 일상존 선택하기") {
                        viewModel.showChangeWarning()
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            if viewModel.showAlert {
                switch viewModel.alertType {
                case .illsangZoneSetWarning:
                    SettingAlertView(
                        alertType: viewModel.alertType,
                        onCancel: { viewModel.showAlert = false },
                        onConfirm: {
                            Task {
                                let setSucc = await viewModel.setIllsangZone()
                                if setSucc {
                                    if let selectedArea = viewModel.selectedArea {
                                        onSuccess?(selectedArea)
                                        dismiss()
                                    }
                                }
                            }
                        }) {
                            HStack(spacing: 0) {
                                Text("현재 선택된 일상존: ")
                                    .foregroundStyle(.gray500)
                                Text(viewModel.selectedArea?.areaName ?? "없음")
                                    .foregroundStyle(.primary500)
                            }
                            .styledFont(.regular, size: 13, lineHeight: 20)
                            
                        }
                case .illsangZoneSetFailed:
                    SettingAlertView(
                        alertType: viewModel.alertType,
                        onConfirm: { viewModel.showAlert = false }
                    )
                default: EmptyView()
                }
            }
        }
    }
}


@MainActor
class IllsangZoneSelectionViewModel: ObservableObject {
    @Published var areas: [MetroArea] = []
    @Published var selectedMetroIdx: Int = 0
    @Published var selectedArea: CommercialArea?
    @Published var showAlert: Bool = false
    @Published var alertType: AlertType = .illsangZoneSetWarning
    
    private let userRepository: UserRepositoryInterface
    private let areaRepository: AreaRepositoryInterface
    
    init(userRepository: UserRepositoryInterface, areaRepository: AreaRepositoryInterface) {
        self.userRepository = userRepository
        self.areaRepository = areaRepository
    }
    
    func loadAreas() async {
        let result = await areaRepository.getMetroAreas(forceRefresh: false)
        switch result {
        case .success(let res):
            self.areas = res
        case .failure:
            Log("지역 조회 실패")
        }
    }
    
    func showChangeWarning() {
        alertType = .illsangZoneSetWarning
        showAlert = true
    }
    
    func setIllsangZone() async -> Bool {
        guard let code = selectedArea?.code else { return false }
        
        let succ = await userRepository.putAreaZone(commercialAreaCode: code)
        if succ {
            return true
        } else {
            alertType = .illsangZoneSetFailed
            showAlert = true
            return false
        }
    }
}

#Preview {
    IllsangZoneSelectionView(userRepository: UserRepository(network: UserNetwork()), areaRepository: AreaRepository(network: AreaNetwork()))
}
