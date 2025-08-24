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
    
    init(onSuccess: ((CommercialArea) -> Void)? = nil) {
        self._viewModel = StateObject(wrappedValue: IllsangZoneSelectionViewModel())
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
                    areas: viewModel.areas,
                    onChangeSelectedCommercial: { area in
                        viewModel.selectedArea = area
                    }
                )
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
}


class IllsangZoneSelectionViewModel: ObservableObject {
    let areas: [MetroAreaResponse] = MetroAreaResponse.mockData

    @Published var showAlert: Bool = false
    @Published var alertType: AlertType = .illsangZoneSetWarning
    @Published var selectedArea: CommercialArea?

    func showChangeWarning() {
        alertType = .illsangZoneSetWarning
        showAlert = true
    }
    
    func setIllsangZone() -> Bool {
        // TODO: 네트워크 요청
         let result: Result<Void, Error> = .success(())
//        let result: Result<Void, Error> = .failure(NetworkError.emptyResponse)
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
    IllsangZoneSelectionView()
}
