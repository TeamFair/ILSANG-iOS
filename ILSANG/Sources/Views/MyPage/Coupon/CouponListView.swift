//
//  CouponListView.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/4/25.
//

import SwiftUI

struct CouponListView: View {
    @StateObject var viewModel: CouponListViewModel
    @EnvironmentObject var sharedState: SharedState
    @Environment(\.dismiss) var dismiss
    
    init(viewModel: CouponListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerView
                
                VStack(spacing: 0) {
                    Section(header: selectScopeView) {
                        switch viewModel.viewStatus {
                        case .loading:
                            ProgressView()
                                .frame(maxHeight: .infinity, alignment: .center)
                        case .loaded:
                            couponListView
                        case .error:
                            networkErrorView
                        }
                    }
                }
            }
            .background(Color.background)
            .navigationBarBackButtonHidden()
            .task {
                await viewModel.loadDataIfNeeded()
            }
        }
        .overlay {
            if let alertType = viewModel.alertType {
                SettingAlertView(alertType: alertType, onConfirm: {
                    viewModel.alertType = nil
                })
            }
        }
    }
}

extension CouponListView {
    private var headerView: some View {
        NavigationTitleView(title: "쿠폰", isSeparatorHidden: true, background: .background) {
            dismiss()
        }
        .padding(.bottom, 8)
    }
    
    private var selectScopeView: some View {
        SelectableTabHeader(
            selectedItem: $viewModel.selectedCouponStatus,
            items: CouponStatus.allCases,
            horizontalPadding: 0,
            height: 44,
            hasBottomLine: true
        )
    }
    
    private var couponListView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.filteredCoupons, id: \.id) { coupon in
                    Button {
                        viewModel.selectedCoupon = coupon
                    } label: {
                        CouponListItem(item: coupon)
                    }
                    .disabled(coupon.useYn || coupon.expireYn)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 72)
        }
        .refreshable {
            await viewModel.loadInitialData()
        }
        .sheet(item: $viewModel.selectedCoupon, onDismiss: {
            viewModel.sheetStatus = .info
            viewModel.password = ""
            viewModel.showPasswordError = false

            if viewModel.alertType != .success {
                viewModel.alertType = nil
            }
        }, content: { coupon in
            switch viewModel.sheetStatus {
            case .info:
                CouponSheetView(viewModel: viewModel, item: coupon)
                    .presentationDragIndicator(.hidden)
                    .presentationDetents([.height(324)])
                    .presentationCornerRadius(24)
            case .passwordInput:
                CouponSheetView(viewModel: viewModel, item: coupon)
                    .presentationDragIndicator(.hidden)
                    .presentationDetents([.height(440)])
                    .presentationCornerRadius(24)
            }
        })
        .overlay {
            if viewModel.filteredCoupons.isEmpty {
                emptyView
            }
        }
    }
    
    private var emptyView: some View {
        switch viewModel.selectedCouponStatus {
        case .available:
            ErrorView(
                title: "보유 중인 쿠폰이 없어요",
                subTitle: "일상존 퀘스트로 쿠폰 확률을 높여보세요!",
                buttonTitle: "퀘스트 바로가기"
            ) {
                sharedState.selectedTab = .home
                dismiss()
            }
        case .redeemed:
            ErrorView(
                title: "만료/완료된 쿠폰이 없어요",
                subTitle: "일상존 퀘스트로 쿠폰 확률을 높여보세요!",
                showButton: false
            )
        }
        
    }
    private var networkErrorView: some View {
        ErrorView(
            systemImageName: "wifi.exclamationmark",
            title: "네트워크 연결 상태를 확인해주세요",
            subTitle: "네트워크 연결 상태가 좋지 않아\n쿠폰을 불러올 수 없어요",
            emoticon: "🥲"
        ) {
            Task { await viewModel.loadInitialData() }
        }
    }
}


enum CouponStatus: String, CaseIterable, Identifiable, SelectableTabItem {
    var id: String { self.rawValue }
    case available
    case redeemed
    
    var headerText: String {
        switch self {
        case .available:
            "보유 중"
        case .redeemed:
            "사용 만료/완료"
        }
    }
    
    func filter(from coupons: [UserCouponItem]) -> [UserCouponItem] {
        switch self {
        case .available:
            return coupons.filter { !$0.useYn && !$0.expireYn }
        case .redeemed:
            return coupons.filter { $0.useYn || $0.expireYn }
        }
    }
}

#Preview {
    CouponListView(
        viewModel: CouponListViewModel(
            couponRepository: CouponRepository(
                network: CouponNetwork()
            )
        )
    )
}
