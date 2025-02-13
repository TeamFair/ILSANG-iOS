//
//  Network.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/12/24.
//

import Alamofire
import Foundation
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
            let token = UserService.shared.authToken
            headers.add(.authorization(token))
        }
        return headers
    }
    
    static func requestData<T: Decodable>(url: String, method: HTTPMethod, parameters: Parameters?, body: Data? = nil, withToken: Bool, page: Int? = nil, size: Int? = nil) async -> Result<T, Error> {
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
        
        let response = await request.validate(statusCode: 200..<300)
            .serializingDecodable(T.self, emptyResponseCodes: [200])
            .response
        
        switch response.result {
        case .success(let res):
            Log("네트워크 요청 성공: \(fullPath), \(request.request?.httpMethod ?? "")")
            return .success(res)
        case .failure(let error):
            Log("네트워크 요청 실패: \(fullPath), \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    static func requestImage(url: String, withToken: Bool) async -> Result<UIImage, Error> {
        guard let fullPath = buildURL(url: url) else {
            return .failure(NetworkError.invalidURL)
        }
        
        let headers = buildHeaders(withToken: withToken)
        
        let request: DataRequest
        request = AF.request(fullPath, method: .get, headers: headers)
        
        let response = await request.validate(statusCode: 200..<300)
            .serializingData()
            .response
        
        switch response.result {
        case .success(let imageData):
            guard let image = UIImage(data: imageData) else {
                return .failure(NetworkError.invalidImageData)
            }
            return .success(image)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    static func postImage(url: String, image: UIImage, withToken: Bool, parameters: Parameters) async -> Result<ImageEntity, Error> {
        guard let fullPath = buildURL(url: url, parameters: parameters) else {
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
        }, with: urlRequest)
            .serializingDecodable(Response<ImageEntity>.self)
            .response
        
        switch response.result {
        case .success(let res):
            if let statusCode = response.response?.statusCode {
                return handleStatusCode(statusCode, data: res.data)
            } else {
                return .failure(NetworkError.unknownError)
            }
        case .failure(let error):
            return .failure(NetworkError.requestFailed(error.localizedDescription))
        }
    }
    
    private static func handleStatusCode<T>(_ statusCode: Int, data: T?) -> Result<T, Error> {
        switch statusCode {
        case 200..<300:
            if let data = data {
                return .success(data)
            } else {
                return .failure(NetworkError.unknownError)
            }
        case 400..<500:
            return .failure(NetworkError.clientError)
        case 500..<600:
            return .failure(NetworkError.serverError)
        default:
            return .failure(NetworkError.unknownStatusCode(statusCode))
        }
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
