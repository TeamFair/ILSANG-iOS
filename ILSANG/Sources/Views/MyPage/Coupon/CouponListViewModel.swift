//
//  CouponListViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 9/5/25.
//


import UIKit
import SwiftUICore

// TODO: 페이지네이션
class CouponListViewModel: ObservableObject {
    @Published var viewStatus: ViewStatus = .loading
    @Published var selectedCouponStatus: CouponStatus = .available
    @Published var selectedCoupon: UserCouponItem?
    @Published var userCoupons: [UserCouponItem] = []
    @Published var sheetStatus: CouponSheetStatus = .info
    @Published var alertType: CouponAlertType?
    @Published var password: String = ""
    
    var filteredCoupons: [UserCouponItem] {
        selectedCouponStatus.filter(from: userCoupons)
    }
    
    var isButtonEnabled: Bool {
        if sheetStatus == .passwordInput {
            return password.count == 4
        } else {
            return true
        }
    }
    private let couponRepository: CouponRepositoryInterface
    
    init(couponRepository: CouponRepositoryInterface) {
        self.couponRepository = couponRepository
    }
    
    func loadDataIfNeeded() async {
        if userCoupons.isEmpty {
            await loadInitialData()
        }
    }
    
    @MainActor
    func loadInitialData() async {
        changeViewStatus(.loading)
        await fetchCoupons(page: 0, size: 10)
        changeViewStatus(.loaded)
    }
    
    @MainActor
    func fetchCoupons(page: Int, size: Int) async {
        let res = await couponRepository.getCoupons(page: page, size: size)
        switch res {
        case .success(let success):
            self.userCoupons = success.map { $0.toUserCoupon() }
        case .failure:
            self.userCoupons = []
            self.changeViewStatus(.error)
        }
    }
    
    @MainActor
    func buttonAction() {
        switch sheetStatus {
        case .info:
            showInputPasswordView()
        case .passwordInput:
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            Task { await confirmCouponUsage() }
        }
    }
    
    @MainActor
    func showInputPasswordView() {
        sheetStatus = .passwordInput
    }
    
    @MainActor
    func confirmCouponUsage() async {
        guard let couponId = selectedCoupon?.id else { return }
        if !isButtonEnabled { return }
        
        switch await couponRepository.verifyPassword(id: couponId, password: password) {
        case .success(true):
            await applyCoupon(couponId: couponId)
        case .success(false):
            alertType = .passwordMismatch
        case .failure:
            alertType = .passwordMismatch
        }
    }
    
    private func applyCoupon(couponId: Int) async {
        switch await couponRepository.useCoupon(id: couponId) {
        case .success:
            selectedCoupon = nil
            alertType = .success
            await loadInitialData()
        case .failure:
            alertType = .fail
        }
    }
    
    @MainActor
    func changeViewStatus(_ viewStatus: ViewStatus) {
        self.viewStatus = viewStatus
    }
    
    enum ViewStatus {
        case error
        case loading
        case loaded
    }
    
    enum CouponSheetStatus {
        case info
        case passwordInput
        
        var title: String {
            switch self {
            case .info: "쿠폰 사용하기"
            case .passwordInput: "비밀번호 입력"
            }
        }
        var buttonTitle: String {
            switch self {
            case .info: "사장님께 보여주기"
            case .passwordInput: "쿠폰 사용하기"
            }
        }
    }
    
    enum CouponAlertType: AlertPresentable {
        case success
        case passwordMismatch
        case fail
        
        var title: String {
            switch self {
            case .success: "쿠폰이 적용되었습니다"
            case .passwordMismatch: "비밀번호가 틀렸습니다"
            case .fail: "쿠폰 사용에 문제가 발생했어요"
            }
        }
        
        var subtitle: String? {
            if self == .fail {
                return "잠시 후 다시 시도해주세요"
            } else {
                return nil
            }
        }
        
        var disagree: String { "" }
        var agree: String { "확인" }
        var titleColor: Color { .black }
        
        var icon: UIImage? {
            switch self {
            case .success: nil
            case .passwordMismatch: .retry
            case .fail: .retry
            }
        }
    }
}
