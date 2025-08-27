//
//  MetroArea.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/10/25.
//

struct MetroAreaResponse: Codable {
    let code: String
    let areaName: String
    let commercialAreas: [CommercialAreaResponse]
    
    static let mockData: [MetroAreaResponse] = [
        MetroAreaResponse(
            code: "G01",
            areaName: "경기남부",
            commercialAreas: CommercialAreaResponse.mockDataList1
        ), MetroAreaResponse(
            code: "G02",
            areaName: "경기북부",
            commercialAreas: CommercialAreaResponse.mockDataList2
        )
    ]
}

struct CommercialAreaResponse: Codable, Equatable {
    let code: String
    let areaName: String
    let description: String
    let metroAreaCode: String
    
    static let mockDataList1: [CommercialAreaResponse] = [
        CommercialAreaResponse(
            code: "R100",
            areaName: "서현",
            description: "번화가,대학가",
            metroAreaCode: "G01"
        ),
        CommercialAreaResponse(
            code: "R101",
            areaName: "정자",
            description: "분당중심상권",
            metroAreaCode: "G01"
        ),
        CommercialAreaResponse(
            code: "R102",
            areaName: "야탑",
            description: "상업지구,역세권",
            metroAreaCode: "G01"
        ),
        CommercialAreaResponse(
            code: "R103",
            areaName: "미금",
            description: "역세권,쇼핑몰",
            metroAreaCode: "G01"
        ),
        CommercialAreaResponse(
            code: "R104",
            areaName: "수내",
            description: "주거밀집,근린상권",
            metroAreaCode: "G01"
        ),
        CommercialAreaResponse(
            code: "R105",
            areaName: "판교",
            description: "IT기업밀집,오피스상권",
            metroAreaCode: "G01"
        ),
        CommercialAreaResponse(
            code: "R106",
            areaName: "이매",
            description: "역세권,주거상권",
            metroAreaCode: "G01"
        ),
        CommercialAreaResponse(
            code: "R107",
            areaName: "서판교",
            description: "주거밀집,카페거리",
            metroAreaCode: "G01"
        ),
        CommercialAreaResponse(
            code: "R108",
            areaName: "구미동",
            description: "주거밀집,근린상권",
            metroAreaCode: "G01"
        ),
        CommercialAreaResponse(
            code: "R109",
            areaName: "정자동",
            description: "역세권,음식점밀집",
            metroAreaCode: "G01"
        ),
        CommercialAreaResponse(
            code: "R110",
            areaName: "동판교",
            description: "신도시,상업지구",
            metroAreaCode: "G01"
        ),
        CommercialAreaResponse(
            code: "R111",
            areaName: "백현동",
            description: "레스토랑거리,고급상권",
            metroAreaCode: "G01"
        ),
        CommercialAreaResponse(
            code: "R112",
            areaName: "운중동",
            description: "주거단지,근린상권",
            metroAreaCode: "G01"
        ),
        CommercialAreaResponse(
            code: "R113",
            areaName: "금곡동",
            description: "역세권,상업시설",
            metroAreaCode: "G01"
        ),
        CommercialAreaResponse(
            code: "R114",
            areaName: "야탑동",
            description: "역세권,대형마트",
            metroAreaCode: "G01"
        ),
        CommercialAreaResponse(
            code: "R115",
            areaName: "서현동",
            description: "중심상권,카페거리",
            metroAreaCode: "G01"
        ),
        CommercialAreaResponse(
            code: "R116",
            areaName: "수내동",
            description: "주거단지,편의시설",
            metroAreaCode: "G01"
        ),
        CommercialAreaResponse(
            code: "R117",
            areaName: "정자동카페거리",
            description: "카페거리,맛집밀집",
            metroAreaCode: "G01"
        ),
        CommercialAreaResponse(
            code: "R118",
            areaName: "판교테크노밸리",
            description: "오피스상권,IT기업",
            metroAreaCode: "G01"
        ),
        CommercialAreaResponse(
            code: "R119",
            areaName: "이매동",
            description: "역세권,학원가",
            metroAreaCode: "G01"
        ),
        CommercialAreaResponse(
            code: "R120",
            areaName: "삼평동",
            description: "신도시,상업시설",
            metroAreaCode: "G01"
        ),
        CommercialAreaResponse(
            code: "R121",
            areaName: "정자역광장",
            description: "역광장,상권밀집",
            metroAreaCode: "G01"
        )
    ]
    
    static let mockDataList2: [CommercialAreaResponse] = [
        CommercialAreaResponse(
            code: "S100",
            areaName: "모란",
            description: "번화가,대학가",
            metroAreaCode: "G02"
        ),
        CommercialAreaResponse(
            code: "S101",
            areaName: "상대원",
            description: "분당중심상권",
            metroAreaCode: "G02"
        )
    ]
}
