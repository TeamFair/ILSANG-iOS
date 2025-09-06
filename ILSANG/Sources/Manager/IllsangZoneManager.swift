//
//  IllsangZoneManager.swift
//  ILSANG
//
//  Created by Lee Jinhee on 9/2/25.
//

import Foundation
import Combine

@MainActor
class IllsangZoneManager: ObservableObject {
    @Published var currentZoneCode: String?
    @Published var currentZoneName: String?
    @Published var shouldShowWarning: Bool = false
    
    @Published var currentSeason: Season?
    private let dontShowKey = "DontShowIllsangZoneWarning"
    private let seasonKey = "IllsangZoneSeason"
    
    private let areaNameService: AreaNameProvider
    private var cancellables = Set<AnyCancellable>() // 구독 저장

    init(areaNameService: AreaNameProvider, seasonManager: SeasonManager) {
        self.areaNameService = areaNameService
        
        // 시즌 변경 시 currentSeason 업데이트
        seasonManager.$currentSeason
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newSeason in
                self?.currentSeason = newSeason
                self?.updateWarningStatus()
            }
            .store(in: &cancellables)
        
        loadCurrentZone()
//        updateWarningStatus()
    }
    
    func loadCurrentZone() {
        if let zoneCode = UserService.shared.currentUser?.commercialAreaCode {
            self.currentZoneCode = zoneCode
            Task {
                self.currentZoneName = await areaNameService.getAreaName(for: zoneCode)
            }
        }
    }
    
    func setZone(_ area: CommercialArea) {
        self.currentZoneCode = area.code
        self.currentZoneName = area.areaName
        // TODO: 서버에 저장 로직
    }
    
    func canChangeZone() -> Bool {
        return currentZoneCode == nil // 시즌 중에는 변경 불가
    }
    
    func isZoneSelected() -> Bool {
        return currentZoneCode != nil
    }
    
    func updateWarningStatus() {
        let savedSeason = UserDefaults.standard.integer(forKey: seasonKey)
        let dontShow = UserDefaults.standard.bool(forKey: dontShowKey)
        
        if let seasonNumber = currentSeason?.id {
            shouldShowWarning = (savedSeason != seasonNumber) || !dontShow
        } else {
            shouldShowWarning = !dontShow
        }
    }
    
    func saveDontShowPreference() {
        UserDefaults.standard.set(true, forKey: dontShowKey)
        if let seasonNumber = currentSeason?.id {
            UserDefaults.standard.set(seasonNumber, forKey: seasonKey)
        }
        shouldShowWarning = false
    }
}
