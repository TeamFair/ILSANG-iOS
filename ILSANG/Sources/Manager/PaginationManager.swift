//
//  PaginationManager.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/25/24.
//

/// 서버에서 응답으로 보내주는 TotalCount를 기반으로 남은 페이지를 계산하여 데이터를 불러옵니다.
/// PaginationManager 내부에서 totalCount 변수를 사용하기 위해 loadPageData에서 totalCount를 반환합니다.
final class PaginationManager<T> {
    let size: Int
    private let threshold: Int
    
    /// 페이지 번호를 인자로 받아 해당 페이지의 데이터를 비동기적으로 로드하는 메서드. 데이터 배열과 전체 항목 수를 반환해야 합니다.
    var loadPageData: ((Int) async -> (data: [T], totalCount: Int))?

    private var currentPage: Int = 0
    private var totalPage: Int = 0
    private var totalCount: Int = 0
    private var isLoading = false
    
    init(size: Int, threshold: Int) {
        self.size = size
        self.threshold = threshold
    }
    
    deinit {
        print("🗑️ PaginationManager deinit")
        loadPageData = nil
    }
    
    /// 인덱스 없이 데이터를 로드할 수 있는지 확인하는 메서드
    func canLoadMoreData() -> Bool {
        let canLoadMorePages = currentPage < totalPage
        return canLoadMorePages
    }
    
    // TODO: 필터로 걸러진 값 있을 경우 고려하여 로직 수정 필요
    /// 인덱스로 데이터를 로드할 수 있는지 확인하는 메서드
    func canLoadMoreData(index: Int, currentCount: Int) -> Bool {
        if currentPage == totalPage {
            return false
        }
        let canLoadMorePages = currentPage < totalPage // 전체페이지와 비교하여 더 불러올 수 있는지 확인
        let shouldLoadMore = (index == currentCount - threshold) // 현재 페이지에 대한 임계값에 도달했는지 확인
        
        return canLoadMorePages && shouldLoadMore
    }
    
    /// loadPageData 반환값인 ([T], 서버에서 응답으로 보내주는 total)을 정확히 매핑하여 반환해야 합니다.
    func loadData(isRefreshing: Bool) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        if isRefreshing {
            resetPagination()
        } else {
            incrementPage()
        }
        guard let loadPageData else { return }
        let (_, totalCount) = await loadPageData(currentPage)
        updatePaginationState(totalCount: totalCount)
    }
    
    private func resetPagination() {
        currentPage = 0
        totalPage = 0
    }
    
    private func incrementPage() {
        currentPage += 1
    }
    
    private func updatePaginationState(totalCount: Int) {
        self.totalCount = totalCount
        
        if totalPage == 0 && size > 0 {
            totalPage = Int(totalCount / size)
        }
    }
}
