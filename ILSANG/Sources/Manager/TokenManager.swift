//
//  TokenManager.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/17/25.
//

import Foundation

actor TokenManager {
    static let shared = TokenManager()
    private let authNetwork: AuthNetwork = AuthNetwork()
    private var isRefreshing = false
    private var waitingContinuations: [CheckedContinuation<Bool, Never>] = []
    
    func refreshTokenIfNeeded() async -> Bool {
        // 이미 토큰 갱신 중이면 대기
        if isRefreshing {
            return await withCheckedContinuation { continuation in
                waitingContinuations.append(continuation)
            }
        }
        
        isRefreshing = true
        defer { isRefreshing = false }

        // 실제 리프레시 요청
        let result = await authNetwork.refresh(
            accessToken: UserService.shared.accessToken,
            refreshToken: UserService.shared.refreshToken
        )
        
        let success: Bool
        switch result {
        case .success(let newToken):
            UserService.shared.updateToken(accessToken: newToken.authorization, refreshToken: newToken.refreshToken)
            success = true
        case .failure:
            // 로그아웃하도록 이벤트 처리
            NotificationCenter.default.post(name: .sessionExpired, object: nil)
            success = false
        }

        // 대기 중이던 요청들 이어주기
        for continuation in waitingContinuations {
            continuation.resume(returning: success)
        }
        waitingContinuations.removeAll()

        return success
    }
}
