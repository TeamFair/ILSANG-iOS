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
    
    init(areaRepository: AreaRepositoryInterface, onSuccess: ((CommercialArea) -> Void)? = nil) {
        self._viewModel = StateObject(wrappedValue: MyRegionAreaSelectionViewModel(areaRepository: areaRepository))
        self.onSuccess = onSuccess
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationTitleView(title: "지역 선택") {
                    dismiss()
                }
                .padding(.bottom, 8)
                
                AreaSelectionView(
                    areas: $viewModel.areas,
                    selectedMetroIdx: $viewModel.selectedMetroIdx,
                    selectedCommercialArea: $viewModel.selectedArea,
                    onChangeSelectedCommercial: { area in
                        viewModel.selectedArea = area
                    }
                )
                .padding(.trailing, 20)
            }
            .task {
                await viewModel.loadAreas()
            }
            .navigationBarBackButtonHidden()
            .safeAreaInset(edge: .bottom, alignment: .center) {
                if viewModel.selectedArea != nil {
                    PrimaryButton(title: "지역 선택하기") {
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


@MainActor
class MyRegionAreaSelectionViewModel: ObservableObject {
    @Published var areas: [MetroArea] = []
    @Published var selectedMetroIdx: Int = 0
    @Published var selectedArea: CommercialArea?
    
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
}


#Preview {
    MyRegionAreaSelectionView(areaRepository: AreaRepository(network: AreaNetwork()))
}
