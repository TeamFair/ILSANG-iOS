//
//  AreaNameService.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/27/25.
//

protocol AreaNameProvider {
    func getAreaName(for code: String) async -> String?
}

actor AreaNameService: AreaNameProvider {
    private let areaRepository: AreaRepositoryInterface
    private var areaDict: [String: String] = [:]
    private var isLoaded = false
    
    init(areaRepository: AreaRepositoryInterface) {
        self.areaRepository = areaRepository
    }
    
    func getAreaName(for code: String) async -> String? {
        if !isLoaded {
            await loadAreas()
        }
        return areaDict[code]
    }
    
    private func loadAreas() async {
        let result = await areaRepository.getMetroAreas(forceRefresh: false)
        
        guard case .success(let metros) = result else { return }
        
        var dict: [String: String] = [:]
        for metro in metros {
            for commercial in metro.commercialAreas {
                dict[commercial.code] = commercial.areaName
            }
        }
        self.areaDict = dict
        self.isLoaded = true
    }
}
