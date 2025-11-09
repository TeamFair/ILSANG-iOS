//
//  PaginationManager.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/25/24.
//

import SwiftUI

final class PaginationManager<T> {
    let size: Int
    private let threshold: Int
    
    /// 페이지 번호를 인자로 받아 해당 페이지의 데이터를 비동기적으로 로드하는 메서드.
    /// isLast(마지막 페이지 여부)를 반환해야 합니다.
    var loadPageData: ((Int, Int) async -> Bool)?
    
    private var currentPage: Int = 0
    
    private(set) var isLastPage: Bool = false
    private(set) var isLoading: Bool = false
    
    init(size: Int, threshold: Int) {
        self.size = size
        self.threshold = threshold
    }
    
    deinit {
        Log("🗑️ PaginationManager deinit")
        loadPageData = nil
    }
    
    /// 더 불러올 수 있는지 여부
    func canLoadMoreData() -> Bool {
        return !isLastPage && !isLoading
    }
    
    /// 스크롤 시점에 따른 추가 로딩 가능 여부
    func canLoadMoreData(index: Int, currentCount: Int) -> Bool {
        guard !isLastPage, !isLoading, currentCount > 0 else {
            return false
        }
        let triggerIndex = max(currentCount - threshold, 0)
        return index >= triggerIndex
    }
    
    /// 데이터 로드
    func loadData(isRefreshing: Bool) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        if isRefreshing {
            resetPagination()
        } else {
            currentPage += 1
        }
        
        guard let loadPageData else { return }
        let isLastPage = await loadPageData(currentPage, size)
        self.isLastPage = isLastPage
    }
    
    func resetPagination() {
        currentPage = 0
        isLastPage = false
    }
}
