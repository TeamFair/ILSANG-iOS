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
                        if let selectedArea = viewModel.selectedArea {
                            onSuccess?(selectedArea)
                        }
                        dismiss()
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}


class MyRegionAreaSelectionViewModel: ObservableObject {
    let areas: [MetroAreaResponse] = MetroAreaResponse.mockData
    @Published var selectedArea: CommercialArea?
}

#Preview {
    MyRegionAreaSelectionView()
}
