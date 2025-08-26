//
//  Network.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/12/24.
//

import Alamofire
import UIKit

final class Network {
    static let maxUploadImageSizeKB = 100.0
    static let requestTimeout: TimeInterval = 30
    
    private static func buildURL(url: String, parameters: Parameters? = nil, page: Int? = nil, size: Int? = nil) -> URL? {
        var components = URLComponents(string: url)
        var queryItems = [URLQueryItem]()

        if let parameters = parameters {
            for (key, value) in parameters {
                queryItems.append(URLQueryItem(name: key, value: "\(value)"))
            }
        }

        if let page = page {
            queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
        }
        
        if let size = size {
            queryItems.append(URLQueryItem(name: "size", value: "\(size)"))
        }
        
        components?.queryItems = queryItems
        return components?.url
    }
    
    private static func buildHeaders(withToken: Bool, contentType: ContentType = .json) -> HTTPHeaders {
        var headers: HTTPHeaders = ["accept": "application/json", "Content-Type": contentType.toString]
        if withToken {
            let token = UserService.shared.accessToken
            headers.add(.authorization(bearerToken: token))
        }
        return headers
    }
    
    static func requestData<T: Decodable>(
        url: String,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        body: Data? = nil,
        withToken: Bool = true,
        page: Int? = nil,
        size: Int? = nil,
        retryOnAuthFail: Bool = true
    ) async -> Result<T, Error> {
        // 1차 시도
        let result: Result<T, Error> = await performRequest(
            url: url, method: method, parameters: parameters, body: body, withToken: withToken, page: page, size: size
        )
        
        // 401 에러인 경우, 토큰 갱신 후 재시도
        if retryOnAuthFail,
            case .failure(let error) = result,
           (error as? NetworkError) == .unauthorized {
            
            let refreshSuccess = await TokenManager.shared.refreshTokenIfNeeded()
            if refreshSuccess {
                return await performRequest(
                    url: url, method: method, parameters: parameters, body: body, withToken: withToken, page: page, size: size
                )
            } else {
                return .failure(NetworkError.unauthorized)
            }
        }
        
        return result
    }
    
