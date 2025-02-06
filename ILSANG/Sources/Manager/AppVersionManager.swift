//
//  AppVersionManager.swift
//  ILSANG
//
//  Created by Lee Jinhee on 2/5/25.
//

import UIKit

final class AppVersionManager {
    static let shared = AppVersionManager()
    private let appStoreOpenUrlStr = "itms-apps://itunes.apple.com/app/apple-store/6504427618"

    private init() { }

    func isUpdateAvailable() async throws -> Bool {
        guard let info = Bundle.main.infoDictionary,
              let currentVersion = info["CFBundleShortVersionString"] as? String, // 현재 버전 가져오기
              let identifier = info["CFBundleIdentifier"] as? String, // 앱 번들아이디 가져오기
              let url = URL(string: "http://itunes.apple.com/kr/lookup?bundleId=\(identifier)") else {
            throw VersionError.invalidBundleInfo
        }
        
        let (data, _) = try await URLSession.shared.data(from: url) // 비동기 네트워크 요청
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], // 네트워크 응답 파싱
              let result = (json["results"] as? [[String: Any]])?.first,
              let appStoreVersion = result["version"] as? String else {
            throw VersionError.invalidResponse
        }

        return currentVersion.compare(appStoreVersion, options: .numeric) == .orderedAscending // 현재 앱의 버전과 앱스토어 버전을 비교해서 업데이트 가능 여부 반환
    }
    
    // 앱 스토어로 이동
    func openAppStore() {
        guard let url = URL(string: appStoreOpenUrlStr) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

enum VersionError: Error {
  case invalidResponse, invalidBundleInfo
}
