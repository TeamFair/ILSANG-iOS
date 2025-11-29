//
//  PaginationLoadable.swift
//  ILSANG
//
//  Created by Lee Jinhee on 11/5/25.
//

import Foundation

protocol PaginationLoadableBase {
    associatedtype Item: Identifiable
    var currentItems: [Item] { get }
    var canLoadMore: Bool { get }
    
    func loadInitialData() async
    func loadMoreDataIfNeeded(at index: Int) async
}

extension PaginationLoadableBase {
    var isCurrentListEmpty: Bool {
        currentItems.isEmpty
    }
}

protocol SinglePaginationLoadable: PaginationLoadableBase {
    var paginationManager: PaginationManager<Item> { get }
    func loadPageData(page: Int, size: Int) async -> Bool
}

extension SinglePaginationLoadable {
    var canLoadMore: Bool {
        paginationManager.canLoadMoreData()
    }
    
    func loadInitialData() async {
        await paginationManager.loadData(isRefreshing: true)
    }
    
    func loadMoreDataIfNeeded(at index: Int) async {
        if paginationManager.canLoadMoreData(index: index, currentCount: currentItems.count) {
            await paginationManager.loadData(isRefreshing: false)
        }
    }
}

protocol CategoryPaginationLoadable: PaginationLoadableBase {
    associatedtype Category: Hashable
    var currentCategory: Category { get }
    func paginationManager(for category: Category) -> PaginationManager<Item>
    func loadPageData(page: Int, size: Int, category: Category) async -> Bool
}

extension CategoryPaginationLoadable {
    var canLoadMore: Bool {
        paginationManager(for: currentCategory).canLoadMoreData()
    }
    
    func loadInitialData() async {
        await loadInitialData(for: currentCategory)
    }
    
    func loadInitialData(for category: Category) async {
        await paginationManager(for: category).loadData(isRefreshing: true)
    }
    
    func loadMoreDataIfNeeded(at index: Int) async {
        let manager = paginationManager(for: currentCategory)
        if manager.canLoadMoreData(index: index, currentCount: currentItems.count) {
            await manager.loadData(isRefreshing: false)
        }
    }
}