    private static func performRequest<T: Decodable>(
        url: String,
        method: HTTPMethod,
        parameters: Parameters?,
        body: Data? = nil,
        withToken: Bool,
        page: Int? = nil,
        size: Int? = nil
    ) async -> Result<T, Error> {
        guard let fullPath = buildURL(url: url, parameters: parameters, page: page, size: size) else {
            return .failure(NetworkError.invalidURL)
        }

        let headers = buildHeaders(withToken: withToken)
        let request: DataRequest

        if let body = body {
            var urlRequest = URLRequest(url: fullPath)
            urlRequest.method = method
            urlRequest.headers = headers
            urlRequest.httpBody = body
            request = AF.request(urlRequest)
        } else {
            request = AF.request(fullPath, method: method, encoding: parameters != nil ? URLEncoding.queryString : JSONEncoding.default, headers: headers)
        }

        let response = await request
            .serializingResponse(using: DecodableResponseSerializer<T>(emptyResponseCodes: [200]))
            .response
        let statusCode = response.response?.statusCode ?? -1
        let responseData = try? response.result.get()
        let result = handleStatusCode(statusCode, data: responseData, errorData: request.data)
        dump(response.result)
        switch result {
        case .success(let res):
            Log("네트워크 요청 성공: \(fullPath), \(method.rawValue)")
            return .success(res)
        case .failure(let error):
            Log("네트워크 요청 실패: \(fullPath), \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    static func requestImage(url: String, parameters: Parameters, withToken: Bool) async -> Result<UIImage, Error> {
        guard let fullPath = buildURL(url: url, parameters: parameters) else {
            return .failure(NetworkError.invalidURL)
        }
        
        let headers = buildHeaders(withToken: withToken)
        let response = await AF.request(fullPath, method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .serializingData()
            .response
        
        switch response.result {
        case .success(let imageData):
            guard let image = UIImage(data: imageData) else {
                return .failure(NetworkError.invalidImageData)
            }
            return .success(image)
        case .failure(let error):
            print("이미지 로드 ERROR", fullPath, error.localizedDescription)
            return .failure(error)
        }
    }
    
    static func postImage(url: String, image: UIImage, withToken: Bool, type: PostImageType) async -> Result<ImageEntity, Error> {
        guard let fullPath = buildURL(url: url) else {
            return .failure(NetworkError.invalidURL)
        }
        
        let headers = buildHeaders(withToken: withToken, contentType: .multipart)
        
        var urlRequest = URLRequest(url: fullPath)
        urlRequest.method = .post
        urlRequest.headers = headers
        urlRequest.timeoutInterval = requestTimeout
        
        // MARK: 이미지 다운 샘플링
        guard let downsampledImage = image.downSample() else {
            return .failure(NetworkError.invalidImageData)
        }
        
        var currentImage = downsampledImage
        
        // MARK: 이미지 업로드 가능한 사이즈까지 압축
        var compressedData = currentImage.jpegData(compressionQuality: 1.0) ?? Data()
        
        var compressionQuality: CGFloat = 0.9
        while compressedData.kilobytes >= maxUploadImageSizeKB {
            if compressionQuality > 0.1 {
                compressionQuality = Double(round(1000 * (compressionQuality - 0.05)) / 1000)
                compressedData = currentImage.jpegData(compressionQuality: compressionQuality) ?? Data()
            } else {
                /// 0.1로 압축한 data 사이즈가 maxUploadImageSizeKB보다 작도록 currentImage 리사이즈
                var tempResizeData: Data = compressedData
                while tempResizeData.kilobytes >= maxUploadImageSizeKB {
                    let newWidth = max(currentImage.size.width - 120, currentImage.size.width * 0.5)
                    currentImage = currentImage.resizeImage(newWidth: newWidth)
                    tempResizeData = currentImage.jpegData(compressionQuality: 0.1) ?? Data()
                }
                compressionQuality = 0.9
            }
        }
        
        let response = await AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(compressedData,
                                     withName: "file",
                                     fileName: "image.png",
                                     mimeType: "image/jpeg")
            if let typeData = type.parameter.data(using: .utf8) {
                multipartFormData.append(typeData, withName: "type")
            }
        }, with: urlRequest)
            .serializingDecodable(ImageEntity.self)
            .response
        
        switch response.result {
        case .success(let res):
            if let statusCode = response.response?.statusCode {
                Log("네트워크 요청 성공: 이미지 등록 \(fullPath), \(urlRequest.urlRequest?.httpMethod ?? "")")
                return handleStatusCode(statusCode, data: res)
            } else {
                return .failure(NetworkError.unknownError)
            }
        case .failure(let error):
            Log("네트워크 요청 실패: 이미지 등록 \(fullPath), \(urlRequest.urlRequest?.httpMethod ?? ""), \(error.localizedDescription)")
            return .failure(NetworkError.requestFailed(error.localizedDescription))
        }
    }
    
    private static func handleStatusCode<T>(_ statusCode: Int, data: T?, errorData: Data? = nil) -> Result<T, Error> {
        switch statusCode {
        case 200..<300:
            if let data = data {
                return .success(data)
            } else {
                return .failure(NetworkError.unknownError)
            }
        case 401:
            return .failure(NetworkError.unauthorized)
        case 400..<500:
            let message = extractErrorMessage(from: errorData) ?? "요청이 잘못되었습니다."
            return .failure(NetworkError.clientError(message))
        case 500..<600:
            let message = extractErrorMessage(from: errorData) ?? "서버에 오류가 발생했습니다."
            return .failure(NetworkError.serverError(message))
        default:
            return .failure(NetworkError.unknownStatusCode(statusCode))
        }
    }
    
    private static func extractErrorMessage(from data: Data?) -> String? {
        guard let data = data,
              let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
        else { return nil }
        return errorResponse.errMessage
    }
}

extension Network {
    enum ContentType {
        case json
        case multipart
        
        var toString: String {
            switch self {
            case .json:
                "application/json"
            case .multipart:
                "multipart/form-data"
            }
        }
    }
}
