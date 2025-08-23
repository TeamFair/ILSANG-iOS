//
//  MissionResponse+Mapping.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/23/25.
//



extension MissionResponse {
    func toDomain() -> Mission {
        guard let missionType = MissionType(rawValue: type) else {
            fatalError("MissionType 초기화 실패")
        }
        return Mission(
            id: id,
            type: missionType,
            exampleImageIds: exampleImageIds
        )
    }
}
