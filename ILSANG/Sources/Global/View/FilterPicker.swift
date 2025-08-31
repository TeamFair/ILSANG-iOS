//
//  FilterPicker.swift
//  ILSANG
//
//  Created by Lee Jinhee on 11/6/24.
//

import SwiftUI

// MARK: - PickerStatus
enum PickerStatus {
    case open, close
    mutating func toggle() { self = (self == .open) ? .close : .open }
}

// MARK: - PickerStateProtocol
protocol PickerStateProtocol: ObservableObject {
    associatedtype Value: Hashable & CustomStringConvertible
    var selectedValue: Value { get set }
    var options: [Value] { get set }
    var pickerStatus: PickerStatus { get set }   // 읽기/쓰기 가능해야 함
}

// MARK: - Static (CaseIterable enum) state
final class StaticFilterPickerState<Value>: PickerStateProtocol
where Value: Hashable & CustomStringConvertible & CaseIterable {
    @Published var selectedValue: Value {
        didSet { onSelectionChange?(selectedValue) }
    }
    @Published var options: [Value]
    @Published var pickerStatus: PickerStatus = .close

    var onSelectionChange: ((Value) -> Void)?

    init(initialValue: Value, onSelectionChange: ((Value) -> Void)? = nil) {
        self.selectedValue = initialValue
        self.options = Array(Value.allCases)
        self.onSelectionChange = onSelectionChange
    }
}

// MARK: - Dynamic State
final class DynamicFilterPickerState<Value>: PickerStateProtocol
where Value: Hashable & CustomStringConvertible {
    @Published var selectedValue: Value {
        didSet {
            if oldValue != selectedValue {
                onSelectionChange?(selectedValue)
            }
        }
    }
    @Published var options: [Value]
    @Published var pickerStatus: PickerStatus = .close

    var onSelectionChange: ((Value) -> Void)?

    init(initialValue: Value, options: [Value] = [], onSelectionChange: ((Value) -> Void)? = nil) {
        self.selectedValue = initialValue
        self.options = options
        self.onSelectionChange = onSelectionChange
    }

    func updateOptions(_ newOptions: [Value]) {
        self.options = newOptions
        if !newOptions.contains(selectedValue), let first = newOptions.first {
            selectedValue = first
        }
    }
}

// MARK: - PickerView
struct PickerView<State>: View where State: PickerStateProtocol {
    @ObservedObject var state: State
    var showBorder: Bool = false
    let width: CGFloat

    var body: some View {
        ZStack(alignment: .top) {
            HStack(spacing: 0) {
                Text(state.selectedValue.description)
                    .font(.system(size: 15, weight: .regular))
                Spacer(minLength: 0)
                Image(systemName: state.pickerStatus == .open ? "chevron.down" : "chevron.up")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12)
                    .frame(width: 19, height: 19)
            }
            .foregroundStyle(.gray500)
            .padding(.horizontal, 12)
            .frame(width: width, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white)
                    .stroke(
                        showBorder ? .gray200 : .clear,
                        style: StrokeStyle(lineWidth: 1)
                    )
            )
            .onTapGesture { state.pickerStatus.toggle() }
            .shadow(color: .shadow7D.opacity(0.05), radius: 20, x: 0, y: 10)

            // 드롭다운
            if state.pickerStatus == .open {
                VStack(spacing: 0) {
                    let list = state.options.filter { $0 != state.selectedValue }
                    ForEach(Array(list.enumerated()), id: \.offset) { idx, value in
                        Button {
                            state.selectedValue = value
                            state.pickerStatus.toggle()
                        } label: {
                            Text(value.description)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(.gray500)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(height: 40)
                                .background(Color.white)
                                .padding(.horizontal, 12)
                        }
                    }
                }
                .frame(width: width)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: .shadow7D.opacity(0.05), radius: 20, x: 0, y: 10)
                .padding(.top, 44)
                .zIndex(1)
            }
        }
    }
}

// MARK: - Example Value Types
enum QuestFilterType: String, CaseIterable, Hashable, CustomStringConvertible {
    case pointHighest = "포인트 높은 순"
    case pointLowest  = "포인트 낮은 순"
    case popular      = "인기순"
    
    var description: String { rawValue }
    
    var orderRewardDesc: Bool? {
        switch self {
        case .pointHighest: return true
        case .pointLowest:  return false
        default: return nil
        }
    }
}

enum EventQuestFilterType: String, Hashable, CustomStringConvertible, CaseIterable {
    case upcoming = "임박순"
    case pointHighest = "포인트 높은 순"
    case pointLowest = "포인트 낮은 순"
    case popular = "인기순"
    
    var description: String { return self.rawValue }
    
    var orderExpiredDesc: Bool? {
        switch self {
        case .upcoming: return false
        default: return nil
        }
    }
}

struct SeasonFilterType: Hashable, CustomStringConvertible {
    let seasonNumber: Int   // -1 = 전체
    var description: String { seasonNumber == -1 ? "전체" : "시즌 \(seasonNumber)" }
}
