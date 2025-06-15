//
//  AuthNetwork.swift
//  ILSANG
//
//  Created by Lee Jinhee on 7/10/24.
//

import Foundation

final class AuthNetwork {
    private let url = APIManager.makeURL(OpenTarget(path: "login"))
    private let logoutUrl = APIManager.makeURL(CustomerTarget(path: "logout"))
    
    /// Apple 또는 Google에서 받은 idToken을 백엔드로 전송해 로그인 요청을 보내고, 성공 시 authorization 토큰을 반환합니다.
    func login(idToken: String, channel: AuthChannel) async -> Result<Auth, NetworkError> {
        let body = [
            "provider": channel.stringValue, /// OAuth 공급 기관 (GOOGLE, APPLE)
            "osType": "IOS", /// 기기 OS
            "idToken": idToken, /// OAuth 공급 기간에서 받은 토큰 정보
            "pushToken": "", /// FCM을 위한 기기 push token
            "deviceUuid": Utils.getDeviceUUID() /// 기기 식별번호
        ]
        
        let bodyData = body.convertToJsonData()
        let result: Result<Response<Auth>, Error> = await Network.requestData(url: url+"/oauth", method: .post, parameters: nil, body: bodyData, withToken: false)
        switch result {
        case .success(let res):
            return .success(res.data)
        case .failure(let error):
            return .failure(.requestFailed(error.localizedDescription))
        }
    }
    
    func logout() async -> Result<ResponseWithoutData, Error> {
        await Network.requestData(url: logoutUrl, method: .get, parameters: nil, withToken: true)
    }
}

import UIKit
// TODO: 확인 필요
// uuid는 앱을 삭제하면 새롭게 생성 됩니다.
// 앱을 재설치해도 고유한 번호가 필요한 경우, 최초 uuid 생성 시점에 keychain에 저장하는 방법있음
class Utils {
    static func getDeviceUUID() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
}
