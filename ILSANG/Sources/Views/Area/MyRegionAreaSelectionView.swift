//
//  MyRegionAreaSelectionView.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/11/25.
//

import SwiftUI

struct MyRegionAreaSelectionView: View {
    @StateObject private var viewModel: MyRegionAreaSelectionViewModel
    @Environment(\.dismiss) var dismiss
    
    var onSuccess: ((CommercialArea) -> Void)?
    
    init(onSuccess: ((CommercialArea) -> Void)? = nil) {
        self._viewModel = StateObject(wrappedValue: MyRegionAreaSelectionViewModel())
        self.onSuccess = onSuccess
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationTitleView(title: "내 지역") {
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
                    PrimaryButton(title: "내 지역 선택하기") {
                        let succ = viewModel.setIllsangZone()
                        if succ {
                            if let selectedArea = viewModel.selectedArea {
                                onSuccess?(selectedArea)
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            if viewModel.showAlert {
                SettingAlertView(
                    alertType: .myRegionChangeFailed,
                    onConfirm: { viewModel.showAlert = false }
                )
            }
        }
        
    }
}


class MyRegionAreaSelectionViewModel: ObservableObject {
    let areas: [MetroArea] = MetroArea.mockData
    
    @Published var showAlert: Bool = false
    @Published var selectedArea: CommercialArea?
    
    func setIllsangZone() -> Bool {
        // TODO: 네트워크 요청
         let result: Result<Void, Error> = .success(())
        // let result: Result<Void, Error> = .failure(NetworkError.emptyResponse)
        switch result {
        case .success:
            return true
        case .failure:
            showAlert = true
            return false
        }
    }
}

#Preview {
    MyRegionAreaSelectionView()
}
