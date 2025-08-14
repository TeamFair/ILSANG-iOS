//
//  AreaSelectionView.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/10/25.
//

import SwiftUI

struct AreaSelectionView: View {
    
    let areas: [MetroArea]
    
    @State var selectedMetroIdx: Int = 0
    @State var selectedCommercialArea: CommercialArea?
    
    var onChangeSelectedCommercial: ((CommercialArea) -> ())
    
    var body: some View {
        HStack(spacing: 0) {
            // 일상지역
            metroAreaList
            
            verticalDivider
            
            // 일상존
            VStack(spacing: 0) {
                commercialAreaHeader(title: areas[selectedMetroIdx].areaName)
                horizontalDivider
                commercialAreaList(areas[selectedMetroIdx].commercialAreaModel)
            }
            .padding(.leading, 8)
        }
        .background(.white)
    }
    
    private var metroAreaList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(areas, id: \.code) { area in
                    metroAreaButton(area, isSelected: area.code == areas[selectedMetroIdx].code)
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color.background)
    }
    
    private func metroAreaButton(_ area: MetroArea, isSelected: Bool) -> some View {
        Button {
            if let idx = areas.firstIndex(of: area) {
                selectedMetroIdx = idx
            }
        } label: {
            Text(area.areaName)
                .styledFont(.subTitle1)
                .frame(width: 103, height: 54)
                .foregroundStyle(isSelected ? .white : .gray500)
                .background(isSelected ? .primary300 : .clear)
                .animation(.default, value: selectedMetroIdx)
        }
    }
    
    private func commercialAreaHeader(title: String) -> some View {
        HStack(spacing: 0) {
            Image(.illsangRegion)
                .resizable()
                .scaledToFit()
                .frame(width: 16)
                .frame(30)
            Text(title)
                .styledFont(.button)
                .foregroundStyle(.black)
        }
        .padding(.leading, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 54)
    }
    
    private func commercialAreaList(_ list: [CommercialArea]) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(list, id: \.code) { area in
                    commercialAreaButton(area, isSelected: area == selectedCommercialArea)
                }
            }
            .padding(.bottom, 160)
        }
        .scrollBounceBehavior(.basedOnSize)
        .padding(.trailing, -20)
    }
    
    private func commercialAreaButton(_ area: CommercialArea, isSelected: Bool) -> some View {
        Button {
            selectedCommercialArea = area
            onChangeSelectedCommercial(area)
        } label: {
            Text(area.areaName)
                .styledFont(.subTitle2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 54)
                .padding(.leading, 20)
                .foregroundStyle(isSelected ? .primary500 : .black)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            isSelected ? Color.primary500 : .clear,
                            style: StrokeStyle(lineWidth: 1)
                        )
                )
                .padding(.trailing, 20)
                .animation(.default, value: selectedCommercialArea)
        }
    }
    
    private var verticalDivider: some View {
        Rectangle()
            .frame(width: 1)
            .frame(maxHeight: .infinity)
            .ignoresSafeArea()
            .foregroundStyle(Color.gray100)
    }
    
    private var horizontalDivider: some View {
        Rectangle()
            .frame(height: 1)
            .frame(maxWidth: .infinity)
            .foregroundStyle(Color.gray100)
    }
}

#Preview {
    AreaSelectionView(areas: MetroArea.mockData, selectedCommercialArea: nil, onChangeSelectedCommercial: {_ in })
}
