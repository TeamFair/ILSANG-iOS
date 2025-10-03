//
//  IllsangZoneManager.swift
//  ILSANG
//
//  Created by Lee Jinhee on 9/2/25.
//

import Combine
import Foundation

@MainActor
class IllsangZoneManager: ObservableObject {
    @Published var currentZoneCode: String?
    @Published var currentZoneName: String?
    @Published var shouldShowWarning: Bool = false
    
    private let dontShowDateKey = "DontShowIllsangZoneWarningDate"
    
    private let areaNameService: AreaNameProvider
    private var cancellables = Set<AnyCancellable>() // 구독 저장
    
    init(areaNameService: AreaNameProvider) {
        self.areaNameService = areaNameService
        
        UserService.shared.$currentUser
            .compactMap { $0?.commercialAreaCode }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] zoneCode in
                self?.currentZoneCode = zoneCode
                Task {
                    self?.currentZoneName = await areaNameService.getAreaName(for: zoneCode)
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .NSCalendarDayChanged)
            .sink { [weak self] _ in
                self?.updateWarningStatus()
            }
            .store(in: &cancellables)
        
        updateWarningStatus()
        Log("🛠️ IllsangZoneManager: init")
    }
    
    deinit {
        Log("🛠️ IllsangZoneManager: deinit")
    }
    
    func setZone(_ area: CommercialArea) {
        self.currentZoneCode = area.code
        self.currentZoneName = area.areaName
    }
    
    func canChangeZone() -> Bool {
        return currentZoneCode == nil // 시즌 중에는 변경 불가
    }
    
    func isZoneSelected() -> Bool {
        return currentZoneCode != nil
    }
    
    func updateWarningStatus() {
        // 일상존이 선택되지 않은 경우
        if currentZoneCode == nil {
            // 오늘 dontShow 저장 여부 확인
            if let dontShowDate = UserDefaults.standard.object(forKey: dontShowDateKey) as? Date {
                let calendar = Calendar.current
                Log(calendar)
                Log(dontShowDate)
                // 오늘 날짜와 같으면 경고 안 띄움
                if calendar.isDateInToday(dontShowDate) {
                    shouldShowWarning = false
                    return
                }
            }
            shouldShowWarning = true
        } else {
            // 일상존 선택된 상태
            shouldShowWarning = false
        }
    }
    
    func saveDontShowPreference() {
        // 오늘 날짜 저장
        UserDefaults.standard.set(Date(), forKey: dontShowDateKey)
        shouldShowWarning = false
    }
}
