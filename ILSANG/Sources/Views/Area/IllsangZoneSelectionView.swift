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
    
    init(areaRepository: AreaRepositoryInterface, onSuccess: ((CommercialArea) -> Void)? = nil) {
        self._viewModel = StateObject(wrappedValue: IllsangZoneSelectionViewModel(areaRepository: areaRepository))
        self.onSuccess = onSuccess
    }
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationTitleView(title: "일상존 선택") {
                dismiss()
            }
            .padding(.bottom, 8)
            .padding(.horizontal, -20)
            
            AreaSelectionView(
                areas: viewModel.areas,
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
                        let setSucc = viewModel.setIllsangZone()
                        if setSucc {
                            if let selectedArea = viewModel.selectedArea {
                                onSuccess?(selectedArea)
                                dismiss()
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


@MainActor
class IllsangZoneSelectionViewModel: ObservableObject {
    @Published var areas: [MetroArea] = []
    @Published var selectedMetroIdx: Int = 0
    @Published var selectedArea: CommercialArea?
    @Published var showAlert: Bool = false
    @Published var alertType: AlertType = .illsangZoneSetWarning
    
    private let areaRepository: AreaRepositoryInterface
    
    init(areaRepository: AreaRepositoryInterface) {
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
    
    func setIllsangZone() -> Bool {
        // TODO: 네트워크 요청
        let result: Result<Void, Error> = .success(())
        switch result {
        case .success:
            return true
        case .failure:
            alertType = .illsangZoneSetFailed
            showAlert = true
            return false
        }
    }
}

#Preview {
    IllsangZoneSelectionView(areaRepository: AreaRepository(network: AreaNetwork()))
}
