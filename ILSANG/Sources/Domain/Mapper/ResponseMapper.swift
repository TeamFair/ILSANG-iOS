//
//  ResponseMapper.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/22/25.
//

protocol DomainConvertible {
    associatedtype Domain
    func toDomain() -> Domain
}

enum ResponseMapper {
    static func mapPagedResponse<DTO: DomainConvertible>(
        _ result: Result<ResponseWithPage<[DTO]>, Error>
    ) -> Result<ResponseWithPage<[DTO.Domain]>, Error> {
        switch result {
        case .success(let response):
            let domainResponse = ResponseWithPage<[DTO.Domain]>(
                size: response.size,
                content: response.content.map { $0.toDomain() },
                totalPages: response.totalPages,
                totalElements: response.totalPages,
                page: response.page,
                isLast: response.isLast
            )
            return .success(domainResponse)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    static func mapResponse<DTO: DomainConvertible>(
        _ result: Result<DTO, Error>
    ) -> Result<DTO.Domain, Error> {
        switch result {
        case .success(let response):
            return .success(response.toDomain())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    static func mapArrayResponse<DTO: DomainConvertible>(
        _ result: Result<[DTO], Error>
    ) -> Result<[DTO.Domain], Error> {
        switch result {
        case .success(let response):
            return .success(response.map { $0.toDomain() })
        case .failure(let error):
            return .failure(error)
        }
    }
}
